//
//  InfoComponents.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI

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