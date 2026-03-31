# Terrific Carousel SDK for iOS SwiftUI

## Requirements

* **Swift:** 5.0
* **Minimum OS versions:**

  * iOS 17
  * macOS 14
  * tvOS 17

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
    storeId: <store_Id>,
    carouselId: <carousel_Id>
)
```

---

### `styleConfiguration` (Required)

Controls the visual appearance and dimensions of the carousel. You can use the default configuration or customize it.

> **Important:** The `CarouselView` determines its own size based on `styleConfiguration`. Do **NOT** wrap it in a `.frame()` modifier. All sizing should be done through `styleConfiguration` properties.

#### Structure

```swift
CarouselStyleConfiguration
├── feed: FeedStyleConfiguration      // Horizontal carousel (feed view)
└── detail: DetailStyleConfiguration  // Fullscreen vertical view
```

#### Key Size Properties (Feed)

The total height of the carousel is determined by these properties in `FeedStyleConfiguration`:

| Property | Default | Description |
|----------|---------|-------------|
| `carouselItemHeight` | 420 | Height of each carousel card |
| `carouselNameFont` | System 22 bold | Font for the carousel title label |
| `carouselNameBottomPadding` | 24 | Space below the carousel title |

**Total carousel height** ≈ `carouselNameFont.size` + `carouselNameBottomPadding` + `carouselItemHeight`

#### Using Default Configuration

```swift
let styleConfiguration = CarouselStyleConfiguration.default
```

#### Custom Configuration Example

```swift
let customFeedStyle = FeedStyleConfiguration(
    carouselItemWidth: 280,
    carouselItemHeight: 500,
    carouselItemSpacing: 20,
    cardCornerRadius: 12,
    titleFont: .system(size: 20, weight: .bold),
    subtitleFont: .system(size: 14, weight: .regular),
    carouselNameFont: .system(size: 24, weight: .heavy),
    carouselNameColor: .black,
    carouselNameBottomPadding: 16
)

let styleConfiguration = CarouselStyleConfiguration(
    feed: customFeedStyle
)
```

#### Using Custom Fonts

To use a custom font, the font must be bundled in your app (added to Info.plist under "Fonts provided by application").

```swift
// Using custom fonts with CarouselFontDescriptor
let customFeedStyle = FeedStyleConfiguration(
    carouselItemWidth: 260,
    carouselItemHeight: 450,
    // Custom font for title - include weight variant in font name
    titleFont: .custom("Avenir-Heavy", size: 18),
    // Custom font for subtitle
    subtitleFont: .custom("Avenir-Medium", size: 14),
    // Custom font for carousel name label
    carouselNameFont: .custom("Avenir-Black", size: 24),
    carouselNameColor: .primary
)

let styleConfiguration = CarouselStyleConfiguration(
    feed: customFeedStyle
)
```

> **Note:** For custom fonts, include the weight variant in the font name (e.g., `"Avenir-Heavy"`, `"Montserrat-Bold"`). The font file must be added to your app bundle and registered in Info.plist.

#### All FeedStyleConfiguration Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `carouselItemWidth` | CGFloat | 240 | Card width |
| `carouselItemHeight` | CGFloat | 420 | Card height |
| `carouselItemSpacing` | CGFloat | 18 | Space between cards |
| `carouselHorizontalPadding` | CGFloat | 16 | Edge padding |
| `cardCornerRadius` | CGFloat | 16 | Card corner radius |
| `cardSpacing` | CGFloat | 8 | Space between card and products |
| `timestampFont` | CarouselFontDescriptor | System 14 semibold | Timestamp font |
| `timestampPaddingHorizontal` | CGFloat | 10 | Timestamp horizontal padding |
| `timestampPaddingVertical` | CGFloat | 6 | Timestamp vertical padding |
| `timestampCornerRadius` | CGFloat | 8 | Timestamp badge corner radius |
| `timestampTopMargin` | CGFloat | 12 | Timestamp top margin |
| `timestampHorizontalMargin` | CGFloat | 12 | Timestamp horizontal margin |
| `titleFont` | CarouselFontDescriptor | System 18 bold | Title font |
| `subtitleFont` | CarouselFontDescriptor | System 16 regular | Subtitle font |
| `titleSubtitleSpacing` | CGFloat | 4 | Space between title and subtitle |
| `bottomInfoPaddingHorizontal` | CGFloat | 12 | Bottom info horizontal padding |
| `bottomInfoPaddingBottom` | CGFloat | 12 | Bottom info bottom padding |
| `carouselNameFont` | CarouselFontDescriptor | System 22 bold | Carousel label font |
| `carouselNameColor` | Color | .white | Carousel label color |
| `carouselNameBottomPadding` | CGFloat | 24 | Space below carousel label |
| `carouselNameHorizontalPadding` | CGFloat | 16 | Carousel label horizontal padding |

---

### `onAnalyticsEvent` (Optional)

Use this closure to listen for analytics events:

```swift
let onAnalyticsEvent: (AnalyticsEvent) -> Void = { event in
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
        storeId: <store_Id>,
        carouselId: <carousel_Id>
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
