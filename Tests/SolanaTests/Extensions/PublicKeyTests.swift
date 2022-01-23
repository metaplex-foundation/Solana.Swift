import XCTest
@testable import Solana

class PublicKeyTest: XCTestCase {
    func testAssociatedAddress() {
        let associatedAddress = try! PublicKey.associatedTokenAddress(walletAddress: PublicKey(string: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx")!, tokenMintAddress: PublicKey(string: "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH")!).get()
        XCTAssertEqual(associatedAddress.base58EncodedString, "4PsGEFn43xc7ztymrt77XfUE4FespyNm6KuYYmsstz5L")
    }
}
