//
//  App.swift
//  OneTwo
//
//  Created by Nando Thomassen on 12/12/2024.
//

import ComposableArchitecture
import SwiftData
import SwiftUI

// MARK: - App Entry Point

@main
struct OneTwoApp: App {
    static let store = Store(
        initialState: AuthenticatorFeature.State(),
        reducer: {
            AuthenticatorFeature()
                ._printChanges()
        }
    )

    init() {
        // Configure the TOTP generator for UI testing if needed
        if ProcessInfo.processInfo.isUITesting {
            withDependencies {
                $0[TOTPGeneratorKey.self] = TOTPGeneratorKey.testUIValue
            } operation: {
                // No operation needed here
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            AuthenticatorView(store: OneTwoApp.store)
        }
    }
}
