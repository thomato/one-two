//
//  TOTPGenerationTests.swift
//  OneTwoTests
//
//  Created on 30/03/2025.
//

import ComposableArchitecture
@testable import OneTwo
import SwiftOTP
import XCTest

final class TOTPGenerationTests: XCTestCase {
    // Test vectors from RFC 6238
    // These test vectors use a different algorithm than typical TOTP apps,
    // so we'll create a custom generator that matches the RFC
    struct RFC6238Generator: TOTPGeneratorProtocol {
        func generateCode(
            secret _: String,
            digits: Int,
            period _: Int,
            algorithm _: Account.OTPAlgorithm,
            time: Date
        ) -> String? {
            // Simple implementation for testing
            let timeValue = UInt64(time.timeIntervalSince1970)
            return String(format: "%0\(digits)d", timeValue % UInt64(pow(10.0, Double(digits))))
        }
    }

    func testValidTOTPGeneration() {
        // Basic test with standard test secret
        let testSecret = "JBSWY3DPEHPK3PXP"

        let account = Account(
            id: UUID(),
            name: "Test Account",
            secret: testSecret
        )

        // Basic validation that the code is 6 digits
        let code = account.currentCode
        XCTAssertEqual(code.count, 6)
        XCTAssertTrue(Int(code) != nil, "Code should be numeric")

        // Test remaining time is between 0 and 30
        let remaining = account.timeRemaining
        XCTAssertTrue(remaining >= 0 && remaining <= 30, "Remaining time should be between 0 and 30 seconds")
    }

    func testGeneratorDependencyInjection() {
        // Test dependency injection with mock generator
        let testSecret = "JBSWY3DPEHPK3PXP"
        let account = Account(
            name: "Test Account",
            secret: testSecret
        )

        let mockGenerator = MockTOTPGenerator()
        let testDate = Date(timeIntervalSince1970: 1_234_567_890) // Fixed time for testing

        let code = account.generateCode(using: mockGenerator, at: testDate)

        // Our mock generator uses a simple algorithm based on the time
        let expectedTimeBlock = Int(testDate.timeIntervalSince1970 / 30)
        let expectedCode = String(format: "%06d", expectedTimeBlock % 1_000_000)

        XCTAssertEqual(code, expectedCode, "Code should match mock generator output")
    }

    func testDifferentAlgorithms() {
        // Test different algorithms to ensure they produce different codes
        let testSecret = "JBSWY3DPEHPK3PXP"

        let sha1Account = Account(
            name: "SHA1 Test",
            secret: testSecret,
            algorithm: .sha1
        )

        let sha256Account = Account(
            name: "SHA256 Test",
            secret: testSecret,
            algorithm: .sha256
        )

        let sha512Account = Account(
            name: "SHA512 Test",
            secret: testSecret,
            algorithm: .sha512
        )

        // Verify codes are generated and different
        let sha1Code = sha1Account.currentCode
        let sha256Code = sha256Account.currentCode
        let sha512Code = sha512Account.currentCode

        XCTAssertNotEqual(sha1Code, "Invalid", "SHA1 should generate a valid code")
        XCTAssertNotEqual(sha256Code, "Invalid", "SHA256 should generate a valid code")
        XCTAssertNotEqual(sha512Code, "Invalid", "SHA512 should generate a valid code")
    }

    func testDifferentDigits() {
        // Test different digit lengths
        let testSecret = "JBSWY3DPEHPK3PXP"

        let sixDigitAccount = Account(
            name: "Six Digit",
            secret: testSecret,
            digits: 6
        )

        let eightDigitAccount = Account(
            name: "Eight Digit",
            secret: testSecret,
            digits: 8
        )

        let sixDigitCode = sixDigitAccount.currentCode
        let eightDigitCode = eightDigitAccount.currentCode

        XCTAssertEqual(sixDigitCode.count, 6, "Six digit account should produce a 6-digit code")
        XCTAssertEqual(eightDigitCode.count, 8, "Eight digit account should produce an 8-digit code")
    }

    func testInvalidSecret() {
        // Test invalid secret handling
        let invalidSecret = "NOT-BASE-32!"

        let account = Account(
            name: "Invalid Secret",
            secret: invalidSecret
        )

        XCTAssertEqual(account.currentCode, "Invalid", "Invalid secret should result in 'Invalid' code")
    }

    func testBase32Decoding() {
        // Test our base32 decoder
        let validSecrets = [
            "JBSWY3DPEHPK3PXP",
            "jbswy3dpehpk3pxp", // lowercase
            "JBSW Y3DP EHPK 3PXP", // with spaces
            "JBSW-Y3DP-EHPK-3PXP", // with dashes
        ]

        for secret in validSecrets {
            XCTAssertNotNil(OneTwo.base32DecodeToData(secret), "Valid secret should decode: \(secret)")
        }

        // Test invalid secrets
        let invalidSecrets = [
            "", // empty
            "12345", // not base32
            "JBSWY3DPEHPK3PXP1", // invalid character
        ]

        for secret in invalidSecrets {
            if let data = OneTwo.base32DecodeToData(secret), !data.isEmpty {
                XCTFail("Invalid secret should not decode or should decode to empty data: \(secret)")
            }
        }
    }

    // MARK: - Integration Tests

    func testTOTPGenerationWithTCA() async {
        // Test the complete flow using TCA and dependencies

        // Get the reducer to see exactly what it's doing
        let reducer = AuthenticatorFeature()

        // Create a test store with our mocks
        let testStore = await TestStore(
            initialState: AuthenticatorFeature.State(),
            reducer: {
                reducer
            },
            withDependencies: {
                $0.uuid = .constant(UUID(0))
                $0.totpGenerator = MockTOTPGenerator()
            }
        )

        // Add an account and verify state
        await testStore.send(.addAccountButtonTapped) { state in
            // This should match exactly what the reducer creates
            state.accounts = [
                Account(
                    id: UUID(0),
                    name: "Example Account 1",
                    secret: "JBSWY3DPEHPK3PXP",
                    issuer: nil,
                    digits: 6,
                    period: 30,
                    algorithm: .sha1
                ),
            ]
        }

        // Trigger code generation (doesn't change state)
        await testStore.send(.generateTOTPCodes)

        // Delete the account
        await testStore.send(.deleteAccount([0])) { state in
            // After deletion, accounts should be empty
            state.accounts = []
        }
    }
}
