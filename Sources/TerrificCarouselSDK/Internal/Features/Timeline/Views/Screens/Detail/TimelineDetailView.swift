//
//  TimelineDetailView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 21.01.2026.
//

import SwiftUI

// MARK: - View
struct TimelineDetailView: View {

    // MARK: - Static Constants
    private static let errorFontSize: CGFloat = 14

    // MARK: - Dependencies
    @ObservedObject private var viewModel: TimelineViewModel

    // MARK: - Configuration
    private let styleConfig: DetailStyleConfiguration

    // MARK: - State
    @State private var isMuted: Bool = true
    @State private var showSwipeHint: Bool = false

    // MARK: - Init
    init(
        viewModel: TimelineViewModel,
        styleConfig: DetailStyleConfiguration = .default
    ) {
        self.viewModel = viewModel
        self.styleConfig = styleConfig
    }

    // MARK: - Body
    var body: some View {
        content
            .background(Color.black)
            .overlay {
                if showSwipeHint {
                    SwipeHintOverlayView(text: viewModel.carouselConfig.swipeUpText) {
                        showSwipeHint = false
                    }
                }
            }
            .onAppear {
                handleOnAppear()
            }
            .onDisappear {
                viewModel.handleDetailViewDisappear()
            }
            .onChange(of: viewModel.state) { _, newState in
                // Show swipe hint when content loads
                if case .content = newState, !showSwipeHint {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSwipeHint = true
                    }
                }
            }
    }
}

// MARK: - UI Components (Factories)
private extension TimelineDetailView {

    @ViewBuilder
    var content: some View {
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
    }

    @ViewBuilder
    func buildAssetList(_ items: [TimelineViewModel.TimelineCarouselItem]) -> some View {
        PagedCarouselView(
            selection: $viewModel.currentPageIndex,
            items: items,
            scrollDirection: .vertical,
            onPageChange: handlePageChange(to:)
        ) { item, isSelected in
            buildCarouselItemView(item, isSelected: isSelected)
        }
    }

    @ViewBuilder
    func buildCarouselItemView(
        _ item: TimelineViewModel.TimelineCarouselItem,
        isSelected: Bool
    ) -> some View {
        switch item {
        case .content(let asset, _):
            let viewData = viewModel.makeViewData(from: asset)
            TimelineDetailAssetCard(
                viewData: viewData,
                isSelected: isSelected,
                isLiked: viewModel.isAssetLiked(asset.id),
                displayDuration: TimelineViewModel.imageDisplayDuration,
                sizeConfig: styleConfig,
                isMuted: $isMuted,
                onCtaButtonTap: {
                    handleCtaButtonTap(asset: asset, viewData: viewData)
                },
                onProductCtaTap: { productData, url in
                    handleProductCtaTap(productData: productData, asset: asset, url: url)
                },
                onLikeTap: {
                    handleLikeTap(asset)
                },
                onShareTap: {
                    handleShareTap(asset, viewData: viewData)
                },
                onVideoFinished: {
                    viewModel.handleVideoFinished()
                }
            )
        case .loading:
            TimelineDetailAssetCardSkeleton()
        }
    }

    var loadingView: some View {
        TimelineDetailAssetCardSkeleton()
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
private extension TimelineDetailView {

    func handleOnAppear() {
        viewModel.enableAutoAdvance()
        viewModel.handleOnAppear()
    }

    func handlePageChange(to index: Int) {
        viewModel.handlePageChange(to: index)
    }

    func handleCtaButtonTap(asset: TimelineAssetDTO, viewData: TimelineAssetData) {
        viewModel.handleCtaButtonTap(asset: asset, url: viewData.ctaButton?.url)
    }

    func handleProductCtaTap(productData: ProductData, asset: TimelineAssetDTO, url: URL?) {
        // Find the ProductDTO from the asset's products using the product ID
        guard let productDTO = asset.products?.first(where: { $0.id == productData.id }) else {
            return
        }
        viewModel.handleProductCtaTap(product: productDTO, asset: asset, url: url)
    }

    func handleLikeTap(_ asset: TimelineAssetDTO) {
        viewModel.handleAssetLiked(asset)
    }

    func handleShareTap(_ asset: TimelineAssetDTO, viewData: TimelineAssetData) {
        // Track analytics
        viewModel.handleAssetShared(asset)

        // Show share sheet
        let items = ShareHelper.createShareItems(from: viewData)
        ShareHelper.share(items: items)
    }
}
