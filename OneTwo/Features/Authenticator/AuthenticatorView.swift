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
                    viewStore.send(.viewAppeared)
                }
                .onDisappear {
                    viewStore.send(.viewDisappeared)
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

    private var progress: Double {
        timeRemaining / Double(period)
    }

    var body: some View {
        ZStack {
            // Circular progress indicator
            Circle()
                .stroke(lineWidth: 2)
                .opacity(0.3)
                .foregroundColor(.secondary)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)

            // Timer text
            Text("\(Int(timeRemaining))s")
                .font(.callout)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Previews

struct AuthenticatorTimerPreview: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode, portrait iPhone
            AuthenticatorView(
                store: Store(
                    initialState: AuthenticatorFeature.State(
                        accounts: [
                            Account(name: "github@example.com", secret: "JBSWY3DPEHPK3PXP", issuer: "GitHub"),
                            Account(name: "personal@example.com", secret: "WAAZK3PNR2KA2", issuer: "Google"),
                            Account(name: "work@example.com", secret: "FVX4NKHFVFDMW", issuer: "Microsoft"),
                        ]
                    )
                ) {
                    AuthenticatorFeature()
                }
            )
            .previewDisplayName("iPhone 15 Pro - Light Mode")
            .previewDevice("iPhone 15 Pro")

            // Dark mode, portrait iPhone
            AuthenticatorView(
                store: Store(
                    initialState: AuthenticatorFeature.State(
                        accounts: [
                            Account(name: "github@example.com", secret: "JBSWY3DPEHPK3PXP", issuer: "GitHub"),
                            Account(name: "personal@example.com", secret: "WAAZK3PNR2KA2", issuer: "Google"),
                            Account(name: "work@example.com", secret: "FVX4NKHFVFDMW", issuer: "Microsoft"),
                        ]
                    )
                ) {
                    AuthenticatorFeature()
                }
            )
            .previewDisplayName("iPhone 15 Pro - Dark Mode")
            .previewDevice("iPhone 15 Pro")
            .preferredColorScheme(.dark)

            // Light mode, landscape iPhone
            AuthenticatorView(
                store: Store(
                    initialState: AuthenticatorFeature.State(
                        accounts: [
                            Account(name: "github@example.com", secret: "JBSWY3DPEHPK3PXP", issuer: "GitHub"),
                            Account(name: "personal@example.com", secret: "WAAZK3PNR2KA2", issuer: "Google"),
                            Account(name: "work@example.com", secret: "FVX4NKHFVFDMW", issuer: "Microsoft"),
                        ]
                    )
                ) {
                    AuthenticatorFeature()
                }
            )
            .previewDisplayName("iPhone 15 Pro Landscape - Light Mode")
            .previewDevice("iPhone 15 Pro")
            .previewInterfaceOrientation(.landscapeLeft)

            // iPad Light mode
            AuthenticatorView(
                store: Store(
                    initialState: AuthenticatorFeature.State(
                        accounts: [
                            Account(name: "github@example.com", secret: "JBSWY3DPEHPK3PXP", issuer: "GitHub"),
                            Account(name: "personal@example.com", secret: "WAAZK3PNR2KA2", issuer: "Google"),
                            Account(name: "work@example.com", secret: "FVX4NKHFVFDMW", issuer: "Microsoft"),
                        ]
                    )
                ) {
                    AuthenticatorFeature()
                }
            )
            .previewDisplayName("iPad Pro - Light Mode")
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")

            // iPad Dark mode
            AuthenticatorView(
                store: Store(
                    initialState: AuthenticatorFeature.State(
                        accounts: [
                            Account(name: "github@example.com", secret: "JBSWY3DPEHPK3PXP", issuer: "GitHub"),
                            Account(name: "personal@example.com", secret: "WAAZK3PNR2KA2", issuer: "Google"),
                            Account(name: "work@example.com", secret: "FVX4NKHFVFDMW", issuer: "Microsoft"),
                        ]
                    )
                ) {
                    AuthenticatorFeature()
                }
            )
            .previewDisplayName("iPad Pro - Dark Mode")
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .preferredColorScheme(.dark)

            // iPad Landscape
            AuthenticatorView(
                store: Store(
                    initialState: AuthenticatorFeature.State(
                        accounts: [
                            Account(name: "github@example.com", secret: "JBSWY3DPEHPK3PXP", issuer: "GitHub"),
                            Account(name: "personal@example.com", secret: "WAAZK3PNR2KA2", issuer: "Google"),
                            Account(name: "work@example.com", secret: "FVX4NKHFVFDMW", issuer: "Microsoft"),
                        ]
                    )
                ) {
                    AuthenticatorFeature()
                }
            )
            .previewDisplayName("iPad Pro Landscape")
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewInterfaceOrientation(.landscapeRight)
        }
    }
}

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
