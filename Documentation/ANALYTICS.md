# Analytics Events Reference

This document provides a complete reference for all analytics events emitted by TerrificCarouselSDK.

## Table of Contents

- [Overview](#overview)
- [Receiving Events](#receiving-events)
- [Event Types](#event-types)
  - [Carousel Lifecycle Events](#carousel-lifecycle-events)
  - [Asset View Events](#asset-view-events)
  - [Detail View Events](#detail-view-events)
  - [User Action Events](#user-action-events)
- [Data Types](#data-types)
- [Event Summary Table](#event-summary-table)

---

## Overview

The SDK emits analytics events for user interactions and carousel lifecycle. These events allow you to:

- Track user engagement
- Measure content performance
- Integrate with your analytics platform
- Build custom reporting

### Event Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        Carousel Lifecycle                        │
├─────────────────────────────────────────────────────────────────┤
│  carouselLoaded → carouselViewed → carouselClicked              │
│                         ↓                                        │
│                   timelineOpened                                 │
│                         ↓                                        │
│              assetViewed / assetViewStarted                      │
│                         ↓                                        │
│  assetLiked / assetShared / ctaButtonClicked / productClicked / pollVoted │
│                         ↓                                        │
│                   assetViewEnded                                 │
│                         ↓                                        │
│                   timelineClosed                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Receiving Events

### How Analytics Work

| Component | Behavior |
|-----------|----------|
| SDK Internal | Always sends pseudonymous analytics to Terrific servers (cannot be disabled) |
| `onAnalyticsEvent` callback | **Optional** - lets you also receive events for your own analytics (Firebase, Mixpanel, etc.) |

The callback does **not** control whether Terrific receives analytics - it only allows you to also receive the same events.

### Data Sent to Terrific Servers

The SDK sends the following data to Terrific servers for each event:

| Data | Description |
|------|-------------|
| Event name | Event type (e.g., `timelineOpened`, `timelineAssetViewed`) |
| User ID | Terrific-generated identifier |
| Session ID | Carousel ID or carousel~asset combination |
| Store ID | Your store identifier (in request header) |
| User Agent | App version and OS version |
| Parent URL | URL context where carousel is embedded |
| Position | Asset position in carousel |
| Brand/Campaign | Content metadata |
| View Duration | Time spent viewing (for view events) |
| Product Info | Product details if applicable |

See [GDPR.md](GDPR.md) for complete data collection details.

### Basic Setup

```swift
CarouselView(
    apiConfiguration: APIConfiguration(
        storeId: "your_store_id",
        carouselId: "your_carousel_id"
    ),
    onAnalyticsEvent: { event in
        // Forward to YOUR analytics (Firebase, Mixpanel, etc.)
        // Terrific already received this event internally
        print("Event received: \(event)")
    }
)
```

### Comprehensive Handler

```swift
func handleAnalyticsEvent(_ event: CarouselAnalyticsEvent) {
    switch event {
    // Carousel Lifecycle
    case .carouselLoaded(let assets):
        handleCarouselLoaded(assets)

    case .carouselViewed(let assets):
        handleCarouselViewed(assets)

    case .carouselClicked(let asset, let position):
        handleCarouselClicked(asset, position: position)

    // Asset View Events
    case .assetViewed(let asset, let position, let isInitialView):
        handleAssetViewed(asset, position: position, isInitial: isInitialView)

    case .assetViewStarted(let asset, let position):
        handleAssetViewStarted(asset, position: position)

    case .assetViewEnded(let asset, let position, let durationMs):
        handleAssetViewEnded(asset, position: position, duration: durationMs)

    // Detail View Events
    case .timelineOpened(let parentUrl):
        handleTimelineOpened(parentUrl)

    case .timelineClosed(let parentUrl, let durationMs):
        handleTimelineClosed(parentUrl, duration: durationMs)

    // User Action Events
    case .assetLiked(let asset):
        handleAssetLiked(asset)

    case .assetShared(let asset, let position):
        handleAssetShared(asset, position: position)

    case .ctaButtonClicked(let asset, let position, let targetUrl):
        handleCtaClicked(asset, position: position, url: targetUrl)

    case .pollVoted(let asset, let position, let pollId, let answer):
        handlePollVoted(asset, position: position, pollId: pollId, answer: answer)

    case .productClicked(let asset, let product, let position, let targetUrl):
        handleProductClicked(asset, product: product, position: position, url: targetUrl)
    }
}
```

---

## Event Types

### Carousel Lifecycle Events

#### `carouselLoaded`

Fired when carousel data is successfully loaded from the API.

| Parameter | Type | Description |
|-----------|------|-------------|
| `assets` | `[CarouselAsset]` | All assets loaded in the carousel |

```swift
case .carouselLoaded(let assets):
    Analytics.track("carousel_loaded", properties: [
        "asset_count": assets.count,
        "asset_types": assets.map { $0.type.rawValue }
    ])
```

**When fired:** After successful API response, before content is displayed.

---

#### `carouselViewed`

Fired when the carousel becomes visible on screen.

| Parameter | Type | Description |
|-----------|------|-------------|
| `assets` | `[CarouselAsset]` | All assets currently in the carousel |

```swift
case .carouselViewed(let assets):
    Analytics.track("carousel_viewed", properties: [
        "asset_count": assets.count
    ])
```

**When fired:** When carousel view appears on screen (via `onAppear`).

---

#### `carouselClicked`

Fired when user taps on an asset to open the detail view.

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The tapped asset |
| `position` | `Int` | Position of the asset (0-indexed) |

```swift
case .carouselClicked(let asset, let position):
    Analytics.track("carousel_clicked", properties: [
        "asset_id": asset.id,
        "asset_title": asset.title ?? "",
        "position": position,
        "asset_type": asset.type.rawValue
    ])
```

**When fired:** When user taps an asset card in the feed view.

---

### Asset View Events

#### `assetViewed`

Fired when an asset becomes visible (in feed or detail view).

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The viewed asset |
| `position` | `Int` | Position of the asset (0-indexed) |
| `isInitialView` | `Bool` | `true` if visible from start, `false` if scrolled into view |

```swift
case .assetViewed(let asset, let position, let isInitialView):
    Analytics.track("asset_viewed", properties: [
        "asset_id": asset.id,
        "position": position,
        "is_initial": isInitialView,
        "asset_type": asset.type.rawValue
    ])
```

**When fired:** When asset enters the visible area.

---

#### `assetViewStarted`

Fired when user starts viewing an asset in detail view (for duration tracking).

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The asset being viewed |
| `position` | `Int` | Position of the asset (0-indexed) |

```swift
case .assetViewStarted(let asset, let position):
    Analytics.track("asset_view_started", properties: [
        "asset_id": asset.id,
        "position": position
    ])
```

**When fired:** When asset becomes the focused/selected item in detail view.

---

#### `assetViewEnded`

Fired when user stops viewing an asset in detail view.

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The asset that was viewed |
| `position` | `Int` | Position of the asset (0-indexed) |
| `durationMs` | `Int` | How long the asset was viewed (milliseconds) |

```swift
case .assetViewEnded(let asset, let position, let durationMs):
    Analytics.track("asset_view_ended", properties: [
        "asset_id": asset.id,
        "position": position,
        "duration_ms": durationMs,
        "duration_seconds": Double(durationMs) / 1000.0
    ])
```

**When fired:** When user scrolls away from asset or closes detail view.

---

### Detail View Events

#### `timelineOpened`

Fired when the detail view (fullscreen timeline) is opened.

| Parameter | Type | Description |
|-----------|------|-------------|
| `parentUrl` | `String` | The parent URL context |

```swift
case .timelineOpened(let parentUrl):
    Analytics.track("timeline_opened", properties: [
        "parent_url": parentUrl
    ])
```

**When fired:** When fullscreen detail view is presented.

---

#### `timelineClosed`

Fired when the detail view is closed.

| Parameter | Type | Description |
|-----------|------|-------------|
| `parentUrl` | `String` | The parent URL context |
| `durationMs` | `Int` | Total time the detail view was open (milliseconds) |

```swift
case .timelineClosed(let parentUrl, let durationMs):
    Analytics.track("timeline_closed", properties: [
        "parent_url": parentUrl,
        "duration_ms": durationMs,
        "duration_seconds": Double(durationMs) / 1000.0
    ])
```

**When fired:** When user dismisses the fullscreen detail view.

---

### User Action Events

#### `assetLiked`

Fired when user likes an asset.

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The liked asset |

```swift
case .assetLiked(let asset):
    Analytics.track("asset_liked", properties: [
        "asset_id": asset.id,
        "asset_title": asset.title ?? "",
        "asset_type": asset.type.rawValue
    ])
```

**When fired:** When user taps the like button.

---

#### `assetShared`

Fired when user shares an asset.

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The shared asset |
| `position` | `Int` | Position of the asset (0-indexed) |

```swift
case .assetShared(let asset, let position):
    Analytics.track("asset_shared", properties: [
        "asset_id": asset.id,
        "position": position,
        "asset_type": asset.type.rawValue
    ])
```

**When fired:** When user taps the share button.

---

#### `ctaButtonClicked`

Fired when user clicks a CTA (Call-to-Action) button.

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The asset containing the CTA |
| `position` | `Int` | Position of the asset (0-indexed) |
| `targetUrl` | `String` | The URL the CTA navigates to |

```swift
case .ctaButtonClicked(let asset, let position, let targetUrl):
    Analytics.track("cta_clicked", properties: [
        "asset_id": asset.id,
        "position": position,
        "target_url": targetUrl,
        "campaign": asset.campaignName ?? ""
    ])
```

**When fired:** When user taps a CTA button on an asset.

---

#### `pollVoted`

Fired when user votes on a poll.

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The asset containing the poll |
| `position` | `Int` | Position of the asset (0-indexed) |
| `pollId` | `String` | The poll identifier |
| `answer` | `String` | The selected answer text |

```swift
case .pollVoted(let asset, let position, let pollId, let answer):
    Analytics.track("poll_voted", properties: [
        "asset_id": asset.id,
        "position": position,
        "poll_id": pollId,
        "answer": answer
    ])
```

**When fired:** When user selects an answer in a poll.

---

#### `productClicked`

Fired when user clicks a product CTA button within a timeline asset.

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | `CarouselAsset` | The asset containing the product |
| `product` | `CarouselProduct` | The clicked product |
| `position` | `Int` | Position of the asset (0-indexed) |
| `targetUrl` | `String` | The URL the product CTA navigates to |

```swift
case .productClicked(let asset, let product, let position, let targetUrl):
    Analytics.track("product_clicked", properties: [
        "asset_id": asset.id,
        "product_id": product.id,
        "product_name": product.name ?? "",
        "position": position,
        "target_url": targetUrl,
        "price": product.price ?? ""
    ])
```

**When fired:** When user taps a CTA button on a product within an asset.

**Server payload:** This event sends additional data to Terrific servers including:
- `terrificClickId`: Unique UUID for click attribution
- `itemViewSource`: "featuredItem"
- Complete product data (name, description, price, image URL, brand, campaign)

---

## Data Types

### CarouselAsset

Public representation of an asset in the carousel.

```swift
public struct CarouselAsset: Identifiable, Sendable {
    /// Unique identifier for the asset
    public let id: String

    /// Display title
    public let title: String?

    /// Description text
    public let description: String?

    /// Type of asset (image, video, poll, ad)
    public let type: CarouselAssetType

    /// Position in the carousel (0-indexed)
    public let position: Int

    /// Timestamp of the asset
    public let timestamp: Date?

    /// Brand name associated with the asset
    public let brandName: String?

    /// Campaign name associated with the asset
    public let campaignName: String?
}
```

### CarouselAssetType

```swift
public enum CarouselAssetType: String, Sendable {
    case image
    case video
    case poll
    case ad
}
```

### CarouselProduct

Public representation of a product within an asset.

```swift
public struct CarouselProduct: Identifiable, Sendable {
    /// Unique identifier for the product
    public let id: String

    /// Product name
    public let name: String?

    /// Product description
    public let description: String?

    /// External URL for the product
    public let externalUrl: String?

    /// Product image URL
    public let imageUrl: String?

    /// Product price (formatted string)
    public let price: String?
}
```

---

## Event Summary Table

| Event | Category | Key Parameters |
|-------|----------|----------------|
| `carouselLoaded` | Lifecycle | assets |
| `carouselViewed` | Lifecycle | assets |
| `carouselClicked` | Lifecycle | asset, position |
| `assetViewed` | View | asset, position, isInitialView |
| `assetViewStarted` | View | asset, position |
| `assetViewEnded` | View | asset, position, durationMs |
| `timelineOpened` | Detail | parentUrl |
| `timelineClosed` | Detail | parentUrl, durationMs |
| `assetLiked` | Action | asset |
| `assetShared` | Action | asset, position |
| `ctaButtonClicked` | Action | asset, position, targetUrl |
| `productClicked` | Action | asset, product, position, targetUrl |
| `pollVoted` | Action | asset, position, pollId, answer |
