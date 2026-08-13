//
//  TimelineFeedView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 14.01.2026.
//

import SwiftUI
import ImageLoader

#if canImport(UIKit)
import UIKit
#endif

// MARK: - View
struct TimelineFeedView: View {

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText
    @Environment(\.openURL) private var openURL

    // MARK: - Dependencies
    @ObservedObject private var viewModel: TimelineViewModel

    // MARK: - Configuration
    private let sizeConfig: FeedStyleConfiguration

    // MARK: - Callbacks
    private let onAssetTap: ((Int) -> Void)?

    // MARK: - State
    @State private var autoAdvanceTask: Task<Void, Never>?
    @State private var highlightedScrollButton: CarouselScrollButtons.HighlightedButton?
    @State private var pageScrollDirection: PageScrollDirection?

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
        if #available(iOS 17, macOS 14, tvOS 17, *) {
            bodyContent
                .onChange(of: viewModel.currentPageIndex) { _, newIndex in
                    handleCurrentItemChanged(to: newIndex)
                }
        } else {
            // iOS16-COMPAT: Remove when minimum target is iOS 17
            bodyContent
                .onChange(of: viewModel.currentPageIndex) { newIndex in
                    handleCurrentItemChanged(to: newIndex)
                }
        }
    }

    private var bodyContent: some View {
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
    }
}

// MARK: - UI Components (Factories)
private extension TimelineFeedView {

    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear
                .frame(height: sizeConfig.totalCarouselHeight)

        case .loading:
            loadingView
                .frame(height: sizeConfig.totalCarouselHeight)

        case .content:
            buildAssetList(viewModel.carouselItems)

