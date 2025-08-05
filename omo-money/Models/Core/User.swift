//
//  User.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 15/7/25.
//

import Foundation
import SwiftData

@Model
final class User: Identifiable {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var homeGroupUsers: [HomeGroupUser] = []
    
    init(id: String = UUID().uuidString, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = Date()
    }
} 