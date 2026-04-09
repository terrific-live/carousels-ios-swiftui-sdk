//
//  EnvironmentSelectionView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 02.03.2026.
//

import SwiftUI
import TerrificCarouselSDK

// MARK: - APIEnvironmentOption
enum APIEnvironmentOption: String, CaseIterable, Identifiable {
    case francTV = "France TV (Production)"
    case test = "Test Store (Staging)"
    case test2 = "Test Store 2 (Staging)"

    var id: String { rawValue }

    var configuration: APIConfiguration {
        switch self {
        case .francTV:
            return .francTVConfiguration
        case .test:
            return .testStoreConfiguration
        case .test2:
            return .tesVolodimirtStagingConfiguration
        }
    }

    var description: String {
        switch self {
        case .francTV:
            return "Live production environment"
        case .test:
            return "Staging environment for testing"
        case .test2:
            return "Staging environment for testing"
        }
    }

    var icon: String {
        switch self {
        case .francTV:
            return "tv"
        case .test:
            return "testtube.2"
        case .test2:
            return "testtube.2"
        }
    }
}

// MARK: - EnvironmentSelectionView
struct EnvironmentSelectionView: View {

    let onEnvironmentSelected: (APIConfiguration) -> Void

    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "server.rack")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text("Select Environment")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Choose which API endpoint to use")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 40)

            // Options
            VStack(spacing: 16) {
                ForEach(APIEnvironmentOption.allCases) { option in
                    EnvironmentOptionButton(option: option) {
                        onEnvironmentSelected(option.configuration)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - EnvironmentOptionButton
private struct EnvironmentOptionButton: View {
    let option: APIEnvironmentOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: option.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(option.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    EnvironmentSelectionView { config in
        print("Selected: \(config.baseURL)")
    }
}
