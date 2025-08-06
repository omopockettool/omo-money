//
//  ContentViewComponents.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 06/8/2025.
//

import SwiftUI
import SwiftData

// MARK: - Header Controls Component
struct HeaderControlsView: View {
    let userHomeGroups: [HomeGroup]
    let currentHomeGroup: HomeGroup?
    let selectedHomeGroupId: String?
    let selectedMonthYear: Date
    let showAllMonths: Bool
    let selectedCategory: String
    let isSearchActive: Bool
    let searchText: String
    
    let onHomeGroupSelected: (String) -> Void
    let onFiltersTapped: () -> Void
    let onSearchTapped: () -> Void
    
    var body: some View {
        HStack {
            // Left side: Group and Filters
            HStack {
                // Home Group Dropdown
                Menu {
                    ForEach(userHomeGroups, id: \.id) { homeGroup in
                        Button(action: {
                            onHomeGroupSelected(homeGroup.id)
                        }) {
                            HStack {
                                Text(homeGroup.name)
                                if selectedHomeGroupId == homeGroup.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(currentHomeGroup?.name ?? "Seleccionar Grupo")
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                
                // Filters Button
                Button(action: onFiltersTapped) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.primary)
                        
                        // Show current filter indicator
                        if !Calendar.current.isDate(selectedMonthYear, equalTo: Date(), toGranularity: .month) || selectedCategory != "Todas" {
                            HStack(spacing: 4) {
                                if !Calendar.current.isDate(selectedMonthYear, equalTo: Date(), toGranularity: .month) {
                                    if showAllMonths {
                                        Text(String(Calendar.current.component(.year, from: selectedMonthYear)))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text(DateFormatter.monthYearFormatter.string(from: selectedMonthYear))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if selectedCategory != "Todas" {
                                    if !Calendar.current.isDate(selectedMonthYear, equalTo: Date(), toGranularity: .month) {
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(selectedCategory)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Right side: Search Button
            Button(action: onSearchTapped) {
                HStack(spacing: 4) {
                    Image(systemName: isSearchActive ? "xmark" : "magnifyingglass")
                        .foregroundColor(isSearchActive ? .gray : .primary)
                    
                    // Show search indicator if there's active search
                    if !searchText.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSearchActive ? Color.gray.opacity(0.1) : Color(.secondarySystemGroupedBackground))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - Search Field Component
struct SearchFieldView: View {
    @Binding var searchText: String
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                TextField("Buscar en entradas y sus items...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.system(size: 15))
                    .focused($isSearchFieldFocused)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                }
                
                Button(action: {
                    isSearchFieldFocused = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4).opacity(0.3), lineWidth: 0.5)
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFieldFocused = true
            }
        }
    }
}

// MARK: - Total Spent Widget Component
struct TotalSpentWidgetView: View {
    let currentHomeGroup: HomeGroup
    let totalSpent: Double
    let onAddEntry: () -> Void
    
    var body: some View {
        let currencySymbol = Currency(rawValue: currentHomeGroup.currency)?.symbol ?? "$"
        
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Total Gastado")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("\(String(format: "%.2f", totalSpent))\(currencySymbol)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Quick action button
            Button(action: onAddEntry) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - Welcome Screen Component
struct WelcomeScreenView: View {
    let onCreateGroup: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("OMO Money")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(.systemGray))
            
            Text("Crea tu primer grupo de gastos para comenzar")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: onCreateGroup) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Crear Primer Grupo")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - Entries List Component
struct EntriesListView: View {
    let entriesByDate: [(date: Date, entries: [Entry], sectionId: String)]
    let onEntryTapped: (Entry) -> Void
    let onEntryEdit: (Entry) -> Void
    let onEntryDelete: ([Entry]) -> Void
    
    var body: some View {
        List {
            ForEach(entriesByDate, id: \.sectionId) { (date, entriesForDate, sectionId) in
                Section(header: Text("\(date.formatted(date: .abbreviated, time: .omitted)) • \(entriesForDate.count)")) {
                    ForEach(entriesForDate, id: \.id) { entry in
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                            
                            EntryRowView(entry: entry, onEdit: {
                                onEntryEdit(entry)
                            })
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        .onTapGesture {
                            onEntryTapped(entry)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color(.secondarySystemGroupedBackground))
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                    .onDelete { offsets in
                        let entriesToDelete = offsets.map { entriesForDate[$0] }
                        onEntryDelete(entriesToDelete)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: entriesByDate.map { $0.sectionId })
        .background(Color.clear)
    }
}

// MARK: - Empty State Logic Helper
struct EmptyStateLogic {
    static func determineEmptyState(
        hasEntriesInGroup: Bool,
        hasEntriesInCurrentPeriod: Bool,
        isCategoryFilterActive: Bool,
        searchText: String,
        selectedMonthYear: Date,
        selectedCategory: String
    ) -> EmptyStateType {
        
        let hasMultipleFilters = (isCategoryFilterActive && !searchText.isEmpty) || 
                               (isCategoryFilterActive && !hasEntriesInCurrentPeriod) ||
                               (!searchText.isEmpty && !hasEntriesInCurrentPeriod)
        
        if hasEntriesInGroup && hasMultipleFilters {
            return .multipleFilters
        } else if hasEntriesInGroup && !searchText.isEmpty {
            return .searchNoResults
        } else if hasEntriesInGroup && isCategoryFilterActive {
            return .categoryFilterNoResults
        } else if hasEntriesInGroup && !hasEntriesInCurrentPeriod && !isCategoryFilterActive && searchText.isEmpty && Calendar.current.isDate(selectedMonthYear, equalTo: Date(), toGranularity: .month) {
            return .noEntriesThisMonth
        } else if hasEntriesInGroup && !hasEntriesInCurrentPeriod {
            return .dateFilterNoResults
        } else if !hasEntriesInGroup {
            return .welcome
        } else {
            return .generic
        }
    }
}

enum EmptyStateType {
    case multipleFilters
    case searchNoResults
    case categoryFilterNoResults
    case noEntriesThisMonth
    case dateFilterNoResults
    case welcome
    case generic
} 