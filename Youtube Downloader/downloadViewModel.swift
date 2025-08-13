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
    @Published var isSettingUp = false // NEW: Tracks initial setup
    @Published var setupStatusMessage = "" // NEW: Message for the UI during setup

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

    // Paths will now point to the Application Support directory
    private var ytDlpPath: String?
    private var ffmpegPath: String?

    // MARK: - Initialization
    init() {
        // Start the dependency check asynchronously
        Task {
            await locateOrDownloadDependencies()
        }
    }
    
    // MARK: - Dependency Management
    
    /// Gets or creates a dedicated directory for our app in ~/Library/Application Support
    private func getAppSupportDirectory() throws -> URL {
        guard let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            throw NSError(domain: "AppError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not determine application name."])
        }
        
        let appSupportURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fullPath = appSupportURL.appendingPathComponent(appName)
        
        if !FileManager.default.fileExists(atPath: fullPath.path) {
            try FileManager.default.createDirectory(at: fullPath, withIntermediateDirectories: true, attributes: nil)
        }
        return fullPath
    }
    
    /// Checks for dependencies, and if they don't exist, downloads and sets them up.
    private func locateOrDownloadDependencies() async {
        do {
            let dir = try getAppSupportDirectory()
            let expectedYtDlpPath = dir.appendingPathComponent("yt-dlp").path
            let expectedFfmpegPath = dir.appendingPathComponent("ffmpeg").path
            
            let ytDlpExists = FileManager.default.fileExists(atPath: expectedYtDlpPath)
            let ffmpegExists = FileManager.default.fileExists(atPath: expectedFfmpegPath)

            if ytDlpExists && ffmpegExists {
                addLog("✅ Dependencies found locally.")
                self.ytDlpPath = expectedYtDlpPath
                self.ffmpegPath = expectedFfmpegPath
                self.dependenciesReady = true
                return
            }
            
            // --- Download & Setup Logic ---
            isSettingUp = true
            addLog("Initial setup: preparing required tools...")
            
            // 1. Download yt-dlp
            if !ytDlpExists {
                setupStatusMessage = "Downloading yt-dlp..."
                addLog(setupStatusMessage)
                let ytdlpURL = URL(string: "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos")!
                try await downloadFile(from: ytdlpURL, to: URL(fileURLWithPath: expectedYtDlpPath))
                try makeExecutable(at: expectedYtDlpPath)
                addLog("yt-dlp downloaded successfully.")
            }
            
            // 2. Download ffmpeg
            if !ffmpegExists {
                setupStatusMessage = "Downloading ffmpeg..."
                addLog(setupStatusMessage)
                
                // Select the correct ffmpeg build for the user's architecture
                #if arch(arm64)
                let ffmpegZipURL = URL(string: "https://evermeet.cx/ffmpeg/getrelease/zip")!
                addLog("Apple Silicon (arm64) architecture.")
                #else
                let ffmpegZipURL = URL(string: "https://evermeet.cx/ffmpeg/getrelease/zip")!
                addLog("Detected Intel (x86_64) architecture.")
                #endif
                
                let zipPath = dir.appendingPathComponent("ffmpeg")
                try await downloadFile(from: ffmpegZipURL, to: zipPath)
                
                setupStatusMessage = "Unpacking ffmpeg..."
                addLog(setupStatusMessage)
                try unzip(file: zipPath, to: dir)
                
                // The unzipped file is named 'ffmpeg', so it will be at the expected path.
                try makeExecutable(at: expectedFfmpegPath)
//                try FileManager.default.removeItem(at: zipPath) // Clean up the zip file
                addLog("ffmpeg setup successfully.")
            }
            
            self.ytDlpPath = expectedYtDlpPath
            self.ffmpegPath = expectedFfmpegPath
            self.dependenciesReady = true
            addLog("✅ Dependencies are ready.")
            
        } catch {
            showError("Failed during initial setup: \(error.localizedDescription). Please check your internet connection and restart the app.")
            self.dependenciesReady = false
        }
        
        isSettingUp = false
        setupStatusMessage = ""
    }

    /// Downloads a file from a URL to a local path.
    private func downloadFile(from url: URL, to destinationURL: URL) async throws {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "DownloadError", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Failed to download file from \(url)."])
        }
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
    }

    /// Unzips a file using the system's unzip command.
    private func unzip(file source: URL, to destination: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        // -o: overwrite files without prompting
        // -d: destination directory
        process.arguments = ["-o", source.path, "-d", destination.path]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "UnzipError", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Failed to unzip file at \(source.path)."])
        }
    }

    /// Sets executable permissions on a file.
    private func makeExecutable(at path: String) throws {
        var permissions = try FileManager.default.attributesOfItem(atPath: path)
        permissions[.posixPermissions] = 0o755 // rwxr-xr-x
        try FileManager.default.setAttributes(permissions, ofItemAtPath: path)
        addLog("Made file executable at \(path)")
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
        // yt-dlp needs the DIRECTORY where ffmpeg is, not the file itself.
        guard let ffmpegBinaryPath = self.ffmpegPath else {
            showError("Cannot build arguments: ffmpeg path is missing.")
            return nil
        }
        let ffmpegDir = (ffmpegBinaryPath as NSString).deletingLastPathComponent
        
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
