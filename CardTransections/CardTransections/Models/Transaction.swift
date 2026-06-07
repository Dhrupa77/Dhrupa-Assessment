//
//  Transaction.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import Foundation

struct Transaction: Identifiable, Encodable {

    let key: String
    let transactionType: TransactionType
    let merchantName: String
    let description: String?
    let amount: Amount
    let postedDate: String
    let fromAccount: String
    let fromCardNumber: String

    // MARK: - Nested types

    struct Amount: Equatable {
        let value: Double
        let currency: String

        /// e.g. "$200.20"
        var formatted: String {
            String(format: "$%.2f", value)
        }
    }

    enum TransactionType: String {
        case credit = "CREDIT"
        case debit  = "DEBIT"
    }

    // MARK: - Identifiable
    var id: String { key }

    // MARK: - CodingKeys (shared by Encodable synthesis + manual Decodable)
    enum CodingKeys: String, CodingKey {
        case key
        case transactionType  = "transaction_type"
        case merchantName     = "merchant_name"
        case description
        case amount
        case postedDate       = "posted_date"
        case fromAccount      = "from_account"
        case fromCardNumber   = "from_card_number"
    }

    // MARK: - Computed helpers

    var isCredit: Bool { transactionType == .credit }

    /// Last 4 digits of the card number, e.g. "5432"
    var lastFourDigits: String {
        String(fromCardNumber.suffix(4))
    }

    /// Amount formatted as "$200.20"
    var formattedAmount: String { amount.formatted }

    /// "2021-05-31" → "May 31, 2021"
    /// Uses local DateFormatter instances — avoids non-Sendable
    /// static storage that would trigger @MainActor inference for unit test.
    var formattedDate: String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        input.locale = Locale(identifier: "en_US_POSIX")
        guard let date = input.date(from: postedDate) else { return postedDate }
        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .none
        return output.string(from: date)
    }
}

// MARK: - Manual Decodable conformance

///to clean warrnings with default as they are nonsendable and was giving warnning  created manual.

extension Transaction: Decodable {

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        key             = try c.decode(String.self,           forKey: .key)
        transactionType = try c.decode(TransactionType.self,  forKey: .transactionType)
        merchantName    = try c.decode(String.self,           forKey: .merchantName)
        description     = try c.decodeIfPresent(String.self,  forKey: .description)
        amount          = try c.decode(Amount.self,           forKey: .amount)
        postedDate      = try c.decode(String.self,           forKey: .postedDate)
        fromAccount     = try c.decode(String.self,           forKey: .fromAccount)
        fromCardNumber  = try c.decode(String.self,           forKey: .fromCardNumber)
    }
}

// MARK: - Amount Codable (manual — same reason as Transaction)

extension Transaction.Amount: Decodable {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        value    = try c.decode(Double.self, forKey: .value)
        currency = try c.decode(String.self, forKey: .currency)
    }

    private enum CodingKeys: String, CodingKey {
        case value, currency
    }
}

extension Transaction.Amount: Encodable {
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(value,    forKey: .value)
        try c.encode(currency, forKey: .currency)
    }
}

// MARK: - TransactionType Codable (manual)

extension Transaction.TransactionType: Codable {}

// MARK: - TransactionResponse

struct TransactionResponse: Decodable {
    let transactions: [Transaction]
}
