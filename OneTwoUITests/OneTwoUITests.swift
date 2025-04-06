//
//  OneTwoUITests.swift
//  OneTwoUITests
//
//  Created by Nando Thomassen on 12/12/2024.
//

import XCTest

final class OneTwoUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests
        // before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // Configure the app with the UI testing flag to prevent any special behavior
            // that might cause premature exit
            let app = XCUIApplication()
            app.launchArguments = ["--uitesting"]

            // This measures how long it takes to launch your application
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()

                // Wait for the app to fully launch before terminating it
                XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

                // Terminate the app manually at the end of each measurement run
                app.terminate()
            }
        }
    }
}
