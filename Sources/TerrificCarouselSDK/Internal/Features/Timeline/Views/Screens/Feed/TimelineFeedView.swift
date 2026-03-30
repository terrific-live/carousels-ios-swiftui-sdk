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
    private let sizeConfig: FeedSizeConfiguration

    // MARK: - Callbacks
    private let onAssetTap: ((Int) -> Void)?

    // MARK: - Init
    init(
        viewModel: TimelineViewModel,
        sizeConfig: FeedSizeConfiguration = .default,
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
}
