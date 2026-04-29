//
//  TimelineDetailView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 21.01.2026.
//

import SwiftUI

// MARK: - View
struct TimelineDetailView: View {

    // MARK: - Dependencies
    @ObservedObject private var viewModel: TimelineViewModel

    // MARK: - Configuration
    private let styleConfig: DetailStyleConfiguration

    // MARK: - Callbacks
    private let onDismiss: (() -> Void)?

    // MARK: - State
    @State private var isMuted: Bool = true
    @State private var showSwipeHint: Bool = false
    @State private var showErrorAlert: Bool = false

    // MARK: - Init
    init(
        viewModel: TimelineViewModel,
        styleConfig: DetailStyleConfiguration = .default,
        onDismiss: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.styleConfig = styleConfig
        self.onDismiss = onDismiss
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
                switch newState {
                case .content:
                    // Show swipe hint when content loads
                    if !showSwipeHint {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showSwipeHint = true
                        }
                    }
                case .error:
                    showErrorAlert = true
                default:
                    break
                }
            }
            .alert("Erreur", isPresented: $showErrorAlert) {
                Button("OK") {
                    onDismiss?()
                }
            } message: {
                Text("Une erreur s'est produite.")
            }
    }
}

// MARK: - UI Components (Factories)
private extension TimelineDetailView {

    @ViewBuilder
    var content: some View {
        switch viewModel.state {
        case .idle, .error:
            Color.clear

        case .loading:
            loadingView

        case .content:
            buildAssetList(viewModel.carouselItems)
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
