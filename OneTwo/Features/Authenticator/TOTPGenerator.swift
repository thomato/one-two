//
//  TOTPGenerator.swift
//  OneTwo
//
//  Created on 30/03/2025.
//

import ComposableArchitecture
import Foundation
import SwiftOTP

// MARK: - TOTP Generator Protocol

protocol TOTPGeneratorProtocol {
    func generateCode(
        secret: String,
        digits: Int,
        period: Int,
        algorithm: Account.OTPAlgorithm,
        time: Date
    ) -> String?
}

// MARK: - Live Implementation

struct LiveTOTPGenerator: TOTPGeneratorProtocol {
    func generateCode(
        secret: String,
        digits: Int,
        period: Int,
        algorithm: Account.OTPAlgorithm,
        time: Date
    ) -> String? {
        guard let secretData = base32DecodeToData(secret) else {
            return nil
        }

        let totp: TOTP? = switch algorithm {
        case .sha1:
            TOTP(secret: secretData, digits: digits, timeInterval: period, algorithm: .sha1)
        case .sha256:
            TOTP(secret: secretData, digits: digits, timeInterval: period, algorithm: .sha256)
        case .sha512:
            TOTP(secret: secretData, digits: digits, timeInterval: period, algorithm: .sha512)
        }

        guard let unwrappedTOTP = totp else {
            return nil
        }

        return unwrappedTOTP.generate(time: time)
    }
}

// MARK: - Mock Implementation (for Testing)

struct MockTOTPGenerator: TOTPGeneratorProtocol {
    func generateCode(
        secret _: String,
        digits: Int,
        period: Int,
        algorithm _: Account.OTPAlgorithm,
        time: Date
    ) -> String? {
        // For testing purposes, return a predictable code
        let timeBlock = Int(time.timeIntervalSince1970 / Double(period))
        return String(format: "%0\(digits)d", timeBlock % Int(pow(10.0, Double(digits))))
    }
}

// MARK: - Dependency Key

enum TOTPGeneratorKey: DependencyKey {
    static var liveValue: any TOTPGeneratorProtocol = LiveTOTPGenerator()
    static var testValue: any TOTPGeneratorProtocol = MockTOTPGenerator()
}

// MARK: - Dependency Values Extension

extension DependencyValues {
    var totpGenerator: any TOTPGeneratorProtocol {
        get { self[TOTPGeneratorKey.self] }
        set { self[TOTPGeneratorKey.self] = newValue }
    }
}
