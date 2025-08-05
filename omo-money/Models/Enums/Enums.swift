//
//  Enums.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation

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