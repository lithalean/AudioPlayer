// ContentView.swift - Main interface with responsive layout
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab = 0
    @State private var showingFileImporter = false
    @State private var importAlert: AlertInfo?
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                // iPhone portrait - use TabView
                TabView(selection: $selectedTab) {
                    AlbumsView()
                        .tabItem {
                            Label("Albums", systemImage: "square.grid.2x2")
                        }
                        .tag(0)
                    
                    SongsView()
                        .tabItem {
                            Label("Songs", systemImage: "music.note.list")
                        }
                        .tag(1)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add Music") {
                            showingFileImporter = true
                        }
                    }
                }
            } else {
                // iPad/landscape - use NavigationSplitView
                NavigationSplitView {
                    // Sidebar
                    VStack(alignment: .leading, spacing: 12) {
                        SidebarItem(title: "Albums", systemImage: "square.grid.2x2", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        SidebarItem(title: "Songs", systemImage: "music.note.list", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        Divider()
                        
                        Button(action: {
                            showingFileImporter = true
                        }) {
                            Label("Add Music", systemImage: "plus")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        
                        Spacer()
                    }
                    .padding()
                    .frame(minWidth: 200)
                } detail: {
                    // Main content area
                    Group {
                        switch selectedTab {
                        case 0:
                            AlbumsView()
                        case 1:
                            SongsView()
                        default:
                            AlbumsView()
                        }
                    }
                }
            }
        }
        // File importer (shared by both layouts)
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

struct SidebarItem: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 20)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .foregroundColor(isSelected ? .accentColor : .primary)
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
