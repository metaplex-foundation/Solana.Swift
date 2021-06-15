import XCTest
@testable import Solana
import CryptoSwift

class TransactionTests: XCTestCase {
    func testCreatingTransfer() throws {
        let compiled = [UInt8]([2, 2, 0, 1, 12, 2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0])
        var receiver = [UInt8]()
        let data = Solana.Transfer.compile()
        receiver.append(contentsOf: data)
        XCTAssertEqual(compiled, receiver)
    }
}
