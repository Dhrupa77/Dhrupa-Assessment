//
//  TransactionListView.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import SwiftUI

// MARK: - TransactionListView

struct TransactionListView: View {

    @StateObject private var viewModel = TransactionListViewModel(service: TransactionService.shared)

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView

                } else if let error = viewModel.errorMessage {
                    errorView(message: error)

                } else {
                    listView
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
        }
        .task { viewModel.loadTransactions() }
    }

    // MARK: - Subviews

    private var listView: some View {
        List(viewModel.transactions) { transaction in
            
            NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                TransactionRowView(transaction: transaction)
            }
            // Remove NavigationLink's default chevron tint
            .listRowBackground(Color(.systemBackground))
        }
        .listStyle(.insetGrouped)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Loading transactions…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 52))
                .foregroundColor(Color.brandRed)

            Text("Couldn't load transactions")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Try Again") { viewModel.loadTransactions() }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandRed)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
