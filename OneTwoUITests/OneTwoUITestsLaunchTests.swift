//
//  OneTwoUITestsLaunchTests.swift
//  OneTwoUITests
//
//  Created by Nando Thomassen on 12/12/2024.
//

import XCTest

final class OneTwoUITestsLaunchTests: XCTestCase {
    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        // More reliable way to wait for the app to be ready
        XCTAssert(app.wait(for: .runningForeground, timeout: 5))

        // Take screenshot without additional expectations that might fail
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
