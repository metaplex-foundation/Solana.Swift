import XCTest
@testable import Solana

class DecodingTests: XCTestCase {
    
    func testDecodingMint() {
        let string = #"["AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==","base64"]"#
        let mintLayout = try! JSONDecoder().decode(Buffer<Mint>.self, from: string.data(using: .utf8)!).value
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", mintLayout?.mintAuthority?.base58EncodedString)
        XCTAssertEqual(1000000000000, mintLayout?.supply)
        XCTAssertEqual(mintLayout?.decimals, 6)
        XCTAssertTrue(mintLayout?.isInitialized == true)
        XCTAssertNil(mintLayout?.freezeAuthority)
    }
    
    func testDecodingAccountInfo() {
        let string = #"["BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"]"#
        let accountInfo = try! JSONDecoder().decode(Buffer<AccountInfo>.self, from: string.data(using: .utf8)!).value
        
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", accountInfo?.mint.base58EncodedString)
        XCTAssertEqual("BQWWFhzBdw2vKKBUX17NHeFbCoFQHfRARpdztPE2tDJ", accountInfo?.owner.base58EncodedString)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", accountInfo?.delegate?.base58EncodedString)
        XCTAssertEqual(100, accountInfo?.delegatedAmount)
        XCTAssertEqual(false, accountInfo?.isNative)
        XCTAssertEqual(true, accountInfo?.isInitialized)
        XCTAssertEqual(false, accountInfo?.isFrozen)
        XCTAssertNil(accountInfo?.rentExemptReserve)
        XCTAssertNil(accountInfo?.closeAuthority)
    }
    
    func testDecodingAccountInfo2() {
        let string = #"["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq","base64"]"#
        let accountInfo = try! JSONDecoder().decode(Buffer<AccountInfo>.self, from: string.data(using: .utf8)!).value
        
        XCTAssertNil(accountInfo?.delegate)
        XCTAssertEqual(0, accountInfo?.delegatedAmount)
        XCTAssertEqual(false, accountInfo?.isInitialized)
        XCTAssertEqual(false, accountInfo?.isNative)
        XCTAssertNil(accountInfo?.rentExemptReserve)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", accountInfo?.closeAuthority?.base58EncodedString)
        
        let string2 = #"["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq","base64"]"#
        let accountInfo2 = try! JSONDecoder().decode(Buffer<AccountInfo>.self, from: string2.data(using: .utf8)!).value
        
        XCTAssertEqual(true, accountInfo2?.isFrozen)
    }
}
