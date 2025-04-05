//
//  AuthenticatorFeature.swift
//  OneTwo
//
//  Created by Nando Thomassen on 14/12/2024.
//

import Combine
import ComposableArchitecture
import Foundation

// MARK: - Timer ID

/// A unique identifier for the timer effect cancellation
private struct TimerId: Hashable {}

// MARK: - Feature

@Reducer
struct AuthenticatorFeature {
    struct State: Equatable {
        var accounts: IdentifiedArrayOf<Account> = []
    }

    enum Action: Equatable {
        case addAccountButtonTapped
        case deleteAccount(IndexSet)
        case generateTOTPCodes

        // Timer-related actions
        case startTimer
        case stopTimer
        case timerTick

        // View lifecycle actions
        case viewAppeared
        case viewDisappeared
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.totpGenerator) var totpGenerator
    @Dependency(\.continuousClock) var clock
    @Dependency(\.timerPublisher) private var timerPublisher

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

            case .startTimer:
                // Start the timer which will emit every second
                return .run { send in
                    let timer = timerPublisher
                    for await _ in timer() {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: TimerId())

            case .stopTimer:
                return .cancel(id: TimerId())

            case .timerTick:
                // Force a view refresh to update codes and timers
                return .send(.generateTOTPCodes)

            case .viewAppeared:
                return .send(.startTimer)

            case .viewDisappeared:
                return .send(.stopTimer)
            }
        }
    }
}

// MARK: - Timer Publisher Dependency

/// A dependency key for providing a clock-based timer
struct TimerPublisherKey: DependencyKey {
    static var liveValue: () -> AsyncStream<Date> = {
        AsyncStream { continuation in
            let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            let cancellable = timer.sink { date in
                continuation.yield(date)
            }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    static var testValue: () -> AsyncStream<Date> = {
        // Empty stream for tests
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}

extension DependencyValues {
    var timerPublisher: () -> AsyncStream<Date> {
        get { self[TimerPublisherKey.self] }
        set { self[TimerPublisherKey.self] = newValue }
    }
}
