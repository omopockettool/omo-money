//
//  Item.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 15/7/25.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    @Attribute(.unique) var id: String
    var money: Double
    var amount: Int?
    var itemDescription: String
    var entryId: String
    var position: Int?
    var payed: Bool?

    init(id: String = UUID().uuidString, money: Double, amount: Int? = nil, itemDescription: String, entryId: String, position: Int? = nil, payed: Bool? = nil) {
        self.id = id
        self.money = money
        self.amount = amount
        self.itemDescription = itemDescription
        self.entryId = entryId
        self.position = position
        self.payed = payed
    }
} 