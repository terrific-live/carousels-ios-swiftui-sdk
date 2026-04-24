# Style Configuration Guide

This document provides detailed information about customizing the carousel appearance using style configurations.

## Table of Contents

- [Overview](#overview)
- [CarouselStyleConfiguration](#carouselstyleconfiguration)
- [FeedStyleConfiguration](#feedstyleconfiguration)
- [DetailStyleConfiguration](#detailstyleconfiguration)
- [PollStyleConfiguration](#pollstyleconfiguration)
- [ProductViewSizeConfiguration](#productviewsizeconfiguration)
- [CarouselFontDescriptor](#carouselfontdescriptor)
- [Examples](#examples)

---

## Overview

The SDK uses a hierarchical configuration structure:

```
CarouselStyleConfiguration
├── feed: FeedStyleConfiguration           // Horizontal carousel (feed view)
│   ├── poll: PollStyleConfiguration       // Poll styling in feed
│   └── product: ProductViewSizeConfiguration  // Product styling in feed
└── detail: DetailStyleConfiguration       // Fullscreen vertical view
    ├── poll: PollStyleConfiguration       // Poll styling in detail
    └── product: ProductViewSizeConfiguration  // Product styling in detail
```

> **Important:** The `CarouselView` determines its own size based on `styleConfiguration`. Do **NOT** wrap it in a `.frame()` modifier. All sizing should be done through `styleConfiguration` properties.

---

## CarouselStyleConfiguration

Top-level configuration containing feed and detail view styles.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `feed` | FeedStyleConfiguration | `.default` | Configuration for the horizontal carousel view |
| `detail` | DetailStyleConfiguration | `.default` | Configuration for the fullscreen detail view |

### Usage

```swift
// Use defaults
let style = CarouselStyleConfiguration.default

// Custom configuration
let style = CarouselStyleConfiguration(
    feed: FeedStyleConfiguration(...),
    detail: DetailStyleConfiguration(...)
)
```

---

## FeedStyleConfiguration

Controls the horizontal carousel (feed) appearance.

### Carousel Layout

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `carouselItemWidth` | CGFloat | 240 | Width of each carousel card |
| `carouselItemHeight` | CGFloat | 420 | Height of each carousel card |
| `carouselItemSpacing` | CGFloat | 18 | Space between cards |
| `carouselHorizontalPadding` | CGFloat | 16 | Horizontal padding at carousel edges |

### Card

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `cardCornerRadius` | CGFloat | 16 | Corner radius of the card |
| `cardSpacing` | CGFloat | 8 | Spacing between card and products |

### Timestamp

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `timestampFont` | CarouselFontDescriptor | System 14 semibold | Font for timestamp label |
| `timestampPaddingHorizontal` | CGFloat | 10 | Horizontal padding inside timestamp label |
| `timestampPaddingVertical` | CGFloat | 6 | Vertical padding inside timestamp label |
| `timestampCornerRadius` | CGFloat | 8 | Corner radius of timestamp background |
| `timestampTopMargin` | CGFloat | 12 | Top margin from card edge |
| `timestampHorizontalMargin` | CGFloat | 12 | Horizontal margin from card edge |

### Title & Subtitle

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `titleFont` | CarouselFontDescriptor | System 18 bold | Font for title |
| `subtitleFont` | CarouselFontDescriptor | System 16 regular | Font for subtitle |
| `titleSubtitleSpacing` | CGFloat | 4 | Spacing between title and subtitle |

### Bottom Info

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `bottomInfoPaddingHorizontal` | CGFloat | 12 | Horizontal padding of bottom info section |
| `bottomInfoPaddingBottom` | CGFloat | 12 | Bottom padding of bottom info section |

### Carousel Name Label

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `carouselNameFont` | CarouselFontDescriptor | System 22 bold | Font for carousel name label |
| `carouselNameColor` | Color | .white | Color for carousel name label |
| `carouselNameHeight` | CGFloat | 54 | Height of carousel name label |
| `carouselNameBottomPadding` | CGFloat | 24 | Bottom padding below carousel name |
| `carouselNameHorizontalPadding` | CGFloat | 16 | Horizontal padding for carousel name |

### Poll

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `poll` | PollStyleConfiguration | `.compact` | Configuration for poll elements in feed |

### Product

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `product` | ProductViewSizeConfiguration | `.feed` | Configuration for product elements in feed |

### Computed Properties

| Property | Type | Description |
|----------|------|-------------|
| `assetCardHorizontalPaddingForProducts` | CGFloat | Calculates horizontal padding for asset cards when products are displayed to maintain aspect ratio |

> **Note:** When products are displayed below the asset card in the feed, the card content area becomes shorter. The `assetCardHorizontalPaddingForProducts` computed property calculates the horizontal padding needed to maintain the original aspect ratio of the card.

### Total Height Calculation

The total height of the carousel is determined by these key properties:

| Property | Default | Description |
|----------|---------|-------------|
| `carouselNameHeight` | 54 | Height of the carousel title label |
| `carouselNameBottomPadding` | 24 | Space below the carousel title |
| `carouselItemHeight` | 420 | Height of each carousel card |

**Formula:**

```
Total Height = carouselNameHeight + carouselNameBottomPadding + carouselItemHeight
             = 54 + 24 + 420
             = 498 points (default)
```

> **Important:** The `carouselNameHeight` default value 54 (2 lines of default font). For custom `Fonts` and `Sizes`, `carouselNameHeight` should be calculated.

---

## DetailStyleConfiguration

Controls the fullscreen detail view appearance.

### Card

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `cardCornerRadius` | CGFloat | 16 | Corner radius of the card |
| `edgePadding` | CGFloat | 16 | Edge padding around the card |
| `cardSpacing` | CGFloat | 8 | Spacing between card and products |

### Progress Bar

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `progressBarHeight` | CGFloat | 8 | Height of the video progress bar |

### Timestamp

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `timestampFont` | CarouselFontDescriptor | System 14 semibold | Font for timestamp label |
| `timestampPaddingHorizontal` | CGFloat | 10 | Horizontal padding inside timestamp |
| `timestampPaddingVertical` | CGFloat | 6 | Vertical padding inside timestamp |
| `timestampCornerRadius` | CGFloat | 8 | Corner radius of timestamp background |
| `timestampTopMargin` | CGFloat | 16 | Top margin from card edge |
| `timestampHorizontalMargin` | CGFloat | 16 | Horizontal margin from card edge |

### Brand Logo

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `brandLogoSize` | CGFloat | 60 | Size of brand logo (width and height) |
| `brandLogoCornerRadius` | CGFloat | 8 | Corner radius of brand logo |

### Title & Subtitle

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `titleFont` | CarouselFontDescriptor | System 22 bold | Font for title |
| `subtitleFont` | CarouselFontDescriptor | System 18 semibold | Font for subtitle |
| `contentSpacing` | CGFloat | 8 | Spacing between content elements |

### CTA Button

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ctaButtonFont` | CarouselFontDescriptor | System 18 semibold | Font for CTA button text |
| `ctaButtonPaddingHorizontal` | CGFloat | 20 | Horizontal padding of CTA button |
| `ctaButtonPaddingVertical` | CGFloat | 10 | Vertical padding of CTA button |

### Action Buttons

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `actionButtonIconSize` | CGFloat | 24 | Icon size for action buttons (like, share, mute) |
| `actionButtonSpacing` | CGFloat | 36 | Spacing between action buttons |

### Content Layout

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `contentHorizontalPadding` | CGFloat | 16 | Horizontal padding for overlay content |
| `bottomInfoPaddingBottom` | CGFloat | 24 | Bottom padding of bottom info section |

### Poll

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `poll` | PollStyleConfiguration | `.default` | Configuration for poll elements in detail |

### Product

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `product` | ProductViewSizeConfiguration | `.detail` | Configuration for product elements in detail |

---

## PollStyleConfiguration

Controls poll element appearance. Has two presets: `.default` (detail size) and `.compact` (feed size).

| Property | Type | Default | Compact | Description |
|----------|------|---------|---------|-------------|
| `questionFont` | CarouselFontDescriptor | System 26 medium | System 20 medium | Font for question text |
| `optionFont` | CarouselFontDescriptor | System 18 medium | System 14 medium | Font for option text |
| `optionSelectedFont` | CarouselFontDescriptor | System 18 semibold | System 14 semibold | Font for selected option (with percentage) |
| `optionHeight` | CGFloat | 56 | 44 | Height of each option button |
| `optionSpacing` | CGFloat | 12 | 8 | Spacing between options |
| `horizontalPadding` | CGFloat | 32 | 24 | Horizontal padding |
| `verticalPadding` | CGFloat | 24 | 16 | Vertical padding |

### Presets

```swift
// Default (larger, for detail view)
let poll = PollStyleConfiguration.default

// Compact (smaller, for feed view)
let poll = PollStyleConfiguration.compact
```

---

## ProductViewSizeConfiguration

Controls product element appearance. Has two presets: `.detail` (larger for detail view) and `.feed` (compact for feed view).

### Container

| Property | Type | Detail | Feed | Description |
|----------|------|--------|------|-------------|
| `cornerRadius` | CGFloat | 16 | 12 | Corner radius of product container |
| `horizontalPadding` | CGFloat | 12 | 10 | Horizontal padding inside container |
| `verticalPadding` | CGFloat | 12 | 10 | Vertical padding inside container |
| `interItemVerticalSpacing` | CGFloat | 4 | 2 | Vertical spacing between text elements |

### Image

| Property | Type | Detail | Feed | Description |
|----------|------|--------|------|-------------|
| `imageSize` | CGFloat | 90 | 50 | Size of product image (width and height) |
| `imageCornerRadius` | CGFloat | 12 | 8 | Corner radius of product image |
| `imageTrailingPadding` | CGFloat | 8 | 6 | Padding after image |

### Text

| Property | Type | Detail | Feed | Description |
|----------|------|--------|------|-------------|
| `titleFontSize` | CGFloat | 18 | 14 | Font size for product title |
| `subtitleFontSize` | CGFloat | 15 | 12 | Font size for product subtitle |
| `priceFontSize` | CGFloat | 16 | 12 | Font size for product price |

### Badge

| Property | Type | Detail | Feed | Description |
|----------|------|--------|------|-------------|
| `badgeFontSize` | CGFloat | 12 | 10 | Font size for sponsor badge |
| `badgeHorizontalPadding` | CGFloat | 10 | 8 | Horizontal padding inside badge |
| `badgeVerticalPadding` | CGFloat | 4 | 2 | Vertical padding inside badge |
| `badgeCornerRadius` | CGFloat | 6 | 4 | Corner radius of badge |

### CTA Button

| Property | Type | Detail | Feed | Description |
|----------|------|--------|------|-------------|
| `ctaFontSize` | CGFloat | 16 | 12 | Font size for CTA button |
| `ctaHorizontalPadding` | CGFloat | 12 | 10 | Horizontal padding of CTA button |
| `ctaVerticalPadding` | CGFloat | 6 | 4 | Vertical padding of CTA button |

### Computed Properties

| Property | Type | Description |
|----------|------|-------------|
| `totalHeight` | CGFloat | Total height of product view (`imageSize + verticalPadding * 2`) |

### Presets

```swift
// Detail mode (larger, for fullscreen detail view)
let product = ProductViewSizeConfiguration.detail  // totalHeight = 114

// Feed mode (compact, for horizontal carousel)
let product = ProductViewSizeConfiguration.feed    // totalHeight = 70
```

### Custom Configuration

```swift
let customProduct = ProductViewSizeConfiguration(
    cornerRadius: 14,
    horizontalPadding: 10,
    verticalPadding: 10,
    interItemVerticalSpacing: 3,
    imageSize: 60,
    imageCornerRadius: 10,
    imageTrailingPadding: 8,
    titleFontSize: 16,
    subtitleFontSize: 13,
    priceFontSize: 14,
    badgeFontSize: 11,
    badgeHorizontalPadding: 9,
    badgeVerticalPadding: 3,
    badgeCornerRadius: 5,
    ctaFontSize: 14,
    ctaHorizontalPadding: 11,
    ctaVerticalPadding: 5
)
```

---

## CarouselFontDescriptor

Describes a font configuration that can be converted to a SwiftUI Font.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `family` | FontFamily | The font family (.system or .custom) |
| `size` | CGFloat | Font size in points |
| `weight` | Font.Weight | Font weight (only for system fonts) |

### FontFamily

| Case | Description |
|------|-------------|
| `.system` | System font (San Francisco on Apple platforms) |
| `.custom(String)` | Custom font with specified family name |

### Usage

```swift
// System font
let font = CarouselFontDescriptor.system(size: 18, weight: .bold)

// Custom font (weight is in the font name)
let font = CarouselFontDescriptor.custom("Avenir-Heavy", size: 18)
```

> **Note:** For custom fonts, include the weight variant in the font name (e.g., `"Avenir-Heavy"`, `"Montserrat-Bold"`). The font file must be added to your app bundle and registered in Info.plist.

---

## Examples

### Custom Feed Style

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
    carouselNameHeight: 54,
    carouselNameBottomPadding: 16
)

let styleConfiguration = CarouselStyleConfiguration(
    feed: customFeedStyle
)
```

### Using Custom Fonts

```swift
let customFeedStyle = FeedStyleConfiguration(
    carouselItemWidth: 260,
    carouselItemHeight: 450,
    titleFont: .custom("Avenir-Heavy", size: 18),
    subtitleFont: .custom("Avenir-Medium", size: 14),
    carouselNameFont: .custom("Avenir-Black", size: 24),
    carouselNameHeight: 54,
    carouselNameColor: .primary
)

let styleConfiguration = CarouselStyleConfiguration(
    feed: customFeedStyle
)
```

### Custom Detail Style

```swift
let customDetailStyle = DetailStyleConfiguration(
    cardCornerRadius: 20,
    edgePadding: 12,
    brandLogoSize: 50,
    titleFont: .system(size: 24, weight: .bold),
    ctaButtonFont: .system(size: 16, weight: .semibold),
    actionButtonIconSize: 28
)

let styleConfiguration = CarouselStyleConfiguration(
    detail: customDetailStyle
)
```

### Custom Product Configuration

```swift
// Custom product sizes for feed
let customFeedProduct = ProductViewSizeConfiguration(
    cornerRadius: 14,
    horizontalPadding: 12,
    verticalPadding: 12,
    interItemVerticalSpacing: 3,
    imageSize: 60,
    imageCornerRadius: 10,
    imageTrailingPadding: 8,
    titleFontSize: 15,
    subtitleFontSize: 13,
    priceFontSize: 13,
    badgeFontSize: 10,
    badgeHorizontalPadding: 8,
    badgeVerticalPadding: 3,
    badgeCornerRadius: 5,
    ctaFontSize: 13,
    ctaHorizontalPadding: 10,
    ctaVerticalPadding: 5
)

let styleConfiguration = CarouselStyleConfiguration(
    feed: FeedStyleConfiguration(
        carouselItemWidth: 260,
        carouselItemHeight: 450,
        product: customFeedProduct
    )
)
```

### Full Custom Configuration

```swift
let styleConfiguration = CarouselStyleConfiguration(
    feed: FeedStyleConfiguration(
        carouselItemWidth: 280,
        carouselItemHeight: 480,
        carouselItemSpacing: 16,
        cardCornerRadius: 12,
        titleFont: .custom("Montserrat-Bold", size: 18),
        carouselNameFont: .custom("Montserrat-Black", size: 26),
        carouselNameHeight: 54,
        poll: PollStyleConfiguration(
            questionFont: .custom("Montserrat-Medium", size: 18),
            optionFont: .custom("Montserrat-Regular", size: 14)
        ),
        product: .feed  // Use default feed product size
    ),
    detail: DetailStyleConfiguration(
        cardCornerRadius: 12,
        titleFont: .custom("Montserrat-Bold", size: 22),
        ctaButtonFont: .custom("Montserrat-SemiBold", size: 16),
        poll: PollStyleConfiguration(
            questionFont: .custom("Montserrat-Medium", size: 24),
            optionFont: .custom("Montserrat-Regular", size: 16)
        ),
        product: .detail  // Use default detail product size
    )
)

CarouselView(
    apiConfiguration: config,
    styleConfiguration: styleConfiguration
)
```
