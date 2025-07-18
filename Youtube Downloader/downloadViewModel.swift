import Foundation
import SwiftUI
import AppKit

// MARK: - Enums for Download Options

/// Supported video container formats
enum VideoContainer: String, CaseIterable {
    case mp4, mkv, webm, flv, avi
}

/// Supported video quality levels
enum VideoQuality: String, CaseIterable {
    case q144p = "144p"
    case q240p = "240p"
    case q360p = "360p"
    case q480p = "480p"
    case q720p = "720p"
    case q1080p = "1080p"
    case q1440p = "1440p"
    case q2160p = "2160p"
    
    /// Numeric value of quality level (height in pixels)
    var pixelValue: Int {
        return Int(rawValue.dropLast()) ?? 0
    }
}

/// Supported audio formats
enum AudioFormat: String, CaseIterable {
    case mp3, m4a, wav, flac, opus, vorbis
}

/// Supported audio quality levels
enum AudioQuality: String, CaseIterable {
    case k64 = "64k", k128 = "128k", k192 = "192k", k256 = "256k", k320 = "320k"
}

/// Download format options
enum DownloadFormat: String, CaseIterable {
    case best = "Best Quality (auto)"
    case video = "Best Video"
    case audio = "Best Audio"
}

// MARK: - Download View Model

@MainActor
class DownloadViewModel: ObservableObject {
    
    // MARK: - User Input Properties
    @Published var singleURL = ""
    @Published var batchURLs = ""
    @Published var isBatchMode = false
    @Published var embedSubtitles = false
    @Published var embedMetadata = false
    @Published var downloadDirectory: URL?
    @Published var subtitleLanguage = "all"
    @Published var filenameTemplate = "%(title)s.%(ext)s"
    @Published var autoOpenFolder = false
    @Published var selectedFormat: DownloadFormat = .best
    @Published var videoContainer: VideoContainer = .mp4
    @Published var videoQuality: VideoQuality = .q1080p
    @Published var audioFormat: AudioFormat = .mp3
    @Published var audioQuality: AudioQuality = .k128
    @Published var downloadSpeedLimit = ""
    @Published var skipExistingFiles = false
    @Published var throttleRate = ""
    
    // MARK: - Download State Properties
    @Published var currentItemProgress: Double = 0.0
    @Published var logLines: [String] = []
    @Published var isRunning = false
    @Published var showingErrorAlert = false
    @Published var errorMessage: String?
    @Published var currentItemIndex = 0
    @Published var totalItems = 0
    
    // MARK: - Private Properties
    private var activeProcess: Process?
    private let maxLogLines = 500
    
    // MARK: - Constants
    private let ytDlpPath = "/opt/homebrew/bin/yt-dlp"
    private let ffmpegPath = "/opt/homebrew/bin"
    private let progressPattern = #"(\d{1,3}(?:\.\d+)?)%"# // Regex for progress percentage
    
    // MARK: - Directory Selection
    
