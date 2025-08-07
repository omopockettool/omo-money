//
//  SearchSuggestions.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 06/8/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Search Suggestion Model
struct SearchSuggestion: Identifiable, Hashable {
    let id = UUID()
    let searchText: String
    let displayText: String
    let type: SuggestionType
    let originalText: String // Para mantener el texto original exacto
    
    enum SuggestionType: String, CaseIterable {
        case entry = "entry"
        case item = "item"
        
        var icon: String {
            switch self {
            case .entry: return "doc.text"
            case .item: return "cart"
            }
        }
        
        var label: String {
            switch self {
            case .entry: return "Entry"
            case .item: return "Item"
            }
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(searchText)
        hasher.combine(type)
    }
    
    static func == (lhs: SearchSuggestion, rhs: SearchSuggestion) -> Bool {
        return lhs.searchText == rhs.searchText && lhs.type == rhs.type
    }
}

// MARK: - Intelligent Search Helper
struct IntelligentSearchHelper {
    
    /// Normaliza el texto para búsqueda inteligente
    static func normalizeText(_ text: String) -> String {
        return text.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
    
    /// Obtiene variaciones de una palabra (singular/plural, etc.)
    static func getWordVariations(_ word: String) -> [String] {
        let normalized = normalizeText(word)
        var variations = [normalized]
        
        // Reglas básicas para español
        if normalized.hasSuffix("s") {
            // Quitar 's' final (plural a singular)
            let singular = String(normalized.dropLast())
            if !singular.isEmpty {
                variations.append(singular)
            }
        } else {
            // Agregar 's' final (singular a plural)
            variations.append(normalized + "s")
        }
        
        // Reglas específicas para español
        if normalized.hasSuffix("es") {
            // Quitar 'es' final (plural a singular)
            let singular = String(normalized.dropLast(2))
            if !singular.isEmpty {
                variations.append(singular)
            }
        } else if normalized.hasSuffix("a") || normalized.hasSuffix("e") || normalized.hasSuffix("i") || normalized.hasSuffix("o") || normalized.hasSuffix("u") {
            // Agregar 'es' final (singular a plural)
            variations.append(normalized + "es")
        }
        
        return Array(Set(variations)) // Eliminar duplicados
    }
    
    /// Verifica si el texto de búsqueda coincide con el texto objetivo
    static func matchesSearch(_ searchText: String, targetText: String) -> Bool {
        let searchVariations = getWordVariations(searchText)
        let targetNormalized = normalizeText(targetText)
        
        // Verificar coincidencia exacta
        if searchVariations.contains(targetNormalized) {
            return true
        }
        
        // Verificar si alguna variación está contenida en el texto objetivo
        for variation in searchVariations {
            if targetNormalized.contains(variation) {
                return true
            }
        }
        
        // Verificar si el texto de búsqueda está contenido en alguna variación del objetivo
        let targetVariations = getWordVariations(targetText)
        for variation in targetVariations {
            if variation.contains(normalizeText(searchText)) {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Search Suggestions Manager
class SearchSuggestionsManager: ObservableObject {
    @Published var suggestions: [SearchSuggestion] = []
    @Published var isLoading = false
    @Published var selectedSuggestionId: UUID? = nil
    
    private var debounceTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Configuración
    private let debounceInterval: TimeInterval = 0.4
    private let maxSuggestions = 10
    private let maxPerType = 5
    
    // MARK: - Public Methods
    
    /// Genera sugerencias basadas en el texto de entrada
    func generateSuggestions(
        from searchText: String,
        entries: [Entry],
        items: [Item],
        excludeCurrent: String? = nil
    ) {
        // Cancelar timer anterior
        debounceTimer?.invalidate()
        
        // Si el texto está vacío, limpiar sugerencias
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DispatchQueue.main.async {
                self.suggestions = []
                self.isLoading = false
                self.selectedSuggestionId = nil
            }
            return
        }
        
        // Mostrar loading
        DispatchQueue.main.async {
            self.isLoading = true
            self.selectedSuggestionId = nil
        }
        
        // Debounce: esperar antes de ejecutar la búsqueda
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { _ in
            self.performSearch(
                searchText: searchText,
                entries: entries,
                items: items,
                excludeCurrent: excludeCurrent
            )
        }
    }
    
    /// Limpia las sugerencias
    func clearSuggestions() {
        debounceTimer?.invalidate()
        DispatchQueue.main.async {
            self.suggestions = []
            self.isLoading = false
            self.selectedSuggestionId = nil
        }
    }
    
    /// Selecciona una sugerencia
    func selectSuggestion(_ id: UUID) {
        selectedSuggestionId = id
    }
    
    /// Obtiene la sugerencia seleccionada
    func getSelectedSuggestion() -> SearchSuggestion? {
        return suggestions.first { $0.id == selectedSuggestionId }
    }
    
    // MARK: - Private Methods
    
    private func performSearch(
        searchText: String,
        entries: [Entry],
        items: [Item],
        excludeCurrent: String?
    ) {
        let searchLower = searchText.lowercased()
        var suggestions: [SearchSuggestion] = []
        
        // Buscar en entries (eliminar duplicados por título exacto)
        let entryMatches = entries
            .filter { entry in
                let titleLower = entry.title.lowercased()
                return (titleLower.contains(searchLower) || 
                       IntelligentSearchHelper.matchesSearch(searchText, targetText: entry.title)) && 
                       entry.title != excludeCurrent
            }
            .reduce(into: [String: Entry]()) { result, entry in
                // Solo mantener una entrada por título único (case-insensitive y normalizado)
                let normalizedTitle = entry.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if result[normalizedTitle] == nil {
                    result[normalizedTitle] = entry
                }
            }
            .values
            .prefix(maxPerType)
        
        for entry in entryMatches {
            suggestions.append(SearchSuggestion(
                searchText: entry.title,
                displayText: entry.title,
                type: .entry,
                originalText: entry.title
            ))
        }
        
        // Buscar en items (eliminar duplicados por descripción exacta y evitar duplicados con entries)
        let itemMatches = items
            .filter { item in
                let descriptionLower = item.itemDescription.lowercased()
                return (descriptionLower.contains(searchLower) || 
                       IntelligentSearchHelper.matchesSearch(searchText, targetText: item.itemDescription)) && 
                       item.itemDescription != excludeCurrent
            }
            .reduce(into: [String: Item]()) { result, item in
                // Solo mantener un item por descripción única (case-insensitive y normalizado)
                let normalizedDescription = item.itemDescription.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if result[normalizedDescription] == nil {
                    result[normalizedDescription] = item
                }
            }
            .values
            .prefix(maxPerType)
        
        for item in itemMatches {
            // Verificar si ya existe un entry con el mismo texto (case-insensitive y normalizado)
            let itemText = item.itemDescription
            let itemTextLower = itemText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let alreadyExistsAsEntry = suggestions.contains { suggestion in
                suggestion.originalText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == itemTextLower
            }
            
            // Solo agregar si no existe como entry (priorizar entries sobre items)
            if !alreadyExistsAsEntry {
                suggestions.append(SearchSuggestion(
                    searchText: itemText,
                    displayText: itemText,
                    type: .item,
                    originalText: itemText
                ))
            }
        }
        
        // Ordenar por relevancia (exact match primero, luego partial, luego inteligente)
        let sortedSuggestions = suggestions.sorted { first, second in
            let firstExact = first.originalText.lowercased().hasPrefix(searchLower)
            let secondExact = second.originalText.lowercased().hasPrefix(searchLower)
            
            if firstExact && !secondExact {
                return true
            } else if !firstExact && secondExact {
                return false
            } else {
                // Si ambos son exact o ambos son partial, priorizar entries sobre items
                if first.type != second.type {
                    return first.type == .entry
                }
                // Si son del mismo tipo, ordenar alfabéticamente
                return first.originalText.lowercased() < second.originalText.lowercased()
            }
        }
        
        // Limitar y actualizar en main thread
        DispatchQueue.main.async {
            self.suggestions = Array(sortedSuggestions.prefix(self.maxSuggestions))
            self.isLoading = false
            self.selectedSuggestionId = nil
        }
    }
}

// MARK: - Search Suggestions View Component
struct SearchSuggestionsView: View {
    let suggestions: [SearchSuggestion]
    let isLoading: Bool
    let selectedSuggestionId: UUID?
    let onSuggestionTapped: (String) -> Void
    let onSuggestionSelected: (UUID) -> Void
    let onDismiss: () -> Void
    
    // Calcular altura dinámica basada en el número de sugerencias
    private var dynamicHeight: CGFloat {
        if isLoading || suggestions.isEmpty {
            return 60 // Altura para loading o mensaje vacío
        }
        
        let itemHeight: CGFloat = 56 // Altura por item (12 padding vertical + contenido)
        let maxHeight: CGFloat = 350 // Altura máxima
        let calculatedHeight = CGFloat(suggestions.count) * itemHeight
        
        return min(calculatedHeight, maxHeight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Buscando...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else if suggestions.isEmpty {
                Text("No se encontraron sugerencias")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(suggestions, id: \.id) { suggestion in
                            Button(action: {
                                // Tap en sugerencia: reemplazar texto y cerrar lista inmediatamente
                                onSuggestionTapped(suggestion.originalText)
                                onDismiss()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: suggestion.type.icon)
                                        .foregroundColor(.gray)
                                        .frame(width: 16)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(suggestion.displayText)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        Text(suggestion.type.label)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.clear)
                                .contentShape(Rectangle()) // Hacer toda la fila clickeable
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if suggestion.id != suggestions.last?.id {
                                Divider()
                                    .padding(.leading, 44)
                            }
                        }
                    }
                }
                .frame(maxHeight: dynamicHeight) // Altura dinámica
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .padding(.horizontal)
    }
}

// MARK: - Reusable Search Field with Suggestions
struct SearchFieldWithSuggestionsView: View {
    @Binding var searchText: String
    @StateObject private var suggestionsManager = SearchSuggestionsManager()
    @State private var showSuggestions = false
    @State private var justSelectedSuggestion = false
    @FocusState private var isFieldFocused: Bool
    
    let entries: [Entry]
    let items: [Item]
    let placeholder: String
    let excludeCurrent: String?
    let onSuggestionSelected: (String) -> Void
    
    init(
        searchText: Binding<String>,
        entries: [Entry],
        items: [Item],
        placeholder: String = "Buscar...",
        excludeCurrent: String? = nil,
        onSuggestionSelected: @escaping (String) -> Void
    ) {
        self._searchText = searchText
        self.entries = entries
        self.items = items
        self.placeholder = placeholder
        self.excludeCurrent = excludeCurrent
        self.onSuggestionSelected = onSuggestionSelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Field with Clear Button
            HStack(spacing: 8) {
                TextField(placeholder, text: $searchText)
                    .autocorrectionDisabled()
                    .focused($isFieldFocused)
                    .onChange(of: searchText) { _, newValue in
                        // Si acabamos de seleccionar una sugerencia, no regenerar
                        if justSelectedSuggestion {
                            justSelectedSuggestion = false
                            return
                        }
                        
                        suggestionsManager.generateSuggestions(
                            from: newValue,
                            entries: entries,
                            items: items,
                            excludeCurrent: excludeCurrent
                        )
                        showSuggestions = !newValue.isEmpty
                    }
                    .onTapGesture {
                        showSuggestions = !searchText.isEmpty
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button("Cerrar") {
                                isFieldFocused = false
                            }
                            .foregroundColor(.red)
                        }
                    }
                
                // Clear Button (only show when there's text)
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        suggestionsManager.clearSuggestions()
                        showSuggestions = false
                        isFieldFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            
            // Suggestions (mostrar siempre que haya texto, independientemente del foco)
            if showSuggestions && !searchText.isEmpty {
                SearchSuggestionsView(
                    suggestions: suggestionsManager.suggestions,
                    isLoading: suggestionsManager.isLoading,
                    selectedSuggestionId: suggestionsManager.selectedSuggestionId,
                    onSuggestionTapped: { selectedText in
                        // Marcar que acabamos de seleccionar una sugerencia
                        justSelectedSuggestion = true
                        searchText = selectedText
                        onSuggestionSelected(selectedText)
                    },
                    onSuggestionSelected: { suggestionId in
                        // Segundo tap: cerrar lista de sugerencias
                        showSuggestions = false
                        isFieldFocused = false
                        suggestionsManager.clearSuggestions()
                    },
                    onDismiss: {
                        showSuggestions = false
                        isFieldFocused = false
                        suggestionsManager.clearSuggestions()
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onChange(of: isFieldFocused) { _, focused in
            // Mantener sugerencias visibles incluso sin foco
            if !focused && searchText.isEmpty {
                showSuggestions = false
            }
        }
    }
} 