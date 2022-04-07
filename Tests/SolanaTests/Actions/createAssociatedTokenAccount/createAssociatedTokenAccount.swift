import XCTest
import Solana

class createAssociatedTokenAccount: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
    }
    
    func testGetOrCreateAssociatedTokenAccount() {
        let tokenMint = PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        let account: (transactionId: TransactionID?, associatedTokenAddress: PublicKey)? = try! solana.action.getOrCreateAssociatedTokenAccount(for: account.publicKey, tokenMint: tokenMint, payer: account)?.get()
        XCTAssertNotNil(account)
    }
    
    func testFailCreateAssociatedTokenAccountItExisted() {
        let tokenMint = PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        XCTAssertThrowsError(try (solana.action.createAssociatedTokenAccount(for: account.publicKey, tokenMint: tokenMint, payer: account)?.get() as TransactionID?))
    }

    func testFindAssociatedTokenAddress() {
        let associatedTokenAddress = try! PublicKey.associatedTokenAddress(
            walletAddress: PublicKey(string: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")!,
            tokenMintAddress: PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")!
        ).get()
        
        XCTAssertEqual(associatedTokenAddress.base58EncodedString, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
    }
}
