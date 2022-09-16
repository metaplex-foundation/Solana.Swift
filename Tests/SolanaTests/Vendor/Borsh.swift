import Foundation
import Beet
import XCTest
@testable import Solana

fileprivate struct Test {
  let x: UInt32
  let y: UInt32
  let z: String
  let q: [UInt128]
    let r: [SubTest]
}

extension Test: BorshCodable {
  func serialize(to writer: inout Data) throws {
    try x.serialize(to: &writer)
    try y.serialize(to: &writer)
    try z.serialize(to: &writer)
    try q.serialize(to: &writer)
    try r.serialize(to: &writer)
  }

  init(from reader: inout BinaryReader) throws {
    self.x = try .init(from: &reader)
    self.y = try .init(from: &reader)
    self.z = try .init(from: &reader)
    self.q = try .init(from: &reader)
    self.r = try .init(from: &reader)
  }
}

struct SubTest {
    let a: PublicKey
    let b: UInt8
}

extension SubTest: BorshCodable {
    func serialize(to writer: inout Data) throws {
        try a.serialize(to: &writer)
        try b.serialize(to: &writer)
    }

    init(from reader: inout BinaryReader) throws {
        self.a = try .init(from: &reader)
        self.b = try .init(from: &reader)
    }
}

class BorshCodableTests: XCTestCase {
    
    func test_should_deserialize(){
        let value = Test(x: 255, y: 20, z: "123", q: [1, 2, 3], r: [SubTest(a: PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!, b: 31)])
        let buf = try! BorshEncoder().encode(value)
        let new_value = try! BorshDecoder().decode(Test.self, from: buf)
        XCTAssertEqual(new_value.x, 255)
        XCTAssertEqual(new_value.y, 20)
        XCTAssertEqual(new_value.z, "123")
        XCTAssertEqual(new_value.q, [1, 2, 3])
        XCTAssertEqual(new_value.r[0].a, PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!)
        XCTAssertEqual(new_value.r[0].b, 31)
    }
    
    func test_should_deserialize_mint(){
        let buf2 = Data(base64Encoded: "AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==")!
        
        let new_mint = try! BorshDecoder().decode(Mint.self, from: buf2)

        let buf = try! BorshEncoder().encode(new_mint)
        
        XCTAssertEqual(buf2.bytes.count, buf.bytes.count)
        XCTAssertEqual(buf2.bytes, buf.bytes)

                
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", new_mint.mintAuthority!.base58EncodedString)
        XCTAssertEqual(1000000000000, new_mint.supply)
        XCTAssertEqual(new_mint.decimals, 6)
        XCTAssertTrue(new_mint.isInitialized == true)
        XCTAssertEqual(new_mint.freezeAuthority, nil)
    }
    
