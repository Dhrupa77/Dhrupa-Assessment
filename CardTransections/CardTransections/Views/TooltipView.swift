//
//  TooltipView.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import SwiftUI

struct TooltipView: View {
    
    @State private var isExpanded: Bool = false
    
    // MARK: - Copy
    
    private let baseMessage =
    "Transactions are processed Monday to Friday (excluding holidays)."
    
    private let extraMessage =
    " Transactions made before 8:30 pm ET Monday to Friday (excluding holidays) will show up in your account the same day."
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // Megaphone / tip icon
            Image("buddy-tip-icon")
                .font(.system(size: 26))
                .foregroundStyle(Color.brandTeal, Color.brandRed)
                .frame(width: 32, height: 32)
                .padding(.top, 2)
            
            // Inline attributed text + toggle link
            inlineText
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { toggleExpanded() }
    }
    
    // MARK: - Inline attributed text
    
    private var inlineText: Text {
        // Base message (normal weight, primary colour)
        var base = AttributedString(
            baseMessage + (isExpanded ? extraMessage : "") + "  "
        )
        base.font            = .system(size: 14)
        base.foregroundColor = Color.primary
        
        // "Show more" / "Show less" link (bold, blue)
        var toggle = AttributedString(isExpanded ? "Show less" : "Show more")
        toggle.font            = .system(size: 14, weight: .bold)
        toggle.foregroundColor = Color.blue
        
        return Text(base + toggle)
    }
    
    // MARK: - Action
    
    private func toggleExpanded() {
        withAnimation(.easeInOut(duration: 0.22)) {
            isExpanded.toggle()
        }
    }
}

#Preview {
    TooltipView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
