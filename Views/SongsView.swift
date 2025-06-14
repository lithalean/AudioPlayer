//
//  SongsView.swift
//  AudioPlayer
//
//  Created by Tyler Allen on 6/14/25.
//


// SongsView.swift - List view of all songs
import SwiftUI
import SwiftData

struct SongsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Song]
    @State private var searchText = ""
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs.sorted { $0.title < $1.title }
        } else {
            return songs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText) ||
                song.albumName.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.title < $1.title }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search songs, artists, albums...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Songs list
                List(filteredSongs) { song in
                    SongRowView(song: song)
                }
                .listStyle(.inset)
            }
            .navigationTitle("Songs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Song") {
                        // TODO: Add song import
                    }
                }
            }
        }
    }
}

struct SongRowView: View {
    let song: Song
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            // Play button (visible on hover)
            Button(action: {
                // TODO: Play song
            }) {
                Image(systemName: isHovered ? "play.fill" : "music.note")
                    .font(.system(size: 16))
                    .frame(width: 24, height: 24)
                    .foregroundColor(isHovered ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            
            // Song info
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(song.artist)
                    Text("•")
                    Text(song.albumName)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            
            Spacer()
            
            // Duration
            Text(song.formattedDuration)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    SongsView()
        .modelContainer(for: [Album.self, Song.self], inMemory: true)
}