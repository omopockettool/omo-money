//
//  AppInfoSheet.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI

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
                            Text("1.4.1")
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