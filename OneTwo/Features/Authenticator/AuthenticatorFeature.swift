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
        case generateTOTPCodes
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.totpGenerator) var totpGenerator

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

            case .generateTOTPCodes:
                // This action is used to trigger a UI refresh when needed
                // The actual code generation happens in the view when the account is displayed
                return .none
            }
        }
    }
}
