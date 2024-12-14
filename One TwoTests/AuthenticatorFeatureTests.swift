//
//  One_TwoTests.swift
//  One TwoTests
//
//  Created by Nando Thomassen on 12/12/2024.
//

import XCTest
import ComposableArchitecture
@testable import One_Two

@MainActor
final class AuthenticatorFeatureTests: XCTestCase {
    func testAddAccount() async {
        let store = withDependencies {
            $0.uuid = .incrementing
        } operation: {
            TestStore(
                initialState: AuthenticatorFeature.State(),
                reducer: { AuthenticatorFeature() }
            )
        }

        await store.send(.addAccountButtonTapped) { state in
            state.accounts = [
                Account(
                    id: UUID(0),
                    name: "Example Account 1",
                    secret: "JBSWY3DPEHPK3PXP"
                )
            ]
        }

        await store.send(.addAccountButtonTapped) { state in
            state.accounts = [
                Account(
                    id: UUID(0),
                    name: "Example Account 1",
                    secret: "JBSWY3DPEHPK3PXP"
                ),
                Account(
                    id: UUID(1),
                    name: "Example Account 2",
                    secret: "JBSWY3DPEHPK3PXP"
                )
            ]
        }
    }

    func testDeleteSingleAccount() async {
        let store = withDependencies {
            $0.uuid = .incrementing
        } operation: {
            TestStore(
                initialState: AuthenticatorFeature.State(
                    accounts: [
                        Account(
                            id: UUID(0),
                            name: "Example Account 1",
                            secret: "JBSWY3DPEHPK3PXP"
                        )
                    ]
                ),
                reducer: { AuthenticatorFeature() }
            )
        }

        await store.send(.deleteAccount([0])) { state in
            state.accounts = []
        }
    }

    func testDeleteMultipleAccounts() async {
        let store = withDependencies {
            $0.uuid = .incrementing
        } operation: {
            TestStore(
                initialState: AuthenticatorFeature.State(
                    accounts: [
                        Account(
                            id: UUID(0),
                            name: "Example Account 1",
                            secret: "JBSWY3DPEHPK3PXP"
                        ),
                        Account(
                            id: UUID(1),
                            name: "Example Account 2",
                            secret: "JBSWY3DPEHPK3PXP"
                        ),
                        Account(
                            id: UUID(2),
                            name: "Example Account 3",
                            secret: "JBSWY3DPEHPK3PXP"
                        )
                    ]
                ),
                reducer: { AuthenticatorFeature() }
            )
        }

        await store.send(.deleteAccount([0, 2])) { state in
            state.accounts = [
                Account(
                    id: UUID(1),
                    name: "Example Account 2",
                    secret: "JBSWY3DPEHPK3PXP"
                )
            ]
        }
    }
}
