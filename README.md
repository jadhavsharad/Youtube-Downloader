# **YouTube Downloader for macOS 🎬**

A powerful, native, and open-source YouTube downloader built exclusively for Apple Silicon Macs. Experience seamless, fast, and high-quality video downloads with a clean, intuitive interface.

<div align="center">  
<!-- Badges -->  
<a href="https://github.com/jadhavsharad/Youtube-Downloader/releases"/><img src="https://img.shields.io/github/v/release/jadhavsharad/Youtube-Downloader?style=for-the-badge\&logo=github" alt="Latest Release"/></a>  
<a href="https://github.com/jadhavsharad/Youtube-Downloader/releases"><img src="https://img.shields.io/github/downloads/jadhavsharad/Youtube-Downloader/total?style=for-the-badge\&logo=icloud\&color=success" alt="Total Downloads"></a>
<img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge\&logo=apple" alt="macOS Version"\>  
<img src="https://img.shields.io/badge/Apple\_Silicon-Optimized-lightgrey?style=for-the-badge\&logo=apple" alt="Apple Silicon"\>  
<a href="https://github.com/jadhavsharad/Youtube-Downloader/issues"\><img src="https://img.shields.io/github/issues/jadhavsharad/Youtube-Downloader?style=for-the-badge\&logo=github" alt="Open Issues"></a>
<a href="https://github.com/jadhavsharad/Youtube-Downloader/pulls"\><img src="https://img.shields.io/github/issues-pr/jadhavsharad/Youtube-Downloader?style=for-the-badge\&logo=github" alt="Pull Requests"></a\>
</div>

## **✨ Key Features**

* **Powerful Batch Processing**: Queue up and download multiple videos or entire playlists at once.  
* **Ultimate Quality Control**: Select from 144p all the way to 8K, including HDR and high-FPS options.  
* **Versatile Format Support**: Download as MP4, MKV, or WebM for video, or extract audio to MP3, FLAC, and more.  
* **Full Metadata**: Automatically embeds titles, descriptions, and thumbnails into your files.  
* **Subtitle Integration**: Download and embed subtitles for any video in your preferred language.  
* **Smart File Organization**: Use custom filename templates to keep your library perfectly organized.  
* **Real-Time Monitoring**: Track download progress with detailed, real-time status updates.  
* **Native macOS Design**: A beautiful, responsive interface that feels right at home on your Mac.

## **📸 Screenshots**

| Single Video Download | Batch Processing |
|----------------------|------------------|
| <img src="https://github.com/user-attachments/assets/069a30a6-fb15-441a-a519-38e2787d4e83" width="300"> | <img src="https://github.com/user-attachments/assets/7b713c07-7c54-435c-81dc-76c8bd857f80" width="300"> |

## **🚀 Getting Started**

### **Prerequisites**

* An Apple Silicon Mac (M1, M2, M3, or newer)  
* macOS Ventura (13.0) or a newer version

### **Installation**

1. **Download the App**:  
   * ➡️ [**Get the Latest Version from Releases**](https://github.com/jadhavsharad/Youtube-Downloader/releases)  
2. **Install**:  
   * Open the downloaded .dmg file.  
   * Drag the **YouTube Downloader** app into your **Applications** folder.

### **First-Time Launch on macOS**

Because the app is from an independent developer, macOS will show a security warning on the first launch. Here’s how to approve it:

Method 1: Using System Settings (Recommended)  
| Step | Action | Screenshot |  
| :--: | ------ | :--------: |  
| 1| Right-click the app icon and select Open. | <img width="300" alt="Right-click menu" src="https://github.com/user-attachments/assets/db62ee5a-a730-473c-bfe5-aa18f483bab7"> |  
| 2| A warning will appear. Click Cancel. | <img width="300" alt="Error message" src="https://github.com/user-attachments/assets/71a02c3f-5531-4490-b964-cd46e9dbb1da"> |  
| 3| Go to System Settings \> Privacy & Security. | <img width="300" alt="System Settings" src="https://github.com/user-attachments/assets/c9f4cbad-3bb1-4c7f-bc90-ed85c44ca673"> |  
| 4| Scroll down to the "Security" section. You will see a message that "YouTube Downloader was blocked...". | <img width="300" alt="Security warning" src="https://github.com/user-attachments/assets/19d53a26-fb8b-4e46-9b21-011d51cb0976"> |  
| 5| Click Open Anyway and confirm with your password or Touch ID. | <img width="300" alt="Open Anyway button" src="https://github.com/user-attachments/assets/7058ef93-0951-4c86-970d-0d0f819cf699"> |  


**Method 2: Using Terminal (Advanced)**
If the above doesn't work, run this command in macOS Terminal:
```bash
sudo xattr -d com.apple.quarantine /Applications/YouTube\ Downloader.app
```
## **🛠️ Usage Guide**

1. Choose between **Single** or **Batch** download mode.  
2. Paste one or more YouTube URLs.  
3. Select your desired download location.  
4. Choose your preferred format and quality settings.  
5. Customize options like subtitles, metadata, and filename templates.  
6. Click **Start Downloading** and watch the magic happen\!

### **Pro Tips**

* **Dynamic Naming**: Use %(title)s \[%(id)s\].%(ext)s in the filename template for perfectly labeled files.  
* **Auto-Open**: Enable "Auto Open" in settings to automatically reveal downloads in Finder when they complete.  
* **Bandwidth Control**: Use the speed limit option to manage network usage during large downloads.

## **🤝 Contributing**

We welcome contributions from developers of all skill levels\! Your ideas, bug fixes, and feedback help make this app better for everyone.

### **How You Can Help**

* **Report a Bug**: Found an issue? [Open an issue](https://github.com/jadhavsharad/Youtube-Downloader/issues) with detailed steps to reproduce it.  
* **Suggest a Feature**: Have a great idea? Let's hear it\!  
* **Submit a Pull Request**: Want to fix something yourself? Fork the repo and submit a PR. Check out our "Good First Issue" tags for easy starting points.

### **Development Setup**

```bash
# Fork and clone
git clone https://github.com/jadhavsharad/Youtube-Downloader.git

# Install dependencies
# Note: These are only needed for development, not for end-users.  
brew install yt-dlp ffmpeg

# Create feature branch
git checkout -b my-amazing-feature

# Make changes and test
# Submit pull request with detailed description
```

## **📬 Support & Feedback**

If you encounter any problems or have questions, please [**open a GitHub Issue**](https://github.com/jadhavsharad/Youtube-Downloader/issues).

⭐ **If you find this app useful, please star the repository to show your support\!**

---

**Ready to download YouTube videos like a pro?**  
➡️ [Get the Latest Version Now](https://github.com/jadhavsharad/Youtube-Downloader/releases)
