//
//  AudioPlayerApp.swift
//  AudioPlayer
//
//  Created by Tyler Allen on 6/14/25.
//

import SwiftUI
import SwiftData

@main
struct AudioPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Album.self, Song.self])
    }
}
