//
//  One_TwoApp.swift
//  One Two
//
//  Created by Nando Thomassen on 12/12/2024.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

// MARK: - App Entry Point
@main
struct OneTwoApp: App {
    static let store = Store(
        initialState: AuthenticatorFeature.State()
    ) {
        AuthenticatorFeature()
    }

    var body: some Scene {
        WindowGroup {
            AuthenticatorView(store: OneTwoApp.store)
        }
    }
}
