# Analytics API Payloads Reference

Complete reference for all analytics event payloads sent to the Terrific backend.

**Endpoint:** `POST /userEvents`

**Headers (all events):**

| Header | Value |
|--------|-------|
| `Accept` | `application/json` |
| `Content-Type` | `application/json` |
| `terrific-store-id` | `{storeId}` |

**Environments:**

| Environment | Base URL |
|-------------|----------|
| Staging | `https://us-central1-terrific-deploy.cloudfunctions.net` |
| Production | `https://us-central1-terrific-live.cloudfunctions.net` |

---

## Field Legend

| Symbol | Meaning |
|--------|---------|
| **required** | Always present, never null |
| **optional** | May be `null` in JSON |
| **always null** | Field exists in payload but is always sent as `null`. Reserved/not yet implemented. |
| **""  if nil** | Sent as empty string `""` when source value is nil. **Backend may error if null is sent instead.** |

---

## Common Request Body Structure

Most events use this structure:

```json
{
  "name": "<EventName>",
  "userId": "<terrific-generated-uuid>",
  "sessionId": "<carouselId>" or "<carouselId>~<assetId>",
  "auxData": { ... }
}
```

Exceptions: `TimelineProductClicked` and `TimelinePollVoted` have additional root-level fields.

### Common Fields (all events)

| Field | Type | Required | Source |
|-------|------|----------|--------|
| `name` | `string` | **required** | Event name enum value |
| `userId` | `string` | **required** | `AnalyticsConfiguration.userId` (Terrific-generated UUID) |
| `sessionId` | `string` | **required** | `carouselId` or `carouselId~assetId` (see each event) |

### About `externalUserId`

Every event's `auxData` contains an `externalUserId: String?` field. This is a **reserved field** that is currently **always `null`**. The parameter exists in all analytics service methods but is hardcoded to `nil` at the coordinator level (`TimelineCoordinator+Analytics.swift`). There is no public API or configuration for the host app to supply this value yet.

---

## 1. TimelineCarouselLoaded

**Trigger:** Assets page loaded from API (first load or pagination).
**Session ID:** `carouselId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `assetIds` | `[string]` | **required** | Array of loaded asset IDs |
| `assetTimestamps` | `[string]` | **required** | Asset timestamps in milliseconds (as strings) |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `userAgent` | `string` | **required** | `"Carousel/{version}.{build} (iOS; {osVersion})"` |
| `parentUrl` | `string` | **"" if nil** | `assets.first?.parentUrl ?? ""` |
| `position` | `int?` | **always null** | Reserved field. Hardcoded to `nil` in service. |
| `totalAssets` | `int` | **required** | Count of loaded assets |

---

## 2. TimelineCarouselViewed

**Trigger:** Carousel view appears on screen.
**Session ID:** `carouselId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `assetIds` | `[string]` | **required** | All asset IDs in carousel |
| `assetTimestamps` | `[string]` | **required** | All asset timestamps in milliseconds |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `userAgent` | `string` | **required** | User agent string |
| `parentUrl` | `string` | **"" if nil** | `assets.first?.parentUrl ?? ""` |
| `position` | `int?` | **always null** | Reserved field. Hardcoded to `nil` in service. |
| `totalAssets` | `int` | **required** | Total asset count |

---

## 3. TimelineCarouselAssetViewed

**Trigger:** Individual asset becomes visible in feed or detail view.
**Session ID:** `carouselId~assetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `assetTimestamp` | `string` | **required** | Asset timestamp in milliseconds |
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `userAgent` | `string` | **required** | User agent string |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `isInitialView` | `bool` | **required** | `true` if visible from start, `false` if scrolled into view |
| `position` | `int` | **required** | Asset position (0-indexed) |
| `fixedPosition` | `int` | **required** | Same as `position` |
| `customProducts` | `[CustomProduct]` | **required** | See [CustomProduct](#customproduct) below |

---

## 4. TimelineCarouselClicked

**Trigger:** User taps an asset card to open detail view.
**Session ID:** `carouselId~clickedAssetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `assetId` | `string` | **required** | Clicked asset ID |
| `assetIds` | `[string]` | **required** | All asset IDs in carousel |
| `assetTimestamps` | `[string]` | **required** | All asset timestamps |
| `brandName` | `string?` | **optional** | From clicked asset |
| `campaignName` | `string?` | **optional** | From clicked asset |
| `customProducts` | `[string]` | **required** | Always empty `[]` |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `parentUrl` | `string` | **"" if nil** | `clickedAsset.parentUrl ?? ""` |
| `position` | `int` | **required** | Position of clicked asset |
| `totalAssets` | `int` | **required** | Total assets in carousel |

