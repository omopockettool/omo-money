//
//  HomeGroup.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation
import SwiftData

@Model
final class HomeGroup: Identifiable {
    @Attribute(.unique) var id: String
    var name: String
    var currency: String // Currency code
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var entries: [Entry] = []
    @Relationship(deleteRule: .cascade) var homeGroupUsers: [HomeGroupUser] = []
    
    init(id: String = UUID().uuidString, name: String, currency: String = "USD") {
        self.id = id
        self.name = name
        self.currency = currency
        self.createdAt = Date()
    }
} 