import Foundation
import XCTest
@testable import Solana

class AssociatedTokenProgramTests: XCTestCase {
    func testFindAssociatedTokenAddress() throws {
        let associatedTokenAddress = try Solana.PublicKey.associatedTokenAddress(
            walletAddress: try Solana.PublicKey(string: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"),
            tokenMintAddress: try Solana.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
        )
        
        XCTAssertEqual(associatedTokenAddress.base58EncodedString, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
    }
}
