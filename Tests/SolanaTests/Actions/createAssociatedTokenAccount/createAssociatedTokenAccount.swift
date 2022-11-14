import XCTest
import Solana

class createAssociatedTokenAccount: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var networkRouterMock: NetworkingRouterMock!
    var solana: Solana!
    var account: Signer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let wallet: TestsWallet = .devnet
        networkRouterMock = NetworkingRouterMock()
        solana = Solana(router: networkRouterMock)
        account = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    override func tearDownWithError() throws {
        networkRouterMock = nil
        solana = nil
        account = nil
        try super.tearDownWithError()
    }

    func testGetOrCreateAssociatedTokenAccount() {
        // arrange
        let tokenMint = PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        networkRouterMock.expectedResults.append(.success(.json(filename:"getAccountInfo")))

        // act
        let account: (transactionId: TransactionID?, associatedTokenAddress: PublicKey)? = try! solana.action.getOrCreateAssociatedTokenAccount(for: account.publicKey, tokenMint: tokenMint, payer: account)?.get()

        // assert
        XCTAssertEqual(networkRouterMock.requestCalled.count, 1)
        XCTAssertNil(account?.transactionId)
        XCTAssertEqual(account?.associatedTokenAddress.base58EncodedString, "2ST2CedQ1QT7f2G31Qws9n7GFj7C56fKnhbxnvLymFwU")
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
