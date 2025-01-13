//
//  AuthenticatorFeature.swift
//  OneTwo
//
//  Created by Nando Thomassen on 14/12/2024.
//

import ComposableArchitecture
import Foundation

// MARK: - Feature

@Reducer
struct AuthenticatorFeature {
    struct State: Equatable {
        var accounts: IdentifiedArrayOf<Account> = []
    }

    enum Action {
        case addAccountButtonTapped
        case deleteAccount(IndexSet)
    }

    @Dependency(\.uuid) var uuid

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addAccountButtonTapped:
                let newAccount = Account(
                    id: uuid(),
                    name: "Example Account \(state.accounts.count + 1)",
                    secret: "JBSWY3DPEHPK3PXP" // Example secret key
                )

                state.accounts.append(newAccount)
                return .none

            case let .deleteAccount(indexSet):
                state.accounts.remove(atOffsets: indexSet)
                return .none
            }
        }
    }
}
