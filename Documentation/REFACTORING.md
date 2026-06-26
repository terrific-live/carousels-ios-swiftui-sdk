# Refactoring Suggestions

| # | Refactoring | Priority | Effort | Impact |
|---|-------------|----------|--------|--------|
| 1 | Split `TimelineDetailAssetCard` (867 lines) into focused sub-views: sponsor overlays, action buttons, info section, TruncatableText utility | Critical | High | Readability, maintainability |
| 2 | Extract duplicated product mapping in `AnalyticsServiceImpl` (same code copy-pasted 5 times) | High | Low | DRY, fewer bugs |
| 3 | Split `TimelineCoordinator` (587 lines) — separate navigation from analytics aggregation (24 delegate methods) | High | Medium | Single responsibility |
| 4 | Deduplicate Feed/Detail shared UI patterns: timestamp label, bottom info section, gradient overlays | High | Medium | DRY, consistent styling |
| 5 | Consolidate `TimelineFeedAssetCardSkeleton` and `TimelineDetailAssetCardSkeleton` (~85% identical) into single component with mode | Medium | Low | DRY, maintenance |
| 6 | Move timestamp formatting logic out of `CarouselConfigDTO` into a utility or view data layer | Medium | Low | Clean architecture |
| 7 | Clean up `ProductDTO` — move sample data to test file, make `id` non-optional | Medium | Low | Code clarity |
| 8 | Reduce `TimelineViewModel` analytics coupling — 19+ tracking calls mixed with business logic | Medium | Medium | Testability |
| 9 | Replace `Timer`-based auto-scroll in `ProductCarouselView` with `Task.sleep` async approach | Low | Low | Modern concurrency |
| 10 | Add `Hashable` conformance to `SponsorshipDTO` (all other DTOs have it) | Low | Trivial | Consistency |
| 11 | Improve `HTTPClient` test coverage (currently only 1 test file vs 12 for ImageLoader) | Low | Medium | Reliability |
