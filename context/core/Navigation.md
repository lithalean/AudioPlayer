# AudioPlayer Navigation Context

**Purpose**: Screen flow, user journeys, and state management  
**Version**: 1.0  
**Navigation Pattern**: Adaptive Split/Tab + Platform-Specific  
**Last Updated**: 2025-08-01

## Navigation Architecture

### Primary Navigation Pattern
```swift
// iOS: Adaptive based on size class
if horizontalSizeClass == .compact {
    TabView(selection: $selectedTab) {
        // Phone: Tab-based navigation
    }
} else {
    NavigationSplitView {
        // iPad/Mac: Sidebar navigation
    }
}

// tvOS: Focus-based grid navigation
NavigationStack {
    AlbumsView()  // No complex hierarchies
}
```

## Screen Hierarchy
```
Root (ContentView)
├── Compact Mode (iPhone)
│   └── TabView
│       ├── Albums Tab
│       ├── Songs Tab
│       └── Search Tab (future)
├── Regular Mode (iPad/Mac)
│   └── NavigationSplitView
│       ├── Sidebar
│       │   ├── Library
│       │   ├── Albums
│       │   └── Songs
│       └── Detail
│           └── Selected View
└── tvOS Mode
    └── NavigationStack
        └── AlbumsView (grid only)

Overlays (All Platforms):
├── AudioPlaybackBar (persistent)
├── Import Sheet (iOS only)
├── Metadata Edit Sheet (planned)
└── Now Playing Full Screen (tvOS)
```

## Navigation State Machine
```
┌─────────┐     ┌──────────┐     ┌──────────┐
│  Init   │────▶│ Library  │────▶│ Playing  │
└─────────┘     └──────────┘     └──────────┘
                      │                 ▲
                      ▼                 │
                ┌──────────┐           │
                │  Import  │───────────┘
                └──────────┘
                      │
                      ▼
                ┌──────────┐
                │ Process  │
                └──────────┘
```

## User Journey Flows

### First Launch Journey (iOS)
```
App Launch → Empty Library Detection → 
Welcome Message → Import Button Prominent →
File Browser Opens → Select M4A Files →
Validation → Processing with Progress →
Library Populated → Default to Albums View
```

### Music Import Flow (iOS Only)
```
Tap Import → FileImporter Sheet →
Browse Files App → Multi-Select M4A →
Validate Each File → Extract Metadata →
Create Album if New → Add Songs →
Save to SwiftData → Dismiss Sheet →
Update Grid/List → Show Success
```

### Playback Initiation
```
Browse Albums/Songs → Tap/Click Item →
Load Audio File → Initialize Player →
Update Now Playing → Show Mini Bar →
Begin Playback → Update UI State
```

### tvOS Navigation Flow
```
Launch → Focus Albums Grid → Navigate with Remote →
Select Album → Play First Song →
Full Screen Player → Swipe for Controls →
Menu Button → Return to Grid
```

## Platform-Specific Navigation

### iOS Navigation Implementation
```swift
struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var selectedTab = 0
    @State private var columnVisibility = NavigationSplitViewColumn.sidebar
    
    var body: some View {
        if sizeClass == .compact {
            // iPhone - Tab based
            TabView(selection: $selectedTab) {
                AlbumsView()
                    .tabItem {
                        Label("Albums", systemImage: "square.stack")
                    }
                    .tag(0)
                
                SongsView()
                    .tabItem {
                        Label("Songs", systemImage: "music.note.list")
                    }
                    .tag(1)
            }
        } else {
            // iPad - Sidebar based
            NavigationSplitView(columnVisibility: $columnVisibility) {
                Sidebar()
            } content: {
                // Content based on selection
            } detail: {
                // Currently unused due to SwiftData issues
                Text("Select an item")
            }
        }
    }
}
```

### tvOS Navigation Constraints
```swift
#if os(tvOS)
// No sidebar - direct grid navigation
NavigationStack {
    AlbumsView()
        .focusable()  // Enable focus
        .focusSection()  // Focus management
        .onMoveCommand { direction in
            // Handle directional navigation
        }
}

// No import capability
// No complex navigation stacks
// Full screen player on selection
#endif
```

