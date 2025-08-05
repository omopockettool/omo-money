//
//  AddHomeGroupSheet.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI

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