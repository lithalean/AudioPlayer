// MusicImportService.swift - Handle importing and processing music files
import Foundation
import SwiftData
import AVFoundation
import UIKit

@MainActor
class MusicImportService {
    static let shared = MusicImportService()
    private init() {}
    
    // Import a single music file
    func importMusicFile(from url: URL, to modelContext: ModelContext) async throws {
        // Ensure we can access the file
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Check if file format is supported
        let supportedExtensions = ["mp3", "m4a", "aac", "aiff", "wav", "alac"]
        let fileExtension = url.pathExtension.lowercased()
        
        print("📁 Importing file: \(url.lastPathComponent)")
        print("📝 File extension: \(fileExtension)")
        
        guard supportedExtensions.contains(fileExtension) else {
            print("❌ Unsupported file format: \(fileExtension)")
            throw ImportError.unsupportedFormat
        }
        
        // Copy file to app's documents directory
        let documentsURL = getDocumentsDirectory()
        let musicDirectory = documentsURL.appendingPathComponent("Music", isDirectory: true)
        
        // Create Music directory if it doesn't exist
        try FileManager.default.createDirectory(at: musicDirectory, withIntermediateDirectories: true)
        
        // Create unique filename to avoid conflicts
        let fileName = "\(UUID().uuidString)_\(url.lastPathComponent)"
        let destinationURL = musicDirectory.appendingPathComponent(fileName)
        
        print("📂 Copying to: \(destinationURL.path)")
        
        // Copy file to app directory
        try FileManager.default.copyItem(at: url, to: destinationURL)
        
        // Verify the copied file
        let copiedFileSize = try FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64 ?? 0
        print("✅ File copied successfully. Size: \(copiedFileSize) bytes")
        
        // Test if AVAudioPlayer can read the file
        do {
            let testPlayer = try AVAudioPlayer(contentsOf: destinationURL)
            print("✅ AVAudioPlayer can read the file. Duration: \(testPlayer.duration) seconds")
        } catch {
            print("❌ AVAudioPlayer cannot read the copied file: \(error)")
            // Clean up the failed file
            try? FileManager.default.removeItem(at: destinationURL)
            throw ImportError.unsupportedFormat
        }
        
        // Extract metadata
        let metadata = try await extractMetadata(from: destinationURL)
        
        // Create Song object
        let song = Song(
            title: metadata.title ?? url.lastPathComponent,
            artist: metadata.artist ?? "Unknown Artist",
            albumName: metadata.album ?? "Unknown Album",
            duration: metadata.duration,
            fileURL: destinationURL,
            trackNumber: metadata.trackNumber,
            year: metadata.year
        )
        
        print("🎵 Created song: \(song.title) by \(song.artist)")
        
        // Find or create album
        let album = try findOrCreateAlbum(
            name: song.albumName,
            artist: song.artist,
            year: song.year,
            artworkData: metadata.artworkData,
            in: modelContext
        )
        
        // Link song to album
        song.album = album
        album.songs.append(song)
        
        // Save to database
        modelContext.insert(song)
        try modelContext.save()
        
        print("💾 Song saved to database successfully")
    }
    
    // Extract metadata from audio file
    private func extractMetadata(from url: URL) async throws -> AudioMetadata {
        let asset = AVURLAsset(url: url)
        
        // Get duration
        let duration = try await asset.load(.duration).seconds
        
        // Extract metadata
        let metadata = try await asset.load(.metadata)
        
        var title: String?
        var artist: String?
        var album: String?
        var artworkData: Data?
        
        for item in metadata {
            guard let key = item.commonKey?.rawValue,
                  let value = try await item.load(.value) else { continue }
            
            switch key {
            case "title":
                title = value as? String
            case "artist":
                artist = value as? String
            case "albumName":
                album = value as? String
            case "artwork":
                if let imageData = value as? Data {
                    artworkData = imageData
                }
            default:
                break
            }
        }
        
        return AudioMetadata(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            trackNumber: nil, // TODO: Extract from metadata
            year: nil, // TODO: Extract from metadata
            artworkData: artworkData
        )
    }
    
    // Find existing album or create new one
    private func findOrCreateAlbum(name: String, artist: String, year: Int?, artworkData: Data?, in modelContext: ModelContext) throws -> Album {
        
        // Try to find existing album
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { album in
                album.name == name && album.artist == artist
            }
        )
        
        let existingAlbums = try modelContext.fetch(descriptor)
        
        if let existingAlbum = existingAlbums.first {
            // Update artwork if we have better data
            if existingAlbum.artworkData == nil && artworkData != nil {
                existingAlbum.artworkData = artworkData
            }
            return existingAlbum
        }
        
        // Create new album
        let newAlbum = Album(name: name, artist: artist, year: year, artworkData: artworkData)
        modelContext.insert(newAlbum)
        return newAlbum
    }
    
    // Get app's documents directory
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// Metadata structure
struct AudioMetadata: Sendable {
    let title: String?
    let artist: String?
    let album: String?
    let duration: TimeInterval
    let trackNumber: Int?
    let year: Int?
    let artworkData: Data?
}

// Import errors
enum ImportError: Error, LocalizedError {
    case accessDenied
    case unsupportedFormat
    case metadataError
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Unable to access the selected file"
        case .unsupportedFormat:
            return "Unsupported audio format"
        case .metadataError:
            return "Unable to read file metadata"
        }
    }
}
