//
//  Entry.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 15/7/25.
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
    
    init(id: String = UUID().uuidString, name: String, currency: String = "USD") {
        self.id = id
        self.name = name
        self.currency = currency
        self.createdAt = Date()
    }
}

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

@Model
final class Item: Identifiable {
    @Attribute(.unique) var id: String
    var money: Double
    var amount: Int?
    var itemDescription: String
    var entryId: String

    init(id: String = UUID().uuidString, money: Double, amount: Int? = nil, itemDescription: String, entryId: String) {
        self.id = id
        self.money = money
        self.amount = amount
        self.itemDescription = itemDescription
        self.entryId = entryId
    }
}

enum EntryCategory: String, CaseIterable {
    case comida = "comida"
    case hogar = "hogar"
    case salud = "salud"
    case ocio = "ocio"
    case transporte = "transporte"
    case otros = "otros"
    
    var displayName: String {
        switch self {
        case .comida: return "Comida"
        case .hogar: return "Hogar"
        case .salud: return "Salud"
        case .ocio: return "Ocio"
        case .transporte: return "Transporte"
        case .otros: return "Otros"
        }
    }
    
    var color: String {
        switch self {
        case .comida: return "red"
        case .hogar: return "blue"
        case .salud: return "green"
        case .ocio: return "purple"
        case .transporte: return "orange"
        default: return "gray"
        }
    }
}

enum Currency: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        }
    }
    
    var displayName: String {
        switch self {
        case .usd: return "Dólar Estadounidense (USD)"
        case .eur: return "Euro (EUR)"
        }
    }
}
