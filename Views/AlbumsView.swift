//
//  AlbumsView.swift
//  AudioPlayer
//
//  Created by Tyler Allen on 6/14/25.
//

import SwiftUI
import SwiftData

struct AlbumsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var albums: [Album]
    
    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(albums) { album in
                        AlbumGridItem(album: album)
                    }
                }
                .padding()
            }
            .navigationTitle("Albums")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Album") {
                        // TODO: Add album import
                    }
                }
            }
        }
    }
}

struct AlbumGridItem: View {
    let album: Album
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Album artwork
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                
                if let artworkData = album.artworkData,
                   let uiImage = UIImage(data: artworkData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    // Default artwork
                    Image(systemName: "music.note")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                // Hover overlay with play button (touch-friendly for iOS)
                if isHovered {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                    
                    Button(action: {
                        // TODO: Play album
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 50, height: 50)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .onTapGesture {
                // For iOS - toggle play overlay on tap instead of hover
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered.toggle()
                }
            }
            
            // Album info
            VStack(alignment: .leading, spacing: 2) {
                Text(album.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text("\(album.songCount) songs")
                    if let year = album.year {
                        Text("• \(year)")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AlbumsView()
        .modelContainer(for: [Album.self, Song.self], inMemory: true)
}
