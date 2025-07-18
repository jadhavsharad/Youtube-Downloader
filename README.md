# YouTube Downloader for macOS 🎬📥

> **The Ultimate Native App for Downloading YouTube Videos on Apple Silicon Macs**  
> Experience blazing-fast downloads with a beautiful macOS-native interface. No browser extensions required!

<div align="center">
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?logo=apple" alt="macOS Version">
  <img src="https://img.shields.io/badge/Platform-Apple%20Silicon-lightgrey?logo=apple" alt="Apple Silicon">
  <a href="https://github.com/jadhavsharad/Youtube-Downloader/releases">
    <img src="https://img.shields.io/github/downloads/jadhavsharad/Youtube-Downloader/total?color=success" alt="Downloads">
  </a>
</div>

## 🔍 Table of Contents
- [✨ Key Features](#-key-features)
- [🚀 Getting Started](#-getting-started)
- [📸 Screenshots](#-screenshots)
- [🛠️ Usage Guide](#%EF%B8%8F-usage-guide)
- [🧩 For Developers](#-for-developers)
- [🤝 Contribute](#-contribute)
- [📬 Support](#-support)

## ✨ Key Features
- **Batch downloading** - Process multiple videos at once
- **Quality selection** - From 144p to best quality available (Inlcuding HDR, High FPS)
- **Format options** - MP4, MKV, WebM, MP3, FLAC and more
- **Metadata embedding** - Preserve titles, descriptions and thumbnails
- **Subtitle support** - Download and embed subtitles
- **Smart organization** - Custom filename templates
- **Real-time monitoring** - Detailed progress tracking
- **Native macOS experience** - Fully optimized for Apple Silicon

## 🚀 Getting Started

### Requirements
- macOS Ventura (13.0) or newer
- Apple Silicon Mac (M1, M2, M3 or newer)
- [Homebrew](https://brew.sh/) package manager (Installation Required)

### Installation (1 Minute Setup)
1. **Install required tools**:
```bash
brew install yt-dlp ffmpeg
```

2. **Download the app**:
   - ➡️ [Get Latest Version](https://github.com/jadhavsharad/Youtube-Downloader/releases)
   - Open the DMG file
   - Drag the app to your Applications folder

3. **First run** (if needed):
```bash
xattr -d com.apple.quarantine /Applications/YouTube\ Downloader.app
```

4. **Launch and start downloading!** 🎉

## 📸 Screenshots

| Single Video Download | Batch Processing |
|----------------------|------------------|
| <img src="https://github.com/user-attachments/assets/8a9e1ed9-f8af-4bb8-ade7-bd450ce10be2" width="300"> | <img src="https://github.com/user-attachments/assets/25ba0404-46c3-42f8-8091-8865d9413992" width="300"> |

## 🛠️ Usage Guide

### Basic Workflow
1. Choose between **Single** or **Batch** mode
2. Paste YouTube URL(s)
3. Select download location
4. Choose format/quality
5. Customize options (subtitles, metadata, etc.)
6. Click **Start Downloading**

### Pro Tips
- Use `%(title)s.%(ext)s` for automatic naming
- Batch mode adds video IDs to filenames automatically
- Enable "Auto Open" to reveal downloads when complete
- Use speed limits to avoid bandwidth congestion

## 🧩 For Developers

### Build from Source
```bash
# Clone repository
git clone https://github.com/jadhavsharad/Youtube-Downloader.git

# Open in Xcode
open Youtube-Downloader.xcodeproj

# Build and run (⌘ + R)
```

### File Structure
```
Youtube-Downloader/
├── ContentView.swift        # Main UI
├── DownloadViewModel.swift  # Business logic
└── Assets.xcassets          # App resources
```

## 🤝 Contribute

We welcome contributions! Here's how to help:

1. **Report bugs** - [Open an issue](https://github.com/jadhavsharad/Youtube-Downloader/issues)
2. **Suggest features** - What would make this better?
3. **Fix issues** - Check our "Good First Issue" tickets
4. **Improve docs** - Help us make instructions clearer

### First-Time Setup
```bash
# Fork and clone
git clone https://github.com/jadhavsharad/Youtube-Downloader.git

# Install dependencies
brew install yt-dlp ffmpeg

# Create feature branch
git checkout -b my-amazing-feature

# Make changes and test
# Submit pull request with detailed description
```

## 📬 Support

Need help? Found a bug?
- [Open a GitHub Issue](https://github.com/jadhavsharad/Youtube-Downloader/issues)

⭐ **Star the repository** to show your support!

---

**Ready to download YouTube videos like a pro?**  
➡️ [Get the Latest Version Now](https://github.com/jadhavsharad/Youtube-Downloader/releases)
