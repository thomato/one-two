//
//  TOTPGeneratorForTesting.swift
//  OneTwo
//
//  Created on 30/03/2025.
//

import ComposableArchitecture
import Foundation

/// A TOTP generator that produces predictable codes for UI testing
final class PredictableTOTPGenerator: TOTPGeneratorProtocol {
    func generateCode(
        secret: String,
        digits: Int,
        period: Int,
        algorithm _: Account.OTPAlgorithm,
        time: Date
    ) -> String? {
        // For UI testing, we'll return a predictable code based on the account properties
        // This makes UI tests more reliable since we don't need to worry about timing
        let timeBlock = Int(time.timeIntervalSince1970 / Double(period))

        // Create a deterministic but changing code
        let baseValue = (timeBlock % 10) * 100_000 + Int((secret.hashValue % 100_000).magnitude)

        // Format with the correct number of digits
        return String(format: "%0\(digits)d", baseValue % Int(pow(10.0, Double(digits))))
    }
}

/// Extension to set up the testing environment
extension TOTPGeneratorKey {
    static var testUIValue: any TOTPGeneratorProtocol = PredictableTOTPGenerator()
}

/// Extension to detect if we're running in UI test mode
extension ProcessInfo {
    var isUITesting: Bool {
        arguments.contains("--uitesting")
    }
}
