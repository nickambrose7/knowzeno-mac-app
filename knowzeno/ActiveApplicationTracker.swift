//
//  ActiveApplicationTracker.swift
//  knowzeno
//

import AppKit
import Combine

@MainActor
final class ActiveApplicationTracker: ObservableObject {
    private(set) var lastExternalApplication: NSRunningApplication?
    private let ownBundleIdentifier = Bundle.main.bundleIdentifier

    init() {
        updateLastExternalApplication(NSWorkspace.shared.frontmostApplication)

        NSWorkspace.shared.notificationCenter.addObserver(
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
