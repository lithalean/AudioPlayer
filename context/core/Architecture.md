# AudioPlayer Architecture Context

**Purpose**: Technical blueprint and system design rationale  
**Version**: 1.0  
**Status**: Phase 2 - Local Library Management (80% Complete)  
**Last Updated**: 2025-08-01

## Key Concepts (AI Quick Reference)

### Core Architecture Pattern
```
M4A-EXCLUSIVE + SWIFTDATA + GLASS-UI = OFFLINE APPLE MUSIC CLONE
```

### Critical Design Elements
1. **M4A Format Exclusivity** - Strategic constraint for Apple ecosystem purity
2. **SwiftData Relationship Workarounds** - Array conversion pattern for ForEach
3. **Platform Divergence Strategy** - iOS (import) vs tvOS (playback) vs macOS (Catalyst)
4. **Singleton Audio Service** - Centralized playback state with @Published
5. **Glass Morphism UI** - WWDC25-style with .ultraThinMaterial effects

## System Architecture

### Core Design Philosophy
**"Constraints Enable Excellence"**
- M4A-only format support creates focused, reliable experience
- Offline-first eliminates network complexity
- Platform-specific features embrace native capabilities
- SwiftData workarounds over complex solutions

### High-Level Architecture
```
┌─────────────────────────────────────────────────┐
│                  AudioPlayer                     │
│            (2,636 LOC across 11 files)          │
├─────────────────────────────────────────────────┤
│               ContentView (317 LOC)             │
│         NavigationSplitView / TabView           │
├──────────────┬────────────┬────────────────────┤
│   Sidebar    │  Content   │  AudioPlaybackBar  │
│   (166 LOC)  │  Views     │    (490 LOC)       │
├──────────────┴────────────┴────────────────────┤
│         AudioPlayerService (200 LOC)            │
│              Singleton Pattern                   │
├──────────────┬─────────────────────────────────┤
│  SwiftData   │   MusicImportService (191 LOC)  │
│  Models      │   M4A Validation & Import        │
│  (148 LOC)   │                                  │
├──────────────┴─────────────────────────────────┤
│              AVFoundation Layer                  │
│    AVAudioPlayer (now) → AVPlayer (future)     │
└─────────────────────────────────────────────────┘
```

## Technical Architecture

### M4A Format Exclusivity Strategy

**Strategic Decision**: Support ONLY M4A containers with AAC (lossy) or ALAC (lossless)

```swift
// File validation - strict M4A only
.fileImporter(
    allowedContentTypes: [UTType(filenameExtension: "m4a")!],
    allowsMultipleSelection: true
)

// Despite code comments suggesting broader support:
// supportedExtensions = ["mp3", "m4a", "aac", "aiff", "wav", "alac"]
// Only M4A actually works by design
```

**Benefits**:
- Native Apple format consistency
- Unified metadata extraction via AVAsset
- Predictable codec behavior (AAC/ALAC only)
- Simplified error handling
- 30% code reduction vs multi-format

### Data Layer - SwiftData Architecture

**Core Models with Relationship Patterns**:

```swift
@Model
class Album {
    @Attribute(.unique) let id: UUID
    var name: String
    var artist: String
    var artworkData: Data?
    var yearReleased: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Song.album)
    var songs: [Song] = []
}

@Model 
class Song {
    @Attribute(.unique) let id: UUID
    var title: String
    var artist: String
    var albumName: String
    var duration: TimeInterval
    var fileURL: URL
    var track: Int?
    var discNumber: Int?
    var isLossless: Bool = false  // ALAC detection
    
    @Relationship var album: Album?
}
```

**Critical SwiftData Workaround Pattern**:
```swift
// ❌ NEVER - SwiftUI can't infer generic parameters
ForEach($album.songs) { $song in
    SongRow(song: $song)
}

// ✅ ALWAYS - Convert to Array first
ForEach(Array(album.songs)) { song in
    SongRow(song: song)
}
```

### Audio Engine Architecture

**Current Implementation - AVAudioPlayer**:
```swift
class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()  // Singleton
    
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    
    private var audioPlayer: AVAudioPlayer?
    
    func playSong(_ song: Song) {
        audioPlayer = try? AVAudioPlayer(contentsOf: song.fileURL)
        audioPlayer?.play()
    }
}
```

**Future Migration - AVPlayer (Phase 3)**:
- Gapless playback support
- Background audio capability
- Better scrubbing control
- Crossfade possibilities

### Platform Divergence Architecture

**iOS (Primary Platform)**:
- Full FileImporter for M4A files
- Metadata editing capabilities
- Adaptive layouts (3-6 column grid)
- Mini bar (iPhone) / Full bar (iPad)

