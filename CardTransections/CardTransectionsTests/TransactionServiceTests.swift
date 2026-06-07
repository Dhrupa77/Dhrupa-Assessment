//
//  TransactionServiceTests.swift
//  CardTransections
//
//  Created by Dhrupa Amin Aka Patel on 2026-06-07.
//

import XCTest
@testable import CardTransections

final class TransactionServiceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Happy path
    
    func test_fetchTransactions_returnsExpectedCount() throws {
        let service = StubTransactionService(json: validJSON(count: 3))
        let result = try service.fetchTransactions()
        XCTAssertEqual(result.count, 3)
    }
    
    func test_fetchTransactions_firstItemParsedCorrectly() throws {
        let service = StubTransactionService(json: validJSON(count: 1))
        let first = try service.fetchTransactions().first!
        XCTAssertEqual(first.merchantName, "Test Merchant 1")
        XCTAssertEqual(first.transactionType, .debit)
        XCTAssertEqual(first.amount.value, 10.00, accuracy: 0.001)
    }
    
    func test_fetchTransactions_emptyArrayReturnsEmpty() throws {
        let service = StubTransactionService(json: #"{"transactions":[]}"#)
        let result = try service.fetchTransactions()
        XCTAssertTrue(result.isEmpty)
    }
    
    // MARK: - Error paths
    
    func test_fetchTransactions_malformedJSONThrowsDecodingError() {
        let service = StubTransactionService(json: "not valid json {{{")
        XCTAssertThrowsError(try service.fetchTransactions()) { error in
            guard case TransactionServiceError.decodingFailed = error else {
                XCTFail("Expected decodingFailed, got \(error)")
                return
            }
        }
    }
    
    func test_fetchTransactions_missingFieldThrowsDecodingError() {
        // 'merchant_name' is required — omitting it should throw
        let service = StubTransactionService(json: """
            {
                "transactions": [{
                    "key": "k1",
                    "transaction_type": "DEBIT",
                    "amount": { "value": 5, "currency": "CAD" },
                    "posted_date": "2021-01-01",
                    "from_account": "Visa",
                    "from_card_number": "1234"
                }]
            }
            """)
        XCTAssertThrowsError(try service.fetchTransactions())
    }
    
    // MARK: - Helpers
    
    private func validJSON(count: Int) -> String {
        let items = (1...count).map { i -> String in
                """
                {
                    "key": "key_\(i)",
                    "transaction_type": "DEBIT",
                    "merchant_name": "Test Merchant \(i)",
                    "amount": { "value": \(Double(i) * 10), "currency": "CAD" },
                    "posted_date": "2021-01-0\(i)",
                    "from_account": "Visa",
                    "from_card_number": "4537350001688012"
                }
                """
        }.joined(separator: ",\n")
        return "{ \"transactions\": [\(items)] }"
    }
}

// MARK: - StubTransactionService
//
// Opens `fetchTransactions()` to a testable surface by accepting
// raw JSON in-memory.

private final class StubTransactionService: TransactionServiceProtocol {
    private let json: String
    
    init(json: String) {
        self.json = json
        // Cannot call super.init() directly (private), so we use the shared
    }
    
    func fetchTransactions() throws -> [Transaction] {
        guard let data = json.data(using: .utf8) else {
            throw TransactionServiceError.decodingFailed(
                NSError(domain: "test", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "UTF-8 encoding failed"])
            )
        }
        do {
            return try JSONDecoder().decode(TransactionResponse.self, from: data).transactions
        } catch {
            throw TransactionServiceError.decodingFailed(error)
        }
    }
}

