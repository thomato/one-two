//
//  AuthenticatorView.swift
//  One Two
//
//  Created by Nando Thomassen on 14/12/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

// MARK: - Views
struct AuthenticatorView: View {
    let store: StoreOf<AuthenticatorFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    ForEach(viewStore.accounts) { account in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(account.name)
                                    .font(.headline)

                                Text(account.currentCode)
                                    .font(.system(.title, design: .monospaced))
                                    .foregroundStyle(.blue)
                            }
                            Spacer()
                        }
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
            }
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
                    Account(id: UUID(), name: "Google", secret: "WAAZK3PNR2KA2"),
                    Account(id: UUID(), name: "AWS", secret: "FVX4NKHFVFDMW")
                ]
            ),
            reducer: { AuthenticatorFeature() }
        )
    )
}
