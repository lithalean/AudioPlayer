## Spacing System

| Token | Value | Usage | Example |
|-------|-------|-------|---------|
| **micro** | 2pt | Inline adjustments | Icon-to-text |
| **mini** | 4pt | Compact spacing | Badge padding |
| **small** | 8pt | Component internal | Button padding |
| **medium** | 16pt | Component margins | Card spacing |
| **large** | 24pt | Section spacing | Group separation |
| **xlarge** | 32pt | Major sections | Header spacing |
| **huge** | 48pt | View margins | Safe area insets |

### Adaptive Spacing
```swift
// Platform-specific adjustments
#if os(tvOS)
    let gridSpacing: CGFloat = 40  // Larger for focus
#else
    let gridSpacing: CGFloat = 20  // Standard touch
#endif
```

## Component Specifications

### Album Grid Card
```yaml
structure:
  container:
    minWidth: 150pt
    maxWidth: 250pt
    spacing: 8pt (artwork to text)
    
  artwork:
    aspectRatio: 1.0 (square)
    cornerRadius: 12pt (iOS), 16pt (tvOS)
    shadow: 
      color: .black.opacity(0.15)
      radius: 8pt
      x: 0pt
      y: 4pt
    
  title:
    font: .title3 (iOS), .title2 (tvOS)
    color: .primary
    lineLimit: 2
    truncationMode: .tail
    
  artist:
    font: .subheadline
    color: .secondary
    lineLimit: 1
    opacity: 0.8

states:
  default:
    scale: 1.0
    shadow: standard
    
  hover: # macOS only
    scale: 1.02
    shadow: elevated
    animation: .spring(response: 0.3)
    
  pressed:
    scale: 0.98
    opacity: 0.8
    
  focused: # tvOS
    scale: 1.1
    shadow: 
      radius: 20pt
      y: 10pt
    parallax: enabled
```

### Glass Sidebar
```yaml
dimensions:
  width:
    compact: 68pt (icon only)
    regular: 220pt (icon + label)
    
appearance:
  background: .ultraThinMaterial
  borderRight: Color.separator.opacity(0.3)
  
items:
  height: 44pt
  padding: 
    horizontal: 16pt
    vertical: 10pt
  cornerRadius: 8pt
  
  selected:
    background: Color.accentColor.opacity(0.15)
    fontWeight: .semibold
    
  hover:
    background: Color.primary.opacity(0.05)
```

### Audio Playback Bar

#### Mini Bar (iPhone)
```yaml
dimensions:
  height: 64pt
  padding: 8pt
  
layout:
  - albumArt: 48x48pt, cornerRadius: 8pt
  - info: flexible width, 2 lines
  - playButton: 44x44pt
  
appearance:
  background: .ultraThinMaterial
  border: top 0.5pt separator
  
animations:
  appear: slide + fade (0.3s)
  playStateChange: .symbolEffect(.bounce)
```

#### Full Bar (iPad/Mac)
```yaml
dimensions:
  height: 88pt
  padding: 16pt
  
layout:
  - albumArt: 64x64pt, cornerRadius: 10pt
  - info: 200pt min width
  - scrubber: flexible width
  - controls: 200pt fixed
  - volume: 120pt
  
appearance:
  background: .ultraThinMaterial
  separators: .separator.opacity(0.2)
  
controls:
  playButton: 
    size: 48pt
    symbols: play.fill / pause.fill
  skipButtons:
    size: 32pt
    symbols: backward.fill / forward.fill
  volumeSlider:
    track: 4pt height
    thumb: 20pt
```

#### tvOS Full Screen
```yaml
background:
  blurredArtwork: full screen
  darkOverlay: 0.4 opacity
  
layout:
  artwork:
    size: 300x300pt
    cornerRadius: 24pt
    shadow: large elevated
    position: center, -100pt from top
    
  info:
    position: below artwork, 40pt gap
    alignment: center
    title: .largeTitle
    artist: .title2
    
  controls:
    position: bottom safe area + 60pt
    playButton: 80pt
    skipButtons: 60pt
    spacing: 60pt
    
  progressBar:
    position: bottom safe area + 20pt
    height: 6pt
    endcaps: rounded
```

### Glass Button Style
```swift
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
```

## Animation Specifications

### Standard Transitions
```swift
// Grid item appearance
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 1.2).combined(with: .opacity)
))
.animation(.spring(response: 0.4, dampingFraction: 0.8))

// Navigation transitions
.navigationTransition(.slide)

// Sheet presentations
.presentationDetents([.medium, .large])
.presentationDragIndicator(.visible)
.presentationBackground(.regularMaterial)
```

### Interactive Animations
```swift
// Play button state change
Image(systemName: isPlaying ? "pause.fill" : "play.fill")
    .symbolEffect(.bounce, value: isPlaying)

// Loading states
ProgressView()
    .progressViewStyle(.circular)
    .scaleEffect(0.8)
    .tint(.accentColor)

// Focus animations (tvOS)
.focusEffect(.lift)
.animation(.smooth(duration: 0.2), value: isFocused)
```

## Platform-Specific Adaptations

### iOS Adaptations
```yaml
grid_columns:
  compact_portrait: 3
  compact_landscape: 4-5
  regular: 4-6
  
safe_areas:
  respect: true
  additional_padding: 0
  
gestures:
  swipe_down: dismiss sheet
  long_press: context menu
  pinch: future zoom
```

### iPadOS Enhancements
```yaml
sidebar:
  style: prominent
  default: visible
  
multitasking:
  split_view: supported
  slide_over: supported
  
pointer:
  hover_effects: enabled
  cursor_adaptation: true
```

