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

// EntryRowView has been moved to Views/Entry/Components/EntryRowView.swift

// AddEntrySheet has been moved to EntryFormView.swift

// EntryDetailView has been moved to EntryDetailView.swift

// ItemRowView has been moved to EntryDetailView.swift

// AddItemSheet has been moved to EntryDetailView.swift

// CategoryManagementSheet has been moved to Views/Category/CategoryManagementSheet.swift

// HomeGroupManagementSheet has been moved to Views/HomeGroup/HomeGroupManagementSheet.swift

// AddHomeGroupSheet has been moved to Views/HomeGroup/AddHomeGroupSheet.swift

// FiltersSheet has been moved to Views/Filters/FiltersSheet.swift

#Preview {
    ContentView()
        .modelContainer(for: [HomeGroup.self, Entry.self, Item.self], inMemory: true)
}

// validateMoneyInput has been moved to Utils/Helpers/MoneyValidation.swift

// AppInfoSheet has been moved to Views/Info/AppInfoSheet.swift

// ShareSheet has been moved to Views/Info/AppInfoSheet.swift

// FeatureRow and AppPreviewRow have been moved to Views/Info/Components/



// DateFormatter extension has been moved to Utils/Extensions/DateFormatter+Extensions.swift


