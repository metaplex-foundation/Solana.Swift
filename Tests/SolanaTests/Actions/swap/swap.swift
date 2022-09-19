import XCTest
@testable import Solana

class swap: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account!
    let publicKey = PublicKey(string: "11111111111111111111111111111111")!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        account = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
    }

    /*func testSwapToken() {
        let USDCWallet = "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8"
        let USDTWallet = "EJwZgeZrdC8TXTQbQBoL6bfuAnFUUy1PVCMB4DYPzVaS"

        let USDCMintAddress = "2ST2CedQ1QT7f2G31Qws9n7GFj7C56fKnhbxnvLymFwU"
        let USDTMintAddress = "E9ySnfyR467236FjUQKswrXq1qmHmS7WyjbiWo7Fnmgo"
        
        let source = try Solana.PublicKey(string: USDCWallet)
        let sourceMint = try Solana.PublicKey(string: USDCMintAddress)
        let destination = try Solana.PublicKey(string: USDTWallet)
        let destinationMint = try Solana.PublicKey(string: USDTMintAddress)

        _ = try solanaSDK.swap(
            source: source,
            sourceMint: sourceMint,
            destination: destination,
            destinationMint: destinationMint,
            slippage: 0.5,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first()
    }*/
    
    func testSwapInstruction() {
        let instruction = TokenSwapProgram.swapInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            userTransferAuthority: publicKey,
            userSource: publicKey,
            poolSource: publicKey,
            poolDestination: publicKey,
            userDestination: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            hostFeeAccount: publicKey,
            swapProgramId: publicKey,
            tokenProgramId: publicKey,
            amountIn: 100000,
            minimumAmountOut: 0
        )
        
        XCTAssertEqual(Base58.decode("tSBHVn49GSCW4DNB1EYv9M"), instruction.data)
    }
    
    func testDepositInstruction() {
        let instruction = TokenSwapProgram.depositInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            sourceA: publicKey,
            sourceB: publicKey,
            intoA: publicKey,
            intoB: publicKey,
            poolToken: publicKey,
            poolAccount: publicKey,
            tokenProgramId: publicKey,
            swapProgramId: publicKey,
            poolTokenAmount: 507788,
            maximumTokenA: 51,
            maximumTokenB: 1038
        )
        
        XCTAssertEqual(Base58.decode("22WQQtPPUknk68tx2dUGRL1Q4Vj2mkg6Hd"), instruction.data)
    }
    
    func testWithdrawInstruction() {
        let instruction = TokenSwapProgram.withdrawInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            sourcePoolAccount: publicKey,
            fromA: publicKey,
            fromB: publicKey,
            userAccountA: publicKey,
            userAccountB: publicKey,
            swapProgramId: publicKey,
            tokenProgramId: publicKey,
            poolTokenAmount: 498409,
            minimumTokenA: 49,
            minimumTokenB: 979
        )
        
        XCTAssertEqual(Base58.decode("2aJyv2ixHWcYWoAKJkYMzSPwTrGUfnSR9R"), instruction.data)
    }
}
