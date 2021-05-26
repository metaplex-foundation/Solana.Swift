import XCTest
    @testable import Solana

    struct  SolanaAccount: SolanaAccountStorage {
        func save(_ account: Solana.Account) throws {
            print(account.publicKey.base58EncodedString)
        }

        var account: Solana.Account?

        func clear() {
            print("Clearing")
        }
    }

    final class SolanaTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
        }
    }
