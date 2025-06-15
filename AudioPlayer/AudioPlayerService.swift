// AudioPlayerService.swift - Handle audio playback
import Foundation
import AVFoundation
import MediaPlayer
import SwiftUI
import Combine

@MainActor
class AudioPlayerService: NSObject, ObservableObject {
    static let shared = AudioPlayerService()
    
    private var player: AVAudioPlayer?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var timeUpdateTimer: Timer?
    
    // Published properties for UI binding
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // Setup audio session for background playback
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // Play a song
    func play(song: Song) {
        // Stop current playback
        stop()
        
        var fileURL = song.fileURL
        
        // Debug: Check if file exists
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("❌ File does not exist at original path: \(fileURL.path)")
            
            // Try to find the file in the current Documents/Music directory
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let musicDirectory = documentsURL.appendingPathComponent("Music", isDirectory: true)
            let fileName = fileURL.lastPathComponent
            let newURL = musicDirectory.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: newURL.path) {
                print("✅ Found file at new path: \(newURL.path)")
                fileURL = newURL
                // TODO: Update the song's fileURL in the database
            } else {
                print("❌ File not found in current music directory either")
                return
            }
        }
        
        // Debug: Check file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            print("📁 File size: \(fileSize) bytes for \(song.title)")
            
            if fileSize == 0 {
                print("❌ File is empty!")
                return
            }
        } catch {
            print("❌ Could not get file attributes: \(error)")
            return
        }
        
        // Debug: Print file info
        print("🎵 Attempting to play: \(song.title)")
        print("📂 File URL: \(fileURL)")
        print("📝 File extension: \(fileURL.pathExtension)")
        
        do {
            // Create player with song file
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.delegate = self
            
            // Debug: Print player info
            print("✅ AVAudioPlayer created successfully")
            print("⏱️ Duration: \(player?.duration ?? 0) seconds")
            print("🔧 Format: \(player?.format.description ?? "Unknown")")
            
            player?.prepareToPlay()
            
            // Update state
            currentSong = song
            duration = player?.duration ?? 0
            
            // Setup now playing info
            setupNowPlayingInfo(for: song)
            
            // Start playback
            let playSuccess = player?.play() ?? false
            print("▶️ Play command result: \(playSuccess)")
            
            isPlaying = playSuccess
            
            if playSuccess {
                // Start time tracking
                startTimeTracking()
            }
            
        } catch let error as NSError {
            print("❌ Failed to play song: \(error)")
            print("❌ Error domain: \(error.domain)")
            print("❌ Error code: \(error.code)")
            print("❌ Error description: \(error.localizedDescription)")
            
            // Convert OSStatus error code to readable format
            if error.domain == "NSOSStatusErrorDomain" {
                let osStatus = OSStatus(error.code)
                let fourCC = String(format: "%c%c%c%c",
                    (osStatus >> 24) & 0xFF,
                    (osStatus >> 16) & 0xFF,
                    (osStatus >> 8) & 0xFF,
                    osStatus & 0xFF)
                print("❌ OSStatus as FourCC: '\(fourCC)'")
            }
        }
    }
    
    // Toggle play/pause
    func togglePlayback() {
        guard let player = player else { return }
        
        if player.isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    // Pause playback
    func pause() {
        player?.pause()
        isPlaying = false
        timeUpdateTimer?.invalidate()
    }
    
    // Resume playback
    func resume() {
        player?.play()
        isPlaying = true
        startTimeTracking()
    }
    
    // Stop playback
    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
        currentSong = nil
        timeUpdateTimer?.invalidate()
    }
    
    // Seek to time
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
    
    // Setup Now Playing info for Control Center
    private func setupNowPlayingInfo(for song: Song) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = song.albumName
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        // Add artwork if available
        if let album = song.album,
           let artworkData = album.artworkData,
           let image = UIImage(data: artworkData) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // Track current time
    private func startTimeTracking() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self, let player = self.player, player.isPlaying else {
                    timer.invalidate()
                    return
                }
                
                self.currentTime = player.currentTime
                
                // Update now playing time
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
}

// AVAudioPlayerDelegate
extension AudioPlayerService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentTime = 0
            self.timeUpdateTimer?.invalidate()
            // TODO: Auto-play next song in queue
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
            self.isPlaying = false
        }
    }
}
