//
//  FilteringLogic.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import Foundation
import SwiftData

// MARK: - Search Match Structure
struct SearchMatch {
    let entryId: String
    let isEntryTitleMatch: Bool
    let isEntryCategoryMatch: Bool
    let matchingItemIds: [String]
}

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
    
    // Filter entries by search text and return matches
    static func filterEntriesBySearch(_ entries: [Entry], searchText: String, allItems: [Item]) -> (entries: [Entry], matches: [SearchMatch]) {
        if searchText.isEmpty {
            return (entries, [])
        }
        
        let searchLower = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchLower.isEmpty {
            return (entries, [])
        }
        
        var matchingEntries: [Entry] = []
        var searchMatches: [SearchMatch] = []
        
        for entry in entries {
            var isEntryTitleMatch = false
            var isEntryCategoryMatch = false
            var matchingItemIds: [String] = []
            
            // Search in entry title
            if entry.title.lowercased().contains(searchLower) {
                isEntryTitleMatch = true
            }
            
            // Search in entry category
            if entry.category.lowercased().contains(searchLower) {
                isEntryCategoryMatch = true
            }
            
            // Search in items associated with this entry
            let items = allItems.filter { $0.entryId == entry.id }
            for item in items {
                if item.itemDescription.lowercased().contains(searchLower) {
                    matchingItemIds.append(item.id)
                }
            }
            
            // If there's any match, include the entry
            if isEntryTitleMatch || isEntryCategoryMatch || !matchingItemIds.isEmpty {
                matchingEntries.append(entry)
                searchMatches.append(SearchMatch(
                    entryId: entry.id,
                    isEntryTitleMatch: isEntryTitleMatch,
                    isEntryCategoryMatch: isEntryCategoryMatch,
                    matchingItemIds: matchingItemIds
                ))
            }
        }
        
        return (matchingEntries, searchMatches)
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
    ) -> (entries: [Entry], searchMatches: [SearchMatch]) {
        guard let selectedHomeGroupId = selectedHomeGroupId else { return ([], []) }
        
        let dateFiltered = filterEntriesByDate(entries, homeGroupId: selectedHomeGroupId, selectedMonthYear: selectedMonthYear, showAllMonths: showAllMonths)
        let categoryFiltered = filterEntriesByCategory(dateFiltered, selectedCategory: selectedCategory)
        let (searchFiltered, searchMatches) = filterEntriesBySearch(categoryFiltered, searchText: searchText, allItems: allItems)
        
        return (searchFiltered, searchMatches)
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
    static func calculateTotalSpent(_ entries: [Entry], allItems: [Item], searchMatches: [SearchMatch] = []) -> Double {
        return entries.reduce(0.0) { total, entry in
            let items = allItems.filter { $0.entryId == entry.id }
            
            // Check if this entry has search matches
            let searchMatch = searchMatches.first { $0.entryId == entry.id }
            
            let entryTotal: Double
            if let searchMatch = searchMatch, !searchMatch.matchingItemIds.isEmpty {
                // If searching for items, only count matching items
                let matchingItems = items.filter { searchMatch.matchingItemIds.contains($0.id) }
                entryTotal = matchingItems.filter { $0.payed == true }.reduce(0.0) { $0 + $1.money }
            } else {
                // Normal calculation - all items
                entryTotal = items.filter { $0.payed == true }.reduce(0.0) { $0 + $1.money }
            }
            
            return total + (entry.type ? 0 : entryTotal) // Only count expenses, not income
        }
    }
} 