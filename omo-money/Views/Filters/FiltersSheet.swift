//
//  FiltersSheet.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI

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
    @Binding var searchText: String
    @Binding var tempSearchText: String
    
    // Data for suggestions
    let entries: [Entry]
    let items: [Item]
    
    @State private var isApplyingFilters = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Search Filter Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Búsqueda")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        SearchFieldWithSuggestionsView(
                            searchText: $tempSearchText,
                            entries: entries,
                            items: items,
                            placeholder: "Buscar en entradas e items...",
                            excludeCurrent: nil
                        ) { selectedText in
                            print("Sugerencia seleccionada: \(selectedText)")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                            )
                    )
                    
                    // Category Filter Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Categoría")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        Menu {
                            // "Todas" option
                            Button(action: {
                                tempSelectedCategory = "Todas"
                            }) {
                                HStack {
                                    Text("Todas")
                                    if tempSelectedCategory == "Todas" {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Individual categories
                            ForEach(EntryCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    tempSelectedCategory = category.displayName
                                }) {
                                    HStack {
                                        Text(category.displayName)
                                        if tempSelectedCategory == category.displayName {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(tempSelectedCategory)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(16)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                            )
                    )
                    
                    // Date Filter Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Período")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 12) {
                            // Month Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mes")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
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
                                                    .foregroundColor(.red)
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
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if tempShowAllMonths {
                                            Text("Todos")
                                                .foregroundColor(.primary)
                                                .font(.body)
                                        } else {
                                            Text(getMonthOptions().first { $0.index == tempSelectedMonth }?.name ?? "Seleccionar")
                                                .foregroundColor(.primary)
                                                .font(.body)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding(16)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Year Dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Año")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
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
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(String(tempSelectedYear))
                                            .foregroundColor(.primary)
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding(16)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                            )
                    )
                    
                    // Spacer to push content to top
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
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
                        tempSearchText = ""
                        searchText = ""
                        
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
                    .disabled(isApplyingFilters)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Group {
                        if isApplyingFilters {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.red)
                        } else {
                            Button("Aplicar") {
                                applyFilters()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Filter Application
    private func applyFilters() {
        // Haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Show loading indicator
        isApplyingFilters = true
        
        // Process filters immediately
        // Update the main state to reflect the applied filter
        showAllMonths = tempShowAllMonths
        selectedCategory = tempSelectedCategory
        searchText = tempSearchText
        
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
        
        // Hide loading indicator and close sheet immediately after processing
        isApplyingFilters = false
        isPresented = false
    }
    
    // Helper functions (need to be accessible)
    private func getMonthOptions() -> [(index: Int, name: String)] {
        let months = [
            (0, "Enero"), (1, "Febrero"), (2, "Marzo"), (3, "Abril"),
            (4, "Mayo"), (5, "Junio"), (6, "Julio"), (7, "Agosto"),
            (8, "Septiembre"), (9, "Octubre"), (10, "Noviembre"), (11, "Diciembre")
        ]
        return months
    }
    
    private func getYearOptions() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(2020...currentYear).reversed()
    }
    
    // Esta función ya no se usa, pero la mantenemos por compatibilidad
    private func getCategoryOptions() -> [String] {
        return ["Todas"] + EntryCategory.allCases.map { $0.displayName }
    }
} 