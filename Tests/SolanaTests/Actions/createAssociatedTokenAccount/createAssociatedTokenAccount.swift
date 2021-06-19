import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class createAssociatedTokenAccount: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = Solana.Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.accountStorage.save(account).get()
    }
    
    func testGetOrCreateAssociatedTokenAccount() {
        let tokenMint = Solana.PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        let account = try! solanaSDK.getOrCreateAssociatedTokenAccount(for: solanaSDK.accountStorage.account!.publicKey, tokenMint: tokenMint).toBlocking().first()
        XCTAssertNotNil(account)
    }
    
    func testFailCreateAssociatedTokenAccountItExisted() {
        let tokenMint = Solana.PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        XCTAssertThrowsError(try solanaSDK.createAssociatedTokenAccount(for: solanaSDK.accountStorage.account!.publicKey, tokenMint: tokenMint).toBlocking().first())
    }
    func testFindAssociatedTokenAddress() {
        let associatedTokenAddress = try! Solana.PublicKey.associatedTokenAddress(
            walletAddress: Solana.PublicKey(string: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")!,
            tokenMintAddress: Solana.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")!
        ).get()
        
        XCTAssertEqual(associatedTokenAddress.base58EncodedString, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
    }
}
