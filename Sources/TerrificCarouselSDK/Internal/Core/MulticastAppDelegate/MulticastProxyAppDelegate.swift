//
//  MulticastAppDelegate.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 30.01.2026.
//

import UIKit

class MulticastProxyAppDelegate: UIResponder, UIApplicationDelegate {

    private var delegates: [UIApplicationDelegate]

    init(delegates: [UIApplicationDelegate] = []) {
        self.delegates = delegates
        super.init()
    }

    // Required for UIResponder
    override convenience init() {
        self.init(delegates: [])
    }

    func addAppDelegate(_ delegate: UIApplicationDelegate) {
        self.delegates.append(delegate)
    }

    // MARK: - Lifecycle Events

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Forward to all delegates
        for delegate in delegates {
            _ = delegate.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        for delegate in delegates {
            delegate.applicationDidBecomeActive?(application)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        for delegate in delegates {
            delegate.applicationDidEnterBackground?(application)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        for delegate in delegates {
            delegate.applicationWillTerminate?(application)
        }
    }

    // MARK: - Push Notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        for delegate in delegates {
            delegate.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        for delegate in delegates {
            delegate.application?(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }

    // MARK: - Deep Links (URL Handling)

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        for delegate in delegates {
            // If ANY delegate handles the URL, we return true
            if let result = delegate.application?(app, open: url, options: options), result == true {
                handled = true
            }
        }
        return handled
    }

    // MARK: - Scene Configuration (iOS 13+)

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Usually, only the main delegate handles scenes.
        // If multiple delegates try to return a config, you must decide which one wins.
        // Here, we return the first non-nil configuration or a default one.

        for delegate in delegates {
            if let config = delegate.application?(application, configurationForConnecting: connectingSceneSession, options: options) {
                return config
            }
        }

        // Default fallback if no delegate handles it
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
