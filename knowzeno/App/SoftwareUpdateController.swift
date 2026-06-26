//
//  SoftwareUpdateController.swift
//  knowzeno
//

import Sparkle

@MainActor
final class SoftwareUpdateController {
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
