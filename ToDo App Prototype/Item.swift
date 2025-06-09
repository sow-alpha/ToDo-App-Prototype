//
//  Item.swift
//  ToDo App Prototype
//
//  Created by Alpha Sow on 6/9/25.
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
