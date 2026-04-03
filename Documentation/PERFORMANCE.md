# Performance Impact

This document describes the performance characteristics of TerrificCarouselSDK, including memory usage, network consumption, battery impact, and optimization strategies.

## Table of Contents

- [Overview](#overview)
- [Memory Usage](#memory-usage)
- [Network Usage](#network-usage)
- [Battery Impact](#battery-impact)
- [Startup Time Impact](#startup-time-impact)
- [Storage Usage](#storage-usage)
- [Performance Optimization](#performance-optimization)
- [Measured Benchmarks](#measured-benchmarks)
- [Troubleshooting Performance Issues](#troubleshooting-performance-issues)

---

## Overview

TerrificCarouselSDK is optimized for performance with:

| Aspect | Approach |
|--------|----------|
| Memory | Lazy loading, LRU cache eviction, video buffers released on deselection |
| Network | Request deduplication, caching |
| Battery | Video pauses when not visible, no background activity |
| CPU | Uses AVPlayer (hardware-accelerated by iOS) |

---

## Memory Usage

### Memory Behavior

| State | Behavior | Typical Memory |
|-------|----------|----------------|
| Carousel opened (images) | Images loaded on demand | ~50 MB |
| Scrolling carousel | Video loads for selected card only | ~150 MB |
| Detail view | Full video playback | ~250 MB |

> **Note:** The SDK uses memory-efficient video loading - videos only load for the currently selected card, and buffers are released when scrolling away.

### Memory Management

The SDK automatically manages memory:

```swift
// Automatic behaviors (no configuration needed)
- Images are cached with LRU eviction
- Off-screen content is released
- Video buffers are cleared when not playing
```

### Memory Limits

| Cache | Default Limit | Configurable |
|-------|---------------|--------------|
| Image memory cache | 50 MB (100 images max) | No |
| Image disk cache | 100 MB (7 days max age) | No |
| Video buffer | System managed | No |

---

## Network Usage

### Network Optimization Features

#### Request Deduplication

```swift
// Multiple views requesting same image = 1 network request
CachedAsyncImage(url: imageURL) // Request #1
CachedAsyncImage(url: imageURL) // Reuses request #1
```

#### Caching Strategy

```
┌─────────────────────────────────────────────────┐
│                  Request Flow                    │
├─────────────────────────────────────────────────┤
│  1. Check memory cache (instant)                │
│  2. Check disk cache (~10ms)                    │
│  3. Network request (variable)                  │
│  4. Store in caches for future use              │
└─────────────────────────────────────────────────┘
```

---

## Battery Impact

### Battery Consumption by Activity

| Activity | Battery Impact | Duration Typical |
|----------|----------------|------------------|
| Idle (carousel visible) | Minimal | Indefinite |
| Scrolling | Low | Seconds |
| Image loading | Low | Seconds |
| Video preview (muted) | Medium | Seconds |
| Full video playback | Medium-High | Minutes |
| Background | None | N/A |

### Battery Optimization Features

1. **No Background Activity**
   - SDK performs no work when app is backgrounded
   - No background fetch or refresh

2. **Efficient Video Playback**
   - Hardware-accelerated decoding (AVPlayer)
   - Pauses when not visible

3. **Lazy Loading**
   - Content loaded only when needed
   - Off-screen content not processed

4. **No Location Services**
   - GPS not used
   - No continuous location updates

---

## Startup Time Impact

### SDK Initialization

- **Lazy initialization**: CarouselView only initializes when added to view hierarchy
- **No app launch work**: No static initializers or app delegate hooks required
- **Cached content**: Subsequent views load faster from cache

---

## Storage Usage

### Disk Space Usage

| Component | Max Size | Location |
|-----------|----------|----------|
| SDK binary | Varies | App bundle |
| Image disk cache | 100 MB | Caches directory |
| User preferences | Minimal | UserDefaults |

### Cache Location

```
App Sandbox/
├── Library/
│   ├── Caches/
│   │   └── ImageCache/           # Disk image cache
│   └── Preferences/
│       └── [BundleID].plist      # UserDefaults (preferences)
```

---

## Performance Optimization

### Automatic Optimizations

The SDK performs these optimizations automatically:

| Optimization | Benefit |
|--------------|---------|
| Request deduplication | Multiple views requesting same image = 1 network request |
| Image prefetching | Adjacent images loaded ahead of time |
| LRU cache eviction | Prevents unbounded memory/disk growth |

---

## Measured Benchmarks

The following measurements were collected using Xcode Instruments on a Mac (Designed for iPad) build.

### Test Scenarios

| Scenario | Memory | Network (received) | Notes |
|----------|--------|-------------------|-------|
| Carousel opened (horizontal) | 50 MB (peak: 107 MB) | 0.4 MB | Initial load, images only |
| Scrolling through carousel (10 items) | 148 MB (peak: 160 MB) | 3.5 MB | Videos load only for selected card |
| Detail view (10 items) | 249 MB (peak: 270 MB) | 73 MB | Full videos downloaded per item |

---

## Troubleshooting Performance Issues

### High Memory Usage

**Symptoms:** App crashes, memory warnings

**Possible Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Large images | Verify source images are appropriately sized |
| Memory leak | Update to latest SDK version |
| Too many carousels | Use single CarouselView instance |
| Other app components | Profile with Instruments |

### Slow Loading

**Symptoms:** Long loading times, skeleton visible too long

**Possible Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Slow network | Check user's connection; SDK shows skeleton |
| Large assets | Contact Terrific to optimize content |
| Cold start | First load is slower; subsequent loads use cache |
| Server issues | Try again later |

### Scroll Jank

**Symptoms:** Stuttering during scroll, dropped frames

**Possible Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Large images | Verify source images are appropriately sized |
| Complex view hierarchy | Simplify parent views |
| Main thread blocking | Profile with Instruments; check app code |
| Old device | Expected on older devices; consider simpler layouts |

### High Battery Drain

**Symptoms:** Battery drains quickly when using carousel

**Possible Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| Video autoplay | Videos only play when visible |
| Network requests | Check for request loops in network profiler |
| Other app features | Profile entire app, not just SDK |

### Debug Checklist

- [ ] Using latest SDK version?
- [ ] Tested on multiple devices?
- [ ] Profiled with Instruments?
- [ ] Checked network conditions?
- [ ] Verified content size (images/videos)?
- [ ] Tested with minimal app (SDK only)?
