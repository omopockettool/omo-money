//
//  HomeGroupManagementSheet.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 15/7/25.
//

import SwiftUI
import SwiftData

struct HomeGroupManagementSheet: View {
    @Binding var isPresented: Bool
    let homeGroups: [HomeGroup]
    let modelContext: ModelContext
    @Binding var selectedHomeGroupId: String?
    
    @Query private var users: [User]
    @Query private var homeGroupUsers: [HomeGroupUser]
    
    @State private var showingAddHomeGroup = false
    @State private var newHomeGroupName = ""
    @State private var newHomeGroupCurrency = "USD"
    @State private var showingDeleteAlert = false
    @State private var groupsToDelete: [HomeGroup] = []
    
    // Get groups that the current user belongs to
    var userHomeGroups: [HomeGroup] {
        guard let currentUser = users.first else { return [] }
        
        let userGroupRelations = homeGroupUsers.filter { $0.user?.id == currentUser.id }
        let userGroupIds = userGroupRelations.compactMap { $0.homeGroup?.id }
        
        return homeGroups.filter { userGroupIds.contains($0.id) }
    }
    
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
                
                if userHomeGroups.isEmpty {
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
                        ForEach(userHomeGroups, id: \.id) { homeGroup in
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
            
            // Associate the new group with the current user
            if let currentUser = users.first {
                let homeGroupUser = HomeGroupUser(
                    dateJoined: Date(),
                    isAdmin: true // User who creates the group is admin
                )
                homeGroupUser.user = currentUser
                homeGroupUser.homeGroup = newHomeGroup
                modelContext.insert(homeGroupUser)
            }
            
            // If this is the first home group, select it automatically
            if userHomeGroups.isEmpty {
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
        newHomeGroupCurrency = "USD"
    }
    
    private func deleteHomeGroups(_ groups: [HomeGroup]) {
        withAnimation {
            for group in groups {
                modelContext.delete(group)
            }
            
            // If we deleted the selected group, select the first available one
            if groups.contains(where: { $0.id == selectedHomeGroupId }) {
                selectedHomeGroupId = userHomeGroups.first { !groups.contains($0) }?.id
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting home groups: \(error)")
            }
        }
    }
}