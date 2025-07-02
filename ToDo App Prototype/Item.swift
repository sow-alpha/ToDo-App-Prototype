//
//  Item.swift
//  ToDo App Prototype
//
//  Created by Alpha Sow on 6/9/25.
//

import Foundation
import SwiftData

enum Priority: String, CaseIterable, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "indigo"
        case .low: return "blue"
        }
    }
    
    var icon: String {
        switch self {
        case .high: return "bolt.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .low: return "clock.fill"
        }
    }
}

@Model
final class Item {
    var title: String
    var priority: Priority
    var completed: Bool
    var itemDescription: String
    var timestamp: Date
    
    init(title: String, priority: Priority = .medium, completed: Bool = false, itemDescription: String = "", timestamp: Date = Date()) {
        self.title = title
        self.priority = priority
        self.completed = completed
        self.itemDescription = itemDescription
        self.timestamp = timestamp
    }
}