### tvOS Specifics
```yaml
focus_engine:
  clip_to_bounds: false
  focus_scale: 1.1
  parallax: enabled
  
remote_control:
  play_pause: center button
  skip: left/right
  menu: back navigation
  
margins:
  safe_area: 60pt
  between_items: 40pt
```

### macOS (Catalyst)
```yaml
window:
  min_size: 800x600
  title_bar: hidden
  
sidebar:
  style: source_list
  width: 250pt
  
traffic_lights:
  position: custom
  inset: 20pt
```

## Glass Effects Implementation

### Material Hierarchy
1. **Ultra Thin**: Navigation bars, sidebars (subtle)
2. **Thin**: Overlays, popovers (balanced)
3. **Regular**: Sheets, modals (prominent)
4. **Thick**: Full-screen overlays (heavy)

### Dark Mode Adjustments
```swift
@Environment(\.colorScheme) var colorScheme

var glassTint: Color {
    colorScheme == .dark 
        ? Color.black.opacity(0.2)
        : Color.white.opacity(0.3)
}
```

## Performance Optimizations

### Artwork Rendering
```swift
// Thumbnail size for grid
let thumbnailSize = CGSize(width: 300, height: 300)

// Lazy loading in grid
LazyVGrid(columns: columns) {
    ForEach(albums) { album in
        AlbumCard(album: album)
            .task {
                await album.loadArtworkIfNeeded()
            }
    }
}
```

### Blur Performance
- Use `.ultraThinMaterial` sparingly
- Cache blurred backgrounds
- Disable on low-power mode
- Reduce blur radius on older devices

## Accessibility

### Dynamic Type
- All text respects Dynamic Type
- Minimum sizes enforced
- Layout adapts to larger text

### Color Contrast
- WCAG AA compliance minimum
- High contrast mode support
- Sufficient contrast on glass

### VoiceOver
- All interactive elements labeled
- Playback state announcements
- Navigation hints provided# AudioPlayer Visual Design Context

**Purpose**: Complete visual design system and UI specifications  
**Version**: 1.0  
**Design Language**: Apple Music WWDC25 Glass Morphism  
**Last Updated**: 2025-08-01

## Visual Hierarchy
```
Z-LAYERS (back→front):
├─[0] Background (.systemBackground)
├─[1] Content Layer (albums, songs, artwork)
├─[2] Glass Overlays (.ultraThinMaterial)
├─[3] Controls (buttons, bars, interactive)
└─[4] Sheets/Modals (.regularMaterial)
```

## Design Philosophy

### Core Principles
1. **Glass Morphism**: Extensive use of SwiftUI Materials for depth
2. **Content First**: UI recedes, music library takes focus
3. **Platform Native**: Respect each platform's design language
4. **Smooth Performance**: 60fps scrolling even with large artwork
5. **Adaptive Layouts**: Responsive to device size and orientation

### Material Usage Strategy
```swift
// Primary glass effect for bars and backgrounds
.background(.ultraThinMaterial)

// Secondary for overlays and sheets
.background(.regularMaterial)

// Thick material for modal backgrounds
.background(.thickMaterial)

// Adaptive based on color scheme
.background(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.8 : 0.9))
```

## Color System

| Element | Light Mode | Dark Mode | Implementation |
|---------|------------|-----------|----------------|
| **Primary Background** | .systemBackground | .systemBackground | Adaptive |
| **Secondary Background** | .secondarySystemBackground | .secondarySystemBackground | Lists/cells |
| **Glass Tint** | .white.opacity(0.7) | .black.opacity(0.3) | Material overlays |
| **Accent** | .accentColor | .accentColor | Interactive elements |
| **Text Primary** | .primary | .primary | Titles, important |
| **Text Secondary** | .secondary | .secondary | Subtitles, metadata |
| **Dividers** | .separator | .separator | List separators |
| **Album Placeholder** | .systemGray3 | .systemGray5 | Missing artwork |

### Dynamic Colors
```swift
// Adaptive tint for glass effects
extension Color {
    static var glassBackground: Color {
        Color(uiColor: .systemBackground).opacity(0.001)
    }
    
    static var glassOverlay: Color {
        Color(uiColor: .tertiarySystemBackground)
    }
}
```

## Typography System

### Scale & Usage
| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| **Large Title** | 34pt | .bold | 41pt | View headers (Albums, Songs) |
| **Title 1** | 28pt | .bold | 34pt | Sheet titles |
| **Title 2** | 22pt | .semibold | 28pt | Section headers |
| **Title 3** | 20pt | .semibold | 24pt | Album/song titles in grid |
| **Headline** | 17pt | .semibold | 22pt | Emphasized UI elements |
| **Body** | 17pt | .regular | 22pt | General text, lyrics |
| **Callout** | 16pt | .regular | 21pt | Playback info |
| **Subheadline** | 15pt | .regular | 20pt | Artist names |
| **Footnote** | 13pt | .regular | 18pt | Metadata, durations |
| **Caption 1** | 12pt | .regular | 16pt | Timestamps |
| **Caption 2** | 11pt | .regular | 13pt | Tertiary info |

### Platform Adaptations
```swift
// iOS/iPadOS
.font(.title3)  // Album titles
.font(.subheadline)  // Artist names

// tvOS (larger for TV distance)
.font(.title)  // Album titles  
.font(.headline)  // Artist names

// Monospaced for durations
.font(.system(.footnote, design: .monospaced))