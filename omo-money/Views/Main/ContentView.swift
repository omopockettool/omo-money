//
//  ContentView.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HomeGroup.createdAt) private var homeGroups: [HomeGroup]
    @Query(sort: \Entry.date, order: .reverse) private var entries: [Entry]
    @Query private var allItems: [Item]
    @Query private var users: [User]
    @Query private var homeGroupUsers: [HomeGroupUser]
    
    @State private var selectedHomeGroupId: String? = nil
    @State private var selectedEntry: Entry? = nil
    @State private var entryTitle = ""
    @State private var entryDate = Date()
    @State private var entryCategory = EntryCategory.otros.rawValue
    @State private var entryType = false // false = outcome, true = income
    @State private var entryHomeGroupId = ""
    @State private var entryMoney = ""
    @State private var editingEntry: Entry? = nil
    @State private var showingCategoryManagement = false
    @State private var showingHomeGroupManagement = false
    @State private var selectedMonthYear = Date() // Default to current month
    @State private var showingFilters = false
    @State private var tempSelectedMonthYear = Date() // For the filter sheet
    @State private var showAllMonths = false // Track if showing all months for the year
    @State private var selectedCategory = "Todas" // Track selected category filter
    @State private var tempSelectedMonth = Calendar.current.component(.month, from: Date()) - 1 // 0-11
    @State private var tempSelectedYear = Calendar.current.component(.year, from: Date())
    @State private var tempShowAllMonths = false // For "All months" option
    @State private var tempSelectedCategory = "Todas" // For category filter
    @State private var showingAppInfo = false
    @State private var searchText = ""
    @State private var tempSearchText = ""
    
    // Navigation state for entry form
    @State private var navigateToAddEntry = false
    @State private var navigateToEditEntry = false
    
    // Navigation state for entry detail
    @State private var navigateToEntryDetail = false
    
    // MARK: - Computed Properties
    
    // Get current user (assuming first user for now)
    var currentUser: User? {
        return users.first
    }
    
    // Get groups that the current user belongs to
    var userHomeGroups: [HomeGroup] {
        guard let currentUser = currentUser else { return [] }
        
        let userGroupRelations = homeGroupUsers.filter { $0.user?.id == currentUser.id }
        let userGroupIds = userGroupRelations.compactMap { $0.homeGroup?.id }
        
        return homeGroups.filter { userGroupIds.contains($0.id) }
    }
    
    // Get current home group
    var currentHomeGroup: HomeGroup? {
        guard let selectedHomeGroupId = selectedHomeGroupId else { return nil }
        return userHomeGroups.first { $0.id == selectedHomeGroupId }
    }
    
    // Main filtered entries computed property
    var filteredEntries: [Entry] {
        return FilteringLogic.getFilteredEntries(
            entries: entries,
            allItems: allItems,
            selectedHomeGroupId: selectedHomeGroupId,
            selectedMonthYear: selectedMonthYear,
            showAllMonths: showAllMonths,
            selectedCategory: selectedCategory,
            searchText: searchText
        )
    }
    
    // Group entries by date with stable section identifiers
    var entriesByDate: [(date: Date, entries: [Entry], sectionId: String)] {
        return FilteringLogic.groupEntriesByDate(filteredEntries)
    }
    
    // Calculate total spent
    var totalSpent: Double {
        return FilteringLogic.calculateTotalSpent(filteredEntries, allItems: allItems)
    }
    
    // MARK: - Main Content View
    @ViewBuilder
    private var mainContent: some View {
        if userHomeGroups.isEmpty {
            // Show welcome screen for first time
            WelcomeScreenView(onCreateGroup: {
                showingHomeGroupManagement = true
            })
        } else if selectedHomeGroupId == nil {
            // Show message to select a home group
            SelectGroupEmptyState()
        } else if filteredEntries.isEmpty {
            // Show appropriate empty state
            emptyStateView
        } else {
            // Show entries list
            EntriesListView(
                entriesByDate: entriesByDate,
                onEntryTapped: { entry in
                    selectedEntry = entry
                    navigateToEntryDetail = true
                },
                onEntryEdit: prepareForEditEntry,
                onEntryDelete: deleteEntries
            )
        }
    }
    
    // MARK: - Empty State View
    @ViewBuilder
    private var emptyStateView: some View {
        let hasEntriesInGroup = entries.contains { $0.homeGroupId == selectedHomeGroupId }
        let hasEntriesInCurrentPeriod = !FilteringLogic.filterEntriesByDate(entries, homeGroupId: selectedHomeGroupId ?? "", selectedMonthYear: selectedMonthYear, showAllMonths: showAllMonths).isEmpty
        let isCategoryFilterActive = selectedCategory != "Todas"
        
        let emptyStateType = EmptyStateLogic.determineEmptyState(
            hasEntriesInGroup: hasEntriesInGroup,
            hasEntriesInCurrentPeriod: hasEntriesInCurrentPeriod,
            isCategoryFilterActive: isCategoryFilterActive,
            searchText: searchText,
            selectedMonthYear: selectedMonthYear,
            selectedCategory: selectedCategory
        )
        
        switch emptyStateType {
        case .multipleFilters:
            MultipleFiltersNoResultsEmptyState(
                onClearAllFilters: {
                    // Reset all filters
                    searchText = ""
                    selectedCategory = "Todas"
                    let calendar = Calendar.current
                    let currentDate = Date()
                    selectedMonthYear = currentDate
                    showAllMonths = false
                }
            )
        case .searchNoResults:
            SearchNoResultsEmptyState(
                searchText: searchText,
                onClearSearch: {
                    searchText = ""
                }
            )
        case .categoryFilterNoResults:
            CategoryFilterNoResultsEmptyState(
                onClearCategoryFilter: {
                    selectedCategory = "Todas"
                }
            )
        case .noEntriesThisMonth:
            NoEntriesThisMonthEmptyState(
                selectedMonthYear: selectedMonthYear,
                onAddEntry: prepareForNewEntry
            )
        case .dateFilterNoResults:
            DateFilterNoResultsEmptyState(
                onClearFilters: {
                    let currentDate = Date()
                    selectedMonthYear = currentDate
                    showAllMonths = false
                    selectedCategory = "Todas"
                }
            )
        case .welcome:
            WelcomeEmptyState(onAddEntry: prepareForNewEntry)
        case .generic:
            GenericNoEntriesEmptyState(
                selectedMonthYear: selectedMonthYear,
                onAddEntry: prepareForNewEntry
            )
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Controls
                if !userHomeGroups.isEmpty {
                    HeaderControlsView(
                        userHomeGroups: userHomeGroups,
                        currentHomeGroup: currentHomeGroup,
                        selectedHomeGroupId: selectedHomeGroupId,
                        selectedMonthYear: selectedMonthYear,
                        showAllMonths: showAllMonths,
                        selectedCategory: selectedCategory,
                        searchText: searchText,
                        onHomeGroupSelected: { homeGroupId in
                            selectedHomeGroupId = homeGroupId
                        },
                        onFiltersTapped: {
                            // Haptic feedback for better UX
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            // Set temp values to current
                            let calendar = Calendar.current
                            tempSelectedMonth = calendar.component(.month, from: selectedMonthYear) - 1
                            tempSelectedYear = calendar.component(.year, from: selectedMonthYear)
                            tempShowAllMonths = showAllMonths
                            tempSelectedCategory = selectedCategory
                            tempSearchText = searchText
                            
                            showingFilters = true
                        }
                    )
                }
                
                // Total Spent Widget - Always show when there's a home group selected
                if let currentHomeGroup = currentHomeGroup {
                    TotalSpentWidgetView(
                        currentHomeGroup: currentHomeGroup,
                        totalSpent: totalSpent,
                        onAddEntry: prepareForNewEntry
                    )
                }
                
                // Main Content
                mainContent
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("OMO Money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Info button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingAppInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                    }
                }
                
                // Category Management button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCategoryManagement = true
                    }) {
                        Image(systemName: "chart.pie")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingHomeGroupManagement = true
                    }) {
                        Image(systemName: "house")
                            .foregroundColor(.gray)
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: EntryFormView(
                        entryTitle: $entryTitle,
                        entryDate: $entryDate,
                        entryCategory: $entryCategory,
                        entryType: $entryType,
                        entryHomeGroupId: $entryHomeGroupId,
                        entryMoney: $entryMoney,
                        isEditing: editingEntry != nil,
                        onSave: {
                            if let editingEntry = editingEntry {
                                updateEntry(editingEntry)
                            } else {
                                addEntry()
                            }
                        }
                    )
                    .onDisappear {
                        // Reset navigation state when view disappears
                        navigateToAddEntry = false
                        navigateToEditEntry = false
                        navigateToEntryDetail = false
                    },
                    isActive: $navigateToAddEntry
                ) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(
                    destination: EntryFormView(
                        entryTitle: $entryTitle,
                        entryDate: $entryDate,
                        entryCategory: $entryCategory,
                        entryType: $entryType,
                        entryHomeGroupId: $entryHomeGroupId,
                        entryMoney: $entryMoney,
                        isEditing: true,
                        onSave: {
                            if let editingEntry = editingEntry {
                                updateEntry(editingEntry)
                            }
                        }
                    )
                    .onDisappear {
                        // Reset navigation state when view disappears
                        navigateToAddEntry = false
                        navigateToEditEntry = false
                        navigateToEntryDetail = false
                    },
                    isActive: $navigateToEditEntry
                ) {
                    EmptyView()
                }
            )
            .sheet(isPresented: $showingCategoryManagement) {
                CategoryManagementSheet(
                    isPresented: $showingCategoryManagement,
                    entries: filteredEntries,
                    modelContext: modelContext,
                    selectedHomeGroupId: selectedHomeGroupId
                )
            }
            .sheet(isPresented: $showingHomeGroupManagement) {
                HomeGroupManagementSheet(
                    isPresented: $showingHomeGroupManagement,
                    homeGroups: homeGroups,
                    modelContext: modelContext,
                    selectedHomeGroupId: $selectedHomeGroupId
                )
            }
            .sheet(isPresented: $showingFilters) {
                FiltersSheet(
                    isPresented: $showingFilters,
                    selectedMonthYear: $selectedMonthYear,
                    tempSelectedMonthYear: $tempSelectedMonthYear,
                    tempSelectedMonth: $tempSelectedMonth,
                    tempSelectedYear: $tempSelectedYear,
                    tempShowAllMonths: $tempShowAllMonths,
                    showAllMonths: $showAllMonths,
                    tempSelectedCategory: $tempSelectedCategory,
                    selectedCategory: $selectedCategory,
                    searchText: $searchText,
                    tempSearchText: $tempSearchText,
                    entries: entries,
                    items: allItems
                )
            }
            .background(
                Group {
                    if let selectedEntry = selectedEntry {
                        NavigationLink(
                            destination: EntryDetailNavigationView(entry: selectedEntry),
                            isActive: $navigateToEntryDetail
                        ) {
                            EmptyView()
                        }
                    }
                }
            )
            .sheet(isPresented: $showingAppInfo) {
                AppInfoSheet(isPresented: $showingAppInfo)
            }
            .onAppear {
                // Auto-select the first home group if none is selected
                if selectedHomeGroupId == nil && !userHomeGroups.isEmpty {
                    selectedHomeGroupId = userHomeGroups.first?.id
                }
            }
        }
    }
    
    private func prepareForNewEntry() {
        // Haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        entryTitle = ""
        entryDate = Calendar.current.startOfDay(for: Date())
        entryCategory = EntryCategory.otros.rawValue
        entryType = false
        entryHomeGroupId = selectedHomeGroupId ?? ""
        entryMoney = ""
        editingEntry = nil
        navigateToAddEntry = true
    }
    
    private func prepareForEditEntry(_ entry: Entry) {
        // Haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        entryTitle = entry.title
        entryDate = entry.date
        entryCategory = entry.category
        entryType = entry.type
        entryHomeGroupId = entry.homeGroupId
        // For editing, we don't pre-fill the money field
        entryMoney = ""
        editingEntry = entry
        navigateToEditEntry = true
    }
    
    private func addEntry() {
        // Haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation {
            let cleanedTitle = entryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let newEntry = Entry(
                title: cleanedTitle,
                date: entryDate,
                category: entryCategory,
                type: entryType,
                homeGroupId: entryHomeGroupId
            )
            modelContext.insert(newEntry)
            
            // Create initial item if money is provided
            if let money = Double(entryMoney), !entryMoney.isEmpty {
                let initialItem = Item(
                    money: money,
                    amount: 1,
                    itemDescription: cleanedTitle,
                    entryId: newEntry.id,
                    position: nil,
                    payed: false
                )
                modelContext.insert(initialItem)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving entry: \(error)")
            }
        }
    }
    
    private func updateEntry(_ entry: Entry) {
        // Haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation {
            let cleanedTitle = entryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.title = cleanedTitle
            entry.date = entryDate
            entry.category = entryCategory
            entry.type = entryType
            entry.homeGroupId = entryHomeGroupId
            
            do {
                try modelContext.save()
            } catch {
                print("Error updating entry: \(error)")
            }
        }
    }
    
    private func deleteEntries(_ entries: [Entry]) {
        withAnimation {
            for entry in entries {
                // Borrar todos los items asociados a este entry
                let itemsToDelete = allItems.filter { $0.entryId == entry.id }
                for item in itemsToDelete {
                    modelContext.delete(item)
                }
                modelContext.delete(entry)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting entries: \(error)")
            }
        }
    }
    

}

#Preview {
    ContentView()
        .modelContainer(for: [HomeGroup.self, Entry.self, Item.self], inMemory: true)
}