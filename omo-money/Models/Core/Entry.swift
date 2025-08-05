//
//  Entry.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation
import SwiftData

@Model
final class Entry: Identifiable {
    @Attribute(.unique) var id: String
    var title: String
    var date: Date
    var category: String
    var type: Bool // false = outcome, true = income
    var homeGroupId: String

    init(id: String = UUID().uuidString, title: String, date: Date = Date(), category: String, type: Bool = false, homeGroupId: String) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.type = type
        self.homeGroupId = homeGroupId
    }
}
