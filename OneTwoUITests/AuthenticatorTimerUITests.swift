//
//  AuthenticatorTimerUITests.swift
//  OneTwoUITests
//
//  Created on 05/04/2025.
//

import XCTest

final class AuthenticatorTimerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTimerUpdatesUI() throws {
        let app = XCUIApplication()
        app.launch()

        // Add an account if there are none
        if app.cells.count == 0 {
            app.buttons["Add Account"].tap()

            // Wait for the cell to appear
            XCTAssertTrue(
                app.cells.firstMatch.waitForExistence(timeout: 3),
                "Account cell should appear after adding"
            )
        }

        // Ensure we have at least one cell
        XCTAssertGreaterThan(app.cells.count, 0, "Should have at least one account cell")

        // Take a screenshot of initial state for debugging
        let screenshot1 = XCUIScreen.main.screenshot()
        let attachment1 = XCTAttachment(screenshot: screenshot1)

        attachment1.name = "Initial State"
        attachment1.lifetime = .keepAlways

        add(attachment1)

        // Wait a moment to capture the initial UI state
        sleep(1)

        // Capture the current UI state
        let initialState = app.cells.firstMatch.debugDescription

        // Wait for timer to tick
        sleep(3)

        // Take another screenshot after waiting
        let screenshot2 = XCUIScreen.main.screenshot()
        let attachment2 = XCTAttachment(screenshot: screenshot2)

        attachment2.name = "After Waiting"
        attachment2.lifetime = .keepAlways

        add(attachment2)

        // Capture the updated UI state
        let updatedState = app.cells.firstMatch.debugDescription

        // The cell's description should change due to the timer updating
        XCTAssertNotEqual(
            initialState,
            updatedState,
            "Cell should change after timer update"
        )
    }
}
