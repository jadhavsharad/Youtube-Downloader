import SwiftUI

// This struct is a great candidate for a reusable sub-view.
// It handles the title and subtitle of the app.
struct AppHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Youtube Downloader")
                Image(systemName: "video.fill")
                    .foregroundStyle(Color.accentColor)
            }
            .font(.title2)
            
            Text("A simple, minimal and high quality youtube downloader.")
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom)
    }
}

// This component encapsulates the UI for selecting single vs. batch mode.
struct ModeSelectionView: View {
    @Binding var isBatchMode: Bool
    
    var body: some View {
        HStack {
            Text("Choose Mode")
                .font(.title)
                .bold()
            
            Spacer()
            
            BoolSegmentedPicker(
                selection: $isBatchMode,
                labels: [
                    false: "Single URL",
                    true: "Batch URLs"
                ]
            ) { label in
                Text(label)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// This component handles the input field for URLs, which changes based on the mode.
struct URLInputView: View {
    @Binding var isBatchMode: Bool
    @Binding var singleURL: String
    @Binding var batchURLs: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isBatchMode ? "Enter Youtube URLs (one per line)" : "Enter Youtube URL")
                    .font(.headline)
                Image(systemName: "link")
                    .font(.headline)
                Spacer()
                Text(isBatchMode ? "Batch URL Mode" : "Single URL Mode")
                    .foregroundStyle(.tertiary)
                    .font(.subheadline)
            }
            
            if isBatchMode {
                TextEditor(text: $batchURLs)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 100, idealHeight: 150, maxHeight: 200)
                    .padding(4)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                CustomInputField(placeholder: "https://youtube.com/watch?v=qwertyuiop", text: $singleURL)
            }
        }
    }
}

// This component handles the UI for selecting and opening the download directory.
struct DownloadLocationView: View {
    @ObservedObject var viewModel: DownloadViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Download Location")
                    .font(.headline)
                Image(systemName: "folder")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) { // Use spacing for cleaner layout
                Text(viewModel.downloadDirectory?.path ?? "No folder selected.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .padding(10)
                    .background(Color(.quaternaryLabelColor))
                    .cornerRadius(6)
                    .foregroundStyle(.tertiary)
                
                Button(action: viewModel.selectDownloadDirectory) {
                    HStack {
                        Image(systemName: "folder.fill.badge.plus")
                        Text("Choose")
                    }
                    .padding(10)
                    .background(Color(.quaternaryLabelColor))
                    .cornerRadius(6)
                    .foregroundStyle(Color.secondary)
                }
                .buttonStyle(.plain)
                
                Button(action: viewModel.openDownloadDirectory) {
                    HStack {
                        Image(systemName: "eyes")
                        Text("Open")
                    }
                    .padding(10)
                    .background(Color(.quaternaryLabelColor))
                    .cornerRadius(6)
                    .foregroundStyle(Color.secondary)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.downloadDirectory == nil)
            }
        }
        .padding(.vertical, 4)
    }
}

// Main content view, now using the reusable components.
struct ContentView: View {
    @StateObject private var viewModel = DownloadViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header of the app
                AppHeaderView()
                
                // Mode selection for single vs. batch URL
                ModeSelectionView(isBatchMode: $viewModel.isBatchMode)
                
                Divider()
                
                // Input field for the URL(s)
                URLInputView(
                    isBatchMode: $viewModel.isBatchMode,
                    singleURL: $viewModel.singleURL,
                    batchURLs: $viewModel.batchURLs
                )
                
                // Download location selection
                DownloadLocationView(viewModel: viewModel)
                
                Divider()