---

## 5. TimelineOpened

**Trigger:** User opens the fullscreen detail view.
**Session ID:** `carouselId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `userAgent` | `string` | **required** | User agent string |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` (from CTA button URL) |

---

## 6. TimelineClosed

**Trigger:** User closes the detail view, returns to feed.
**Session ID:** `carouselId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `activeViewDurationMs` | `int` | **required** | Duration in milliseconds |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `totalOpenDurationMs` | `int` | **required** | Same as `activeViewDurationMs` currently |

---

## 7. TimelineAssetViewStarted

**Trigger:** User scrolls to an asset in the detail view.
**Session ID:** `carouselId~assetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `assetType` | `string` | **required** | `"video"`, `"image"`, `"poll"`, or `"ad"` |
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `customProducts` | `[CustomProduct]` | **required** | See [CustomProduct](#customproduct) |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `fixedPosition` | `int?` | **optional** | Same as `position` (nullable in struct, but always provided) |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `position` | `int` | **required** | Asset position |
| `products` | `[AnalyticProduct]` | **required** | See [AnalyticProduct](#analyticproduct) |

---

## 8. TimelineAssetViewEnded

**Trigger:** User scrolls away from an asset in the detail view.
**Session ID:** `carouselId~assetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `assetType` | `string` | **required** | `"video"`, `"image"`, `"poll"`, or `"ad"` |
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `customProducts` | `[CustomProduct]` | **required** | See [CustomProduct](#customproduct) |
| `drawerOpenDurationMs` | `int` | **required** | Hardcoded to `0` (TODO: not yet implemented) |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `netoAssetWatchTimeMs` | `int` | **required** | Same as `viewDurationMs` currently (TODO) |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `position` | `int` | **required** | Asset position |
| `products` | `[AnalyticProduct]` | **required** | See [AnalyticProduct](#analyticproduct) |
| `viewDurationMs` | `int` | **required** | Total view duration in milliseconds |

---

## 9. TimelineAssetLiked

**Trigger:** User taps the like/heart button.
**Session ID:** `carouselId~assetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `userAgent` | `string` | **required** | User agent string |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `position` | `int` | **required** | Asset position |

---

## 10. TimelineCTAButtonClicked

**Trigger:** User taps a CTA (call-to-action) button on an asset.
**Session ID:** `carouselId~assetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `customProducts` | `[CustomProduct]` | **required** | See [CustomProduct](#customproduct) |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `position` | `int` | **required** | Asset position |
| `targetUrl` | `string` | **required** | URL the button navigates to |
| `terrificClickId` | `string` | **required** | Unique UUID (lowercased) for click attribution |
| `url` | `string` | **required** | Same as `targetUrl` |
| `userAgent` | `string` | **required** | User agent string |

---

## 11. TimelineAssetShared

**Trigger:** User taps the share button.
**Session ID:** `carouselId~assetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `customProducts` | `[CustomProduct]` | **required** | See [CustomProduct](#customproduct) |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `position` | `int` | **required** | Asset position |
| `userAgent` | `string` | **required** | User agent string |

---

## 12. TimelinePollVoted

**Trigger:** User selects an answer and votes on a poll.
**Session ID:** `carouselId~assetId`

> **Non-standard body:** Has extra root-level fields `pollId` and `pollAnswer`.

### Root-level fields (in addition to common fields)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `pollId` | `string` | **required** | Poll identifier |
| `pollAnswer` | `string` | **required** | Selected answer text |

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `position` | `int` | **required** | Asset position |
| `questionId` | `string` | **required** | Question identifier |
| `userAgent` | `string` | **required** | User agent string |

---

## 13. TimelineProductClicked

**Trigger:** User taps a product CTA button within an asset.
**Session ID:** `carouselId~assetId`

> **Non-standard body:** Has extra root-level fields `items` and `itemViewSource`.

### Root-level fields (in addition to common fields)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `items` | `[ProductItem]` | **required** | See below |
| `itemViewSource` | `string` | **required** | Always `"featuredItem"` |

### ProductItem

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `productId` | `string` | **required** | Product ID |
| `variantId` | `string` | **"" if nil** | `product.variants?.first?.id ?? ""` |

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `string` | **required** | Product ID |
| `name` | `string` | **"" if nil** | `product.name ?? ""` |
| `description` | `string` | **"" if nil** | `product.description ?? ""` |
| `externalURL` | `string` | **"" if nil** | `product.externalUrl ?? ""` |
| `imageURL` | `string` | **"" if nil** | `product.imageUrl ?? ""` |
| `price` | `string` | **"" if nil** | `product.formattedPrice ?? ""` |
| `isCatalog` | `bool` | **required** | Always `false` |
| `brandName` | `string?` | **optional** | From asset DTO |
| `campaignName` | `string?` | **optional** | From asset DTO |
| `customProducts` | `[CustomProduct]` | **required** | Mapped from single product |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `position` | `int` | **required** | Asset position |
| `terrificClickId` | `string` | **required** | Unique UUID (lowercased) for attribution |
| `userAgent` | `string` | **required** | User agent string |

---

## 14. TimelineCarouselSponsorshipClicked

**Trigger:** User taps a sponsorship element in the horizontal feed carousel.
**Session ID:** `carouselId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `parentUrl` | `string?` | **optional** | From first carousel asset (truly optional, not "" fallback) |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `sponsorshipPlacement` | `string` | **required** | `"TopLogo"` or `"SideLogo"` |
| `sponsorshipUrl` | `string?` | **optional** | Sponsorship redirect URL |

---

## 15. TimelineAssetSponsorshipClicked

**Trigger:** User taps a sponsorship element in the detail view.
**Session ID:** `carouselId~assetId`

### auxData

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `parentUrl` | `string` | **"" if nil** | `asset.parentUrl ?? ""` |
| `externalUserId` | `string?` | **always null** | Reserved field. Hardcoded to `nil` in coordinator, no public API to set it. |
| `sponsorshipPlacement` | `string` | **required** | `"badgeLogo"`, `"bannerLogo"`, or `"pollLogo"` |
| `sponsorshipPosition` | `string?` | **optional** | `"top"`, `"bottom"`, or `"both"` |
| `clickPosition` | `string?` | **optional** | `"Top"` or `"Bottom"` (capitalized) |
| `sponsorshipUrl` | `string?` | **optional** | Sponsorship redirect URL |

---

## Shared Data Types

### CustomProduct

Sent in events: AssetViewed, AssetViewStarted, AssetViewEnded, CTAButtonClicked, AssetShared, ProductClicked.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | `string` | **"" if nil** | `product.name ?? ""` |
| `price` | `string` | **"" if nil** | `product.formattedPrice ?? String(product.price ?? 0)` |
| `currency` | `string` | **"" if nil** | `product.currency ?? ""` |
| `description` | `string` | **"" if nil** | `product.description ?? ""` |
| `externalURL` | `string` | **"" if nil** | `product.externalUrl ?? ""` |

### AnalyticProduct

Sent in events: AssetViewStarted, AssetViewEnded.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `string` | **required** | Product ID (non-optional, UUID fallback if missing from API) |
| `sku` | `string` | **"" if nil** | `product.sku ?? ""` |
| `categories` | `[string]` | **required** | `product.categories ?? []` |
| `tags` | `[string]` | **required** | Always empty `[]` |

---

## Summary: All "always null" Fields

These fields exist in the payload but are **always sent as `null`**. They are reserved or not yet implemented.

| Field | Events Where Used | Reason |
|-------|-------------------|--------|
| `externalUserId` | All 15 events | Reserved. Parameter exists in service protocol but hardcoded to `nil` in `TimelineCoordinator+Analytics.swift`. No public API to supply a value. |
| `position` | CarouselLoaded, CarouselViewed | Hardcoded to `nil` in `AnalyticsServiceImpl`. |

---

## Summary: All "" if nil Fields

These fields send empty string `""` instead of null when the source value is nil. Sending `null` for these fields causes backend errors.

| Field | Events Where Used |
|-------|-------------------|
| `parentUrl` | All events except CarouselSponsorshipClicked (which allows null) |
| `customProducts[].name` | AssetViewed, AssetViewStarted, AssetViewEnded, CTAButtonClicked, AssetShared, ProductClicked |
| `customProducts[].price` | Same as above |
| `customProducts[].currency` | Same as above |
| `customProducts[].description` | Same as above |
| `customProducts[].externalURL` | Same as above |
| `products[].sku` | AssetViewStarted, AssetViewEnded |
| `auxData.name` (ProductClicked) | ProductClicked |
| `auxData.description` (ProductClicked) | ProductClicked |
| `auxData.externalURL` (ProductClicked) | ProductClicked |
| `auxData.imageURL` (ProductClicked) | ProductClicked |
| `auxData.price` (ProductClicked) | ProductClicked |
| `items[].variantId` | ProductClicked |