    func test_should_serialize_publickey() {
        
        let key = PublicKey(data: Data([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))!
        
        XCTAssertEqual("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3", key.base58EncodedString)
        let buf = try! BorshEncoder().encode(key)
        XCTAssertEqual(key.data, buf)
        
        XCTAssertEqual(PublicKey(bytes: buf.bytes)!.base58EncodedString, key.base58EncodedString)
        let key2 = try! BorshDecoder().decode(PublicKey.self, from: buf)
        
        XCTAssertEqual(key2.base58EncodedString, key.base58EncodedString)
    }
    
    func test_should_deserialize_accountInfo(){
        let expectedBuf = Data(base64Encoded: "BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")!
        
        let generateInfo = try! BorshDecoder().decode(AccountInfo.self, from: expectedBuf)
        let generatedBuf = try! BorshEncoder().encode(generateInfo)
        
        let generateInfoDecoded = try! BorshDecoder().decode(AccountInfo.self, from: expectedBuf)

        XCTAssertEqual(expectedBuf.bytes.count, generatedBuf.bytes.count)
        XCTAssertEqual(expectedBuf.bytes, generatedBuf.bytes)

                
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", generateInfo.mint.base58EncodedString)
        XCTAssertEqual("BQWWFhzBdw2vKKBUX17NHeFbCoFQHfRARpdztPE2tDJ", generateInfo.owner.base58EncodedString)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", generateInfo.delegate?.base58EncodedString)
        XCTAssertEqual(100, generateInfo.delegatedAmount)
        XCTAssertEqual(false, generateInfo.isNative)
        XCTAssertEqual(true, generateInfo.isInitialized)
        XCTAssertEqual(false, generateInfo.isFrozen)
        XCTAssertNil(generateInfo.rentExemptReserve)
        XCTAssertNil(generateInfo.closeAuthority)
        
        XCTAssertEqual(generateInfoDecoded.mint.base58EncodedString, generateInfo.mint.base58EncodedString)
        XCTAssertEqual(generateInfoDecoded.owner.base58EncodedString, generateInfo.owner.base58EncodedString)
        XCTAssertEqual(generateInfoDecoded.delegate?.base58EncodedString, generateInfo.delegate?.base58EncodedString)
        XCTAssertEqual(generateInfoDecoded.delegatedAmount, generateInfo.delegatedAmount)
        XCTAssertEqual(generateInfoDecoded.isNative, generateInfo.isNative)
        XCTAssertEqual(generateInfoDecoded.isInitialized, generateInfo.isInitialized)
        XCTAssertEqual(generateInfoDecoded.isFrozen, generateInfo.isFrozen)
        XCTAssertEqual(generateInfoDecoded.rentExemptReserve, generateInfo.rentExemptReserve)
        XCTAssertEqual(generateInfoDecoded.closeAuthority, generateInfo.closeAuthority)
    }
    
    func testDecodingTokenSwap() {
        let string = #"["AQH/Bt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKnPPnmVdf8VefedpPOl3xy2V/o+YvTT+f/dj/1blp9D9lI+9w67aLlO5X6dSFPB7WkhvyP+71AxESXk7Qw9nyYEYH7t0UamkBlPrllRfjnQ9h+sx/GQHoBS4AbWPpi2+m5dBuymmuZeydiI91aVN//6kR8bk4czKnvSXu1WXNW4hwabiFf+q4GE+2h/Y0YYwDXaxDncGus7VZig8AAAAAAB1UBY8wcrypvzuco4dv7UUURt8t9MOpnq7YnffB1OovkZAAAAAAAAABAnAAAAAAAABQAAAAAAAAAQJwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"]"#
        
        let tokenSwapInfo = try! JSONDecoder().decode(Buffer<TokenSwapInfo>.self, from: string.data(using: .utf8)!).value!
        XCTAssertEqual(1, tokenSwapInfo.version)
        XCTAssertEqual("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA", tokenSwapInfo.tokenProgramId.base58EncodedString)
        XCTAssertEqual("7G93KAMR8bLq5TvgLHmpACLXCYwDcdtXVBKsN5Fx41iN", tokenSwapInfo.mintA.base58EncodedString)
        XCTAssertEqual("So11111111111111111111111111111111111111112", tokenSwapInfo.mintB.base58EncodedString)
        XCTAssertEqual(0, tokenSwapInfo.curveType)
        XCTAssertEqual(0, tokenSwapInfo.ownerWithdrawFeeDenominator)
        XCTAssertTrue(tokenSwapInfo.isInitialized == true)
        XCTAssertEqual("11111111111111111111111111111111", tokenSwapInfo.payer.base58EncodedString)
        
        let expectedBuf = Data(base64Encoded: "AQH/Bt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKnPPnmVdf8VefedpPOl3xy2V/o+YvTT+f/dj/1blp9D9lI+9w67aLlO5X6dSFPB7WkhvyP+71AxESXk7Qw9nyYEYH7t0UamkBlPrllRfjnQ9h+sx/GQHoBS4AbWPpi2+m5dBuymmuZeydiI91aVN//6kR8bk4czKnvSXu1WXNW4hwabiFf+q4GE+2h/Y0YYwDXaxDncGus7VZig8AAAAAAB1UBY8wcrypvzuco4dv7UUURt8t9MOpnq7YnffB1OovkZAAAAAAAAABAnAAAAAAAABQAAAAAAAAAQJwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")!
        
        let generatedTokenSwapInfo = try! BorshDecoder().decode(TokenSwapInfo.self, from: expectedBuf)
        let generatedBuf = try! BorshEncoder().encode(generatedTokenSwapInfo)
        
        XCTAssertEqual(expectedBuf.bytes.count, generatedBuf.bytes.count)
        XCTAssertEqual(expectedBuf.bytes, generatedBuf.bytes)
        
        XCTAssertEqual(1, generatedTokenSwapInfo.version)
        XCTAssertEqual("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA", generatedTokenSwapInfo.tokenProgramId.base58EncodedString)
        XCTAssertEqual("7G93KAMR8bLq5TvgLHmpACLXCYwDcdtXVBKsN5Fx41iN", generatedTokenSwapInfo.mintA.base58EncodedString)
        XCTAssertEqual("So11111111111111111111111111111111111111112", generatedTokenSwapInfo.mintB.base58EncodedString)
        XCTAssertEqual(0, generatedTokenSwapInfo.curveType)
        XCTAssertTrue(generatedTokenSwapInfo.isInitialized == true)
        XCTAssertEqual("11111111111111111111111111111111", generatedTokenSwapInfo.payer.base58EncodedString)
        
    }

    func testReaderAndWriter() {
        let value = Test(x: 255, y: 20, z: "123", q: [1, 2, 3], r: [SubTest(a: PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!, b: 31), SubTest(a: PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!, b: 31), SubTest(a: PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!, b: 31)])
        let buf = try! BorshEncoder().encode(value)
        var binaryReader = BinaryReader(bytes: buf.bytes)
        let newBuf = try! Test(from: &binaryReader)

        XCTAssertEqual(newBuf.x, 255)
        XCTAssertEqual(newBuf.y, 20)
        XCTAssertEqual(newBuf.z, "123")
        XCTAssertEqual(newBuf.q, [1, 2, 3])

        var writtenBuf = Data()
        try! newBuf.serialize(to: &writtenBuf)

        var newReader = BinaryReader(bytes: writtenBuf.bytes)
        let newTest = try! Test(from: &newReader)

        XCTAssertEqual(buf.bytes, writtenBuf.bytes)
        XCTAssertEqual(newBuf.x, newTest.x)
        XCTAssertEqual(newBuf.y, newTest.y)
        XCTAssertEqual(newBuf.z, newTest.z)
        XCTAssertEqual(newBuf.q, newTest.q)
    }
}