                // Download options section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Download Options")
                            .font(.headline)
                        Image(systemName: "ellipsis.circle")
                            .font(.headline)
                    }
                    .padding(.bottom, 4)
                    
                    // Format picker
                    HStack {
                        Picker("", selection: $viewModel.selectedFormat) {
                            ForEach(DownloadFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        Spacer()
                    }
                    
                    // Conditional format options
                    if viewModel.selectedFormat != .best {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Format Options")
                                .font(.headline)
                                .padding(.bottom, 4)
                            if viewModel.selectedFormat == .video {
                                HStack(spacing: 16) {
                                    Picker("Container", selection: $viewModel.videoContainer) {
                                        ForEach(VideoContainer.allCases) { Text($0.rawValue.uppercased()).tag($0) }
                                    }
                                    Picker("Quality", selection: $viewModel.videoQuality) {
                                        ForEach(VideoQuality.allCases) { Text($0.rawValue).tag($0) }
                                    }
                                }
                            } else if viewModel.selectedFormat == .audio {
                                HStack(spacing: 16) {
                                    Picker("Format", selection: $viewModel.audioFormat) {
                                        ForEach(AudioFormat.allCases) { Text($0.rawValue.uppercased()).tag($0) }
                                    }
                                    Picker("Quality", selection: $viewModel.audioQuality) {
                                        ForEach(AudioQuality.allCases) { Text($0.rawValue).tag($0) }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Divider()

                // Advanced options section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Advance Options")
                            .font(.headline)
                        Image(systemName: "oar.2.crossed")
                            .font(.headline)
                        Spacer()
                        Text("Use only if you know what you are doing!")
                            .foregroundStyle(.tertiary)
                            .font(.subheadline)
                    }
                    .padding(.bottom, 4)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Filename Template")
                                .foregroundStyle(.secondary)
                            CustomInputField(placeholder: "%(title)s.%(ext)s", text: $viewModel.filenameTemplate)
                        }
                        VStack(alignment: .leading) {
                            Text("Subtitle Languages (e.g. en,es)")
                                .foregroundStyle(.secondary)
                            CustomInputField(placeholder: "%(title)s.%(ext)s", text: $viewModel.subtitleLanguage)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Speed Limit (e.g. 1M)")
                                .foregroundStyle(.secondary)
                            CustomInputField(placeholder: "Unlimited", text: $viewModel.downloadSpeedLimit)
                        }
                        VStack(alignment: .leading) {
                            Text("Throttle Rate (e.g. 100K)")
                                .foregroundStyle(.secondary)
                            CustomInputField(placeholder: "None", text: $viewModel.throttleRate)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // More options (Toggles)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("More Options")
                            .font(.headline)
                        Image(systemName: "gear")
                            .font(.headline)
                    }
                    .padding(.bottom, 4)
                    
                    HStack(spacing:12) {
                        Toggle("Embed Subtitles", isOn: $viewModel.embedSubtitles)
                        Spacer()
                        Toggle("Embed Metadata", isOn: $viewModel.embedMetadata)
                        Spacer()
                        Toggle("Skip Existing", isOn: $viewModel.skipExistingFiles)
                        Spacer()
                        Toggle("Auto Open Folder", isOn: $viewModel.autoOpenFolder)
                    }
                    .toggleStyle(CustomCheckboxStyle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()

                // Download progress and control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Download progress")
                            .font(.headline)
                        Image(systemName: "icloud.and.arrow.down.fill")
                            .font(.headline)
                    }
                    
                    if viewModel.isRunning {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("Downloading item \(viewModel.currentItemIndex) of \(viewModel.totalItems)")
                                .font(.caption)
                            ProgressView(value: viewModel.currentItemProgress)
                                .progressViewStyle(.linear)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        HStack(alignment: .center) {
                            Text("\(Int(viewModel.currentItemProgress * 100))%")
                                .font(.system(.body, design: .monospaced).bold())
                            Spacer()
                            Button(action: viewModel.cancelDownload) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text("Cancel")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.quaternaryLabelColor))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        Button(action: viewModel.startDownload) {
                            Label("Start Downloading", systemImage: "arrow.down.to.line")
                                .padding(8)
                                .frame(minWidth: 150, maxWidth: .infinity)
                                .background(Color.accentColor)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!viewModel.dependenciesReady || viewModel.isRunning)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the button
                    }
                }
                
                Divider()

                // Log output section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Logs")
                            .font(.headline)
                        Image(systemName: "info.circle")
                            .font(.headline)
                    }
                    .padding(.bottom, 4)
                    
                    LogOutputView(logLines: $viewModel.logLines)
                        .frame(idealHeight: 200, maxHeight: .infinity)
                        .scrollIndicators(.hidden)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden) // Hides the main scroll bar
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
