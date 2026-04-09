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
    @StateObject private var analyticsStore = AnalyticsEventStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if let configuration = selectedConfiguration {
                    timelineView(for: configuration)
                } else {
                    EnvironmentSelectionView { configuration in
                        analyticsStore.clear()
                        selectedConfiguration = configuration
                    }
                }
            }
            .onAppear {
                CarouselDebugConfiguration.isHTTPLoggingEnabled = true
                CarouselDebugConfiguration.isVideoLoggingEnabled = true
            }
        }
    }

    @ViewBuilder
    private func timelineView(for configuration: APIConfiguration) -> some View {
        VStack(spacing: 0) {
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
                    analyticsStore.add(event)
                }
            )

            AnalyticsEventsView(store: analyticsStore)
        }
    }
}
