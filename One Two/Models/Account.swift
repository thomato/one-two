//
//  Account.swift
//  One Two
//
//  Created by Nando Thomassen on 14/12/2024.
//

import Foundation

// MARK: - Models
struct Account: Equatable, Identifiable {
    let id: UUID
    let name: String
    let secret: String

    var currentCode: String {
        // TODO: implement proper TOTP generation here
        // This is just a placeholder that changes every 30 seconds
        let timeBlock = Int(Date().timeIntervalSince1970 / 30)
        return String(format: "%06d", timeBlock % 1000000)
    }
}
