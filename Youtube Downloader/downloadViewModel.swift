import Foundation
import SwiftUI
import AppKit

// MARK: - Enums for Download Options (Identifiable for ForEach)
enum VideoContainer: String, CaseIterable, Identifiable {
    case mp4, mkv, webm, flv, avi
    var id: Self { self }
}

enum VideoQuality: String, CaseIterable, Identifiable {
    case q144p = "144p", q240p = "240p", q360p = "360p", q480p = "480p"
    case q720p = "720p", q1080p = "1080p", q1440p = "1440p", q2160p = "2160p"
    var id: Self { self }
    var pixelValue: Int { Int(rawValue.dropLast()) ?? 0 }
}

enum AudioFormat: String, CaseIterable, Identifiable {
    case mp3, m4a, wav, flac, opus, vorbis
    var id: Self { self }
}

enum AudioQuality: String, CaseIterable, Identifiable {
    case k64 = "64k", k128 = "128k", k192 = "192k", k256 = "256k", k320 = "320k"
    var id: Self { self }
}

enum DownloadFormat: String, CaseIterable, Identifiable {
    case best = "Best Quality (auto)"
    case video = "Best Video"
    case audio = "Best Audio"
    var id: Self { self }
}

// MARK: - Download View Model
@MainActor
class DownloadViewModel: ObservableObject {
    
    // MARK: - User Input Properties
    @Published var singleURL = ""
    @Published var batchURLs = ""
    @Published var isBatchMode = false
    @Published var downloadDirectory: URL?
    
    // Format Selection
    @Published var selectedFormat: DownloadFormat = .best
    @Published var videoContainer: VideoContainer = .mp4
    @Published var videoQuality: VideoQuality = .q1080p
    @Published var audioFormat: AudioFormat = .mp3
    @Published var audioQuality: AudioQuality = .k128
    
    // Advanced Options
    @Published var embedSubtitles = false
    @Published var embedMetadata = false
    @Published var skipExistingFiles = false
    @Published var autoOpenFolder = false
    @Published var subtitleLanguage = "all"
    @Published var filenameTemplate = "%(title)s.%(ext)s"
    @Published var downloadSpeedLimit = ""
    @Published var throttleRate = ""
    
    // MARK: - State Properties
    @Published var logLines: [String] = []
    @Published var isRunning = false
    @Published var dependenciesReady = false
    
    // Progress
    @Published var currentItemProgress: Double = 0.0
    @Published var currentItemIndex = 0
    @Published var totalItems = 0
    
    // Error Handling
    @Published var showingErrorAlert = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var activeProcess: Process?
    private let maxLogLines = 1000
    private let progressRegex = try! NSRegularExpression(pattern: #"\[download\]\s+([0-9.]+)% of.*"#)

    private var ytDlpPath: String?
    private var ffmpegDirectoryPath: String?

    // MARK: - Initialization
    init() {
        locateDependencies()
    }
    
    // MARK: - Dependency Management
    
    private func locateDependencies() {
        guard let ytdlp = Bundle.main.path(forResource: "yt-dlp", ofType: nil) else {
            showError("FATAL: yt-dlp executable not found in the app bundle.")
            dependenciesReady = false
            return
        }
        self.ytDlpPath = ytdlp
        
        guard let ffmpeg = Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            showError("FATAL: ffmpeg executable not found in the app bundle.")
            dependenciesReady = false
            return
        }
        self.ffmpegDirectoryPath = (ffmpeg as NSString).deletingLastPathComponent
        
        addLog("Making bundled tools executable...")
        do {
            try makeExecutable(at: ytdlp)
            try makeExecutable(at: ffmpeg)
        } catch {
            showError("Failed to set executable permissions: \(error.localizedDescription)")
            dependenciesReady = false
            return
        }
        
        addLog("✅ Dependencies are ready.")
        dependenciesReady = true
    }
    
    private func makeExecutable(at path: String) throws {
        var permissions = try FileManager.default.attributesOfItem(atPath: path)
        var posixPermissions = permissions[.posixPermissions] as! UInt16
        posixPermissions |= 0o111
        permissions[.posixPermissions] = posixPermissions
        try FileManager.default.setAttributes(permissions, ofItemAtPath: path)
    }
    
    // MARK: - User Actions
    
