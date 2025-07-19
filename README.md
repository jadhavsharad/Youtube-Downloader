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
  - [Prerequisites](#prerequisites)
  - [Homebrew Installation](#homebrew-installation)
  - [Tools Installation](#tools-installation)
  - [First Run on macOS](#first-run-on-macos)
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

### Prerequisites
- macOS Ventura (13.0) or newer
- Apple Silicon Mac (M1, M2, M3 or newer)
- Below Tools (Just copy paste the commands in macOS Terminal)

### Homebrew Installation
If you don't have Homebrew installed run this command in macOS Terminal:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Tools Installation

After homebrew installed run below command in macOS Terminal:

 - **Install required tools**:
```bash
brew install yt-dlp ffmpeg
```

 - **Download the app**:
   - ➡️ [Get Latest Version](https://github.com/jadhavsharad/Youtube-Downloader/releases)
   - Open the DMG file
   - Drag the app to your Applications folder

### First Run on macOS
macOS might block the app because it's from an unidentified developer. Here's how to fix it:

**Method 1: Using System Settings (Recommended)**
| Step | Screenshot |
|------|------------|
| **1.** Right-click the app and select "Open" | <img width="300" alt="Right-click menu" src="https://github.com/user-attachments/assets/db62ee5a-a730-473c-bfe5-aa18f483bab7" /> |
| **2.** You'll see this error message - click "Done" | <img width="300" alt="Error message" src="https://github.com/user-attachments/assets/71a02c3f-5531-4490-b964-cd46e9dbb1da" /> |
| **3.** Go to System Settings > Privacy & Security | <img width="300" alt="System Settings" src="https://github.com/user-attachments/assets/c9f4cbad-3bb1-4c7f-bc90-ed85c44ca673" /> |
| **4.** Scroll down to the "Security" section | *No screenshot needed* |
| **5.** You'll see: "YouTube Downloader was blocked..." | <img width="300" alt="Security warning" src="https://github.com/user-attachments/assets/19d53a26-fb8b-4e46-9b21-011d51cb0976" /> |
| **6.** Click "Open Anyway" | <img width="300" alt="Open Anyway button" src="https://github.com/user-attachments/assets/7058ef93-0951-4c86-970d-0d0f819cf699" /> |

**Method 2: Using Terminal (Advanced)**
If the above doesn't work, run this command in macOS Terminal:
```bash
xattr -d com.apple.quarantine /Applications/YouTube\ Downloader.app
```

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

We warmly welcome contributions from developers of all skill levels! Whether you’re a seasoned Swift pro or just exploring open source, your ideas, skills, and feedback can help shape the future of this app.

### There are many ways you can get involved:

- 🐞 Found a bug? – Open an issue
- 💡 Got a feature idea? – We’d love to hear it!
- 🔧 Want to fix something? – Check out our “Good First Issue” tags to get started
- 📚 Improve the docs – Clearer instructions help everyone

### ✨ A Few Areas You Could Explore:
- 🚀 Add playlist or batch download support
- 🌐 Extend support to other video platforms
- 📊 Enhance download progress, history, or analytics
- 🎨 Refine the UI/UX, animations, or theme
- 🛡️ Improve privacy or add security features

**But don’t stop there — if you have ideas or improvements that don’t fall into these categories, go for it! Every contribution matters, and we’re excited to collaborate with you.**

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
