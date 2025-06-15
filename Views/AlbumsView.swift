// AlbumsView.swift - iPad-style albums grid with expandable track lists
import SwiftUI
import SwiftData

struct AlbumsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var albums: [Album] = []
    @State private var expandedAlbumID: UUID? = nil
    @StateObject private var audioPlayer = AudioPlayerService.shared
    
    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 20)
    ]
    
    var body: some View {
        // Use NavigationStack instead of NavigationView for better iOS behavior
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(albums) { album in
                        VStack(spacing: 0) {
                            // Album grid item
                            AlbumGridItem(
                                album: album,
                                isExpanded: expandedAlbumID == album.id
                            ) {
                                // Toggle expansion on tap
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if expandedAlbumID == album.id {
                                        expandedAlbumID = nil
                                    } else {
                                        expandedAlbumID = album.id
                                    }
                                }
                            }
                            
                            // Expandable track list
                            if expandedAlbumID == album.id {
                                AlbumTrackList(album: album, audioPlayer: audioPlayer)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Album") {
                        // TODO: Add album import
                    }
                }
            }
            .onAppear {
                loadAlbums()
            }
            .onChange(of: modelContext) {
                loadAlbums()
            }
        }
    }
    
    private func loadAlbums() {
        do {
            let descriptor = FetchDescriptor<Album>(
                sortBy: [SortDescriptor(\Album.name)]
            )
            let fetchedAlbums = try modelContext.fetch(descriptor)
            print("📀 Loaded \(fetchedAlbums.count) albums")
            albums = fetchedAlbums
        } catch {
            print("❌ Failed to fetch albums: \(error)")
            albums = []
        }
    }
}

struct AlbumGridItem: View {
    let album: Album
    let isExpanded: Bool
    let onTap: () -> Void
    
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
                
                // Expansion indicator
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                            .font(.title2)
                    }
                    .padding(8)
                }
            }
            .onTapGesture {
                onTap()
            }
            
            // Album info
            VStack(alignment: .leading, spacing: 2) {
                Text(album.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(isExpanded ? .accentColor : .primary)
                
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
        .scaleEffect(isExpanded ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

struct AlbumTrackList: View {
    let album: Album
    let audioPlayer: AudioPlayerService
    
    var sortedSongs: [Song] {
        album.songs.sorted { song1, song2 in
            // Sort by track number if available, otherwise by title
            if let track1 = song1.trackNumber, let track2 = song2.trackNumber {
                return track1 < track2
            }
            return song1.title < song2.title
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Track list header
            HStack {
                Text("Tracks")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(album.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            // Track list
            ForEach(sortedSongs) { song in
                AlbumTrackRow(song: song, audioPlayer: audioPlayer)
                
                if song.id != sortedSongs.last?.id {
                    Divider()
                        .padding(.leading, 40)
                }
            }
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .padding(.top, 4)
    }
}

struct AlbumTrackRow: View {
    let song: Song
    let audioPlayer: AudioPlayerService
    
    var isCurrentSong: Bool {
        audioPlayer.currentSong?.id == song.id
    }
    
    var body: some View {
        HStack {
            // Track number or play button
            Button(action: {
                print("🎵 Track tapped: \(song.title)")
                if isCurrentSong && audioPlayer.isPlaying {
                    print("⏸️ Pausing current song")
                    audioPlayer.pause()
                } else if isCurrentSong {
                    print("▶️ Resuming current song")
                    audioPlayer.resume()
                } else {
                    print("🎶 Playing new song: \(song.title)")
                    audioPlayer.play(song: song)
                }
            }) {
                ZStack {
                    if let trackNumber = song.trackNumber {
                        Text("\(trackNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .opacity(isCurrentSong ? 0 : 1)
                    }
                    
                    Image(systemName: playButtonIcon)
                        .font(.system(size: 14))
                        .foregroundColor(isCurrentSong ? .accentColor : .secondary)
                        .opacity(isCurrentSong ? 1 : 0)
                }
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            // Song title
            Text(song.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundColor(isCurrentSong ? .accentColor : .primary)
            
            Spacer()
            
            // Duration
            Text(song.formattedDuration)
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            // Alternative tap gesture for the whole row
            print("🎵 Row tapped: \(song.title)")
            if isCurrentSong && audioPlayer.isPlaying {
                audioPlayer.pause()
            } else if isCurrentSong {
                audioPlayer.resume()
            } else {
                audioPlayer.play(song: song)
            }
        }
    }
    
    private var playButtonIcon: String {
        if isCurrentSong {
            return audioPlayer.isPlaying ? "pause.fill" : "play.fill"
        } else {
            return "play.fill"
        }
    }
}

#Preview {
    AlbumsView()
        .modelContainer(for: [Album.self, Song.self], inMemory: true)
}
