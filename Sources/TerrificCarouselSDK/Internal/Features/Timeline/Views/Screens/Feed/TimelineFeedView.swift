//
//  TimelineFeedView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 14.01.2026.
//

import SwiftUI

// MARK: - View
struct TimelineFeedView: View {

    // MARK: - Static Constants
    private static let errorFontSize: CGFloat = 14

    // MARK: - Dependencies
    @ObservedObject private var viewModel: TimelineViewModel

    // MARK: - Configuration
    private let sizeConfig: FeedStyleConfiguration

    // MARK: - Callbacks
    private let onAssetTap: ((Int) -> Void)?

    // MARK: - State
    @State private var autoAdvanceTask: Task<Void, Never>?

    // MARK: - Init
    init(
        viewModel: TimelineViewModel,
        sizeConfig: FeedStyleConfiguration = .default,
        onAssetTap: ((Int) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.sizeConfig = sizeConfig
        self.onAssetTap = onAssetTap
    }

    // MARK: - Body
    var body: some View {
        content
            .onAppear {
                handleOnAppear()
                // Restart auto-advance when view reappears (e.g., returning from detail)
                handleCurrentItemChanged(to: viewModel.currentPageIndex)
            }
            .onDisappear {
                autoAdvanceTask?.cancel()
                autoAdvanceTask = nil
            }
            .onChange(of: viewModel.currentPageIndex) { _, newIndex in
                handleCurrentItemChanged(to: newIndex)
            }
    }
}

// MARK: - UI Components (Factories)
private extension TimelineFeedView {

    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .idle:
                Color.clear

            case .loading:
                loadingView

            case .content:
                buildAssetList(viewModel.carouselItems)

            case .error(let message):
                buildErrorView(message: message)
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    func buildAssetList(_ items: [TimelineViewModel.TimelineCarouselItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Carousel name label (if showName is true)
            if let carouselName = viewModel.carouselConfig.name,
               viewModel.carouselConfig.showName == true {
                Text(carouselName)
                    .font(sizeConfig.carouselNameFont.toFont())
                    .foregroundColor(sizeConfig.carouselNameColor)
                    .padding(.horizontal, sizeConfig.carouselNameHorizontalPadding)
                    .padding(.bottom, sizeConfig.carouselNameBottomPadding)
            }

            MultiItemHorizontalCarousel(
                currentPageIndex: $viewModel.currentPageIndex,
                items: items,
                itemWidth: sizeConfig.carouselItemWidth,
                itemHeight: sizeConfig.carouselItemHeight,
                spacing: sizeConfig.carouselItemSpacing,
                horizontalPadding: sizeConfig.carouselHorizontalPadding,
                onPageChange: handlePageChange(to:)
            ) { item, isSelected in
                buildCarouselItemView(item, isSelected: isSelected)
            }
            .coordinateSpace(name: "TimelineScrollSpace")
            .onAppear {
                handleCarouselViewed()
            }
        }
    }

    @ViewBuilder
    func buildCarouselItemView(
        _ item: TimelineViewModel.TimelineCarouselItem,
        isSelected: Bool
    ) -> some View {
        switch item {
        case .content(let asset, _):
            TimelineFeedAssetCard(
                viewData: viewModel.makeViewData(from: asset),
                isSelected: isSelected,
                sizeConfig: sizeConfig,
                onProductCtaTap: { url in
                    handleProductCtaTap(url: url)
                },
                onVideoFinished: {
                    handleVideoFinished()
                }
            )
            .onTapGesture {
                handleAssetTap(asset)
            }
            .onAppear {
                handleAssetAppeared(asset)
            }
        case .loading:
            TimelineFeedAssetCardSkeleton(sizeConfig: sizeConfig)
        }
    }

    var loadingView: some View {
        TimelineFeedSkeletonCarousel(sizeConfig: sizeConfig)
    }

    func buildErrorView(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .imageScale(.large)
                .foregroundColor(.red)

            Text(message)
                .font(.system(size: Self.errorFontSize))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(minWidth: UIScreen.main.bounds.width)
    }
}


// MARK: - Logic & Actions
private extension TimelineFeedView {

