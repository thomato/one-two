//
//  AuthenticatorView.swift
//  OneTwo
//
//  Created by Nando Thomassen on 14/12/2024.
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Views

struct AuthenticatorView: View {
    let store: StoreOf<AuthenticatorFeature>
    @State private var refreshTimer: Timer?

    // Access the totpGenerator directly through the dependency system
    @Dependency(\.totpGenerator) var totpGenerator

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    ForEach(viewStore.accounts) { account in
                        AccountRowView(
                            account: account,
                            totpGenerator: totpGenerator
                        )
                    }
                    .onDelete { indexSet in
                        viewStore.send(.deleteAccount(indexSet))
                    }
                }
                .navigationTitle("One Two")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { viewStore.send(.addAccountButtonTapped) }) {
                            Label("Add Account", systemImage: "plus")
                        }
                    }
                }
                .onAppear {
                    // Set up a timer to refresh the UI every second for the countdown display
                    refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        viewStore.send(.generateTOTPCodes)
                    }
                }
                .onDisappear {
                    refreshTimer?.invalidate()
                    refreshTimer = nil
                }
            }
        }
    }
}

struct AccountRowView: View {
    let account: Account
    let totpGenerator: TOTPGeneratorProtocol

    @State private var currentTime = Date()

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)

                if let issuer = account.issuer {
                    Text(issuer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(account.generateCode(using: totpGenerator, at: currentTime))
                    .font(.system(.title, design: .monospaced))
                    .foregroundStyle(.blue)
            }

            Spacer()

            // Display the time remaining
            TimeRemainingView(
                timeRemaining: account.timeRemaining,
                period: account.period
            )
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { time in
            currentTime = time
        }
    }
}

struct TimeRemainingView: View {
    let timeRemaining: Double
    let period: Int

    var body: some View {
        Text("\(Int(timeRemaining))s")
            .foregroundStyle(.secondary)
            .monospacedDigit()
            .frame(width: 30)
    }
}

// MARK: - Previews

#Preview("Empty") {
    AuthenticatorView(
        store: Store(
            initialState: AuthenticatorFeature.State(),
            reducer: { AuthenticatorFeature() }
        )
    )
}

#Preview("With Accounts") {
    AuthenticatorView(
        store: Store(
            initialState: AuthenticatorFeature.State(
                accounts: [
                    Account(id: UUID(), name: "GitHub", secret: "JBSWY3DPEHPK3PXP"),
                    Account(id: UUID(), name: "Google", secret: "WAAZK3PNR2KA2", issuer: "Google"),
                    Account(id: UUID(), name: "AWS", secret: "FVX4NKHFVFDMW", algorithm: .sha256),
                ]
            ),
            reducer: { AuthenticatorFeature() }
        )
    )
}