    /// Opens directory selection dialog
    func selectDownloadDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            self.downloadDirectory = panel.url
        }
    }
    
    // MARK: - Download Management
    
    /// Starts download process
    func startDownload() {
        guard let outputDir = downloadDirectory else {
            showError("Please select a download folder.")
            return
        }
        
        let urls = isBatchMode ?
        batchURLs.split(separator: "\n").map(String.init) :
        [singleURL]
        
        guard !urls.isEmpty else {
            showError(isBatchMode ?
                      "No URLs found in batch input" :
                        "Please enter a valid URL")
            return
        }
        
        Task {
            isRunning = true
            currentItemProgress = 0.0
            currentItemIndex = 0
            totalItems = urls.count
            logLines = ["Starting download..."]
            
            // Process each URL sequentially
            for (index, url) in urls.enumerated() {
                currentItemIndex = index + 1
                currentItemProgress = 0.0
                
                addLog("\nDownloading item \(currentItemIndex)/\(totalItems)")
                addLog("URL: \(url)")
                
                await runYtDlp(for: url, in: outputDir)
                
                // Check if download was canceled
                if !isRunning { break }
            }
            
            isRunning = false
            addLog("\nDownload completed")
            
            if autoOpenFolder {
                openDownloadDirectory()
            }
        }
    }
    
    /// Opens download directory in Finder
    func openDownloadDirectory() {
        guard let dir = downloadDirectory else { return }
        NSWorkspace.shared.open(dir)
    }
    
    // MARK: - Core Download Logic
    
    /// Executes yt-dlp command with configured parameters
    private func runYtDlp(for url: String, in directory: URL) async {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        // Store reference to active process
        activeProcess = process
        
        // Use default template if filenameTemplate is empty
        let actualTemplate = filenameTemplate.isEmpty ? "%(title)s.%(ext)s" : filenameTemplate
            
        
        // Configure base arguments
        var args = [
            "--newline",
            "--no-warnings",
            "-o", "\(directory.path)/\( isBatchMode ? "%(id)s_" + actualTemplate : actualTemplate)",
            "--ffmpeg-location", ffmpegPath
        ]
        
        // Add format-specific arguments
        switch selectedFormat {
        case .video:
            args.append(contentsOf: [
                "-f", "bestvideo[height<=\(videoQuality.pixelValue)]+bestaudio",
                "--merge-output-format", videoContainer.rawValue
            ])
        case .audio:
            args.append(contentsOf: [
                "-f", "bestaudio",
                "--extract-audio",
                "--audio-format", audioFormat.rawValue,
                "--audio-quality", audioQuality.rawValue
            ])
        case .best:
            args.append(contentsOf: ["-f", "bv*+ba/best"])
        }
        
        // Add optional parameters
        if !downloadSpeedLimit.isEmpty {
            args.append(contentsOf: ["-r", downloadSpeedLimit])
        }
        
        if skipExistingFiles {
            args.append("--skip-downloads")
        }
        
        if !throttleRate.isEmpty {
            args.append(contentsOf: ["--throttled-rate", throttleRate])
        }
        
        if embedSubtitles {
            args.append(contentsOf: [
                "--write-sub",
                "--embed-subs",
                "--sub-langs", subtitleLanguage
            ])
        }
        
        if embedMetadata {
            args.append(contentsOf: ["--embed-metadata", "--embed-thumbnail"])
        }
        
        args.append(url)
        
        // Configure process
        process.executableURL = URL(fileURLWithPath: ytDlpPath)
        process.arguments = args
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            
            // Process output in real-time
            for try await line in outputPipe.fileHandleForReading.bytes.lines {
                // Add cancellation check
                if !isRunning {
                    addLog("Canceling download...")
                    process.terminate()
                    return
                }
                await processOutputLine(line)
            }
            process.waitUntilExit()
            
            // Check for errors
            if process.terminationStatus != 0 && isRunning {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                showError("Download failed: \(errorMessage)")
            }
        } catch {
            // Handle cancellation as non-error
            if !isRunning { return }
            showError("Process execution failed: \(error.localizedDescription)")        }
        
        // Clear active process reference
        activeProcess = nil
    }
    
    // MARK: - Output Processing
    
    /// Processes a line of output from yt-dlp
    private func processOutputLine(_ line: String) async {
        // Add to log
        addLog(line)
        
        // Update progress if available
        if let progressValue = parsePercentage(from: line) {
            currentItemProgress = progressValue / 100
        }
    }
    
    /// Extracts progress percentage from output line
    private func parsePercentage(from line: String) -> Double? {
        guard let regex = try? NSRegularExpression(pattern: progressPattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line)
        else { return nil }
        
        return Double(line[range])
    }
    
    // MARK: - Log Management
    
    /// Adds a line to the log with memory management
    private func addLog(_ message: String) {
        // Add new message
        logLines.append(message)
        
        // Trim log if exceeds max capacity
        if logLines.count > maxLogLines {
            logLines.removeFirst(logLines.count - maxLogLines)
        }
    }
    
    // MARK: - Error Handling
    
    /// Displays error message
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
        isRunning = false
        activeProcess = nil
        addLog("ERROR: \(message)")
    }
    
    // MARK: - Cancel Functions
    
    func resetProgress() {
        currentItemProgress = 0.0
        currentItemIndex = 0
        totalItems = 0
    }
    
    // Update cancelDownload method
    func cancelDownload() {
        activeProcess?.terminate()
        isRunning = false
        resetProgress()
        addLog("Download canceled by user")
    }
    
}