    func handleOnAppear() {
        viewModel.handleOnAppear()
    }

    func handlePageChange(to index: Int) {
        // Note: Auto-advance cancellation and restart is handled by handleCurrentItemChanged
        // which is triggered via onChange(of: currentPageIndex)
        viewModel.handlePageChange(to: index)
    }

    func handleAssetTap(_ asset: TimelineAssetDTO) {
        // Find the index of the tapped asset in carouselItems
        let index = viewModel.carouselItems.firstIndex { item in
            if case .content(let itemAsset, _) = item {
                return itemAsset.id == asset.id
            }
            return false
        }

        if let index {
            onAssetTap?(index)
        }
    }

    func handleProductCtaTap(url: URL?) {
        guard let url else { return }
        print("Product CTA tapped: \(url.absoluteString)")
    }

    func handleCarouselViewed() {
        viewModel.handleCarouselViewed()
    }

    func handleAssetAppeared(_ asset: TimelineAssetDTO) {
        viewModel.handleAssetAppeared(asset)
    }

    func handleCurrentItemChanged(to index: Int) {
        print("🔄 [AutoAdvance] handleCurrentItemChanged to index: \(index)")

        // Cancel any existing auto-advance task when item changes
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil

        // Only auto-advance if carouselAutoPlay is enabled
        guard viewModel.carouselConfig.carouselAutoPlay == true else { return }

        // Get current asset to check media type
        guard let asset = getCurrentAsset(at: index) else {
            print("🔄 [AutoAdvance] No asset at index \(index)")
            return
        }
        print("🔄 [AutoAdvance] Asset type: \(asset.type)")

        // Determine if we should start timer immediately or wait for video to finish
        let shouldStartTimerImmediately: Bool
        switch asset.type {
        case .image, .poll:
            // Images and polls never have video preview - start timer immediately
            shouldStartTimerImmediately = true
        case .video:
            // Videos always wait for video playback to finish
            shouldStartTimerImmediately = false
        case .ad:
            // Ads: start timer immediately if no video preview, otherwise wait for video
            shouldStartTimerImmediately = asset.media?.videoPreviewUrl == nil
        }

        if shouldStartTimerImmediately {
            startAutoAdvanceTimer()
        }
    }

    func handleVideoFinished() {
        print("🎬 [AutoAdvance] handleVideoFinished called")

        // Cancel any existing auto-advance task
        autoAdvanceTask?.cancel()

        // Only auto-advance if carouselAutoPlay is enabled
        // TODO: Uncomment after testing
        // guard viewModel.carouselConfig.carouselAutoPlay == true else { return }

        // Start auto-advance timer after video finishes
        startAutoAdvanceTimer()
    }

    func startAutoAdvanceTimer() {
        // Get the interval (default to 4 seconds if not specified)
        let interval = viewModel.carouselConfig.carouselAutoPlayInterval ?? 4.0
        print("⏱️ [AutoAdvance] Starting timer with interval: \(interval)s")

        autoAdvanceTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                if !Task.isCancelled {
                    print("⏱️ [AutoAdvance] Timer fired, advancing...")
                    await MainActor.run {
                        advanceToNextItem()
                    }
                } else {
                    print("⏱️ [AutoAdvance] Timer was cancelled")
                }
            } catch {
                print("⏱️ [AutoAdvance] Timer error: \(error)")
            }
        }
    }

    func advanceToNextItem() {
        let nextIndex = viewModel.currentPageIndex + 1
        let itemCount = viewModel.carouselItems.count
        print("➡️ [AutoAdvance] advanceToNextItem: current=\(viewModel.currentPageIndex), next=\(nextIndex), count=\(itemCount)")

        // Only advance if there's a next item
        guard nextIndex < itemCount else {
            print("➡️ [AutoAdvance] No more items to advance to")
            return
        }

        viewModel.currentPageIndex = nextIndex
        print("➡️ [AutoAdvance] Advanced to index \(nextIndex)")
    }

    func getCurrentAsset(at index: Int) -> TimelineAssetDTO? {
        let items = viewModel.carouselItems
        guard index < items.count else { return nil }

        if case .content(let asset, _) = items[index] {
            return asset
        }
        return nil
    }
}
