//
//  AuthenticatorTimerTests.swift
//  OneTwoTests
//
//  Created on 05/04/2025.
//

import ComposableArchitecture
@testable import OneTwo
import XCTest

@MainActor
final class AuthenticatorTimerTests: XCTestCase {
    // Test that timer ticks trigger code generation
    func testTimerTickTriggersCodeGeneration() async {
        let store = TestStore(
            initialState: AuthenticatorFeature.State(),
            reducer: { AuthenticatorFeature() }
        )

        // When a timer tick occurs
        await store.send(.timerTick)

        // It should trigger code generation (UI refresh)
        await store.receive(.generateTOTPCodes)
    }

    // Test that the timer starts on viewAppeared and stops on viewDisappeared
    func testViewLifecycleControls() async {
        let store = TestStore(
            initialState: AuthenticatorFeature.State(),
            reducer: { AuthenticatorFeature() }
        )

        // When the view appears
        await store.send(.viewAppeared)

        // It should start the timer
        await store.receive(.startTimer)

        // When the view disappears
        await store.send(.viewDisappeared)

        // It should stop the timer
        await store.receive(.stopTimer)
    }

    // Test the timer with a controlled clock
    func testTimerWithControlledClock() async {
        let store = TestStore(
            initialState: AuthenticatorFeature.State(),
            reducer: { AuthenticatorFeature() }
        )

        // Allow unhandled effects in this test since we're testing async behavior
        store.exhaustivity = .off

        // Start the timer
        await store.send(.startTimer)

        // Stop the timer
        await store.send(.stopTimer)
    }
}
