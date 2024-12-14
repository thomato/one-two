//
//  Item.swift
//  One Two
//
//  Created by Nando Thomassen on 12/12/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
