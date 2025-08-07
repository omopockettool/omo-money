//
//  EntryRowView.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI
import SwiftData

struct EntryRowView: View {
    let entry: Entry
    @Query private var allItems: [Item]
    @Query(sort: \HomeGroup.createdAt) private var homeGroups: [HomeGroup]
    var onEdit: (() -> Void)?
    var searchMatch: SearchMatch? = nil // Add search match parameter
    
    var items: [Item] {
        allItems.filter { $0.entryId == entry.id }
    }
    
    // Get matching items for search
    var matchingItems: [Item] {
        guard let searchMatch = searchMatch, !searchMatch.matchingItemIds.isEmpty else { return [] }
        return items.filter { searchMatch.matchingItemIds.contains($0.id) }
    }
    
    // Calculate total based on search context
    var displayTotal: Double {
        if let searchMatch = searchMatch, !searchMatch.matchingItemIds.isEmpty {
            // If searching for items, show total of matching items only
            return matchingItems.filter { $0.payed == true }.reduce(0.0) { $0 + $1.money }
        } else {
            // Normal total calculation
            return items.filter { $0.payed == true }.reduce(0.0) { $0 + $1.money }
        }
    }
    
    // Computed property to determine payment status
    private var paymentStatus: (icon: String, color: Color) {
        if items.isEmpty {
            return ("circle", .gray) // No items
        }
        
        let paidItems = items.filter { $0.payed == true }
        let totalItems = items.count
        
        if paidItems.count == 0 {
            return ("exclamationmark.triangle.fill", .orange) // No items paid
        } else if paidItems.count == totalItems {
            return ("checkmark.circle.fill", .green) // All items paid
        } else {
            return ("exclamationmark.circle.fill", .orange) // Some items paid
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                // Entry title with search highlighting
                if let searchMatch = searchMatch, searchMatch.isEntryTitleMatch {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.yellow.opacity(0.3))
                                .padding(.horizontal, -4)
                                .padding(.vertical, -2)
                        )
                } else {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack(spacing: 8) {
                    // Category with search highlighting
                    if let searchMatch = searchMatch, searchMatch.isEntryCategoryMatch {
                        Text(entry.category.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.yellow.opacity(0.3))
                            )
                            .foregroundColor(.primary)
                    } else {
                        Text(entry.category.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(categoryColor(entry.category))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    // Payment status icon (smaller size) - only show if there are items
                    if !items.isEmpty {
                        paymentStatusIconSmall
                    }
                    
                    // Search indicator icon - show when there are matching items
                    if let searchMatch = searchMatch, !searchMatch.matchingItemIds.isEmpty {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
                            // Show total amount and status if there are items
                if !items.isEmpty {
                    let paidItems = items.filter { $0.payed == true }
                    let unpaidItems = items.filter { $0.payed != true }
                    let totalPaid = displayTotal
                    let totalUnpaid = unpaidItems.reduce(0) { $0 + $1.money }
                    
                    // Get currency from home group
                    let homeGroup = homeGroups.first { $0.id == entry.homeGroupId }
                    let currencySymbol = Currency(rawValue: homeGroup?.currency ?? "USD")?.symbol ?? "$"
                
                VStack(alignment: .trailing, spacing: 4) {
                    // Show total paid amount (always show if there are paid items)
                    if paidItems.count > 0 {    
                        Text("\(String(format: "%.2f", totalPaid))\(currencySymbol)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(entry.type ? Color.green : Color.red)
                    }
                    
                    // Show unpaid amount or status
                    if totalUnpaid > 0 {
                        Text("Pendiente: \(String(format: "%.2f", totalUnpaid))\(currencySymbol)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else if unpaidItems.count > 0 {
                        // Items pending but with 0.00 price
                        Text("Items pendientes")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            } else {
                Text("Sin items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        // Remove background highlight for items - keep only title and category highlighting
    }
    
    // Computed property for payment status icon (smaller size)
    private var paymentStatusIconSmall: some View {
        let (iconName, iconColor) = paymentStatus
        return Image(systemName: iconName)
            .font(.caption)
            .foregroundColor(iconColor)
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "comida": return .red
        case "hogar": return .blue
        case "salud": return .green
        case "ocio": return .purple
        case "transporte": return .orange
        default: return .gray
        }
    }
} 