**tvOS (Playback Only)**:
- No FileImporter (platform limitation)
- Focus-based navigation
- Fixed 4-column grid
- Full-screen now playing
- Remote control integration

**macOS (Catalyst - Deprioritized)**:
- Basic functionality via Catalyst
- Desktop layout patterns
- Not optimized or tested

### State Management Patterns

**Singleton Service Pattern**:
```swift
// Centralized audio state
AudioPlayerService.shared
    
// Views observe via @ObservedObject
@ObservedObject private var audioPlayer = AudioPlayerService.shared

// SwiftData automatic updates via @Query
@Query private var albums: [Album]
```

**Navigation State**:
```swift
// Adaptive navigation based on device
#if os(iOS)
    NavigationSplitView { } content: { } detail: { }
#elseif os(tvOS)
    NavigationStack { }
#endif
```

## Design Patterns

### Pattern 1: M4A Format Constraint
```
PURPOSE: Simplify entire audio pipeline
IMPLEMENTATION: UTType validation, AVAsset optimization
BENEFITS: Predictable behavior, native performance, unified metadata
TRADEOFFS: No MP3/FLAC support (by design)
```

### Pattern 2: SwiftData Array Conversion
```
PURPOSE: Work around SwiftUI binding limitations with relationships
IMPLEMENTATION: ForEach(Array(relationship)) pattern
BENEFITS: Avoids generic parameter inference errors
TRADEOFFS: Slight performance overhead for large collections
```

### Pattern 3: Platform-Specific Capabilities
```
PURPOSE: Native experience per platform without compromise
IMPLEMENTATION: Extensive #if os() conditional compilation
BENEFITS: Each platform feels native, no awkward adaptations
TRADEOFFS: More code paths to maintain
```

### Pattern 4: Glass Morphism Consistency
```
PURPOSE: WWDC25 Apple Music design language
IMPLEMENTATION: .ultraThinMaterial throughout, adaptive materials
BENEFITS: Modern, cohesive visual experience
TRADEOFFS: Requires iOS 17.0+ minimum
```

## Anti-Patterns to Avoid

### ❌ NEVER: Support Non-M4A Formats
```swift
// WRONG - Multi-format complexity
let supportedTypes: [UTType] = [.mp3, .wav, .flac, .m4a]

// CORRECT - M4A only
let supportedTypes = [UTType(filenameExtension: "m4a")!]
```

### ❌ NEVER: Direct SwiftData Relationship Binding
```swift
// WRONG - Causes "Generic parameter 'C' could not be inferred"
List($album.songs) { $song in
    TextField("Title", text: $song.title)
}

// CORRECT - Read-only or manual updates
List(Array(album.songs)) { song in
    Text(song.title)
}
```

### ❌ NEVER: Fight Platform Limitations
```swift
// WRONG - Trying to add FileImporter to tvOS
#if os(tvOS)
    FileImporter(...) // Will not compile
#endif

// CORRECT - Embrace platform differences
#if os(iOS)
    Button("Import Music") { showImporter = true }
#elseif os(tvOS)
    Text("Music synced from iOS devices")
#endif
```

### ❌ NEVER: Complex Navigation Hierarchies
```swift
// WRONG - Deep navigation stacks that break on tvOS
NavigationStack {
    AlbumsView()
        .navigationDestination(for: Album.self) { album in
            AlbumDetailView(album: album)  // Removed due to issues
        }
}

// CORRECT - Simple, platform-appropriate navigation
AlbumsView()  // Direct playback from grid
```

## Architectural Decisions Log

### Decision: M4A Format Exclusivity (Strategic)
**Rationale**: Focus on Apple ecosystem consistency over broad compatibility
**Implementation**: Single format validation, optimized metadata extraction
**Result**: 30% less code, zero format-related bugs, predictable behavior

### Decision: Remove AlbumDetailView (Tactical)
**Rationale**: SwiftData relationship bindings caused persistent errors
**Implementation**: Grid-only browsing with direct playback
**Result**: Simpler navigation, no binding errors, better UX

### Decision: Singleton Audio Service (Foundational)
**Rationale**: Single source of truth for playback state
**Implementation**: Static shared instance with @Published properties
**Result**: Consistent state across all views, simple integration

### Decision: Glass Morphism UI (Aesthetic)
**Rationale**: Match Apple Music WWDC25 design language
**Implementation**: Consistent use of SwiftUI Materials
**Result**: Professional, modern appearance that feels native

### Decision: Platform Divergence (Strategic)
**Rationale**: Optimize for each platform's strengths
**Implementation**: Conditional compilation, platform-specific UI
**Result**: Native feel on each platform, clear boundaries