//
//  TransactionModelTests.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import XCTest
@testable import CardTransections

@MainActor
final class TransactionModelTests: XCTestCase {
    
    // MARK: - Decoding

    func test_decodeFullTransaction() throws {
        let json = fullTransactionJSON()
        let txn = try decode(json)

        XCTAssertEqual(txn.key, "test_key_001")
        XCTAssertEqual(txn.transactionType, .debit)
        XCTAssertEqual(txn.merchantName, "Test Merchant")
        XCTAssertEqual(txn.description, "Bill payment")
        XCTAssertEqual(txn.amount.value, 200.20, accuracy: 0.001)
        XCTAssertEqual(txn.amount.currency, "CAD")
        XCTAssertEqual(txn.postedDate, "2021-05-31")
        XCTAssertEqual(txn.fromAccount, "Momentum Regular Visa")
        XCTAssertEqual(txn.fromCardNumber, "4537350001688012")
    }

    func test_decodeTransactionWithNilDescription() throws {
        let json = """
        {
            "key": "k2",
            "transaction_type": "CREDIT",
            "merchant_name": "Scotiabank",
            "amount": { "value": 5.0, "currency": "CAD" },
            "posted_date": "2021-03-30",
            "from_account": "Passport Visa Infinite",
            "from_card_number": "4537350001688012"
        }
        """
        let txn = try decode(json)
        XCTAssertNil(txn.description)
    }

    func test_decodeCreditTransactionType() throws {
        let json = fullTransactionJSON(type: "CREDIT")
        let txn = try decode(json)
        XCTAssertEqual(txn.transactionType, .credit)
    }

    func test_decodeDebitTransactionType() throws {
        let json = fullTransactionJSON(type: "DEBIT")
        let txn = try decode(json)
        XCTAssertEqual(txn.transactionType, .debit)
    }

    func test_decodeInvalidTypeThrows() {
        let json = fullTransactionJSON(type: "UNKNOWN")
        XCTAssertThrowsError(try decode(json))
    }

    // MARK: - isCredit

    func test_isCreditTrue_forCreditType() throws {
        let txn = try decode(fullTransactionJSON(type: "CREDIT"))
        XCTAssertTrue(txn.isCredit)
    }

    func test_isCreditFalse_forDebitType() throws {
        let txn = try decode(fullTransactionJSON(type: "DEBIT"))
        XCTAssertFalse(txn.isCredit)
    }

    // MARK: - lastFourDigits

    func test_lastFourDigits_standard() throws {
        let txn = try decode(fullTransactionJSON(cardNumber: "4537350001688012"))
        XCTAssertEqual(txn.lastFourDigits, "8012")
    }

    func test_lastFourDigits_shortCardNumber() throws {
        let txn = try decode(fullTransactionJSON(cardNumber: "4537350001688"))
        XCTAssertEqual(txn.lastFourDigits, "1688")
    }

    func test_lastFourDigits_exactlyFourChars() throws {
        let txn = try decode(fullTransactionJSON(cardNumber: "1234"))
        XCTAssertEqual(txn.lastFourDigits, "1234")
    }

    // MARK: - formattedAmount

    func test_formattedAmount_twoDecimalPlaces() throws {
        let txn = try decode(fullTransactionJSON(amount: 200.20))
        XCTAssertEqual(txn.formattedAmount, "$200.20")
    }

    func test_formattedAmount_wholeNumber() throws {
        let txn = try decode(fullTransactionJSON(amount: 5.0))
        XCTAssertEqual(txn.formattedAmount, "$5.00")
    }

    func test_formattedAmount_largeValue() throws {
        let txn = try decode(fullTransactionJSON(amount: 2961.91))
        XCTAssertEqual(txn.formattedAmount, "$2961.91")
    }

    // MARK: - formattedDate

    func test_formattedDate_validDate() throws {
        let txn = try decode(fullTransactionJSON())
        // "2021-05-31" → "May 31, 2021"
        XCTAssertTrue(txn.formattedDate.contains("2021"))
        XCTAssertTrue(txn.formattedDate.contains("31"))
    }

    func test_formattedDate_invalidDateFallsBackToRaw() throws {
        let txn = try decode(fullTransactionJSON(date: "not-a-date"))
        XCTAssertEqual(txn.formattedDate, "not-a-date")
    }

    // MARK: - Identifiable

    func test_id_equalsKey() throws {
        let txn = try decode(fullTransactionJSON())
        XCTAssertEqual(txn.id, txn.key)
    }

    // MARK: - Amount.formatted

    func test_amountFormatted() {
        let amount = Transaction.Amount(value: 42.50, currency: "CAD")
        XCTAssertEqual(amount.formatted, "$42.50")
    }

    // MARK: - Helpers

    private func decode(_ json: String) throws -> Transaction {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Transaction.self, from: data)
    }

    private func fullTransactionJSON(
        type: String = "DEBIT",
        amount: Double = 200.20,
        cardNumber: String = "4537350001688012",
        date: String = "2021-05-31"
    ) -> String {
        """
        {
            "key": "test_key_001",
            "transaction_type": "\(type)",
            "merchant_name": "Test Merchant",
            "description": "Bill payment",
            "amount": { "value": \(amount), "currency": "CAD" },
            "posted_date": "\(date)",
            "from_account": "Momentum Regular Visa",
            "from_card_number": "\(cardNumber)"
        }
        """
    }
}
