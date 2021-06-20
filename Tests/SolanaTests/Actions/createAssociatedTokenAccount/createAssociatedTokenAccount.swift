import XCTest
import RxSwift
import RxBlocking
@testable import RxSolana
import Solana

class createAssociatedTokenAccount: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account { try! solana.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solana.auth.save(account).get()
    }
    
    func testGetOrCreateAssociatedTokenAccount() {
        let tokenMint = PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        let account = try! solana.api.getOrCreateAssociatedTokenAccount(for: solana.auth.account.get().publicKey, tokenMint: tokenMint).toBlocking().first()
        XCTAssertNotNil(account)
    }
    
    func testFailCreateAssociatedTokenAccountItExisted() {
        let tokenMint = PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        XCTAssertThrowsError(try solana.api.createAssociatedTokenAccount(for: solana.auth.account.get().publicKey, tokenMint: tokenMint).toBlocking().first())
    }
    func testFindAssociatedTokenAddress() {
        let associatedTokenAddress = try! PublicKey.associatedTokenAddress(
            walletAddress: PublicKey(string: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")!,
            tokenMintAddress: PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")!
        ).get()
        
        XCTAssertEqual(associatedTokenAddress.base58EncodedString, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
    }
}
