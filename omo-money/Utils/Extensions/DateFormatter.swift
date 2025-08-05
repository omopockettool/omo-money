//
//  DateFormatter+Extensions.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation

// Extension for stable date formatting
extension DateFormatter {
    static let sectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
} 