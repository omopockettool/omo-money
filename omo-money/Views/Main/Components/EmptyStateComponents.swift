//
//  EmptyStateComponents.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI

// MARK: - Reusable Empty State Components

struct EmptyStateCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let buttonText: String
    let buttonIcon: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(.systemGray))
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: buttonAction) {
                HStack {
                    Image(systemName: buttonIcon)
                    Text(buttonText)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
        }
        .padding()
        
        Spacer()
    }
}

struct CompactEmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    let buttonText: String
    let buttonIcon: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(Color(.systemGray))
            
            Text(message)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: buttonAction) {
                HStack(spacing: 6) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 14))
                    Text(buttonText)
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
        
        Spacer()
    }
}

// MARK: - Specific Empty State Views

struct WelcomeEmptyState: View {
    let onAddEntry: () -> Void
    
    var body: some View {
        EmptyStateCard(
            icon: "dollarsign.circle.fill",
            iconColor: .green,
            title: "OMO Money",
            message: "Comienza a registrar tus gastos e ingresos en este grupo",
            buttonText: "Agregar Primer Entrada",
            buttonIcon: "plus.circle.fill",
            buttonAction: onAddEntry
        )
    }
}

struct NoEntriesThisMonthEmptyState: View {
    let selectedMonthYear: Date
    let onAddEntry: () -> Void
    
    var body: some View {
        EmptyStateCard(
            icon: "calendar.badge.plus",
            iconColor: .gray,
            title: "Sin Entradas este Mes",
            message: "Añade tu primer entrada.",
            buttonText: "Agregar Entrada",
            buttonIcon: "plus.circle.fill",
            buttonAction: onAddEntry
        )
    }
}

struct GenericNoEntriesEmptyState: View {
    let selectedMonthYear: Date
    let onAddEntry: () -> Void
    
    var body: some View {
        EmptyStateCard(
            icon: "calendar.badge.plus",
            iconColor: .blue,
            title: "Sin Entradas este Mes",
            message: "No hay entradas registradas en \(DateFormatter.monthYearFormatter.string(from: selectedMonthYear))",
            buttonText: "Agregar Entrada",
            buttonIcon: "plus.circle.fill",
            buttonAction: onAddEntry
        )
    }
}

struct SearchNoResultsEmptyState: View {
    let searchText: String
    let onClearSearch: () -> Void
    
    var body: some View {
        EmptyStateCard(
            icon: "magnifyingglass",
            iconColor: .gray,
            title: "No se encontraron resultados",
            message: "No hay entradas o items que coincidan con '\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))'",
            buttonText: "Limpiar Búsqueda",
            buttonIcon: "xmark.circle.fill",
            buttonAction: onClearSearch
        )
    }
}

struct CategoryFilterNoResultsEmptyState: View {
    let onClearCategoryFilter: () -> Void
    
    var body: some View {
        EmptyStateCard(
            icon: "line.3.horizontal.decrease.circle",
            iconColor: .gray,
            title: "No se encontraron resultados",
            message: "No hay entradas para los filtros aplicados.",
            buttonText: "Limpiar Filtro",
            buttonIcon: "arrow.clockwise.circle.fill",
            buttonAction: onClearCategoryFilter
        )
    }
}

struct MultipleFiltersNoResultsEmptyState: View {
    let onClearAllFilters: () -> Void
    
    var body: some View {
        EmptyStateCard(
            icon: "line.3.horizontal.decrease.circle",
            iconColor: .gray,
            title: "No se encontraron resultados",
            message: "No hay entradas para los filtros aplicados.",
            buttonText: "Limpiar Todos los Filtros",
            buttonIcon: "arrow.clockwise.circle.fill",
            buttonAction: onClearAllFilters
        )
    }
}

struct DateFilterNoResultsEmptyState: View {
    let onClearFilters: () -> Void
    
    var body: some View {
        EmptyStateCard(
            icon: "calendar",
            iconColor: .gray,
            title: "No se encontraron resultados",
            message: "No hay entradas para los filtros aplicados.",
            buttonText: "Limpiar Filtro",
            buttonIcon: "arrow.clockwise.circle.fill",
            buttonAction: onClearFilters
        )
    }
}

struct SelectGroupEmptyState: View {
    var body: some View {
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
        
        Spacer()
    }
} 