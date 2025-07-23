# AudioPlayer
*An Open Source, modern Darwin ARM64 Audio Playback Application following WWDC25 iPadOS & tvOS Design Principles*

![Platform Support](https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20iPadOS%20%7C%20tvOS-blue)
![Swift Version](https://img.shields.io/badge/swift-6.2+-orange)
![iOS Version](https://img.shields.io/badge/iOS-18.0+-green)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Current Status: **WORKING BUILD**

The app is now fully functional with **cross-platform playback**, a **modern SwiftUI interface**, and **Darwin ARM64 optimization**. 🎉

## 🎯 Project Vision

AudioPlayer aims to be the cleanest, most native-feeling music player for Apple platforms. It follows **WWDC25 design principles** to deliver a polished iPadOS-first interface that scales beautifully to **macOS, iOS, and tvOS**.

## 🚀 Features

### 🎶 Core Playback
- ✅ Smooth playback powered by **AVAudioPlayer**
- ✅ Real-time **volume control & progress scrubbing**
- ✅ Album art & metadata display
- ✅ Automatic **Now Playing integration** (iOS Control Center, lock screen)

### 📚 Music Library
- ✅ **Album & Song Browsing** with adaptive layouts
- ✅ **File Importer** for adding custom audio files (iOS/macOS only)
- ✅ Modern grid-based album view with artwork previews

### 🖥️ Cross-Platform Design
- ✅ **macOS** – Native Mac toolbar and Catalyst styling
- ✅ **iPadOS** – Full-height sidebar and floating controls
- ✅ **iPhone** – Compact floating player bar
- ✅ **tvOS** – Remote-friendly controls (stepper-style volume, focusable UI)

### 🎨 Modern Interface
- ✅ **SwiftUI Adaptive Layouts** using `.ultraThinMaterial`
- ✅ Smooth animations, hover states, and shadows
- ✅ Dark, minimalistic design optimized for **Darwin ARM64**

## 🛠 Technical Overview

### Architecture
- **SwiftUI 6.2+** – Reactive, adaptive design
- **@Published & Combine** – Real-time state updates
- **Modular Views** – Separate components for playback, library, and controls
- **Platform Checks** – Conditional logic for tvOS vs iOS/macOS

### Tech Stack
- **Audio** – AVFoundation (AVAudioPlayer)
- **Data** – SwiftData for albums/songs, JSON-based import
- **Cross-Platform** – Single codebase for iOS, iPadOS, macOS, tvOS

## 📦 Installation & Setup

### Prerequisites
- **Xcode 26+**
- **iOS 18+, iPadOS 18+, macOS 15+, tvOS 18+**
- **Swift 6.2+**
- Runs best on **Darwin ARM64 (Apple Silicon)**

### Run the Project
1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/AudioPlayer.git
   ```
2. Open `AudioPlayer.xcodeproj` in Xcode 26+
3. Build & run on your preferred platform.

## ⌨️ Controls

### iOS/iPadOS/macOS
- **Play/Pause** – Tap playback button
- **Scrub Track** – Drag progress bar (macOS & iOS only)
- **Volume** – Interactive slider

### tvOS
- **Play/Pause** – Siri Remote select button
- **Volume** – +/- buttons (stepper style)
- **Navigation** – Remote swipe/focus

## 🗺 Development Roadmap

### ✅ Phase 1 (Core Playback) – Complete
- Basic playback, album/song browsing, cross-platform layouts

### 🚧 Phase 2 (Enhanced UI) – In Progress
- Improved animations, advanced filtering, tvOS refinements

### 🔮 Future (Planned)
- Playlist management
- Background audio & AirPlay
- Search & metadata editing
- Advanced EQ & DSP (Darwin ARM64 optimized)