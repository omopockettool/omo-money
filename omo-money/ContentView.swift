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
    
    @State private var selectedHomeGroupId: String? = nil
    @State private var showingAddEntry = false
    @State private var selectedEntry: Entry? = nil
    @State private var entryTitle = ""
    @State private var entryDate = Date()
    @State private var entryCategory = EntryCategory.comida.rawValue
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
    
    // Get current home group
    var currentHomeGroup: HomeGroup? {
        guard let selectedHomeGroupId = selectedHomeGroupId else { return nil }
        return homeGroups.first { $0.id == selectedHomeGroupId }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Home Group and Month/Year Selector
                if !homeGroups.isEmpty {
                    HStack {
                        // Left side: Group and Filters
                        HStack {
                            // Home Group Dropdown
                            Menu {
                                ForEach(homeGroups, id: \.id) { homeGroup in
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
                                .background(Color(.systemGray6))
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
                                .background(Color(.systemGray6))
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
                                    .foregroundColor(.primary)
                                
                                // Show search indicator if there's active search
                                if !searchText.isEmpty {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSearchActive ? Color.red.opacity(0.1) : Color(.systemGray6))
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
                            TextField("Buscar en entries e items...", text: $searchText)
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
                        .background(Color(.systemGray6).opacity(0.6))
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
                            let entryTotal = items.reduce(0.0) { $0 + $1.money }
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
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                
                if homeGroups.isEmpty {
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
                        } else {
                            // No entries in group
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
                                        selectedEntry = entry
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color(.systemGray6))
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
                }
            }
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
            .sheet(isPresented: $showingAddEntry) {
                AddEntrySheet(
                    isPresented: $showingAddEntry,
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
            }
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
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
            .sheet(isPresented: $showingAppInfo) {
                AppInfoSheet(isPresented: $showingAppInfo)
            }
            .onAppear {
                // Auto-select the first home group if none is selected
                if selectedHomeGroupId == nil && !homeGroups.isEmpty {
                    selectedHomeGroupId = homeGroups.first?.id
                }
            }
        }
    }
    
    private func prepareForNewEntry() {
        entryTitle = ""
        entryDate = Calendar.current.startOfDay(for: Date())
        entryCategory = EntryCategory.comida.rawValue
        entryType = false
        entryHomeGroupId = selectedHomeGroupId ?? ""
        entryMoney = ""
        editingEntry = nil
        showingAddEntry = true
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
        showingAddEntry = true
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
                    entryId: newEntry.id
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
                    
                    // Show list icon only when entry has items
                    if !items.isEmpty {
                        Image(systemName: "list.bullet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Show total amount if there are items
            if !items.isEmpty {
                let total = items.reduce(0) { $0 + $1.money }
                let color = entry.type ? Color.green : Color.red
                // Get currency from home group
                let homeGroup = homeGroups.first { $0.id == entry.homeGroupId }
                let currencySymbol = Currency(rawValue: homeGroup?.currency ?? "USD")?.symbol ?? "$"
                
                if total > 0 {
                    Text("\(currencySymbol)\(String(format: "%.2f", total))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                } else {
                    Text("Sin precio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Sin items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
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

struct AddEntrySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @Binding var entryTitle: String
    @Binding var entryDate: Date
    @Binding var entryCategory: String
    @Binding var entryType: Bool
    @Binding var entryHomeGroupId: String
    @Binding var entryMoney: String
    var isEditing: Bool = false
    var onSave: () -> Void
    
    @Query(sort: \HomeGroup.createdAt) private var homeGroups: [HomeGroup]
    
    @State private var showDatePicker: Bool = false
    @FocusState private var focusedField: Field?
    
    // Computed property to check if the form is valid
    private var isFormValid: Bool {
        !entryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    enum Field {
        case title
        case money
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Entry Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.headline)
                            .foregroundColor(Color(.systemGray))
                        
                        TextField("Ej: Compra del super, Gimnasio, etc.", text: $entryTitle)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .title)
                    }
                    .padding(.horizontal)
                    
                    // Money Section (only show for new entries, not editing)
                    if !isEditing {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Precio (opcional)")
                                .font(.headline)
                                .foregroundColor(Color(.systemGray))
                            
                                                    TextField("0.00", text: $entryMoney)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .money)
                            .onChange(of: entryMoney) { _, newValue in
                                // Convertir coma a punto para decimales
                                let convertedValue = newValue.replacingOccurrences(of: ",", with: ".")
                                if convertedValue != newValue {
                                    entryMoney = convertedValue
                                    return
                                }
                                
                                // Validar formato de dinero
                                let validatedValue = validateMoneyInput(convertedValue)
                                if validatedValue != convertedValue {
                                    entryMoney = validatedValue
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fecha")
                            .font(.headline)
                            .foregroundColor(Color(.systemGray))
                        
                        Button(action: {
                            // Cerrar el teclado antes de mostrar el date picker
                            focusedField = nil
                            showDatePicker.toggle()
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                Text(entryDate.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if showDatePicker {
                            DatePicker("", selection: $entryDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .onChange(of: entryDate) { _, _ in
                                    // Close the date picker when a date is selected
                                    showDatePicker = false
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categoría")
                            .font(.headline)
                            .foregroundColor(Color(.systemGray))
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(EntryCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    entryCategory = category.rawValue
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(categoryColor(category.rawValue))
                                            .frame(width: 12, height: 12)
                                        Text(category.displayName)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if entryCategory == category.rawValue {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(entryCategory == category.rawValue ? Color.green.opacity(0.1) : Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(entryCategory == category.rawValue ? Color.green : Color(.systemGray4), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Home Group Section (only show if editing or multiple home groups exist)
                    if isEditing || homeGroups.count > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grupo")
                                .font(.headline)
                                .foregroundColor(Color(.systemGray))
                            
                            Menu {
                                ForEach(homeGroups, id: \.id) { homeGroup in
                                    Button(action: {
                                        entryHomeGroupId = homeGroup.id
                                    }) {
                                        HStack {
                                            Text(homeGroup.name)
                                            if entryHomeGroupId == homeGroup.id {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    let selectedGroup = homeGroups.first { $0.id == entryHomeGroupId }
                                    Text(selectedGroup?.name ?? "Seleccionar Grupo")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Type Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tipo")
                            .font(.headline)
                            .foregroundColor(Color(.systemGray))
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                entryType = false
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle")
                                        .foregroundColor(.red)
                                    Text("Gasto")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if !entryType {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(!entryType ? Color.red.opacity(0.1) : Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(!entryType ? Color.red : Color(.systemGray4), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Button(action: {
                            //     entryType = true
                            // }) {
                            //     HStack {
                            //         Image(systemName: "arrow.up.circle")
                            //             .foregroundColor(.green)
                            //         Text("Ingreso")
                            //             .foregroundColor(.primary)
                            //         Spacer()
                            //         if entryType {
                            //             Image(systemName: "checkmark")
                            //                 .foregroundColor(.green)
                            //         }
                            //     }
                            //     .padding()
                            //     .background(entryType ? Color.green.opacity(0.1) : Color(.systemGray6))
                            //     .cornerRadius(8)
                            //     .overlay(
                            //         RoundedRectangle(cornerRadius: 8)
                            //             .stroke(entryType ? Color.green : Color(.systemGray4), lineWidth: 1)
                            //     )
                            // }
                            // .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(isEditing ? "Editar Entrada" : "Nueva Entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        onSave()
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    .disabled(!isFormValid)
                }
                
                                ToolbarItemGroup(placement: .keyboard) {
                    // Only show navigation arrows for new entries (not editing)
                    if !isEditing {
                        Button(action: {
                            if focusedField == .money {
                                focusedField = .title
                            }
                        }) {
                            Image(systemName: "chevron.up")
                        }
                        .foregroundColor(.red)
                        .disabled(focusedField == .title)
                        
                        Button(action: {
                            if focusedField == .title {
                                focusedField = .money
                            }
                        }) {
                            Image(systemName: "chevron.down")
                        }
                        .foregroundColor(.red)
                        .disabled(focusedField == .money)
                    }
 
                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Set focus to description field only for new entries, not when editing
            if !isEditing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .title
                }
            }
        }
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

struct EntryDetailView: View {
    let entry: Entry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allItems: [Item]
    @State private var showingAddItem = false
    @State private var showingEditItem = false
    @State private var showingEditEntry = false
    @State private var itemMoney = ""
    @State private var itemAmount = ""
    @State private var itemDescription = ""
    @State private var editingItem: Item? = nil
    @State private var entryTitle = ""
    @State private var entryDate = Date()
    @State private var entryCategory = ""
    @State private var entryType = false
    @State private var entryHomeGroupId = ""
    @State private var entryMoney = ""
    @State private var editingEntry: Entry? = nil
    
    var items: [Item] {
        allItems.filter { $0.entryId == entry.id }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("No hay items")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemGray))
                        
                        Text("Agrega items a este entry para comenzar")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: {
                            prepareForNewItem()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Agregar Primer Item")
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
                    List {
                        ForEach(items, id: \.id) { item in
                            ItemRowView(item: item, entry: entry, onEdit: {
                                prepareForEditItem(item)
                            })
                        }
                        .onDelete { offsets in
                            let itemsToDelete = offsets.map { items[$0] }
                            deleteItems(itemsToDelete)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        prepareForEditEntry(entry)
                    }) {
                        HStack(spacing: 4) {
                            Text(entry.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        prepareForNewItem()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemSheet(
                    isPresented: $showingAddItem,
                    itemMoney: $itemMoney,
                    itemAmount: $itemAmount,
                    itemDescription: $itemDescription,
                    editingItem: $editingItem,
                    onSave: {
                        if let editingItem = editingItem {
                            updateItem(editingItem)
                        } else {
                            addItem()
                        }
                    }
                )
                .onDisappear {
                    editingItem = nil
                }
            }
            .sheet(isPresented: $showingEditEntry) {
                AddEntrySheet(
                    isPresented: $showingEditEntry,
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
            }
        }
    }
    
    private func prepareForNewItem() {
        itemMoney = ""
        itemAmount = "1"
        itemDescription = ""
        editingItem = nil
        showingAddItem = true
    }
    
    private func prepareForEditItem(_ item: Item) {
        itemMoney = String(format: "%.2f", item.money)
        itemAmount = item.amount?.description ?? ""
        itemDescription = item.itemDescription
        editingItem = item
        showingAddItem = true
    }
    
    private func prepareForEditEntry(_ entry: Entry) {
        entryTitle = entry.title
        entryDate = entry.date
        entryCategory = entry.category
        entryType = entry.type
        entryHomeGroupId = entry.homeGroupId
        editingEntry = entry
        showingEditEntry = true
    }
    
    private func addItem() {
        guard !itemDescription.isEmpty else { return }
        
        // Use 0 as default money if empty or invalid
        let money = Double(itemMoney) ?? 0.0
        
        // Use 1 as default amount if empty
        let amount = itemAmount.isEmpty ? 1 : Int(itemAmount) ?? 1
        
        withAnimation {
            let newItem = Item(
                money: money,
                amount: amount,
                itemDescription: itemDescription,
                entryId: entry.id
            )
            modelContext.insert(newItem)
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving item: \(error)")
            }
        }
        
        // Reset form
        itemMoney = ""
        itemAmount = ""
        itemDescription = ""
    }
    
    private func updateItem(_ item: Item) {
        guard !itemDescription.isEmpty else { return }
        
        // Use 0 as default money if empty or invalid
        let money = Double(itemMoney) ?? 0.0
        
        // Use 1 as default amount if empty
        let amount = itemAmount.isEmpty ? 1 : Int(itemAmount) ?? 1
        
        withAnimation {
            item.money = money
            item.amount = amount
            item.itemDescription = itemDescription
            
            do {
                try modelContext.save()
            } catch {
                print("Error updating item: \(error)")
            }
        }
        
        // Reset form
        itemMoney = ""
        itemAmount = ""
        itemDescription = ""
        editingItem = nil
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
        
        // Reset form
        entryTitle = ""
        entryDate = Date()
        entryCategory = ""
        entryType = false
        entryHomeGroupId = ""
        editingEntry = nil
    }
    
    private func deleteItems(_ items: [Item]) {
        withAnimation {
            for item in items {
                modelContext.delete(item)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting items: \(error)")
            }
        }
    }
}

struct ItemRowView: View {
    let item: Item
    let entry: Entry // Add entry parameter to know the type
    var onEdit: (() -> Void)?
    
    @Query(sort: \HomeGroup.createdAt) private var homeGroups: [HomeGroup]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.itemDescription)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let amount = item.amount {
                    Text("Cantidad: \(amount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Color the amount based on entry type (red for expenses, green for income)
            let amountColor = entry.type ? Color.green : Color.red
            // Get currency from home group
            let homeGroup = homeGroups.first { $0.id == entry.homeGroupId }
            let currencySymbol = Currency(rawValue: homeGroup?.currency ?? "USD")?.symbol ?? "$"
            
            if item.money > 0 {
                Text("\(currencySymbol)\(String(format: "%.2f", item.money))")
                    .font(.headline)
                    .foregroundColor(amountColor)
            } else {
                Text("Sin precio")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit?()
        }
    }
}

struct AddItemSheet: View {
    @Binding var isPresented: Bool
    @Binding var itemMoney: String
    @Binding var itemAmount: String
    @Binding var itemDescription: String
    @Binding var editingItem: Item?
    var onSave: () -> Void
    @FocusState private var focusedField: Field?
    
    private var isFormValid: Bool {
        let descriptionValid = !itemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Si hay precio, debe ser un número válido
        let moneyValid = itemMoney.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                        Double(itemMoney.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
        
        return descriptionValid && moneyValid
    }
    
    enum Field {
        case money
        case amount
        case description
    }
    
    var body: some View {
        let isEditing = editingItem != nil
        NavigationView {
            VStack(spacing: 20) {
                // Description Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                    
                    TextField("Detallar cada producto tiene sus ventajas...", text: $itemDescription)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .description)
                        .onChange(of: itemDescription) { _, newValue in
                        }
                }
                .padding(.horizontal)

                // Money Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Precio (opcional)")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                    
                    TextField("0.00", text: $itemMoney)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .money)
                        .onChange(of: itemMoney) { _, newValue in
                            // Convertir coma a punto para decimales
                            let convertedValue = newValue.replacingOccurrences(of: ",", with: ".")
                            if convertedValue != newValue {
                                itemMoney = convertedValue
                                return
                            }
                            
                            // Validar formato de dinero
                            let validatedValue = validateMoneyInput(convertedValue)
                            if validatedValue != convertedValue {
                                itemMoney = validatedValue
                            }
                        }
                }
                .padding(.horizontal)
                
                // Amount Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cantidad (opcional)")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                    
                    TextField("1", text: $itemAmount)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .amount)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle(isEditing ? "Editar Item" : "Nuevo Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        onSave()
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    .disabled(!isFormValid)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    
                    Button(action: {
                        if focusedField == .amount {
                            focusedField = .money
                        } else if focusedField == .money {
                            focusedField = .description
                        }
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .foregroundColor(.red)
                    .disabled(focusedField == .description)
                    
                    Button(action: {
                        if focusedField == .description {
                            focusedField = .money
                        } else if focusedField == .money {
                            focusedField = .amount
                        }
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.red)
                    .disabled(focusedField == .amount)
                    
                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            if !isEditing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = .description
                }
            } else {
                focusedField = nil
            }
        }
    }
}

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
                let entryTotal = items.reduce(0.0) { $0 + $1.money }
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

struct HomeGroupManagementSheet: View {
    @Binding var isPresented: Bool
    let homeGroups: [HomeGroup]
    let modelContext: ModelContext
    @Binding var selectedHomeGroupId: String?
    
    @State private var showingAddHomeGroup = false
    @State private var newHomeGroupName = ""
    @State private var newHomeGroupCurrency = Currency.usd.rawValue
    @State private var showingDeleteAlert = false
    @State private var groupsToDelete: [HomeGroup] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cerrar") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("Gestión de Grupos")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddHomeGroup = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                if homeGroups.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "house")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No hay grupos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemGray))
                        
                        Text("Crea tu primer grupo para organizar tus gastos")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingAddHomeGroup = true
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
                } else {
                    List {
                        ForEach(homeGroups, id: \.id) { homeGroup in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(homeGroup.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    let currencySymbol = Currency(rawValue: homeGroup.currency)?.symbol ?? "$"
                                    Text("Moneda: \(currencySymbol) (\(homeGroup.currency))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    if selectedHomeGroupId == homeGroup.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    
                                    Button(action: {
                                        groupsToDelete = [homeGroup]
                                        showingDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedHomeGroupId == homeGroup.id {
                                    // Si ya está seleccionado, cerrar el sheet
                                    isPresented = false
                                } else {
                                    // Si no está seleccionado, seleccionarlo
                                    selectedHomeGroupId = homeGroup.id
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .sheet(isPresented: $showingAddHomeGroup) {
            AddHomeGroupSheet(
                isPresented: $showingAddHomeGroup,
                homeGroupName: $newHomeGroupName,
                homeGroupCurrency: $newHomeGroupCurrency,
                onSave: {
                    addHomeGroup()
                }
            )
        }
        .alert("¿Estás seguro de eliminar \(groupsToDelete.first?.name ?? "este grupo")?", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) {
                // No hacer nada, solo cerrar el alert
            }
            .foregroundColor(.gray)
            
            Button("Eliminar", role: .destructive) {
                deleteHomeGroups(groupsToDelete)
            }
            .foregroundColor(.red)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func addHomeGroup() {
        withAnimation {
            let newHomeGroup = HomeGroup(
                name: newHomeGroupName,
                currency: newHomeGroupCurrency
            )
            modelContext.insert(newHomeGroup)
            
            // If this is the first home group, select it automatically
            if homeGroups.isEmpty {
                selectedHomeGroupId = newHomeGroup.id
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving home group: \(error)")
            }
        }
        
        // Reset form
        newHomeGroupName = ""
        newHomeGroupCurrency = Currency.usd.rawValue
    }
    
    private func deleteHomeGroups(_ groups: [HomeGroup]) {
        withAnimation {
            for group in groups {
                modelContext.delete(group)
            }
            
            // If we deleted the selected group, select the first available one
            if groups.contains(where: { $0.id == selectedHomeGroupId }) {
                selectedHomeGroupId = homeGroups.first { !groups.contains($0) }?.id
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting home groups: \(error)")
            }
        }
    }
}

struct AddHomeGroupSheet: View {
    @Binding var isPresented: Bool
    @Binding var homeGroupName: String
    @Binding var homeGroupCurrency: String
    var onSave: () -> Void
    
    @FocusState private var focusedField: Field?
    
    private var isFormValid: Bool {
        !homeGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    enum Field {
        case name
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Home Group Name Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre del Grupo")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                    
                    TextField("Ej: Gastos Diarios", text: $homeGroupName)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .name)
                }
                .padding(.horizontal)
                
                // Currency Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Moneda")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                    
                    Menu {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Button(action: {
                                homeGroupCurrency = currency.rawValue
                            }) {
                                HStack {
                                    Text(currency.displayName)
                                    if homeGroupCurrency == currency.rawValue {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            let selectedCurrency = Currency(rawValue: homeGroupCurrency)
                            Text(selectedCurrency?.displayName ?? "Seleccionar Moneda")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Nuevo Grupo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        onSave()
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    .disabled(!isFormValid)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

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

// MARK: - Money Validation Helper
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
                            Text("1.2.1")
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
