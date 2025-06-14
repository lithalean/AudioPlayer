//
//  MusicModels.swift
//  AudioPlayer
//
//  Created by Tyler Allen on 6/14/25.
//

import Foundation
import SwiftData

@Model
class Song {
    @Attribute(.unique) var id: UUID
    var title: String
    var artist: String
    var albumName: String
    var duration: TimeInterval
    var fileURL: URL
    var dateAdded: Date
    var trackNumber: Int?
    var year: Int?
    
    // Relationship to album
    @Relationship(inverse: \Album.songs) var album: Album?
    
    init(title: String, artist: String, albumName: String, duration: TimeInterval, fileURL: URL, trackNumber: Int? = nil, year: Int? = nil) {
        self.id = UUID()
        self.title = title
        self.artist = artist
        self.albumName = albumName
        self.duration = duration
        self.fileURL = fileURL
        self.dateAdded = Date()
        self.trackNumber = trackNumber
        self.year = year
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

@Model
class Album {
    @Attribute(.unique) var id: UUID
    var name: String
    var artist: String
    var year: Int?
    var artworkData: Data?
    var dateAdded: Date
    
    // Relationship to songs
    @Relationship var songs: [Song] = []
    
    init(name: String, artist: String, year: Int? = nil, artworkData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.artist = artist
        self.year = year
        self.artworkData = artworkData
        self.dateAdded = Date()
    }
    
    var songCount: Int {
        songs.count
    }
    
    var totalDuration: TimeInterval {
        songs.reduce(0) { $0 + $1.duration }
    }
    
    var formattedDuration: String {
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
