# Integration Guide

This guide provides detailed instructions for integrating TerrificCarouselSDK into your iOS, macOS, or tvOS application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Basic Setup](#basic-setup)
- [Configuration Options](#configuration-options)
- [Lifecycle Management](#lifecycle-management)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Requirements

| Requirement | Minimum Version |
|-------------|-----------------|
| Xcode | 15.0+ |
| Swift | 5.0+ |
| iOS | 17.0+ |
| macOS | 14.0+ |
| tvOS | 17.0+ |

### Before You Begin

You will need:

1. **Store ID** - Your unique store identifier from Terrific dashboard
2. **Carousel ID** - The specific carousel you want to display

---

## Installation

### Swift Package Manager (Recommended)

#### Using Xcode

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL:
   ```
   https://github.com/terrific-live/carousels-ios-swiftui-sdk.git
   ```
4. Select version rule: **Up to Next Major Version**
5. Click **Add Package**
6. Select `TerrificCarouselSDK` and add to your target

### Verify Installation

```swift
import TerrificCarouselSDK

// If this compiles, installation is successful
let _ = CarouselStyleConfiguration.default
```

---

## Basic Setup

### Step 1: Import the SDK

```swift
import SwiftUI
import TerrificCarouselSDK
```

### Step 2: Create API Configuration

```swift
let apiConfiguration = APIConfiguration(
    storeId: "your_store_id",
    carouselId: "your_carousel_id"
)
```

### Step 3: Add CarouselView

```swift
struct ContentView: View {
    var body: some View {
        CarouselView(
            apiConfiguration: APIConfiguration(
                storeId: "your_store_id",
                carouselId: "your_carousel_id"
            )
        )
    }
}
```

### Complete Basic Example

```swift
import SwiftUI
import TerrificCarouselSDK

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to Our Store")
                .font(.title)
                .padding()

            CarouselView(
                apiConfiguration: APIConfiguration(
                    storeId: "store_abc123",
                    carouselId: "carousel_xyz789"
                ),
                styleConfiguration: .default,
                onAnalyticsEvent: { event in
                    print("Analytics event: \(event)")
                }
            )

            Spacer()
        }
    }
}
```

---

## Configuration Options

### APIConfiguration

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `storeId` | String | Yes | Your store identifier |
| `carouselId` | String | Yes | Carousel to display |
| `baseURL` | String? | No | Override API endpoint (testing only) |

```swift
// Production configuration
let prodConfig = APIConfiguration(
    storeId: "store_abc123",
    carouselId: "carousel_xyz789"
)

// Staging/Testing configuration
let stagingConfig = APIConfiguration(
    storeId: "test_store",
    carouselId: "test_carousel",
    baseURL: "https://staging-api.terrific.live"
)
```

### CarouselStyleConfiguration

Controls visual appearance. See [Style Configuration Guide](STYLING.md) for full reference.

```swift
// Use defaults
let defaultStyle = CarouselStyleConfiguration.default

// Custom feed style
let customStyle = CarouselStyleConfiguration(
    feed: FeedStyleConfiguration(
        carouselItemWidth: 280,
        carouselItemHeight: 480,
        carouselItemSpacing: 16,
        cardCornerRadius: 12
    )
)
```

### Analytics Callback

```swift
CarouselView(
    apiConfiguration: config,
    onAnalyticsEvent: { event in
        // Handle analytics events
        // See ANALYTICS.md for complete event reference
        print("Event: \(event)")
    }
)
```

For complete analytics events reference, see [Analytics Events](ANALYTICS.md).

---

## Lifecycle Management

### SwiftUI Lifecycle

The SDK automatically handles:
- View appearance/disappearance
- Video playback pause/resume
- Memory cleanup on disappear

```swift
struct ContentView: View {
    var body: some View {
        CarouselView(apiConfiguration: config)
            // SDK handles these automatically:
            // .onAppear { } - Loads content
            // .onDisappear { } - Pauses video, cleans up
    }
}
```

---

## Troubleshooting

### Common Issues

#### Carousel Not Appearing

```swift
// Ensure you're not constraining height
// BAD:
CarouselView(apiConfiguration: config)
    .frame(height: 200) // Don't do this!

// GOOD:
CarouselView(apiConfiguration: config)
// Let the SDK determine its own height
```
