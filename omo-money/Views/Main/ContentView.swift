//
//  ContentView.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 15/7/25.
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
    @State private var showingSearch = false
    @State private var searchText = ""
    @State private var isSearchActive = false
    @FocusState private var isSearchFieldFocused: Bool
    
    // Navigation state for entry form
    @State private var navigateToAddEntry = false
    @State private var navigateToEditEntry = false
    
    // Navigation state for entry detail
    @State private var navigateToEntryDetail = false
    
    // Helper function to convert displayName to rawValue
    private func getCategoryRawValue(from displayName: String) -> String {
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
    
    // Filter entries by selected home group, month/year, category, and search
    var filteredEntries: [Entry] {
        guard let selectedHomeGroupId = selectedHomeGroupId else { return [] }
        
        let calendar = Calendar.current
        
        // First filter by date
        let dateFilteredEntries: [Entry]
        if showAllMonths {
            let startOfYear = calendar.dateInterval(of: .year, for: selectedMonthYear)?.start ?? selectedMonthYear
            let endOfYear = calendar.dateInterval(of: .year, for: selectedMonthYear)?.end ?? selectedMonthYear
            
            dateFilteredEntries = entries.filter { entry in
                entry.homeGroupId == selectedHomeGroupId &&
                entry.date >= startOfYear &&
                entry.date < endOfYear
            }
        } else {
            // Filter by specific month
            let startOfMonth = calendar.dateInterval(of: .month, for: selectedMonthYear)?.start ?? selectedMonthYear
            let endOfMonth = calendar.dateInterval(of: .month, for: selectedMonthYear)?.end ?? selectedMonthYear
            
            dateFilteredEntries = entries.filter { entry in
                entry.homeGroupId == selectedHomeGroupId &&
                entry.date >= startOfMonth &&
                entry.date < endOfMonth
            }
        }
        
        // Then filter by category
        let categoryFilteredEntries: [Entry]
        if selectedCategory == "Todas" {
            categoryFilteredEntries = dateFilteredEntries
        } else {
            let categoryRawValue = getCategoryRawValue(from: selectedCategory)
            categoryFilteredEntries = dateFilteredEntries.filter { entry in
                entry.category == categoryRawValue
            }
        }
        
        // Finally filter by search text
        if searchText.isEmpty {
            return categoryFilteredEntries
        } else {
            // Clean search text: trim whitespace and convert to lowercase
            let searchLower = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            // If search text is empty after trimming, return all entries
            if searchLower.isEmpty {
                return categoryFilteredEntries
            }
            
            return categoryFilteredEntries.filter { entry in
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
    }
    
    // Group entries by date (without time) with stable section identifiers
    var entriesByDate: [(date: Date, entries: [Entry], sectionId: String)] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        return grouped.map { (date: $0.key, entries: $0.value, sectionId: DateFormatter.sectionFormatter.string(from: $0.key)) }
            .sorted { $0.date > $1.date }
    }
    
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

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Add extra spacing when search is active to prevent overlap with navigation bar
                if isSearchActive {
                    Spacer()
                        .frame(height: 16)
                }
                
                // Home Group and Month/Year Selector
                if !userHomeGroups.isEmpty {
                    HStack {
                        // Left side: Group and Filters
                        HStack {
                            // Home Group Dropdown
                            Menu {
                                ForEach(userHomeGroups, id: \.id) { homeGroup in
                                    Button(action: {
                                        selectedHomeGroupId = homeGroup.id
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
                            Button(action: {
                                // Set temp values to current
                                let calendar = Calendar.current
                                tempSelectedMonth = calendar.component(.month, from: selectedMonthYear) - 1
                                tempSelectedYear = calendar.component(.year, from: selectedMonthYear)
                                tempShowAllMonths = showAllMonths
                                tempSelectedCategory = selectedCategory
                                
                                showingFilters = true
                            }) {
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
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSearchActive.toggle()
                                if !isSearchActive {
                                    searchText = ""
                                }
                            }
                        }) {
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
                
                // Search Field (when active)
                if isSearchActive {
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
                                // Focus on the text field when tapping the magnifying glass
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
                        // Auto-focus when search field appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isSearchFieldFocused = true
                        }
                    }
                }
                
                // Total Spent Widget - Always show when there's a home group selected
                if let currentHomeGroup = currentHomeGroup {
                        let totalSpent = filteredEntries.reduce(0.0) { total, entry in
                            let items = allItems.filter { $0.entryId == entry.id }
                            let entryTotal = items.filter { $0.payed == true }.reduce(0.0) { $0 + $1.money }
                            return total + (entry.type ? 0 : entryTotal) // Only count expenses, not income
                        }
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
                            Button(action: {
                                prepareForNewEntry()
                            }) {
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
                
                if userHomeGroups.isEmpty {
                    // Show welcome screen for first time
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
                        
                        Button(action: {
                            showingHomeGroupManagement = true
                        }) {
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
                } else if selectedHomeGroupId == nil {
                    // Show message to select a home group
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Selecciona un Grupo")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemGray))
                        
                        Text("Elige un grupo de la lista superior para ver sus entries")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding()
                } else if filteredEntries.isEmpty {
                    // Check if this is due to search or actually no entries
                    let hasEntriesInGroup = entries.contains { $0.homeGroupId == selectedHomeGroupId }
                    let hasEntriesInCurrentMonth = !filteredEntries.isEmpty
                    let isGroupNew = !hasEntriesInGroup
                    
                    VStack {
                        if hasEntriesInGroup && !searchText.isEmpty {
                            // Search returned no results - Compact design
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No se encontraron resultados")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(.systemGray))
                                
                                Text("No hay entries o items que coincidan con '\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    searchText = ""
                                    isSearchActive = false
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Limpiar Búsqueda")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.gray)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 40)
                        } else if isGroupNew {
                            // New group - show welcome message
                            VStack(spacing: 20) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                
                                Text("OMO Money")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGray))
                                
                                Text("Comienza a registrar tus gastos e ingresos en este grupo")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    prepareForNewEntry()
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Agregar Primer Entry")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                                }
                            }
                            .padding()
                        } else {
                            // Group has entries in other months but not in current month
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                                
                                Text("Sin Entradas este Mes")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGray))
                                
                                Text("No hay entradas registrados en \(selectedMonthYear.formatted(.dateTime.month(.wide).year()))")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    prepareForNewEntry()
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Agregar Entrada")
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
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(entriesByDate, id: \.sectionId) { (date, entriesForDate, sectionId) in
                            Section(header: Text("\(date.formatted(date: .abbreviated, time: .omitted)) • \(entriesForDate.count)")) {
                                ForEach(entriesForDate, id: \.id) { entry in
                                    ZStack {
                                        // Invisible background to capture all taps
                                        Rectangle()
                                            .fill(Color.clear)
                                            .contentShape(Rectangle())
                                        
                                        EntryRowView(entry: entry, onEdit: {
                                            prepareForEditEntry(entry)
                                        })
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                    }
                                    .onTapGesture {
                                        // Store the selected entry for navigation
                                        selectedEntry = entry
                                        navigateToEntryDetail = true
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
                                    deleteEntries(entriesToDelete)
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: entriesByDate.map { $0.sectionId })
                    .background(Color.clear)
                }
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
                    modelContext: modelContext
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
                    selectedCategory: $selectedCategory
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
        withAnimation {
            let newEntry = Entry(
                title: entryTitle,
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
                    itemDescription: entryTitle,
                    entryId: newEntry.id,
                    position: nil,
                    payed: true
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
        withAnimation {
            entry.title = entryTitle
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

struct EntryRowView: View {
    let entry: Entry
    @Query private var allItems: [Item]
    @Query(sort: \HomeGroup.createdAt) private var homeGroups: [HomeGroup]
    var onEdit: (() -> Void)?
    
    var items: [Item] {
        allItems.filter { $0.entryId == entry.id }
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
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(entry.category.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(categoryColor(entry.category))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    // Payment status icon (smaller size) - only show if there are items
                    if !items.isEmpty {
                        paymentStatusIconSmall
                    }
                }
            }
            
            Spacer()
            
            // Show total amount and status if there are items
            if !items.isEmpty {
                let paidItems = items.filter { $0.payed == true }
                let unpaidItems = items.filter { $0.payed != true }
                let totalPaid = paidItems.reduce(0) { $0 + $1.money }
                let totalUnpaid = unpaidItems.reduce(0) { $0 + $1.money }
                
                // Get currency from home group
                let homeGroup = homeGroups.first { $0.id == entry.homeGroupId }
                let currencySymbol = Currency(rawValue: homeGroup?.currency ?? "USD")?.symbol ?? "$"
                
                VStack(alignment: .trailing, spacing: 4) {
                    // Show total paid amount (always show if there are paid items)
                    if paidItems.count > 0 {
                        Text("\(currencySymbol)\(String(format: "%.2f", totalPaid))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(entry.type ? Color.green : Color.red)
                    }
                    
                    // Show unpaid amount or status
                    if totalUnpaid > 0 {
                        Text("Pendiente: \(currencySymbol)\(String(format: "%.2f", totalUnpaid))")
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

// AddEntrySheet has been moved to EntryFormView.swift

// EntryDetailView has been moved to EntryDetailView.swift

// ItemRowView has been moved to EntryDetailView.swift

// AddItemSheet has been moved to EntryDetailView.swift

// CategoryManagementSheet has been moved to Views/Category/CategoryManagementSheet.swift

// HomeGroupManagementSheet has been moved to Views/HomeGroup/HomeGroupManagementSheet.swift

// AddHomeGroupSheet has been moved to Views/HomeGroup/AddHomeGroupSheet.swift

// MARK: - Filters Sheet
struct FiltersSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedMonthYear: Date
    @Binding var tempSelectedMonthYear: Date
    @Binding var tempSelectedMonth: Int
    @Binding var tempSelectedYear: Int
    @Binding var tempShowAllMonths: Bool
    @Binding var showAllMonths: Bool
    @Binding var tempSelectedCategory: String
    @Binding var selectedCategory: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Date Filter Section
                VStack(alignment: .leading, spacing: 12) {
                    // Text("Fecha:")
                    //     .font(.headline)
                    //     .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        // Month Dropdown
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                // "All months" option
                                Button(action: {
                                    tempShowAllMonths = true
                                }) {
                                    HStack {
                                        Text("Todos los meses")
                                        if tempShowAllMonths {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                // Individual months
                                ForEach(getMonthOptions(), id: \.index) { month in
                                    Button(action: {
                                        tempSelectedMonth = month.index
                                        tempShowAllMonths = false
                                    }) {
                                        HStack {
                                            Text(month.name)
                                            if tempSelectedMonth == month.index && !tempShowAllMonths {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if tempShowAllMonths {
                                        Text("Todos los meses")
                                            .foregroundColor(.primary)
                                    } else {
                                        Text(getMonthOptions().first { $0.index == tempSelectedMonth }?.name ?? "Seleccionar")
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Year Dropdown
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Año")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(getYearOptions(), id: \.self) { year in
                                    Button(action: {
                                        tempSelectedYear = year
                                    }) {
                                        HStack {
                                            Text(String(year))
                                            if tempSelectedYear == year {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(String(tempSelectedYear))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Category Filter Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Categoría:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Menu {
                        ForEach(getCategoryOptions(), id: \.self) { category in
                            Button(action: {
                                tempSelectedCategory = category
                            }) {
                                HStack {
                                    Text(category)
                                    if tempSelectedCategory == category {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(tempSelectedCategory)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Restaurar") {
                        // Reset to current month and year
                        let calendar = Calendar.current
                        let currentDate = Date()
                        tempSelectedMonth = calendar.component(.month, from: currentDate) - 1
                        tempSelectedYear = calendar.component(.year, from: currentDate)
                        tempShowAllMonths = false
                        showAllMonths = false
                        tempSelectedCategory = "Todas"
                        selectedCategory = "Todas"
                        
                        // Apply the reset immediately by updating selectedMonthYear
                        var components = DateComponents()
                        components.year = tempSelectedYear
                        components.month = tempSelectedMonth + 1
                        components.day = 1
                        
                        if let newDate = calendar.date(from: components) {
                            selectedMonthYear = newDate
                        }
                        
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aceptar") {
                        // Update the main state to reflect the applied filter
                        showAllMonths = tempShowAllMonths
                        selectedCategory = tempSelectedCategory
                        
                        // Update selectedMonthYear to reflect the current filter
                        let calendar = Calendar.current
                        if tempShowAllMonths {
                            // For "all months", set to first day of the year
                            var components = DateComponents()
                            components.year = tempSelectedYear
                            components.month = 1
                            components.day = 1
                            
                            if let newDate = calendar.date(from: components) {
                                selectedMonthYear = newDate
                            }
                        } else {
                            // Convert month and year to Date
                            var components = DateComponents()
                            components.year = tempSelectedYear
                            components.month = tempSelectedMonth + 1
                            components.day = 1
                            
                            if let newDate = calendar.date(from: components) {
                                selectedMonthYear = newDate
                            }
                        }
                        
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)

    }
    
    // Helper functions (need to be accessible)
    private func getMonthOptions() -> [(index: Int, name: String)] {
        let months = [
            (0, "Enero"), (1, "Febrero"), (2, "Marzo"), (3, "Abril"),
            (4, "Mayo"), (5, "Junio"), (6, "Julio"), (7, "Agosto"),
            (8, "Septiembre"), (9, "Octubre"), (10, "Noviembre"), (11, "Diciembre")
        ]
        return months.reversed()
    }
    
    private func getYearOptions() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(2020...currentYear).reversed()
    }
    
    private func getCategoryOptions() -> [String] {
        return ["Todas"] + EntryCategory.allCases.map { $0.displayName }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [HomeGroup.self, Entry.self, Item.self], inMemory: true)
}

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

// MARK: - App Info Sheet
struct AppInfoSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        // Suppress simulator warnings
        #if targetEnvironment(simulator)
        // These warnings are simulator-specific and don't affect functionality
        #endif
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Section 1: App Icon and Title
                    VStack(spacing: 16) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                        
                        Text("OMO Money")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Gestión inteligente de gastos personales")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    
                    Divider()
                    
                    // Section 2: App Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Acerca de OMO Money")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("OMO Money es una herramienta de bolsillo diseñada para ayudarte a gestionar tus gastos personales de manera simple y eficiente. Organiza tus gastos por grupos, categorías y fechas para tener un control total de tus finanzas. Hazlo a tu manera con OMO.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                    
                    Divider()
                    
                    // Section 3: Donations
                    VStack(spacing: 12) {
                        Text("¿Te gusta OMO Money?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Si la app te está ayudando, considera apoyar el desarrollo con una donación.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        Button(action: {
                            if let url = URL(string: "https://buymeacoffee.com/omopockettool") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 16))
                                Text("Apoyar la comunidad")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.gray)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                    
                    Divider()
                    
                    // Section 4: Share App
                    VStack(spacing: 12) {
                        Text("Compartir OMO Money")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Ayuda a otros a gestionar mejor sus finanzas compartiendo OMO Money con amigos y familiares.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16))
                                Text("Compartir App")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.gray)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                    
                    Divider()
                    
                    // Section 5: OMO Pocket Tool Catalog
                    VStack(spacing: 12) {
                        Text("Ecosistema OMO")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Descubre todas las herramientas del ecosistema OMO Pocket Tool diseñadas para tu crecimiento personal.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                        
                        Button(action: {
                            if let url = URL(string: "https://omopockettool.com/") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "apps.iphone")
                                    .font(.system(size: 16))
                                Text("Ver Catálogo Completo")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.gray)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                    
                    Divider()
                    
                    // Section 6: Contact, Developer signature, and Version
                    VStack(spacing: 16) {
                        // Contact
                        VStack(spacing: 4) {
                            Text("Contacto")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("omopockettool@gmail.com")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                        
                        // Developer signature
                        VStack(spacing: 12) {
                            Text("Con 🤍 Dennis")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Version
                        VStack(spacing: 4) {
                            Text("Versión")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("1.3.0")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [
                    "¡Descubre OMO Money! 💰\n\nUna herramienta de bolsillo para gestionar tus gastos personales de manera simple y eficiente.\n\nHazlo a tu manera con OMO.\n\nDescarga aquí: https://apps.apple.com/app/omo-money/id1234567890"
                 ])
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Configure for iPad if needed
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.red)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct AppPreviewRow: View {
    let name: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // App icon
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // App name
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Status badge
            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(status == "Disponible" ? .green : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(status == "Disponible" ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}



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