        case .error:
            // Hide carousel on error (no height)
            EmptyView()
        }
    }

    /// Whether the sponsor label row has content to show (label text or top logo)
    private func hasSponsorLabelContent(_ sponsorship: SponsorshipDTO?) -> Bool {
        let hasLabel = sponsorship?.sponsorLabel != nil && !(sponsorship?.sponsorLabel?.isEmpty ?? true)
        let hasTopLogo = sponsorship?.topLogoUrl != nil
        return hasLabel || hasTopLogo
    }

    @ViewBuilder
    func buildAssetList(_ items: [TimelineViewModel.TimelineCarouselItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Sponsor label row (above carousel name)
            if let sponsorship = viewModel.carouselConfig.sponsorship,
               sponsorship.enabled == true,
               hasSponsorLabelContent(sponsorship) {
                sponsorLabelRow(sponsorship: sponsorship)
                    .onTapGesture { handleCarouselSponsorshipTap(placement: .topLogo, url: sponsorship.clickRedirect) }
            }

            // Carousel name label (if showName is true)
            if let carouselName = viewModel.carouselConfig.name,
               viewModel.carouselConfig.showName == true {
                HStack(alignment: .bottom, spacing: 0) {
                    Text(carouselName)
                        .font(sizeConfig.carouselNameFont.toFont())
                        .foregroundColor(sizeConfig.carouselNameColor)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    // Scroll navigation buttons (iPad only)
                    #if canImport(UIKit)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        CarouselScrollButtons(
                            canScrollPrevious: viewModel.currentPageIndex > 0,
                            canScrollNext: viewModel.currentPageIndex < items.count - 1,
                            highlightedButton: $highlightedScrollButton,
                            buttonSize: sizeConfig.scrollButtonSize,
                            iconSize: sizeConfig.scrollButtonIconSize,
                            buttonSpacing: sizeConfig.scrollButtonSpacing,
                            capsuleHorizontalPadding: sizeConfig.scrollButtonCapsuleHorizontalPadding,
                            capsuleVerticalPadding: sizeConfig.scrollButtonCapsuleVerticalPadding,
                            onScrollPrevious: {
                                pageScrollDirection = .backward
                            },
                            onScrollNext: {
                                pageScrollDirection = .forward
                            }
                        )
                    }
                    #endif
                }
                .padding(.leading, sizeConfig.carouselNameHorizontalPadding)
                .padding(.trailing, sizeConfig.carouselNameHorizontalPadding * 2)
                .padding(.bottom, sizeConfig.carouselNameBottomPadding)
            }

            MultiItemHorizontalCarousel(
                currentPageIndex: $viewModel.currentPageIndex,
                pageScrollDirection: $pageScrollDirection,
                items: items,
                itemWidth: sizeConfig.carouselItemWidth,
                itemHeight: sizeConfig.carouselItemHeight,
                spacing: sizeConfig.carouselItemSpacing,
                horizontalPadding: sizeConfig.carouselHorizontalPadding,
                onPageChange: handlePageChange(to:)
            ) { item, isSelected, index, total in
                buildCarouselItemView(item, isSelected: isSelected)
                    .accessibilityValue(accessibilityText.itemPositionLabel(
                        current: index + 1,
                        total: total
                    ))
            }
            .frame(height: sizeConfig.carouselItemHeight)
            .coordinateSpace(name: "TimelineScrollSpace")
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilityText.carouselLabel)
            .accessibilityHint(accessibilityText.carouselHint)
            .onVisibilityThreshold(0.5) {
                handleCarouselViewed()
            }

            // Sponsor logo at bottom
            if let sponsorship = viewModel.carouselConfig.sponsorship,
               sponsorship.enabled == true,
               let sideLogoUrl = sponsorship.sideLogoUrl {
                sponsorLogoView(urlString: sideLogoUrl, backgroundColor: sponsorship.backgroundColor)
                    .padding(.top, sizeConfig.sponsorLogoTopSpacing)
                    .onTapGesture { handleCarouselSponsorshipTap(placement: .sideLogo, url: sponsorship.clickRedirect) }
            }
        }
    }

    // MARK: - Sponsorship Views

    @ViewBuilder
    func sponsorLabelRow(sponsorship: SponsorshipDTO) -> some View {
        HStack(spacing: 8) {
            if let label = sponsorship.sponsorLabel, !label.isEmpty {
                Text(label)
                    .font(sizeConfig.sponsorLabelFont.toFont())
                    .foregroundColor(sizeConfig.sponsorLabelColor)
            }
            if let topLogoUrl = sponsorship.topLogoUrl {
                CachedAsyncImage(urlString: topLogoUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(height: sizeConfig.sponsorLabelHeight)
            }
        }
        .frame(height: sizeConfig.sponsorLabelHeight, alignment: .leading)
        .padding(.horizontal, sizeConfig.carouselNameHorizontalPadding)
        .padding(.vertical, sizeConfig.sponsorLabelPadding)
    }

    @ViewBuilder
    func sponsorLogoView(urlString: String, backgroundColor: String?) -> some View {
        CachedAsyncImage(urlString: urlString) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .frame(height: sizeConfig.sponsorLogoHeight)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(sizeConfig.sponsorLogoPadding)
        .background(backgroundColor.map { Color(hex: $0) } ?? .clear)
        .clipShape(CompatUnevenRoundedRectangle(bottomLeadingRadius: sizeConfig.cardCornerRadius, bottomTrailingRadius: sizeConfig.cardCornerRadius))
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
                onProductCtaTap: { productData, url in
                    handleProductCtaTap(productData: productData, asset: asset, url: url)
                },
                onVideoFinished: {
                    handleVideoFinished()
                }
            )
            .onTapGesture {
                handleAssetTap(asset)
            }
            .onVisibilityThreshold(0.5) {
                handleAssetAppeared(asset)
            }
        case .loading:
            TimelineAssetCardSkeleton(mode: .feed(sizeConfig))
        }
    }

    var loadingView: some View {
        TimelineFeedSkeletonCarousel(sizeConfig: sizeConfig)
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
        highlightedScrollButton = nil

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

    func handleProductCtaTap(productData: ProductData, asset: TimelineAssetDTO, url: URL?) {
        // Find the ProductDTO from the asset's products using the product ID
        guard let productDTO = asset.products?.first(where: { $0.id == productData.id }) else {
            return
        }
        viewModel.handleProductCtaTap(product: productDTO, asset: asset, url: url)
    }

    func handleCarouselViewed() {
        viewModel.handleCarouselViewed()
    }

    func handleCarouselSponsorshipTap(placement: CarouselSponsorshipPlacement, url urlString: String?) {
        viewModel.handleCarouselSponsorshipClicked(
            placement: placement,
            sponsorshipUrl: urlString
        )
        openSponsorRedirect(urlString)
    }

    func openSponsorRedirect(_ urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else { return }
        openURL(url)
    }

    func handleAssetAppeared(_ asset: TimelineAssetDTO) {
        viewModel.handleAssetAppeared(asset)
    }

    func handleCurrentItemChanged(to index: Int) {
        // Cancel any existing auto-advance task when item changes
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil

        // Only auto-advance if carouselAutoPlay is enabled
        guard viewModel.carouselConfig.carouselAutoPlay == true else { return }

        // Get current asset to check media type
        guard let asset = getCurrentAsset(at: index) else {
            return
        }

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
        // Cancel any existing auto-advance task
        autoAdvanceTask?.cancel()

        // Only auto-advance if carouselAutoPlay is enabled
        guard viewModel.carouselConfig.carouselAutoPlay == true else { return }

        // Start auto-advance timer after video finishes
        startAutoAdvanceTimer()
    }

    func startAutoAdvanceTimer() {
        // Get the interval (default to 4 seconds if not specified)
        let interval = viewModel.carouselConfig.carouselAutoPlayInterval ?? 4.0

        autoAdvanceTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                if !Task.isCancelled {
                    await MainActor.run {
                        advanceToNextItem()
                    }
                }
            } catch {
                // Task cancelled — expected when auto-advance is disabled
            }
        }
    }

    func advanceToNextItem() {
        let nextIndex = viewModel.currentPageIndex + 1
        let itemCount = viewModel.carouselItems.count

        // Only advance if there's a next item
        guard nextIndex < itemCount else {
            return
        }

        viewModel.currentPageIndex = nextIndex
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