### Navigation State Management

#### Current Implementation
```swift
// Simple state for current view
@State private var selectedView: ViewType = .albums

enum ViewType: String, CaseIterable {
    case albums = "Albums"
    case songs = "Songs"
    
    var icon: String {
        switch self {
        case .albums: return "square.stack"
        case .songs: return "music.note.list"
        }
    }
}
```

#### Sheet Presentations
```swift
// Import sheet (iOS only)
@State private var showingImporter = false

// Future metadata editing
@State private var editingSong: Song?
@State private var editingAlbum: Album?

// Full screen player (tvOS)
@State private var showingFullScreenPlayer = false
```

## Removed Navigation Patterns

### ❌ Album Detail View (Removed December 2024)
**Original Design**: 
```swift
// This pattern caused SwiftData binding issues
NavigationLink(value: album) {
    AlbumCard(album: album)
}
.navigationDestination(for: Album.self) { album in
    AlbumDetailView(album: album)  // Generic parameter errors
}
```

**Current Solution**:
```swift
// Direct playback from grid
AlbumCard(album: album)
    .onTapGesture {
        if let firstSong = album.songs.first {
            audioPlayer.playSong(firstSong)
        }
    }
```

**Rationale**: SwiftData relationship bindings incompatible with SwiftUI navigation

### ❌ Complex Navigation Stacks (Avoided)
**Why Removed**: tvOS focus engine conflicts, unnecessary complexity
**Current**: Single-level navigation with modal sheets

## Navigation Quick Reference

| From | To | Trigger | Platform | Animation |
|------|-----|---------|----------|-----------|
| Library | Albums | Sidebar/Tab | All | None/Slide |
| Library | Songs | Sidebar/Tab | All | None/Slide |
| Albums | Playback | Tap album | All | Bottom sheet |
| Songs | Playback | Tap song | All | Bottom sheet |
| Any | Import | Import button | iOS only | Sheet |
| Grid | Full Player | Select | tvOS | Push |
| Player | Grid | Menu button | tvOS | Pop |

## Focus Management (tvOS)

### Current Implementation
```swift
@FocusState private var focusedAlbum: UUID?
@Namespace private var albumGridNamespace

// In AlbumsView
ForEach(albums) { album in
    AlbumCard(album: album)
        .focusable()
        .focused($focusedAlbum, equals: album.id)
        .prefersDefaultFocus(album == albums.first)
}
```

### Known Focus Issues
1. **Grid Jump Bug**: Focus occasionally jumps to wrong item
2. **Cause**: LazyVGrid recycling conflicts with FocusState
3. **Workaround**: Manual focus restoration
4. **Fix**: Custom focus guides (planned)

## Gesture Support

### Implemented Gestures
```swift
// Swipe to dismiss (iOS)
.swipeActions {
    Button("Delete") { /* ... */ }
}

// Tap to play
.onTapGesture {
    audioPlayer.playSong(song)
}

// Long press (future)
.contextMenu {
    Button("Edit") { /* ... */ }
    Button("Delete") { /* ... */ }
}
```

### Platform-Specific Gestures
- **iOS**: Swipe, tap, long press, pinch (future)
- **tvOS**: Remote navigation, select, menu
- **macOS**: Click, right-click, hover

## Navigation Performance

### Optimizations
1. **Lazy Loading**: LazyVGrid for albums
2. **Shallow Hierarchy**: Removed deep navigation
3. **Modal Sheets**: Lighter than push navigation
4. **Focus Recycling**: Efficient tvOS grid updates

### Metrics
- Navigation response: <100ms
- Sheet presentation: 350ms standard
- Focus movement: 200ms tvOS
- Tab switching: Instant

## Future Navigation Enhancements

### Phase 3 Additions
1. **Search Tab**: Full-text search across library
2. **Playlists Sidebar**: Custom playlist management
3. **Queue View**: Now playing queue
4. **Settings**: App preferences

### Gesture Enhancements
1. **Pinch to Zoom**: Grid size adjustment
2. **Drag to Reorder**: Playlist management
3. **Swipe Actions**: More options
4. **Keyboard Shortcuts**: Power user features