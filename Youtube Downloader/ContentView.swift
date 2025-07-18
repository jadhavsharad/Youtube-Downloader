import SwiftUI
import AppKit

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = DownloadViewModel()
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 12) {
                // === Mode Selection ===
                Picker("Mode", selection: $viewModel.isBatchMode) {
                    Text("Single").tag(false)
                    Text("Batch").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 8)
                
                // === URL Input ===
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.isBatchMode ? "Batch URLs (one per line)" : "Video URL")
                        .font(.headline)
                    if viewModel.isBatchMode {
                        TextEditor(text: $viewModel.batchURLs)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 100, maxHeight: 150)
                            .padding(4)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(4)
                    } else {
                        TextField("https://example.com/video", text: $viewModel.singleURL)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(4)
                    }
                }
                
                // === Download Location ===
                VStack(alignment: .leading, spacing: 6) {
                    Text("Download Location")
                        .font(.headline)
                    HStack {
                        Text(viewModel.downloadDirectory?.path ?? "No folder selected")
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Choose") {
                            viewModel.selectDownloadDirectory()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Open") {
                            viewModel.openDownloadDirectory()
                        }
                        .disabled(viewModel.downloadDirectory == nil)
                    }
                    .padding(.horizontal, 8)
                }
                
                // === Format Selection ===
                VStack(alignment: .leading, spacing: 6) {
                    Text("Download Format")
                        .font(.headline)
                    Picker("", selection: $viewModel.selectedFormat) {
                        ForEach(DownloadFormat.allCases, id: \.self) { format in
                            Text(format.rawValue)
                                .tag(format)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()


                }
                
                // === Format-Specific Options ===
                if viewModel.selectedFormat != .best {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Format Options")
                            .font(.headline)
                        if viewModel.selectedFormat == .video {
                            HStack(spacing: 12) {
                                Text("Container:")
                                Picker("", selection: $viewModel.videoContainer) {
                                    ForEach(VideoContainer.allCases, id: \.self) {
                                        Text($0.rawValue.uppercased())
                                    }
                                }
                                .frame(width: 100)
                                
                                Text("Quality:")
                                Picker("", selection: $viewModel.videoQuality) {
                                    ForEach(VideoQuality.allCases, id: \.self) {
                                        Text($0.rawValue)
                                    }
                                }
                                .frame(width: 100)

                            }
                        } else if viewModel.selectedFormat == .audio {
                            HStack(spacing: 12) {
                                Text("Format:")
                                Picker("", selection: $viewModel.audioFormat) {
                                    ForEach(AudioFormat.allCases, id: \.self) {
                                        Text($0.rawValue.uppercased())
                                    }
                                }
                                .frame(width: 100)
                                
                                Text("Quality:")
                                Picker("", selection: $viewModel.audioQuality) {
                                    ForEach(AudioQuality.allCases, id: \.self) {
                                        Text($0.rawValue)
                                    }
                                }
                                .frame(width: 100)
                            }
                        }
                    }
                }
                
                // === Download Options ===
                VStack(alignment: .leading, spacing: 6) {
                    Text("Download Options")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Filename Template: \(viewModel.isBatchMode ? "When using custom file names video id will be added to each video." : "" )")
                                TextField("%(title)s.%(ext)s", text: $viewModel.filenameTemplate)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Subtitle Languages:")
                                TextField("all,en,es", text: $viewModel.subtitleLanguage)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Speed Limit:")
                                TextField("e.g., 1M", text: $viewModel.downloadSpeedLimit)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Throttle Rate:")
                                TextField("e.g., 100K", text: $viewModel.throttleRate)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        
                        HStack {
                            Toggle("Embed Subtitles", isOn: $viewModel.embedSubtitles)
                            Toggle("Embed Metadata", isOn: $viewModel.embedMetadata)
                            Toggle("Skip Existing", isOn: $viewModel.skipExistingFiles)
                            Toggle("Auto Open", isOn: $viewModel.autoOpenFolder)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                }
                
                // === Progress & Controls ===
                HStack {
                    Spacer()
                    if viewModel.isRunning {
                        Button(action: viewModel.cancelDownload) {
                            Label("Cancel Download", systemImage: "stop.fill")
                                .frame(minWidth: 150)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    } else {
                        Button(action: viewModel.startDownload) {
                            HStack(alignment: .center) {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Start Downloading")
                            }.padding(3)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        
                    }
                    
                    if viewModel.isRunning {
                        VStack(alignment: .leading) {
                            Text("Item \(viewModel.currentItemIndex)/\(viewModel.totalItems)")
                                .font(.caption)
                            ProgressView(value: viewModel.currentItemProgress)
                                .progressViewStyle(.linear)
                                .frame(height: 8)
                        }
                        
                        Text("\(Int(viewModel.currentItemProgress * 100))%")
                            .frame(width: 40)
                    }
                }
                .padding(.top, 5)
                
                // === Log Output ===
                VStack(alignment: .leading) {
                    Text("Download Log")
                        .font(.headline)
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(viewModel.logLines.indices, id: \.self) { index in
                                    Text(viewModel.logLines[index])
                                        .font(.system(.caption, design: .monospaced))
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .id(index)
                                }
                            }
                            .padding(4)
                        }
                        .frame(maxHeight: .infinity)
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(6)
                        .onChange(of: viewModel.logLines.count) { _ in
                            if let last = viewModel.logLines.indices.last {
                                withAnimation {
                                    proxy.scrollTo(last, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 8)
                Spacer()
            }
            .padding()
            .alert("Download Error", isPresented: $viewModel.showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
        .frame(minWidth: 600, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        .scrollIndicators(.never)
    }
}

#Preview {
    ContentView()
}
