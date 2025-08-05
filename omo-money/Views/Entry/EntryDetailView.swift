//
//  EntryDetailView.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI
import SwiftData

// MARK: - Navigation-based Entry Detail View
struct EntryDetailNavigationView: View {
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
    @State private var itemPayed = false
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
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.red)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        prepareForEditEntry(entry)
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        prepareForNewItem()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemSheet(
                isPresented: $showingAddItem,
                itemMoney: $itemMoney,
                itemAmount: $itemAmount,
                itemDescription: $itemDescription,
                itemPayed: $itemPayed,
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
                ),
                isActive: $showingEditEntry
            ) {
                EmptyView()
            }
        )
    }
    
    private func prepareForNewItem() {
        itemMoney = ""
        itemAmount = "1"
        itemDescription = ""
        itemPayed = false
        editingItem = nil
        showingAddItem = true
    }
    
    private func prepareForEditItem(_ item: Item) {
        itemMoney = String(format: "%.2f", item.money)
        itemAmount = item.amount?.description ?? ""
        itemDescription = item.itemDescription
        itemPayed = item.payed ?? false
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
                entryId: entry.id,
                position: nil,
                payed: itemPayed
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
        itemPayed = false
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
            item.payed = itemPayed
            
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
        itemPayed = false
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

// MARK: - Sheet-based Entry Detail View (for backward compatibility)
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
    @State private var itemPayed = false
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
                // ToolbarItem(placement: .navigationBarLeading) {
                //     Button("Cerrar") {
                //         dismiss()
                //     }
                //     .foregroundColor(.gray)
                // }
                
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
                    itemPayed: $itemPayed,
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
                    ),
                    isActive: $showingEditEntry
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    private func prepareForNewItem() {
        itemMoney = ""
        itemAmount = "1"
        itemDescription = ""
        itemPayed = false
        editingItem = nil
        showingAddItem = true
    }
    
    private func prepareForEditItem(_ item: Item) {
        itemMoney = String(format: "%.2f", item.money)
        itemAmount = item.amount?.description ?? ""
        itemDescription = item.itemDescription
        itemPayed = item.payed ?? false
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
                entryId: entry.id,
                position: nil,
                payed: itemPayed
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
        itemPayed = false
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
            item.payed = itemPayed
            
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
        itemPayed = false
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
                HStack(spacing: 4) {
                    Text(item.itemDescription)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if item.payed != true {
                        Text("(Pendiente)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                if let amount = item.amount {
                    Text("Cantidad: \(amount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Get currency from home group
            let homeGroup = homeGroups.first { $0.id == entry.homeGroupId }
            let currencySymbol = Currency(rawValue: homeGroup?.currency ?? "USD")?.symbol ?? "$"
            
            if item.money > 0 {
                Text("\(currencySymbol)\(String(format: "%.2f", item.money))")
                    .font(.headline)
                    .foregroundColor(item.payed != true ? .orange : (entry.type ? Color.green : Color.red))
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
    @Binding var itemPayed: Bool
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
                .padding(.top, 20)

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
                
                // Payed Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pagado")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                    
                    HStack {
                        Text(itemPayed ? "Sí" : "No")
                            .foregroundColor(.primary)
                        Spacer()
                        Toggle("", isOn: $itemPayed)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
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