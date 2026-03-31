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

You can use the default style configuration or create a custom one:

```swift
let styleConfiguration = StyleConfiguration.default
```

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
