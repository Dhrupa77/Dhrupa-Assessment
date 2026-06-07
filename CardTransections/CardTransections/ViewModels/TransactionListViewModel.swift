//
//  TransactionListViewModel.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import Foundation
import Combine

@MainActor
final class TransactionListViewModel: ObservableObject {

    // MARK: - Published state

    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Dependency

    private let service: TransactionServiceProtocol

    init(service: TransactionServiceProtocol) {
        self.service = service
    }

    // MARK: - Intent

    func loadTransactions() {
        isLoading = true
        errorMessage = nil

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.service.fetchTransactions()
                await MainActor.run {
                    self.transactions = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

