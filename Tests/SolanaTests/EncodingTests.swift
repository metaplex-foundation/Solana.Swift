import XCTest
@testable import Solana

class EncodingTests: XCTestCase {
    func testCodingBytesLength() throws {
        let bytes = Data([5, 3, 1, 2, 3, 7, 8, 5, 4])
        XCTAssertEqual(bytes.decodedLength, 5)
        let bytes2 = Data([74, 174, 189, 206, 113, 78, 60, 226, 136, 170])
        XCTAssertEqual(bytes2.decodedLength, 74)
        
        XCTAssertEqual(Data([0]), Data.encodeLength(0))
        XCTAssertEqual(Data([1]), Data.encodeLength(1))
        XCTAssertEqual(Data([5]), Data.encodeLength(5))
        XCTAssertEqual(Data([0x7f]), Data.encodeLength(127))
        XCTAssertEqual(Data([128, 1]), Data.encodeLength(128))
        XCTAssertEqual(Data([0xff, 0x01]), Data.encodeLength(255))
        XCTAssertEqual(Data([0x80, 0x02]), Data.encodeLength(256))
        XCTAssertEqual(Data([0xff, 0xff, 0x01]), Data.encodeLength(32767))
        XCTAssertEqual(Data([0x80, 0x80, 0x80, 0x01]), Data.encodeLength(2097152))
    }
}
