import SwiftUI
import AppKit

// Extension to remove the focus ring from text fields for a cleaner look.
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = DownloadViewModel()
    
    var body: some View {
        // Use a GeometryReader to adapt to different window sizes.
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // MARK: - Dependency Status Banner
                // A clear banner that shows if the required tools are missing.
                if !viewModel.dependenciesReady {
                    HStack {
                        Image(systemName: "xmark.octagon.fill")
                            .foregroundColor(.red)
                        Text("Required tools (yt-dlp, ffmpeg) not found. Please restart the app or re-install.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                // Main content view that scrolls
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // MARK: - Mode Selection
                        Picker("Mode", selection: $viewModel.isBatchMode) {
                            Text("Single URL").tag(false)
                            Text("Batch URLs").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // MARK: - URL Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.isBatchMode ? "Batch URLs (one per line)" : "Video URL")
                                .font(.headline)
                            if viewModel.isBatchMode {
                                TextEditor(text: $viewModel.batchURLs)
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
                                TextField("https://www.youtube.com/watch?v=...", text: $viewModel.singleURL)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(8)
                                    .background(Color(.textBackgroundColor))
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // MARK: - Download Location
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Download Location").font(.headline)
                            HStack {
                                // Use a placeholder if no directory is selected
                                Text(viewModel.downloadDirectory?.path ?? "No folder selected")
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(viewModel.downloadDirectory == nil ? .secondary : .primary)
                                
                                Spacer()
                                
                                Button("Choose…", action: viewModel.selectDownloadDirectory)
                                Button("Open") { viewModel.openDownloadDirectory() }
                                    .disabled(viewModel.downloadDirectory == nil)
                            }
                        }
                        
                        // MARK: - Format Selection & Options
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Download Format").font(.headline)
                                Picker("", selection: $viewModel.selectedFormat) {
                                    ForEach(DownloadFormat.allCases) { Text($0.rawValue).tag($0) }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                            
                            Spacer()
                            
                            // Options appear dynamically based on the selected format
                            if viewModel.selectedFormat != .best {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Format Options").font(.headline)
                                    if viewModel.selectedFormat == .video {
                                        HStack {
                                            Picker("Container", selection: $viewModel.videoContainer) {
                                                ForEach(VideoContainer.allCases) { Text($0.rawValue.uppercased()).tag($0) }
                                            }
                                            Picker("Quality", selection: $viewModel.videoQuality) {
                                                ForEach(VideoQuality.allCases) { Text($0.rawValue).tag($0) }
                                            }
                                        }
                                    } else if viewModel.selectedFormat == .audio {
                                        HStack {
                                            Picker("Format", selection: $viewModel.audioFormat) {
                                                ForEach(AudioFormat.allCases) { Text($0.rawValue.uppercased()).tag($0) }
                                            }
                                            Picker("Quality", selection: $viewModel.audioQuality) {
                                                ForEach(AudioQuality.allCases) { Text($0.rawValue).tag($0) }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Download Options
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Advanced Options").font(.headline)
                            VStack(alignment: .leading, spacing: 12) {
                                LabeledTextField(label: "Filename Template", placeholder: "%(title)s.%(ext)s", text: $viewModel.filenameTemplate)
                                LabeledTextField(label: "Subtitle Languages (e.g. en,es)", placeholder: "all", text: $viewModel.subtitleLanguage)
                                HStack(spacing: 16) {
                                    LabeledTextField(label: "Speed Limit (e.g. 1M)", placeholder: "Unlimited", text: $viewModel.downloadSpeedLimit)
                                    LabeledTextField(label: "Throttle Rate (e.g. 100K)", placeholder: "None", text: $viewModel.throttleRate)
                                }
                                
                                HStack(spacing: 20) {
                                    Toggle("Embed Subtitles", isOn: $viewModel.embedSubtitles)
                                    Toggle("Embed Metadata", isOn: $viewModel.embedMetadata)
                                    Toggle("Skip Existing", isOn: $viewModel.skipExistingFiles)
                                    Toggle("Auto Open Folder", isOn: $viewModel.autoOpenFolder)
                                }
                                .toggleStyle(.checkbox)
                            }
                        }
                        
                        Divider().padding(.vertical, 8)
                        
                        // MARK: - Progress & Controls
                        HStack {
                            if viewModel.isRunning {
                                Button(action: viewModel.cancelDownload) {
                                    Label("Cancel", systemImage: "stop.circle.fill")
                                        .frame(minWidth: 120)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                                
                                VStack(alignment: .leading) {
                                    Text("Downloading item \(viewModel.currentItemIndex) of \(viewModel.totalItems)")
                                        .font(.caption)
                                    ProgressView(value: viewModel.currentItemProgress)
                                        .progressViewStyle(.linear)
                                }
                                
                                Text("\(Int(viewModel.currentItemProgress * 100))%")
                                    .font(.system(.body, design: .monospaced).bold())
                                    .frame(width: 45)
                                
                            } else {
                                Spacer()
                                Button(action: viewModel.startDownload) {
                                    Label("Start Downloading", systemImage: "arrow.down.circle.fill")
                                        .frame(minWidth: 150)
                                }
                                .buttonStyle(.borderedProminent)
                                // Disable button if dependencies are not ready or a download is running
                                .disabled(!viewModel.dependenciesReady || viewModel.isRunning)
                                Spacer()
                            }
                        }
                        
                    }
                    .padding()
                }
                
                // MARK: - Log Output
                VStack(alignment: .leading) {
                    Text("Log Output")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.vertical) {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(viewModel.logLines.indices, id: \.self) { index in
                                    Text(viewModel.logLines[index])
                                        .font(.system(size: 10, design: .monospaced))
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .id(index)
                                }
                            }
                            .padding(8)
                        }
                        .background(Color(.textBackgroundColor))
                        .frame(height: max(100, geometry.size.height * 0.25))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .padding([.horizontal, .bottom])
                        .onChange(of: viewModel.logLines.count) { _ in
                            // Auto-scroll to the bottom of the log
                            if let last = viewModel.logLines.indices.last {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(last, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 650, minHeight: 700)
        .alert("Download Error", isPresented: $viewModel.showingErrorAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        })
    }
}

// A helper view for cleaner layout of text fields with labels
struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    ContentView()
}
