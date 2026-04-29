//
//  ActiveApplicationTracker.swift
//  knowzeno
//

import AppKit
import Observation

@MainActor
@Observable
final class ActiveApplicationTracker {
    private(set) var lastExternalApplication: NSRunningApplication?
    private let ownBundleIdentifier = Bundle.main.bundleIdentifier
    private var activationObserver: NSObjectProtocol?

    init() {
        updateLastExternalApplication(NSWorkspace.shared.frontmostApplication)

        activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
                return
            }

            Task { @MainActor [weak self] in
                self?.updateLastExternalApplication(application)
            }
        }
    }

    deinit {
        MainActor.assumeIsolated {
            if let activationObserver {
                NSWorkspace.shared.notificationCenter.removeObserver(activationObserver)
            }
        }
    }

    func reactivateLastExternalApplication() {
        lastExternalApplication?.activate()
    }

    private func updateLastExternalApplication(_ application: NSRunningApplication?) {
        guard let application,
              application.bundleIdentifier != ownBundleIdentifier else {
            return
        }

        lastExternalApplication = application
    }
}