    func selectDownloadDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK, let url = panel.url {
            self.downloadDirectory = url
            addLog("Download location set to: \(url.path)")
        }
    }
    
    func openDownloadDirectory() {
        guard let dir = downloadDirectory else { return }
        NSWorkspace.shared.open(dir)
    }
    
    func startDownload() {
        guard dependenciesReady else {
            showError("Cannot start download: dependencies are not ready.")
            return
        }
        guard let outputDir = downloadDirectory else {
            showError("Please choose a download folder first.")
            return
        }
        
        let urls = isBatchMode ? batchURLs.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } : [singleURL]
        
        guard !urls.isEmpty, !urls[0].trimmingCharacters(in: .whitespaces).isEmpty else {
            showError(isBatchMode ? "No URLs found in batch input." : "Please enter a video URL.")
            return
        }
        
        isRunning = true
        currentItemProgress = 0.0
        currentItemIndex = 0
        totalItems = urls.count
        logLines = ["🚀 Starting download of \(totalItems) item(s)..."]
        
        Task {
            for (index, url) in urls.enumerated() {
                if !isRunning { break }
                currentItemIndex = index + 1
                currentItemProgress = 0.0
                addLog("\n⬇️ Downloading item \(currentItemIndex)/\(totalItems): \(url)")
                await runYtDlp(for: url, in: outputDir)
            }
            
            if isRunning {
                addLog("\n✅ Download queue finished.")
                if autoOpenFolder {
                    openDownloadDirectory()
                }
            }
            isRunning = false
        }
    }
    
    func cancelDownload() {
        guard isRunning else { return }
        addLog("\n🛑 User cancelled download. Halting process...")
        isRunning = false
        activeProcess?.terminate()
        activeProcess = nil
        resetProgress()
    }
    
    // MARK: - Core Download Logic
    
    private func buildArguments(for url: String, in directory: URL) -> [String]? {
        guard let ffmpegDir = ffmpegDirectoryPath else {
            showError("Cannot build arguments: ffmpeg path is missing.")
            return nil
        }
        
        let template = filenameTemplate.trimmingCharacters(in: .whitespaces).isEmpty ? "%(title)s.%(ext)s" : filenameTemplate
        let outputPath = isBatchMode ? "\(directory.path)/%(playlist_index)s-%(id)s-\(template)" : "\(directory.path)/\(template)"
        
        var args = [
            url,
            "--newline",
            "--no-warnings",
            "--progress",
            "--ffmpeg-location", ffmpegDir,
            "-o", outputPath
        ]
        
        switch selectedFormat {
        case .best:
            args += ["-f", "bv*+ba/b"]
        case .video:
            args += ["-f", "bestvideo[height<=\(videoQuality.pixelValue)]+bestaudio/best", "--merge-output-format", videoContainer.rawValue]
        case .audio:
            args += ["-f", "bestaudio/best", "--extract-audio", "--audio-format", audioFormat.rawValue, "--audio-quality", audioQuality.rawValue]
        }
        
        if embedSubtitles {
            args += ["--write-sub", "--embed-subs", "--sub-langs", subtitleLanguage.isEmpty ? "all" : subtitleLanguage]
        }
        if embedMetadata {
            args += ["--embed-metadata", "--embed-thumbnail"]
        }
        if skipExistingFiles {
            args += ["--no-overwrites"]
        }
        if !downloadSpeedLimit.isEmpty {
            args += ["-r", downloadSpeedLimit]
        }
        if !throttleRate.isEmpty {
            args += ["--throttled-rate", throttleRate]
        }
        
        return args
    }
    
    /// **FIXED:** This function now uses `withCheckedContinuation` to wrap the callback-based `Process`
    /// API into a modern `async/await` function. This prevents blocking the main thread.
    private func runYtDlp(for url: String, in directory: URL) async {
        guard isRunning else { return }

        guard let ytdlpPath = self.ytDlpPath, let arguments = buildArguments(for: url, in: directory) else {
            showError("Failed to start yt-dlp: paths or arguments are invalid.")
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let process = Process()
            self.activeProcess = process
            
            process.executableURL = URL(fileURLWithPath: ytdlpPath)
            process.arguments = arguments

            let outputPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = outputPipe

            let outputHandle = outputPipe.fileHandleForReading
            outputHandle.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: .utf8), !line.isEmpty {
                    DispatchQueue.main.async {
                        self.processOutputLine(line)
                    }
                }
            }

            process.terminationHandler = { finishedProcess in
                DispatchQueue.main.async {
                    if finishedProcess.terminationStatus != 0 && self.isRunning {
                        self.showError("Download failed with exit code \(finishedProcess.terminationStatus). Check log for details.")
                    }
                    self.activeProcess = nil
                    outputHandle.readabilityHandler = nil
                    continuation.resume()
                }
            }

            do {
                try process.run()
            } catch {
                DispatchQueue.main.async {
                    self.showError("Failed to execute yt-dlp process: \(error.localizedDescription)")
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Output Processing & Helpers
    
    private func processOutputLine(_ output: String) {
        output.enumerateLines { line, _ in
            self.addLog(line)
            
            if let match = self.progressRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let range = Range(match.range(at: 1), in: line),
               let progressValue = Double(line[range]) {
                self.currentItemProgress = progressValue / 100.0
            }
        }
    }
    
    private func addLog(_ message: String) {
        logLines.append(message)
        if logLines.count > maxLogLines {
            logLines.removeFirst(logLines.count - maxLogLines)
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
        isRunning = false
        addLog("❌ ERROR: \(message)")
    }
    
    private func resetProgress() {
        currentItemProgress = 0.0
        currentItemIndex = 0
        totalItems = 0
    }
}
