//
//  FilteringLogic.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation
import SwiftData

// MARK: - Filtering Logic
struct FilteringLogic {
    
    // Helper function to convert displayName to rawValue
    static func getCategoryRawValue(from displayName: String) -> String {
        if displayName == "Todas" {
            return "Todas"
        }
        
        for category in EntryCategory.allCases {
            if category.displayName == displayName {
                return category.rawValue
            }
        }
        return "otros" // fallback
    }
    
    // Filter entries by home group and date
    static func filterEntriesByDate(_ entries: [Entry], homeGroupId: String, selectedMonthYear: Date, showAllMonths: Bool) -> [Entry] {
        let calendar = Calendar.current
        
        if showAllMonths {
            let startOfYear = calendar.dateInterval(of: .year, for: selectedMonthYear)?.start ?? selectedMonthYear
            let endOfYear = calendar.dateInterval(of: .year, for: selectedMonthYear)?.end ?? selectedMonthYear
            
            return entries.filter { entry in
                entry.homeGroupId == homeGroupId &&
                entry.date >= startOfYear &&
                entry.date < endOfYear
            }
        } else {
            let startOfMonth = calendar.dateInterval(of: .month, for: selectedMonthYear)?.start ?? selectedMonthYear
            let endOfMonth = calendar.dateInterval(of: .month, for: selectedMonthYear)?.end ?? selectedMonthYear
            
            return entries.filter { entry in
                entry.homeGroupId == homeGroupId &&
                entry.date >= startOfMonth &&
                entry.date < endOfMonth
            }
        }
    }
    
    // Filter entries by category
    static func filterEntriesByCategory(_ entries: [Entry], selectedCategory: String) -> [Entry] {
        if selectedCategory == "Todas" {
            return entries
        } else {
            let categoryRawValue = getCategoryRawValue(from: selectedCategory)
            return entries.filter { entry in
                entry.category == categoryRawValue
            }
        }
    }
    
    // Filter entries by search text
    static func filterEntriesBySearch(_ entries: [Entry], searchText: String, allItems: [Item]) -> [Entry] {
        if searchText.isEmpty {
            return entries
        }
        
        let searchLower = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchLower.isEmpty {
            return entries
        }
        
        return entries.filter { entry in
            // Search in entry title
            if entry.title.lowercased().contains(searchLower) {
                return true
            }
            
            // Search in entry category
            if entry.category.lowercased().contains(searchLower) {
                return true
            }
            
            // Search in items associated with this entry
            let items = allItems.filter { $0.entryId == entry.id }
            return items.contains { item in
                item.itemDescription.lowercased().contains(searchLower)
            }
        }
    }
    
    // Main filtered entries function
    static func getFilteredEntries(
        entries: [Entry],
        allItems: [Item],
        selectedHomeGroupId: String?,
        selectedMonthYear: Date,
        showAllMonths: Bool,
        selectedCategory: String,
        searchText: String
    ) -> [Entry] {
        guard let selectedHomeGroupId = selectedHomeGroupId else { return [] }
        
        let dateFiltered = filterEntriesByDate(entries, homeGroupId: selectedHomeGroupId, selectedMonthYear: selectedMonthYear, showAllMonths: showAllMonths)
        let categoryFiltered = filterEntriesByCategory(dateFiltered, selectedCategory: selectedCategory)
        let searchFiltered = filterEntriesBySearch(categoryFiltered, searchText: searchText, allItems: allItems)
        
        return searchFiltered
    }
    
    // Group entries by date with stable section identifiers
    static func groupEntriesByDate(_ entries: [Entry]) -> [(date: Date, entries: [Entry], sectionId: String)] {
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        return grouped.map { (date: $0.key, entries: $0.value, sectionId: DateFormatter.sectionFormatter.string(from: $0.key)) }
            .sorted { $0.date > $1.date }
    }
    
    // Calculate total spent for filtered entries
    static func calculateTotalSpent(_ entries: [Entry], allItems: [Item]) -> Double {
        return entries.reduce(0.0) { total, entry in
            let items = allItems.filter { $0.entryId == entry.id }
            let entryTotal = items.filter { $0.payed == true }.reduce(0.0) { $0 + $1.money }
            return total + (entry.type ? 0 : entryTotal) // Only count expenses, not income
        }
    }
} 