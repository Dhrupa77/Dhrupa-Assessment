//
//  TransactionDetailView.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import SwiftUI

struct TransactionDetailView: View {
    
    let transaction: Transaction

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // Content card + close button
            VStack(spacing: 0) {
                mainCard
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                Spacer()
                
                closeButton
            }
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        // Custom nav-bar "×" for accessibility;
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .foregroundColor(.primary)
            }
        }
    }

    // MARK: - Main card

    private var mainCard: some View {
        VStack(spacing: 0) {

            // Status icon + title
            VStack(spacing: 14) {
                statusCircle
                    .padding(.top, 32)

                Text(isCredit ? "Credit transaction" : "Debit transaction")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 28)

            // From row
            Divider()
                .padding(.horizontal, 24)

            detailRow(label: "From") {
                HStack(spacing: 0) {
                    Text(transaction.fromAccount)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                    Text(" (\(transaction.lastFourDigits))")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }
            }

            // Amount row
            Divider()
                .padding(.horizontal, 24)

            detailRow(label: "Amount") {
                Text(transaction.formattedAmount)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
            }

            // Tooltip
            TooltipView()
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Status circle  (outline style, matching screenshot)

//    private var statusCircle: some View {
//        ZStack {
//            Image("success-icon")
//                .font(.system(size: 22, weight: .medium))
//                .foregroundColor(statusColor)
//        }
//    }
    
    private var statusCircle: some View {
           ZStack {
               Circle()
                   .stroke(statusColor, lineWidth: 2)
                   .frame(width: 58, height: 58)

               Image(systemName: "checkmark")
                   .font(.system(size: 22, weight: .medium))
                   .foregroundColor(statusColor)
           }
       }

    // MARK: - Generic detail row

    @ViewBuilder
    private func detailRow<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }

    // MARK: - Close button

    private var closeButton: some View {
        Button { dismiss() } label: {
            Text("Close")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.brandRed)
                .cornerRadius(14)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 36)
        .padding(.top, 12)
    }

    // MARK: - Helpers

    private var isCredit: Bool { transaction.isCredit }
    private var statusColor: Color { isCredit ? Color.brandTeal : Color.brandRed }
}

// MARK: - Preview
#Preview("Credit") {
    NavigationStack {
        TransactionDetailView(
            transaction: Transaction(
                key: "preview_credit",
                transactionType: .credit,
                merchantName: "Payment-thank You Scotiabank",
                description: "Payment (Scotiabank)",
                amount: .init(value: 5.00, currency: "CAD"),
                postedDate: "2021-03-30",
                fromAccount: "Momentum Regular Visa",
                fromCardNumber: "4537350001688004"
            )
        )
    }
}

#Preview("Debit") {
    NavigationStack {
        TransactionDetailView(
            transaction: Transaction(
                key: "preview_debit",
                transactionType: .debit,
                merchantName: "Mb - Cash Advance To - 1785",
                description: "Bill payment",
                amount: .init(value: 200.20, currency: "CAD"),
                postedDate: "2021-05-31",
                fromAccount: "Momentum Regular Visa",
                fromCardNumber: "4537350001688012"
            )
        )
    }
}
