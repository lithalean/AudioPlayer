// SongsView.swift - List view of all songs with playback
import SwiftUI
import SwiftData

struct SongsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var songs: [Song] = []
    @State private var searchText = ""
    @StateObject private var audioPlayer = AudioPlayerService.shared
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText) ||
                song.albumName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
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
                        .environmentObject(audioPlayer)
                }
                .listStyle(.inset)
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Song") {
                        // TODO: Add song import
                    }
                }
            }
            .onAppear {
                loadSongs()
            }
            .onChange(of: modelContext) {
                loadSongs()
            }
        }
    }
    
    private func loadSongs() {
        do {
            let descriptor = FetchDescriptor<Song>(
                sortBy: [SortDescriptor(\Song.title)]
            )
            songs = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch songs: \(error)")
            songs = []
        }
    }
}

struct SongRowView: View {
    let song: Song
    @EnvironmentObject var audioPlayer: AudioPlayerService
    @State private var isHovered = false
    
    var isCurrentSong: Bool {
        audioPlayer.currentSong?.id == song.id
    }
    
    var body: some View {
        HStack {
            // Play button
            Button(action: {
                if isCurrentSong && audioPlayer.isPlaying {
                    audioPlayer.pause()
                } else if isCurrentSong {
                    audioPlayer.resume()
                } else {
                    audioPlayer.play(song: song)
                }
            }) {
                Image(systemName: playButtonIcon)
                    .font(.system(size: 16))
                    .frame(width: 24, height: 24)
                    .foregroundColor(isCurrentSong ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            
            // Song info
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(isCurrentSong ? .accentColor : .primary)
                
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
        .onTapGesture {
            // For iOS - tap to show/hide play button
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered.toggle()
            }
        }
    }
    
    private var playButtonIcon: String {
        if isCurrentSong {
            return audioPlayer.isPlaying ? "pause.fill" : "play.fill"
        } else {
            return isHovered ? "play.fill" : "music.note"
        }
    }
}

#Preview {
    SongsView()
        .modelContainer(for: [Album.self, Song.self], inMemory: true)
}
