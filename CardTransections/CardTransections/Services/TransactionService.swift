//
//  TransactionService.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import Foundation

enum TransactionServiceError: LocalizedError {
    case fileNotFound
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "transaction-list.json was not found in the app bundle."
        case .decodingFailed(let error):
            return "Failed to decode transactions: \(error.localizedDescription)"
        }
    }
}

final class TransactionService: TransactionServiceProtocol {
    
    static let shared = TransactionService()
    private init() {}
    
    /// Loads and decodes all transactions.
    /// Throws `TransactionServiceError` on failure.
    func fetchTransactions() throws -> [Transaction] {
        let data = try loadBundledData()
        return try decode(data)
    }
    
    // MARK: - Private helpers
    
    private func loadBundledData() throws -> Data {
        guard let url = Bundle.main.url(forResource: "transaction-list",
                                        withExtension: "json") else {
            throw TransactionServiceError.fileNotFound
        }
        return try Data(contentsOf: url)
    }
    
    private func decode(_ data: Data) throws -> [Transaction] {
        do {
            let response = try JSONDecoder().decode(TransactionResponse.self, from: data)
            return response.transactions
        } catch {
            throw TransactionServiceError.decodingFailed(error)
        }
    }
}


// MARK: - TransactionServiceProtocol

protocol TransactionServiceProtocol {
    func fetchTransactions() throws -> [Transaction]
}
