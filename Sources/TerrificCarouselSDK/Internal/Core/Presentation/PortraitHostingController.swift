//
//  PortraitHostingController.swift
//  CarouselDemo
//
//  A hosting controller that locks orientation to portrait.
//  Used to ensure carousel detail views are always presented in portrait mode.
//

import SwiftUI

// MARK: - PortraitHostingController
/// A UIHostingController subclass that locks the interface orientation to portrait.
final class PortraitHostingController<Content: View>: UIHostingController<Content> {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    override var shouldAutorotate: Bool {
        false
    }
}

// MARK: - PortraitCoverController
/// Controller that manages portrait-locked fullscreen presentation
final class PortraitCoverController: UIViewController {
    var contentBuilder: ((@escaping () -> Void) -> AnyView)?
    var isPresenting: Bool { presentedHostingController != nil }
    private var presentedHostingController: UIViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    func presentContent() {
        guard presentedHostingController == nil, let contentBuilder = contentBuilder else { return }

        let dismissAction: () -> Void = { [weak self] in
            self?.dismissContent()
        }

        let content = contentBuilder(dismissAction)
        let hostingController = PortraitHostingController(rootView: content)
        hostingController.modalPresentationStyle = .fullScreen

        presentedHostingController = hostingController

        // Find the top view controller to present from
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           var topVC = window.rootViewController {
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(hostingController, animated: true)
        }
    }

    func dismissContent() {
        guard let presented = presentedHostingController else { return }
        presented.dismiss(animated: true) { [weak self] in
            self?.presentedHostingController = nil
            NotificationCenter.default.post(name: .portraitCoverDismissed, object: nil)
        }
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let portraitCoverDismissed = Notification.Name("portraitCoverDismissed")
}

// MARK: - PortraitFullScreenCover
struct PortraitFullScreenCover<FullScreenContent: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let content: (@escaping () -> Void) -> FullScreenContent

    func makeUIViewController(context: Context) -> PortraitCoverController {
        let controller = PortraitCoverController()
        controller.view.backgroundColor = .clear
        controller.view.isHidden = true
        return controller
    }

    func updateUIViewController(_ controller: PortraitCoverController, context: Context) {
        controller.contentBuilder = { dismiss in
            AnyView(content(dismiss))
        }

        if isPresented && !controller.isPresenting {
            DispatchQueue.main.async {
                controller.presentContent()
            }
        }
    }

    static func dismantleUIViewController(_ controller: PortraitCoverController, coordinator: ()) {
        controller.dismissContent()
    }
}

// MARK: - View Modifier
struct PortraitFullScreenModifier<FullScreenContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let fullScreenContent: (@escaping () -> Void) -> FullScreenContent

    func body(content: Content) -> some View {
        content
            .background(
                PortraitFullScreenCover(isPresented: $isPresented, content: fullScreenContent)
            )
            .onReceive(NotificationCenter.default.publisher(for: .portraitCoverDismissed)) { _ in
                isPresented = false
            }
    }
}

// MARK: - View Extension
extension View {
    /// Presents a fullscreen cover locked to portrait orientation.
    /// The content closure receives a dismiss function to call when closing.
    func portraitFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content
    ) -> some View {
        modifier(PortraitFullScreenModifier(isPresented: isPresented, fullScreenContent: content))
    }
}
