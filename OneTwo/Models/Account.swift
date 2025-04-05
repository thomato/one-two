//
//  Account.swift
//  OneTwo
//
//  Created by Nando Thomassen on 14/12/2024.
//

import Foundation
import SwiftOTP

// MARK: - Models

struct Account: Equatable, Identifiable {
    let id: UUID
    let name: String
    let secret: String
    let issuer: String?
    let digits: Int
    let period: Int
    let algorithm: OTPAlgorithm

    enum OTPAlgorithm: String, Equatable {
        case sha1, sha256, sha512
    }

    init(
        id: UUID = UUID(),
        name: String,
        secret: String,
        issuer: String? = nil,
        digits: Int = 6,
        period: Int = 30,
        algorithm: OTPAlgorithm = .sha1
    ) {
        self.id = id
        self.name = name
        self.secret = secret
        self.issuer = issuer
        self.digits = digits
        self.period = period
        self.algorithm = algorithm
    }

    var currentCode: String {
        // Direct implementation for when the model is used outside of TCA
        guard let secretData = base32DecodeToData(secret) else {
            return "Invalid"
        }

        let totp: TOTP? = switch algorithm {
        case .sha1:
            TOTP(secret: secretData, digits: digits, timeInterval: period, algorithm: .sha1)
        case .sha256:
            TOTP(secret: secretData, digits: digits, timeInterval: period, algorithm: .sha256)
        case .sha512:
            TOTP(secret: secretData, digits: digits, timeInterval: period, algorithm: .sha512)
        }

        return totp?.generate(time: Date()) ?? "Error"
    }

    func generateCode(using generator: TOTPGeneratorProtocol? = nil, at time: Date = Date()) -> String {
        // Use the provided generator if available
        if let generator {
            return generator.generateCode(
                secret: secret,
                digits: digits,
                period: period,
                algorithm: algorithm,
                time: time
            ) ?? "Invalid"
        }

        // Fall back to direct implementation
        return currentCode
    }

    var timeRemaining: Double {
        let timeInterval = Date().timeIntervalSince1970
        let currentTimeBlock = Int(timeInterval / Double(period))
        let nextInterval = Double(currentTimeBlock + 1) * Double(period)
        return nextInterval - timeInterval
    }
}

// MARK: - Helper Functions

func base32DecodeToData(_ string: String) -> Data? {
    let base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    let cleanedString = string
        .uppercased()
        .replacingOccurrences(of: "-", with: "")
        .replacingOccurrences(of: " ", with: "")

    // Ensure all characters are valid Base32 characters
    guard cleanedString.allSatisfy(base32Chars.contains) else {
        return nil
    }

    var bits = 0
    var bitsCount = 0
    var result = Data()

    for char in cleanedString {
        guard let value = base32Chars.firstIndex(of: char) else {
            continue // This should never happen due to the check above
        }

        let intValue = base32Chars.distance(from: base32Chars.startIndex, to: value)
        bits = (bits << 5) | intValue
        bitsCount += 5

        while bitsCount >= 8 {
            bitsCount -= 8
            result.append(UInt8(bits >> bitsCount & 0xFF))
        }
    }

    return result.isEmpty ? nil : result
}
