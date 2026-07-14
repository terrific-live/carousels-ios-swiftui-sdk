# Refactoring Suggestions

## Completed (Round 1)

| # | Refactoring | Status |
|---|-------------|--------|
| 1 | Split `TimelineDetailAssetCard` into focused sub-views | Done |
| 2 | Extract duplicated product mapping in `AnalyticsServiceImpl` | Done |
| 3 | Split `TimelineCoordinator` — separate navigation from analytics | Done |
| 4 | Deduplicate Feed/Detail shared UI patterns | Done |
| 5 | Consolidate skeleton views into single component with mode | Done |
| 6 | Move timestamp formatting into dedicated `TimestampFormatter` | Done |
| 7 | Clean up `ProductDTO` — sample data to tests, `id` non-optional | Done |
| 8 | Reduce `TimelineViewModel` analytics coupling | Done |
| 9 | Replace `Timer`-based auto-scroll with `Task.sleep` | Done |
| 10 | Add `Hashable` conformance to `SponsorshipDTO` | Done |
| 11 | Improve `HTTPClient` test coverage (1 → 9 test files, 117 tests) | Done |

## Proposed (Round 2)

| # | Refactoring | Priority | Effort | Impact |
|---|-------------|----------|--------|--------|
| 12 | Remove debug `print()` statements from production code | Done | Trivial | Code quality |
| 13 | Fix force unwraps in configuration — `URL(string:)!` replaced with optional `URL?`, `.min(by:)!` guarded | Done | Trivial | Crash safety |
| 14 | Centralize session ID construction — extracted `sessionId(carouselId:assetId:)` helper | Done | Trivial | DRY, maintainability |
| 15 | Resolve TODO in AnalyticsServiceImpl — `drawerOpenDurationMs: 0` clarified | Done | Trivial | Data accuracy |
| 16 | Split `AnalyticsServiceImpl` into extensions — `+Timeline`, `+Asset`, `+Carousel`, `+Interaction` | Done | Medium | Readability |
| 17 | Extract common asset card rendering — `CardWithProductsContainer` + `AssetImageContent` shared by Feed and Detail cards | Done | Medium | DRY, consistency |
| 18 | Extract `AssetViewTracker` and `DetailSessionTracker` from `TimelineViewModel` — duration + background time logic | Done | High | Testability, SRP |
| 19 | Extract visibility calculation logic from `MultiItemHorizontalCarousel` into `CarouselVisibilityCalculator` + `VisibilityReporter` + 14 tests | Done | Medium | Readability |
| 20 | Add tests for analytics request building — 36 tests covering all AuxData structs, request types, enum raw values, and JSON encoding contract | Done | Medium | Reliability |
| 21 | Naming consistency — renamed `AssetMediaType` to `AssetMediaTypeData` to match ViewData layer convention (`*Data` suffix) | Done | Medium | Consistency |
