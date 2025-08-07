//
//  EntryFormView.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI
import SwiftData

// MARK: - Navigation-based Entry Form
struct EntryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
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
    @State private var dateSelected: Bool = false
    @State private var showAdvancedOptions: Bool = false
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
                
                // Advanced Options Section
                VStack(alignment: .leading, spacing: 8) {
                    // Only show collapsible advanced options for new entries
                    if !isEditing {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showAdvancedOptions.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "gearshape")
                                    .foregroundColor(.gray)
                                Text("Opciones Avanzadas")
                                    .font(.headline)
                                    .foregroundColor(Color(.systemGray))
                                Spacer()
                                Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
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
                    }
                    
                    // Show advanced options when editing or when expanded for new entries
                    if isEditing || showAdvancedOptions {
                        VStack(spacing: 16) {
                            // Date Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fecha")
                                    .font(.headline)
                                    .foregroundColor(Color(.systemGray))
                                
                                Button(action: {
                                    // Cerrar el teclado antes de mostrar el date picker
                                    focusedField = nil
                                    dateSelected = false
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
                                    VStack(spacing: 8) {
                                        DatePicker("", selection: $entryDate, displayedComponents: .date)
                                            .datePickerStyle(.graphical)
                                            .labelsHidden()
                                            .onChange(of: entryDate) { _, _ in
                                                // Mark that a date has been selected
                                                dateSelected = true
                                            }
                                        
                                        if dateSelected {
                                            Button(action: {
                                                showDatePicker = false
                                                dateSelected = false
                                            }) {
                                                Text("Confirmar fecha")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(Color.blue)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Category Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Categoría")
                                    .font(.headline)
                                    .foregroundColor(Color(.systemGray))
                                
                                Menu {
                                    ForEach(EntryCategory.allCases, id: \.self) { category in
                                        Button(action: {
                                            entryCategory = category.rawValue
                                        }) {
                                            HStack {
                                                Circle()
                                                    .fill(categoryColor(category.rawValue))
                                                    .frame(width: 12, height: 12)
                                                Text(category.displayName)
                                                if entryCategory == category.rawValue {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(categoryColor(entryCategory))
                                            .frame(width: 12, height: 12)
                                        Text(EntryCategory(rawValue: entryCategory)?.displayName ?? "Seleccionar Categoría")
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
                        }
                        .padding(.horizontal, isEditing ? 0 : 4)
                        .padding(.vertical, isEditing ? 0 : 8)
                        .background(isEditing ? Color.clear : Color(.systemGray6).opacity(0.5))
                        .cornerRadius(isEditing ? 0 : 8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(isEditing ? "Editar Entrada" : "Nueva Entrada")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
                .foregroundColor(.gray)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    onSave()
                    dismiss()
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
                
                Button("Hecho") {
                    focusedField = nil
                }
                .foregroundColor(.red)
            }
        }
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

// MARK: - Sheet-based Entry Form (for backward compatibility)
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
    @State private var dateSelected: Bool = false
    @State private var showAdvancedOptions: Bool = false
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
                    
                    // Advanced Options Section
                    VStack(alignment: .leading, spacing: 8) {
                        // Only show collapsible advanced options for new entries
                        if !isEditing {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showAdvancedOptions.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "gearshape")
                                        .foregroundColor(.gray)
                                    Text("Opciones Avanzadas")
                                        .font(.headline)
                                        .foregroundColor(Color(.systemGray))
                                    Spacer()
                                    Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
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
                        }
                        
                        // Show advanced options when editing or when expanded for new entries
                        if isEditing || showAdvancedOptions {
                            VStack(spacing: 16) {
                                // Date Section
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Fecha")
                                        .font(.headline)
                                        .foregroundColor(Color(.systemGray))
                                    
                                    Button(action: {
                                        // Cerrar el teclado antes de mostrar el date picker
                                        focusedField = nil
                                        dateSelected = false
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
                                        VStack(spacing: 8) {
                                            DatePicker("", selection: $entryDate, displayedComponents: .date)
                                                .datePickerStyle(.graphical)
                                                .labelsHidden()
                                                .onChange(of: entryDate) { _, _ in
                                                    // Mark that a date has been selected
                                                    dateSelected = true
                                                }
                                            
                                            if dateSelected {
                                                Button(action: {
                                                    showDatePicker = false
                                                    dateSelected = false
                                                }) {
                                                    Text("Confirmar fecha")
                                                        .font(.subheadline)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 8)
                                                        .background(Color.blue)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                                
                                // Category Section
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Categoría")
                                        .font(.headline)
                                        .foregroundColor(Color(.systemGray))
                                    
                                    Menu {
                                        ForEach(EntryCategory.allCases, id: \.self) { category in
                                            Button(action: {
                                                entryCategory = category.rawValue
                                            }) {
                                                HStack {
                                                    Circle()
                                                        .fill(categoryColor(category.rawValue))
                                                        .frame(width: 12, height: 12)
                                                    Text(category.displayName)
                                                    if entryCategory == category.rawValue {
                                                        Image(systemName: "checkmark")
                                                            .foregroundColor(.green)
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Circle()
                                                .fill(categoryColor(entryCategory))
                                                .frame(width: 12, height: 12)
                                            Text(EntryCategory(rawValue: entryCategory)?.displayName ?? "Seleccionar Categoría")
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
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(8)
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
                    .foregroundColor(.red)
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
                    
                    Button("Hecho") {
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

// validateMoneyInput function is defined in ContentView.swift and shared between forms 