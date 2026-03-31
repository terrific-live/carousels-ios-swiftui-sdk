//
//  AudioSessionConfigurator.swift
//  MediaPlayback
//

#if canImport(UIKit)
import UIKit
import AVFAudio

/// App delegate for configuring audio session for video playback.
///
/// This specifically tells the operating system: "I am about to play audio associated with
/// a movie/video, but I don't want to stop background music from other apps (like Spotify),
/// and I want to play even if the phone is on Silent."
///
/// ## Usage
/// Add this delegate to your App using `@UIApplicationDelegateAdaptor`:
/// ```swift
/// @main
/// struct MyApp: App {
///     @UIApplicationDelegateAdaptor(AudioSessionConfigurator.self) var delegate
///     // ...
/// }
/// ```
///
/// ## Configuration Details
/// - **setCategory(.playback)**: Overrides the Silent switch and allows background audio
/// - **mode: .moviePlayback**: Optimizes audio signal processing for video content
/// - **options: .mixWithOthers**: Allows other app's music to keep playing
/// - **setActive(true)**: Activates the configuration
public final class AudioSessionAppDelegate: NSObject, UIApplicationDelegate {

    public override init() {
        super.init()
    }

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureAudioSession()
        return true
    }

    /// Configures the audio session for video playback.
    /// Can be called manually if needed outside of app launch.
    public func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback,
                options: .mixWithOthers
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logMediaPlayback("[AudioConfig] Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}
#endif
