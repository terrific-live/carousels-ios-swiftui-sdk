# Terrific Carousel SDK for iOS SwiftUI

## Requirements

* **Xcode:** 15.0+
* **Swift:** 5.0+
* **Minimum OS versions:**

  * iOS 17
  * macOS 14
  * tvOS 17

---

## Documentation

| Document | Description |
|----------|-------------|
| [Integration Guide](Documentation/INTEGRATION.md) | Detailed setup, SwiftUI/UIKit patterns |
| [Style Configuration](Documentation/STYLING.md) | All style properties for feed, detail, poll, fonts |
| [Analytics Events](Documentation/ANALYTICS.md) | Complete analytics events reference |
| [Privacy & Data Collection](Documentation/PRIVACY.md) | Privacy manifest, App Store labels, data collection |
| [GDPR Compliance](Documentation/GDPR.md) | Consent integration, user rights, data processing |
| [Performance Impact](Documentation/PERFORMANCE.md) | Memory, network, battery usage and optimization |

---

## Swift Package Manager (SPM) Integration

You can integrate `carousels-ios-swiftui-sdk` into your project using Swift Package Manager.

### Using Xcode

1. Open your project in **Xcode**.
2. Go to **File → Add Packages...**
3. Enter the package URL:

   ```
   https://github.com/terrific-live/carousels-ios-swiftui-sdk.git
   ```
4. Select **Up to Next Major** version rule.
5. Add the package to your app target’s **Package Dependencies** list.

Once added, import the SDK into your Swift files:

```swift
import TerrificCarouselSDK
```

---

## Initialization

The `CarouselView` requires the following parameters:

### `apiConfiguration` (Required)

Defines how the SDK connects to your backend.

#### Parameters

* **`storeId` (Required)**
  Unique identifier of your store.

* **`carouselId` (Required)**
  Identifier of the carousel you want to display.

* **`baseURL` (Optional)**

  * Used to override the default API endpoint.
  * **Do NOT set in production** (SDK uses the default production environment automatically).
  * **Set only for testing/staging environments**.

#### Example

```swift
let apiConfiguration = APIConfiguration(
    storeId: "your_store_id",
    carouselId: "your_carousel_id"
)
```

---

### `styleConfiguration` (Optional)

Controls the visual appearance and dimensions of the carousel. Use `.default` for standard styling or create a custom configuration.

```swift
let styleConfiguration = CarouselStyleConfiguration.default
```

For custom styling (sizes, fonts, colors), see [Style Configuration Details](#style-configuration-details) below.

---

### `onAnalyticsEvent` (Optional)

Use this closure to listen for analytics events:

```swift
let onAnalyticsEvent: (CarouselAnalyticsEvent) -> Void = { event in
    switch event {
    case .assetLiked(asset: _):
        debugPrint("Track asset liked event")
    default:
        break
    }
}
```

---

## Quick Example

```swift
CarouselView(
    apiConfiguration: APIConfiguration(
        storeId: "your_store_id",
        carouselId: "your_carousel_id"
    ),
    styleConfiguration: .default,
    onAnalyticsEvent: { event in
        switch event {
        case .assetLiked(asset: _):
            debugPrint("Track asset liked event")
        default:
            break
        }
    }
)
```

---

## Running the Example App

The SDK includes a fully functional example app demonstrating all features.

### Steps to Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/terrific-live/carousels-ios-swiftui-sdk.git
   cd carousels-ios-swiftui-sdk
   ```

2. **Open the example project:**
   ```bash
   open Example/CarouselDemo/CarouselDemo.xcodeproj
   ```

3. **Build and run** the `CarouselDemo` target on a simulator or device.

The example app references the SDK as a local package, so any changes to the SDK source will be reflected immediately when you rebuild.

---

## Style Configuration Details

> **Important:** The `CarouselView` determines its own size based on `styleConfiguration`. Do **NOT** wrap it in a `.frame()` modifier.

For complete styling documentation, see [Style Configuration Guide](Documentation/STYLING.md).

### Quick Reference

```swift
CarouselStyleConfiguration
├── feed: FeedStyleConfiguration      // Horizontal carousel
│   └── poll: PollStyleConfiguration  // Poll styling in feed
└── detail: DetailStyleConfiguration  // Fullscreen view
    └── poll: PollStyleConfiguration  // Poll styling in detail
```

### Total Height Calculation

| Property | Default | Description |
|----------|---------|-------------|
| `carouselNameFont.size` | 22 | Height of the carousel title label |
| `carouselNameBottomPadding` | 24 | Space below the carousel title |
| `carouselItemHeight` | 420 | Height of each carousel card |

**Total Height** = `carouselNameFont.size` + `carouselNameBottomPadding` + `carouselItemHeight` = **466 points** (default)

### Example

```swift
let styleConfiguration = CarouselStyleConfiguration(
    feed: FeedStyleConfiguration(
        carouselItemWidth: 280,
        carouselItemHeight: 500,
        cardCornerRadius: 12,
        titleFont: .system(size: 20, weight: .bold)
    )
)

CarouselView(
    apiConfiguration: config,
    styleConfiguration: styleConfiguration
)
```

---

## Support

- **Documentation**: See [Documentation](#documentation) section above
- **Issues**: [GitHub Issues](https://github.com/terrific-live/carousels-ios-swiftui-sdk/issues)

---

## License

Copyright (c) Terrific. All rights reserved.
