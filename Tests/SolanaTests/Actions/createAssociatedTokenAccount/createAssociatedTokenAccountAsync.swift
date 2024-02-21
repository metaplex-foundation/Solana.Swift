import XCTest
import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class createAssociatedTokenAccountAsync: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var networkRouterMock: NetworkingRouterMock!
    var solana: SolanaCore!
    var signer: Signer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let wallet: TestsWallet = .devnet
        solana = SolanaCore(router: NetworkingRouter(endpoint: .devnetSolana))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testGetOrCreateAssociatedTokenAccount() async throws {
        let tokenMint = PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        let account: (transactionId: TransactionID?, associatedTokenAddress: PublicKey)? = try await solana.action.getOrCreateAssociatedTokenAccount(owner: signer.publicKey, tokenMint: tokenMint, payer: signer)
        XCTAssertNotNil(account)
    }
    
    func testFailCreateAssociatedTokenAccountItExisted() async throws {
        let tokenMint = PublicKey(string: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!
        await asyncAssertThrowing("Should fail to create associated token account if existed") {
            try await (solana.action.createAssociatedTokenAccount(for: signer.publicKey, tokenMint: tokenMint, payer: signer) as TransactionID?)
        }

    }

    func testFindAssociatedTokenAddress() {
        let associatedTokenAddress = try! PublicKey.associatedTokenAddress(
            walletAddress: PublicKey(string: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")!,
            tokenMintAddress: PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")!
        ).get()

        XCTAssertEqual(associatedTokenAddress.base58EncodedString, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
    }
}
