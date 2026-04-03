# Privacy & Data Collection

This document describes the data collection practices of TerrificCarouselSDK and provides information required for App Store privacy labels.

## Table of Contents

- [Overview](#overview)
- [Privacy Manifest](#privacy-manifest)
- [Data Collection Summary](#data-collection-summary)
- [App Store Privacy Labels](#app-store-privacy-labels)
- [Network Communication](#network-communication)
- [Local Data Storage](#local-data-storage)
- [Required Reason APIs](#required-reason-apis)
- [App Tracking Transparency](#app-tracking-transparency)
- [Children's Privacy (COPPA)](#childrens-privacy-coppa)
- [Privacy Best Practices](#privacy-best-practices)

---

## Overview

TerrificCarouselSDK is built with a **privacy-first** approach:

| Principle | Implementation |
|-----------|----------------|
| Data Minimization | Only essential data is collected |
| Pseudonymization | Data linked by UUID, no personal identifiers (name, email) |
| Transparency | All data collection is documented |
| No Tracking | No cross-app or cross-site tracking |

> **Note:** The SDK sends pseudonymous analytics to Terrific servers automatically. This cannot be disabled and is required for the SDK to function. Data is linked by a generated UUID but contains no personal identifiers like name or email.

---

## Privacy Manifest

Starting with iOS 17, Apple requires SDKs to include a privacy manifest (`PrivacyInfo.xcprivacy`). TerrificCarouselSDK includes this manifest in the package.

### Location

```
TerrificCarouselSDK/
└── Sources/
    └── TerrificCarouselSDK/
        └── PrivacyInfo.xcprivacy
```

### Manifest Contents

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>

    <key>NSPrivacyTrackingDomains</key>
    <array/>

    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeProductInteraction</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeOtherUsageData</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
            </array>
        </dict>
    </array>

    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## Data Collection Summary

### Data Collected

| Data Type | Description | Linked to Identity | Used for Tracking |
|-----------|-------------|-------------------|-------------------|
| Product Interaction | Likes, views, shares within carousel | No | No |
| Other Usage Data | Scroll behavior, time spent | No | No |

### Data NOT Collected

| Data Type | Status |
|-----------|--------|
| Contact Info (name, email, phone) | Not collected |
| Health & Fitness | Not collected |
| Financial Info | Not collected |
| Location | Not collected |
| Sensitive Info | Not collected |
| Contacts | Not collected |
| User Content | Not collected |
| Browsing History | Not collected |
| Search History | Not collected |
| Device ID (IDFV, IDFA) | Not collected |
| Purchases | Not collected |
| Diagnostics (crash logs) | Not collected |
| Advertising Data | Not collected |

---

## App Store Privacy Labels

When submitting your app to the App Store, use the following information for privacy labels:

### Required Privacy Labels

The SDK always collects pseudonymous analytics data. Select these in App Store Connect:

**Data Types Collected:**

| Category | Data Type | Usage |
|----------|-----------|-------|
| Usage Data | Product Interaction | Analytics |
| Usage Data | Other Usage Data | Analytics |

**For each data type, answer:**

| Question | Answer |
|----------|--------|
| Is this data linked to the user's identity? | No |
| Is this data used for tracking? | No |
| Is this data used for Third-Party Advertising? | No |
| Is this data used for Developer's Advertising or Marketing? | No |
| Is this data used for Analytics? | Yes |
| Is this data used for Product Personalization? | No |
| Is this data used for App Functionality? | No |

> **Note:** These privacy labels are always required when using TerrificCarouselSDK because the SDK sends pseudonymous analytics to Terrific servers automatically. The `onAnalyticsEvent` callback only controls whether you also receive events for your own analytics - it does not disable Terrific's analytics collection.

---

## Network Communication

### Domains Used

| Domain | Purpose | Required |
|--------|---------|----------|
| `api.terrific.live` | API requests (carousel data, analytics) | Yes |
| `cdn.terrific.live` | Media content (images, videos) | Yes |

### Request Types

| Endpoint | Method | Purpose | Data Sent |
|----------|--------|---------|-----------|
| `/carousels/{id}` | GET | Fetch carousel content | Store ID, Carousel ID |
| `/userEvents` | POST | Send analytics events | Event data (see below) |

### Analytics Event Payload

Example payload for `timelineAssetViewed` event:

```json
{
  "name": "timelineCarouselAssetViewed",
  "userId": "terrific-generated-id",
  "sessionId": "carouselId~assetId",
  "auxData": {
    "assetTimestamp": "1704067200000",
    "brandName": "Brand Name",
    "campaignName": "Campaign Name",
    "externalUserId": null,
    "userAgent": "Carousel/1.0.1 (iOS; Version 17.2)",
    "parentUrl": "https://example.com",
    "isInitialView": true,
    "position": 0,
    "fixedPosition": 0,
    "customProducts": []
  }
}
```

**Headers:** `terrific-store-id: your_store_id`

**Note:** The `externalUserId` field is only populated if your app provides it. No advertising identifiers, device IDs, or IP addresses are included in the payload.

### SSL/TLS

- All connections use HTTPS
- No HTTP fallback

---

## Local Data Storage

### UserDefaults Keys

| Key | Type | Purpose | Contains PII |
|-----|------|---------|--------------|
| `com.carouseldemo.likedAssetIds` | [String] | Store liked asset IDs | No |
| `com.carouseldemo.terrificUserId` | String | Generated user UUID for analytics | No |
| `com.carouseldemo.pollAnswers` | Data | Store poll answers | No |

### Data Location

All data is stored in the app's sandboxed `UserDefaults`:
- **iOS**: App container (not shared)
- **macOS**: App container (sandboxed)
- **tvOS**: App container (not shared)

### Data Persistence

| Data | Persists Across | Cleared When |
|------|-----------------|--------------|
| Liked assets | App launches | App uninstalled |
| User ID (UUID) | App launches | App uninstalled |
| Poll answers | App launches | App uninstalled |

### Clearing Local Data

Local data is automatically cleared when the app is uninstalled.

---

## Required Reason APIs

Apple requires developers to declare why they use certain APIs. TerrificCarouselSDK uses:

### UserDefaults

| API | Reason Code | Description |
|-----|-------------|-------------|
| `NSUserDefaults` | CA92.1 | Access user preferences within the app |

**Why we use it:** Store user preferences (liked assets, mute state) locally on device.

### APIs NOT Used

The SDK does **not** use these commonly-flagged APIs:

| API | Status |
|-----|--------|
| File timestamp APIs | Not used |
| Disk space APIs | Not used |
| Active keyboard APIs | Not used |
| User defaults (cross-app) | Not used |

---

## App Tracking Transparency

### ATT Framework

TerrificCarouselSDK does **NOT**:

- Request ATT permission
- Use IDFA (Advertising Identifier)
- Track users across apps or websites
- Share data with data brokers

**You do NOT need to show an ATT prompt** for this SDK.

### Verification

The SDK's `NSPrivacyTracking` is set to `false` in the privacy manifest, confirming no tracking occurs.

---

## Children's Privacy (COPPA)

### Compliance Status

TerrificCarouselSDK is designed to be **COPPA-compliant**:

| Requirement | SDK Compliance |
|-------------|----------------|
| No personal information collection | Compliant - no PII collected |
| Parental consent mechanisms | Not required - no PII |
| Data minimization | Compliant - minimal pseudonymous data |
| No behavioral advertising | Compliant - no advertising |

### Usage in Children's Apps

The SDK can be used in apps directed at children under 13, provided:

1. Analytics callback is not used, OR
2. Analytics data is not combined with any user-identifying information

### Recommended Configuration for Children's Apps

```swift
// Safe configuration for children's apps
CarouselView(
    apiConfiguration: APIConfiguration(
        storeId: "your_store_id",
        carouselId: "your_carousel_id"
    )
    // Do NOT provide onAnalyticsEvent for children's apps
)
```

---

## Privacy Best Practices

### For App Developers

1. **Review your privacy policy**
   - Mention use of third-party SDKs
   - Describe carousel analytics if enabled

2. **Minimize data collection**
   ```swift
   // Only enable analytics if needed
   let enableAnalytics = shouldCollectAnalytics()

   CarouselView(
       apiConfiguration: config,
       onAnalyticsEvent: enableAnalytics ? handleEvent : nil
   )
   ```

3. **Provide user controls**
   ```swift
   // Settings screen option
   Toggle("Carousel Analytics", isOn: $analyticsEnabled)
   ```

4. **Keep SDK updated**
   - Privacy improvements are released regularly
   - Check release notes for privacy-related changes

### Privacy Checklist

- [ ] Privacy policy updated to mention SDK
- [ ] App Store privacy labels configured correctly
- [ ] ATT prompt NOT shown for this SDK alone
- [ ] COPPA compliance verified (if applicable)
