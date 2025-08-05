//
//  HomeGroupUser.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation
import SwiftData

@Model
final class HomeGroupUser: Identifiable {
    @Attribute(.unique) var id: String
    var dateJoined: Date
    var isAdmin: Bool
    
    // Relationships
    var user: User?
    var homeGroup: HomeGroup?
    
    init(id: String = UUID().uuidString, dateJoined: Date = Date(), isAdmin: Bool = false) {
        self.id = id
        self.dateJoined = dateJoined
        self.isAdmin = isAdmin
    }
} 