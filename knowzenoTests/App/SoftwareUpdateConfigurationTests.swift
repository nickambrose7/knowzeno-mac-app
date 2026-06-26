//
//  SoftwareUpdateConfigurationTests.swift
//  knowzenoTests
//

import XCTest

final class SoftwareUpdateConfigurationTests: XCTestCase {
    func testSparkleInfoPlistConfigurationIsPresent() {
        XCTAssertEqual(
            Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String,
            "https://github.com/nickambrose7/knowzeno-mac-app/releases/latest/download/appcast.xml"
        )
        XCTAssertEqual(
            Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String,
            "32wRHP5t0bJm6vSb+ktyJaTPsVSkUABIT7QrQlJVc7w="
        )
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "SUEnableAutomaticChecks") as? Bool, true)
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "SUEnableInstallerLauncherService") as? Bool, true)
    }
}
