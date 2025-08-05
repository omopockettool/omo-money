//
//  CategoryManagementSheet.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI
import SwiftData

struct CategoryManagementSheet: View {
    @Binding var isPresented: Bool
    let entries: [Entry]
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allItems: [Item]
    @Query(sort: \HomeGroup.createdAt) private var homeGroups: [HomeGroup]
    
    // Structure to group entries by category with money spent
    struct CategoryStats {
        let category: String
        let entries: [Entry]
        let totalSpent: Double
        let currency: String
    }
    
    // Get current home group
    var currentHomeGroup: HomeGroup? {
        guard let selectedHomeGroupId = homeGroups.first?.id else { return nil }
        return homeGroups.first { $0.id == selectedHomeGroupId }
    }
    
    // Computed property to group entries by category with money calculations
    private var categoryStats: [CategoryStats] {
        let grouped = Dictionary(grouping: entries) { $0.category }
        return grouped.map { category, categoryEntries in
            let totalSpent = categoryEntries.reduce(0.0) { total, entry in
                let items = allItems.filter { $0.entryId == entry.id }
                let entryTotal = items.filter { $0.payed == true }.reduce(0.0) { $0 + $1.money }
                return total + (entry.type ? 0 : entryTotal) // Only count expenses, not income
            }
            return CategoryStats(
                category: category,
                entries: categoryEntries,
                totalSpent: totalSpent,
                currency: currentHomeGroup?.currency ?? "USD"
            )
        }.sorted { $0.totalSpent > $1.totalSpent }
    }
    
    // Get maximum spent amount for progress bar scaling
    private var maxSpentAmount: Double {
        let maxAmount = categoryStats.map { $0.totalSpent }.max() ?? 0
        return maxAmount > 0 ? maxAmount : 1.0
    }
    
    private func categoryDisplayName(for category: String) -> String {
        switch category {
        case "comida": return "Comida"
        case "hogar": return "Hogar"
        case "salud": return "Salud"
        case "ocio": return "Ocio"
        case "transporte": return "Transporte"
        case "otros": return "Otros"
        default: return category.capitalized
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "comida": return .red
        case "hogar": return .blue
        case "salud": return .green
        case "ocio": return .purple
        case "transporte": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("Gastos por Categoría")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.clear)
                    .disabled(true)
                }
                .padding()
                .background(Color(.systemBackground))
                
                if let homeGroup = currentHomeGroup {
                    // Home Group Info
                    HStack {
                        Text(homeGroup.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        let currencySymbol = Currency(rawValue: homeGroup.currency)?.symbol ?? "$"
                        Text("Moneda: \(currencySymbol)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // Categories list with money spent
                List {
                    ForEach(categoryStats, id: \.category) { categoryStat in
                        Section(header: 
                            HStack {
                                Circle()
                                    .fill(categoryColor(for: categoryStat.category))
                                    .frame(width: 20, height: 20)
                                Text(categoryDisplayName(for: categoryStat.category))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("• \(categoryStat.entries.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        ) {
                            let progress = maxSpentAmount > 0 ? categoryStat.totalSpent / maxSpentAmount : 0.0
                            let currencySymbol = Currency(rawValue: categoryStat.currency)?.symbol ?? "$"
                            
                            // Progress bar with money info
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background bar
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 32)
                                    
                                    // Progress bar
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(categoryStat.totalSpent == 0 ? Color.orange : categoryColor(for: categoryStat.category))
                                        .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 32)
                                        .animation(.easeInOut(duration: 0.3), value: progress)
                                    
                                    // Category label with money
                                    HStack {
                                        Text(categoryDisplayName(for: categoryStat.category))
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(categoryStat.totalSpent == 0 ? .black : .white)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                        
                                        Spacer()
                                        
                                        // Money amount on the right side of the bar
                                        Text("\(currencySymbol)\(String(format: "%.0f", categoryStat.totalSpent))")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(categoryStat.totalSpent == 0 ? .black : .white)
                                            .padding(.trailing, 12)
                                    }
                                }
                                .frame(height: 32)
                            }
                            .frame(height: 32)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Stats footer
                VStack(spacing: 8) {
                    let totalSpent = categoryStats.reduce(0) { $0 + $1.totalSpent }
                    let currencySymbol = Currency(rawValue: currentHomeGroup?.currency ?? "USD")?.symbol ?? "$"
                    
                    HStack {
                        Text("Total gastado: \(currencySymbol)\(String(format: "%.2f", totalSpent))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Categorías: \(categoryStats.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    let emptyCategories = categoryStats.filter { $0.totalSpent == 0 }.count
                    if emptyCategories > 0 {
                        Text("Categorías sin gastos: \(emptyCategories)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}