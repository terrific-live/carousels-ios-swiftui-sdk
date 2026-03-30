//
//  ImageLoadingState.swift
//  ImageLoader
//

// MARK: - ImageLoadingState
public enum ImageLoadingState: Equatable {
    case idle
    case loading
    case loaded(PlatformImage)
    case failed(Error)

    public static func == (lhs: ImageLoadingState, rhs: ImageLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.loaded(let lhsImage), .loaded(let rhsImage)):
            return lhsImage === rhsImage
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
