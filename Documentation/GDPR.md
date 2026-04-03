# GDPR Compliance Guide

This document describes how TerrificCarouselSDK handles data in compliance with the General Data Protection Regulation (GDPR) and provides guidance for integrating the SDK in a GDPR-compliant manner.

## Table of Contents

- [Overview](#overview)
- [Data Processing Summary](#data-processing-summary)
- [Data Controller vs Data Processor](#data-controller-vs-data-processor)
- [Types of Data Processed](#types-of-data-processed)
- [Legal Basis for Processing](#legal-basis-for-processing)
- [Consent Integration](#consent-integration)
- [User Rights Implementation](#user-rights-implementation)
- [Data Retention](#data-retention)
- [Data Security](#data-security)
- [Checklist for GDPR Compliance](#checklist-for-gdpr-compliance)

---

## Overview

TerrificCarouselSDK is designed with privacy in mind. The SDK:

- Does **NOT** collect personal identifiers (name, email, phone)
- Does **NOT** use advertising identifiers (IDFA)
- Does **NOT** perform cross-app tracking
- Does **NOT** share data with third parties for advertising
- Collects **pseudonymous** interaction data (linked by generated UUID, not personal identity)

---

## Data Processing Summary

| Aspect | Details |
|--------|---------|
| SDK Analytics Controller | Terrific Live |
| Your Analytics Controller | Your organization (if using callback) |
| Data Type | Pseudonymous (UUID-linked, no personal identity) |

---

## Data Controller vs Data Processor

### GDPR Roles by Data Flow

| Data Flow | Data Controller | Data Processor | Legal Basis |
|-----------|-----------------|----------------|-------------|
| SDK → Terrific servers | Terrific Live | - | Legitimate interest |
| SDK → Your analytics (via callback) | You (app developer) | Your analytics provider | Your choice (consent or legitimate interest) |

### SDK Analytics (to Terrific)

For analytics sent automatically to Terrific servers:

- **Terrific is the Data Controller** - Terrific determined what data to collect and how to use it
- This data collection **cannot be disabled** - it is required for SDK functionality
- Legal basis is **legitimate interest** because:
  - Data is pseudonymous (UUID-linked, no personal identifiers like name/email)
  - Processing is necessary for service improvement
  - Minimal privacy impact

By integrating TerrificCarouselSDK, you accept that pseudonymous analytics will be sent to Terrific.

### Your Analytics (via callback)

For analytics you receive via `onAnalyticsEvent` callback:

- **You are the Data Controller** - You decide what to do with these events
- You choose whether to forward to Firebase, Mixpanel, etc.
- You determine the legal basis (consent or legitimate interest)
- You are responsible for:
  - Obtaining user consent if required by your use case
  - Providing privacy notices to users
  - Responding to data subject requests for YOUR analytics data

### Terrific's Responsibilities

Terrific Live, as Controller for SDK analytics:

- Collects pseudonymous data (UUID-linked, no personal identifiers)
- Does not share data with third parties for advertising
- Data is linked by generated UUID, not by personal identity

---

## Types of Data Processed

### Data Stored Locally (On Device)

| Data | Purpose | Storage | Retention |
|------|---------|---------|-----------|
| Liked asset IDs | Remember user preferences | UserDefaults | Until app deleted |
| User ID (UUID) | Analytics session tracking | UserDefaults | Until app deleted |
| Poll answers | Remember poll responses | UserDefaults | Until app deleted |

### Data Sent to Servers (Analytics)

**Request Headers:**

| Data | Example | Personal Data? | Purpose |
|------|---------|----------------|---------|
| Store ID | `store_abc123` | No | Identify store |

**Request Body (all events):**

| Data | Example | Personal Data? | Purpose |
|------|---------|----------------|---------|
| Event name | `timelineOpened`, `timelineAssetViewed` | No | Event type |
| User ID | Terrific-generated ID | No | Session tracking |
| Session ID | `carouselId` or `carouselId~assetId` | No | Session grouping |

**AuxData (varies by event type):**

| Data | Example | Personal Data? | Purpose |
|------|---------|----------------|---------|
| User Agent | `Carousel/1.0.1 (iOS; Version 17.2)` | No | App/OS version |
| Parent URL | URL where carousel is embedded | No | Context |
| External User ID | App-provided ID (if any) | Potentially | Custom tracking |
| Position | `0`, `1`, `2` | No | Asset position |
| Brand Name | Content brand | No | Content analytics |
| Campaign Name | Content campaign | No | Content analytics |
| Asset IDs | Array of asset identifiers | No | Content tracking |
| Asset Timestamps | Array of timestamps | No | Content ordering |
| View Duration (ms) | `5000` | No | Engagement metrics |
| Asset Type | `video`, `image`, `poll` | No | Content type |
| Is Initial View | `true`, `false` | No | View mode |
| Target URL | CTA destination URL | No | Click tracking |
| Product Info | Name, price, currency, SKU | No | Product analytics |
| Poll Data | Poll ID, answer, question ID | No | Poll analytics |

### Data NOT Collected

The SDK explicitly does **NOT** collect:

- Names, emails, or phone numbers
- Location data (GPS, IP-based)
- Advertising identifiers (IDFA/IDFV)
- Device identifiers that persist across apps
- Browsing history outside the carousel
- Data from other apps
- Biometric data
- Financial information

---

## Legal Basis for Processing

### Legitimate Interest (Default)

Pseudonymous analytics data is processed under **legitimate interest** (GDPR Article 6(1)(f)):

- **Purpose**: Improve carousel content and user experience
- **Necessity**: Analytics are essential for content optimization
- **Balancing**: Minimal privacy impact (no personal identifiers)

### Consent (When Required)

You must obtain **consent** (GDPR Article 6(1)(a)) when:

- Forwarding analytics to your own systems that link to user profiles
- Combining SDK data with other personal data
- Using data for purposes beyond basic analytics

---

## Consent Integration

### Understanding SDK Analytics

The SDK sends pseudonymous analytics to Terrific servers automatically. This **cannot be disabled** and is required for the SDK to function.

| Analytics Type | Destination | Can Be Disabled? |
|----------------|-------------|------------------|
| SDK internal analytics | Terrific servers | No |
| Your analytics (via callback) | Your analytics platform | Yes |

The `onAnalyticsEvent` callback is an **additional** hook that lets you also receive events for your own analytics integration (Firebase, Mixpanel, etc.).

### Legal Basis for SDK Analytics

Since SDK analytics cannot be disabled, Terrific processes this data under **legitimate interest** (GDPR Article 6(1)(f)):

- Data is pseudonymous (UUID-linked, no personal identifiers like name/email)
- Processing is necessary for service operation and improvement
- Minimal privacy impact
- Users can still use the carousel without providing personal data

### Option 1: SDK Only (No Additional Analytics)

If you don't need your own analytics, simply don't provide the callback:

```swift
// SDK sends pseudonymous analytics to Terrific (required)
// No additional analytics to your systems
CarouselView(
    apiConfiguration: APIConfiguration(
        storeId: "your_store_id",
        carouselId: "your_carousel_id"
    )
    // onAnalyticsEvent not provided = no forwarding to YOUR analytics
)
```

### Option 2: Add Your Own Analytics

If forwarding events to your own analytics platform, the legal basis depends on how you use the data:

| Usage | Legal Basis | Consent Required? |
|-------|-------------|-------------------|
| Anonymous aggregate statistics | Legitimate interest | No |
| Linked to user accounts/profiles | Consent | Yes |
| Used for personalization | Consent | Yes |
| Tracking individual users over time | Consent | Yes |

#### Example: Aggregate Analytics (No Consent Required)

```swift
import TerrificCarouselSDK

struct CarouselWithAnalytics: View {
    var body: some View {
        CarouselView(
            apiConfiguration: APIConfiguration(
                storeId: "your_store_id",
                carouselId: "your_carousel_id"
            ),
            onAnalyticsEvent: { event in
                // Aggregate tracking - no user IDs attached
                // Can use legitimate interest as legal basis
                Analytics.track("carousel_event")
            }
        )
    }
}
```

#### Example: User-Linked Analytics (Consent Required)

```swift
import TerrificCarouselSDK

struct ConsentAwareCarouselView: View {
    @AppStorage("analyticsConsent") private var hasConsent = false

    var body: some View {
        CarouselView(
            apiConfiguration: APIConfiguration(
                storeId: "your_store_id",
                carouselId: "your_carousel_id"
            ),
            onAnalyticsEvent: hasConsent ? handleAnalyticsEvent : nil
        )
    }

    private func handleAnalyticsEvent(_ event: CarouselAnalyticsEvent) {
        // Linking to user profile - requires consent
        Analytics.track("carousel_event", userId: currentUser.id)
    }
}
```

---

## User Rights Implementation

### Right to Rectification (Article 16)

Right to Rectification applies to correcting inaccurate personal data. The SDK collects only interaction events (views, clicks, durations), not personal data that could be inaccurate, so this right is typically not applicable.

### Right to Data Portability (Article 20)

Right to Data Portability applies to personal data provided by the user. The SDK stores only local preferences (liked assets, poll answers) in UserDefaults - this is not personal data, so this right is typically not applicable.

### Right to Object (Article 21)

**For SDK analytics to Terrific:** Users cannot opt out of SDK analytics as this is required for the SDK to function. The data is pseudonymous (UUID-linked) but does not contain personal identifiers like name or email.

**For your own analytics:** If you forward events to your own analytics via the callback, implement opt-out by not providing the callback or conditionally disabling it based on user preference.

### Right to Restrict Processing (Article 18)

**For SDK analytics to Terrific:** Cannot be restricted as SDK analytics are required for functionality. Data is pseudonymous (UUID-linked).

**For your own analytics:** Implement by conditionally forwarding events:

```swift
var processingRestricted: Bool {
    UserDefaults.standard.bool(forKey: "my_app_processing_restricted")
}

// In your CarouselView setup:
onAnalyticsEvent: processingRestricted ? nil : { event in
    // Forward to your analytics only if not restricted
    forwardToMyAnalytics(event)
}
```

---

## Data Retention

| Data Type | Retention Period | Deletion Method |
|-----------|------------------|-----------------|
| Local preferences | Until app uninstalled | Automatic (app deletion) |
| Server analytics | Pseudonymous (UUID-linked) | Requires UUID |

---

## Data Security

### In Transit

- All network communication uses HTTPS
- No sensitive data in URLs

### At Rest (Local)

- Data stored in app sandbox (iOS security)
- No encryption beyond OS-level (non-sensitive data)
- Keychain not used (no secrets stored)

---

## Checklist for GDPR Compliance

Use this checklist to ensure your integration is GDPR-compliant:

### Before Integration

- [ ] Review your privacy policy - does it cover analytics SDKs?
- [ ] Determine legal basis (legitimate interest vs consent)
- [ ] If using consent, integrate with your consent management
- [ ] Update your privacy notice to mention carousel analytics

### During Integration

- [ ] If using `onAnalyticsEvent` callback with user data, implement consent checks
- [ ] Test that callback is only provided when user has consented (if applicable)

### User Interface (if using your own analytics)

- [ ] Privacy settings accessible in app
- [ ] Clear explanation of what data is collected
- [ ] Option to disable your analytics callback

### Documentation

- [ ] Document data flows in your ROPA (Records of Processing Activities)
- [ ] Update Data Protection Impact Assessment if required
- [ ] Keep records of consent (timestamp, version, scope)

### Ongoing

- [ ] Monitor for SDK updates that may change data collection
- [ ] Respond to user data requests within 30 days
- [ ] Review consent mechanisms periodically
- [ ] Train support staff on handling data requests
