//
//  CarouselDemoApp.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 14.01.2026.
//

import SwiftUI
import TerrificCarouselSDK

@main
struct CarouselDemoApp: App {

    @State private var selectedConfiguration: APIConfiguration?

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if let configuration = selectedConfiguration {
                    timelineView(for: configuration)
                } else {
                    EnvironmentSelectionView { configuration in
                        selectedConfiguration = configuration
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func timelineView(for configuration: APIConfiguration) -> some View {
        VStack {
            // Back button
            HStack {
                Button(action: {
                    selectedConfiguration = nil
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Change Environment")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 8)

            CarouselView(
                apiConfiguration: configuration,
                styleConfiguration: .default,
                onAnalyticsEvent: { event in
                    switch event {
                    case .assetLiked(asset: _):
                        debugPrint("Track asset liked event")
                    default:
                        break
                    }
                }
            )
        }
    }
}
