struct SongsContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var songs: [Song] = []
    @StateObject private var audioPlayer = AudioPlayerService.shared
    
    var body: some View {
        // Pure list, no navigation wrapper, no toolbar
        List(songs) { song in
            SongRowView(song: song)
                .environmentObject(audioPlayer)
        }
        .listStyle(.inset)
        .onAppear {
            loadSongs()
        }
        .onChange(of: modelContext) {
            loadSongs()
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
}// ContentView.swift - Adaptive interface with floating Sidebar/TabBar patterns
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var selectedTab: AppSection = .albums
    @State private var showingFileImporter = false
    @State private var importAlert: AlertInfo?
    @State private var showingNowPlaying = false
    @StateObject private var audioPlayer = AudioPlayerService.shared
    
    // Determine if we should show sidebar (larger screens)
    private var showSidebar: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        ZStack {
            // Main content area
            if showSidebar {
                // iPad landscape, macOS - Show sidebar and main content side by side
                HStack(spacing: 0) {
                    // Modular sidebar area (left side)
                    VStack(spacing: 0) {
                        HStack {
                            // Floating sidebar (smaller width)
                            FloatingSidebar(
                                selectedSection: $selectedTab,
                                onAddMusic: { showingFileImporter = true }
                            )
                            .frame(width: 240) // 15% smaller than 280
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                    
                    // Main content area (to the right of sidebar)
                    VStack(spacing: 0) {
                        // Content Area's Top Bar
                        HStack {
                            // Section title capsule (left)
                            Text(selectedTab.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(.regularMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                            
                            Spacer()
                            
                            // Mini Player (right side of content area top bar)
                            if audioPlayer.currentSong != nil {
                                MiniPlayer(
                                    isPresented: $showingNowPlaying,
                                    audioPlayer: audioPlayer,
                                    isCompact: false // Landscape version
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        // Detail view content (clean, no toolbars)
                        DetailView(section: selectedTab, showAddButton: false)
                    }
                }
            } else {
                // iPhone, iPad portrait - Clean views with floating tab bar
                ZStack {
                    // Main content (NO NavigationStack wrapper)
                    VStack {
                        // Top padding for status bar
                        Color.clear.frame(height: 1)
                        
                        DetailView(section: selectedTab, showAddButton: true)
                    }
                    
                    // Floating Tab Bar
                    VStack {
                        Spacer()
                        
                        // Mini Player (full width in portrait)
                        if audioPlayer.currentSong != nil {
                            MiniPlayer(
                                isPresented: $showingNowPlaying,
                                audioPlayer: audioPlayer,
                                isCompact: true // Portrait version
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        }
                        
                        FloatingTabBar(selectedTab: $selectedTab)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 34) // Safe area padding
                    }
                    
                    // Floating Add Music button for portrait
                    VStack {
                        HStack {
                            Spacer()
                            Button("Add Music") {
                                showingFileImporter = true
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.regularMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .padding(.trailing, 20)
                            .padding(.top, 50) // Below status bar
                        }
                        Spacer()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result: result)
        }
        .alert(item: $importAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showingNowPlaying) {
            FullNowPlayingView()
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            Task {
                await importFiles(urls: urls)
            }
        case .failure(let error):
            importAlert = AlertInfo(
                title: "Import Failed",
                message: error.localizedDescription
            )
        }
    }
    
    private func importFiles(urls: [URL]) async {
        var successCount = 0
        var failureCount = 0
        
        for url in urls {
            do {
                try await MusicImportService.shared.importMusicFile(from: url, to: modelContext)
                successCount += 1
            } catch {
                failureCount += 1
                print("Failed to import \(url.lastPathComponent): \(error)")
            }
        }
        
        // Show result alert
        await MainActor.run {
            let message = buildImportResultMessage(success: successCount, failure: failureCount)
            importAlert = AlertInfo(title: "Import Complete", message: message)
        }
    }
    
    private func buildImportResultMessage(success: Int, failure: Int) -> String {
        if failure == 0 {
            return "Successfully imported \(success) song\(success == 1 ? "" : "s")"
        } else if success == 0 {
            return "Failed to import \(failure) song\(failure == 1 ? "" : "s")"
        } else {
            return "Imported \(success) song\(success == 1 ? "" : "s"), failed to import \(failure)"
        }
    }
}

// MARK: - App Sections (Albums and Songs only)
enum AppSection: String, CaseIterable {
    case albums = "Albums"
    case songs = "Songs"
    
    var title: String {
        return self.rawValue
    }
    
    var systemImage: String {
        switch self {
        case .albums: return "square.grid.2x2"
        case .songs: return "music.note.list"
        }
    }
}

// MARK: - Floating Sidebar
struct FloatingSidebar: View {
    @Binding var selectedSection: AppSection
    let onAddMusic: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("AudioPlayer")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Navigation items
            VStack(spacing: 8) {
                ForEach(AppSection.allCases, id: \.self) { section in
                    SidebarRow(
                        section: section,
                        isSelected: selectedSection == section,
                        action: { selectedSection = section }
                    )
                }
                
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                Button(action: onAddMusic) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus")
                            .frame(width: 20)
                        Text("Add Music")
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct SidebarRow: View {
    let section: AppSection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: section.systemImage)
                    .frame(width: 20)
                Text(section.title)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .primary)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: AppSection
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppSection.allCases, id: \.self) { section in
                Button(action: {
                    selectedTab = section
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: section.systemImage)
                            .font(.system(size: 20))
                        Text(section.title)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == section ? .accentColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 8)
    }
}

// MARK: - Mini Player (was FloatingNowPlaying)
struct MiniPlayer: View {
    @Binding var isPresented: Bool
    let audioPlayer: AudioPlayerService
    let isCompact: Bool // true for portrait (full width), false for landscape (fixed width)
    
    var body: some View {
        if let currentSong = audioPlayer.currentSong {
            Button(action: {
                isPresented = true
            }) {
                HStack(spacing: 12) {
                    // Album artwork
                    Group {
                        if let album = currentSong.album,
                           let artworkData = album.artworkData,
                           let uiImage = UIImage(data: artworkData) {
                            Image(uiImage: uiImage)
                                .resizable()
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "music.note")
                                        .foregroundColor(.gray)
                                        .font(.system(size: isCompact ? 16 : 14))
                                )
                        }
                    }
                    .frame(width: isCompact ? 50 : 44, height: isCompact ? 50 : 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Song info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentSong.title)
                            .font(isCompact ? .subheadline : .caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text(currentSong.artist)
                            .font(isCompact ? .caption : .caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if !isCompact {
                        Spacer()
                    } else {
                        Spacer(minLength: 20)
                    }
                    
                    // Play/pause button
                    Button(action: {
                        audioPlayer.togglePlayback()
                    }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: isCompact ? 20 : 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, isCompact ? 16 : 12)
                .padding(.vertical, isCompact ? 12 : 8)
            }
            .buttonStyle(.plain)
            .background(
                Capsule()
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .frame(maxWidth: isCompact ? .infinity : 280)
        }
    }
}

// MARK: - Detail View
struct DetailView: View {
    let section: AppSection
    let showAddButton: Bool
    
    var body: some View {
        switch section {
        case .albums:
            AlbumsView()
        case .songs:
            SongsView()
        }
    }
}

// MARK: - Full Now Playing View
struct FullNowPlayingView: View {
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if let currentSong = audioPlayer.currentSong {
                    VStack(spacing: 30) {
                        // Album artwork
                        Group {
                            if let album = currentSong.album,
                               let artworkData = album.artworkData,
                               let uiImage = UIImage(data: artworkData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 80))
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 300)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        // Song info
                        VStack(spacing: 8) {
                            Text(currentSong.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text(currentSong.artist)
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text(currentSong.albumName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Playback controls
                        HStack(spacing: 50) {
                            Button(action: {
                                // Previous track
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.title)
                            }
                            
                            Button(action: {
                                audioPlayer.togglePlayback()
                            }) {
                                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 70))
                            }
                            
                            Button(action: {
                                // Next track
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.title)
                            }
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding()
                }
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Helper for alerts
struct AlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    ContentView()
        .modelContainer(for: [Album.self, Song.self], inMemory: true)
}

#Preview {
    ContentView()
        .modelContainer(for: [Album.self, Song.self], inMemory: true)
}
