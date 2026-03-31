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

Sets API data. Example for testing:

```swift
let apiConfiguration = APIConfiguration(
    baseURL: "https://terrific-staging-polls.web.app",
    storeId: "uO5g9yzOTkR39JFG3ORP",
    carouselId: "doS2DpZV4YIoYjR2YYQc",
    shopPageUrl: nil
)
```

### `styleConfiguration` (Required)

You can use the default style configuration or create a custom one:

```swift
let styleConfiguration = StyleConfiguration.default
```

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
        baseURL: "https://terrific-staging-polls.web.app",
        storeId: "uO5g9yzOTkR39JFG3ORP",
        carouselId: "doS2DpZV4YIoYjR2YYQc",
        shopPageUrl: nil
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
