//
//  TransactionRowView.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import SwiftUI

struct TransactionRowView: View {
    
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {

            // ── Type indicator dot ───────────────────────────────────────
            Circle()
                .fill(transaction.isCredit ? Color.brandTeal : Color.brandRed)
                .frame(width: 10, height: 10)

            // ── Text content ─────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.merchantName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if let description = transaction.description {
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text(transaction.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.tertiaryLabel))
            }

            Spacer()

            // ── Amount ───────────────────────────────────────────────────
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.formattedAmount)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.isCredit ? Color.brandTeal : .primary)

                Text(transaction.amount.currency)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

//#Preview {
//    TransactionRowView(transaction: <#Transaction#>)
//}
