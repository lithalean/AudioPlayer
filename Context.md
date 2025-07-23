## context.md

### objective
Build an Apple Music–style application for iOS and tvOS with full on-device library management.  
No subscriptions, no streaming, no radio, no online services.  
Exclusive support for m4a files (AAC lossy and ALAC lossless).  
Design fidelity is Apple Music WWDC25 style (sidebar, now playing bar, grid-based album view).  
Optimized for Darwin ARM64 (Apple Silicon).

---

### scope
- iOS: full local import, metadata editing, artwork replacement, playback.
- tvOS: playback only, focus-based navigation, no file import.
- macOS: deprioritized, but core playback works via Catalyst.

---

### architecture
- **audio engine**: AVAudioPlayer for initial stability; AVPlayer planned for gapless and background playback.
- **data layer**: SwiftData for persistent albums and songs.  
  - Album: id, name, artist, artworkData, [Song].  
  - Song: id, title, artist, album, duration, fileURL, isLossless (derived from ALAC detection).
- **metadata**: AVFoundation (AVAsset) used to read title, artist, albumName, artwork, duration, and ALAC flags.
- **import**: iOS FileImporter restricted to `.m4a`. Validation rejects all other formats.
- **library sync**: tvOS reads only pre-imported local library; no imports allowed.

---

### design
- Apple Music WWDC25 layout patterns.
- ultraThinMaterial for glass effects.
- adaptive grid: 3-6 columns on iOS, 4 columns tvOS.
- now playing: mini bar on iPhone, full bar on iPad, full-screen tvOS view.

---

### what we tried
1. **full format support (mp3, flac, wav)**  
   - rejected. objective narrowed to m4a-only for simplicity and Apple-like consistency.

2. **AlbumDetailView using SwiftData bindings**  
   - failed due to SwiftUI attempting to infer Bindings for PersistentArray relationships.  
   - repeated errors: Generic parameter 'C' could not be inferred, Binding<Data> expected.  
   - attempted solutions: direct ForEach on album.songs, coercion to Array, coercion to Set, compactMap, sorting.  
   - ultimate decision: removed album detail navigation entirely.

3. **cross-platform unified import (tvOS + iOS)**  
   - rejected. tvOS has no FileImporter support; restricted to playback only.

4. **complex navigation stacks**  
   - failed on tvOS due to focus issues and navigation bar incompatibilities.  
   - resolved by keeping grid-only toggle for albums.

5. **ALAC gapless playback with AVPlayer**  
   - tested, but inconsistencies in tvOS remote scrubbing. deferred until Phase 3.

---

### known issues
- SwiftData relationships remain fragile across ForEach and Lists; we use manual array conversion.
- tvOS grid performance degrades when artworkData is large; may need caching.
- AVAudioPlayer does not provide true gapless playback for ALAC; deferred to AVPlayer.

---

### current phase
Phase 2: local library management.  
Focus:  
- strict `.m4a` validation on import.  
- persistent SwiftData relationships.  
- metadata editing support (title, artist, album, artwork replacement).

---

### future
Phase 3 will address:  
- playlists (local only).  
- ALAC-to-AAC conversion option for storage optimization.  
- equalizer and DSP (Darwin ARM64 optimized).  
- gapless playback and crossfade.

---

### strict exclusions
- no cloud services.  
- no online metadata fetching.  
- no Apple Music integration or subscriptions.  
- no analytics or tracking.  
- no other audio formats.