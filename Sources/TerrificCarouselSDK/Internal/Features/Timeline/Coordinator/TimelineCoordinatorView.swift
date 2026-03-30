//
//  TimelineCoordinatorView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 25.02.2026.
//

import SwiftUI

// MARK: - TimelineCoordinatorView
/// Root view for Timeline feature that manages navigation between Feed and Detail.
/// Owns the coordinator and handles view composition.
struct TimelineCoordinatorView: View {

    // MARK: - Dependencies
    @StateObject private var coordinator: TimelineCoordinator
    private let styleConfiguration: CarouselStyleConfiguration

    // MARK: - Init
    init(
        coordinator: TimelineCoordinator,
        sizeConfiguration: CarouselStyleConfiguration = .default
    ) {
        _coordinator = StateObject(wrappedValue: coordinator)
        self.styleConfiguration = sizeConfiguration
    }

    // MARK: - Body
    var body: some View {
        TimelineFeedView(
            viewModel: coordinator.feedViewModel,
            sizeConfig: styleConfiguration.feed,
            onAssetTap: { offset in
                coordinator.presentDetail(at: offset)
            }
        )
        .portraitFullScreenCover(isPresented: $coordinator.isDetailPresented) { dismiss in
            TimelineDetailView(
                viewModel: coordinator.makeDetailViewModel(),
                styleConfig: styleConfiguration.detail
            )
            .floatingCloseButton(28) {
                dismiss()
            }
            .coordinateSpace(name: "TimelineScrollSpace")
        }
    }
}

