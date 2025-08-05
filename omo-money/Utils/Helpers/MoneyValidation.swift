//
//  MoneyValidation.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation

// MARK: - Money Validation Helper (shared between forms)
func validateMoneyInput(_ input: String) -> String {
    // Si está vacío, permitir
    if input.isEmpty {
        return input
    }
    
    // Solo permitir números y un punto decimal
    let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
    let filtered = input.filter { String($0).rangeOfCharacter(from: allowedCharacters) != nil }
    
    // Si no hay caracteres válidos, retornar vacío
    if filtered.isEmpty {
        return ""
    }
    
    // Separar parte entera y decimal
    let components = filtered.components(separatedBy: ".")
    
    // Si hay más de un punto, solo tomar el primero
    if components.count > 2 {
        let integerPart = components[0]
        let decimalPart = components[1]
        return "\(integerPart).\(decimalPart)"
    }
    
    // Si solo hay parte entera
    if components.count == 1 {
        let integerPart = components[0]
        // Limitar a 9 dígitos
        if integerPart.count > 9 {
            return String(integerPart.prefix(9))
        }
        // Eliminar ceros a la izquierda, pero permitir un solo cero
        let cleanedIntegerPart = integerPart.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        return cleanedIntegerPart.isEmpty ? "0" : cleanedIntegerPart
    }
    
    // Si hay parte entera y decimal
    let integerPart = components[0]
    let decimalPart = components[1]
    
    // Limitar parte entera a 9 dígitos
    let limitedIntegerPart = integerPart.count > 9 ? String(integerPart.prefix(9)) : integerPart
    
    // Eliminar ceros a la izquierda de la parte entera, pero permitir un solo cero
    let cleanedIntegerPart = limitedIntegerPart.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    let finalIntegerPart = cleanedIntegerPart.isEmpty ? "0" : cleanedIntegerPart
    
    // Limitar parte decimal a 2 dígitos
    let limitedDecimalPart = decimalPart.count > 2 ? String(decimalPart.prefix(2)) : decimalPart
    
    return "\(finalIntegerPart).\(limitedDecimalPart)"
} 