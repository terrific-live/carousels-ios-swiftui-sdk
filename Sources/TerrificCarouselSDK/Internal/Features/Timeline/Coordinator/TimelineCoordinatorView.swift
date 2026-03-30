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
    private let sizeConfiguration: CarouselSizeConfiguration

    // MARK: - Init
    init(
        coordinator: TimelineCoordinator,
        sizeConfiguration: CarouselSizeConfiguration = .default
    ) {
        _coordinator = StateObject(wrappedValue: coordinator)
        self.sizeConfiguration = sizeConfiguration
    }

    // MARK: - Body
    var body: some View {
        TimelineFeedView(
            viewModel: coordinator.feedViewModel,
            sizeConfig: sizeConfiguration.feed,
            onAssetTap: { offset in
                coordinator.presentDetail(at: offset)
            }
        )
        .portraitFullScreenCover(isPresented: $coordinator.isDetailPresented) { dismiss in
            TimelineDetailView(
                viewModel: coordinator.makeDetailViewModel(),
                sizeConfig: sizeConfiguration.detail
            )
            .floatingCloseButton(28) {
                dismiss()
            }
            .coordinateSpace(name: "TimelineScrollSpace")
        }
    }
}

