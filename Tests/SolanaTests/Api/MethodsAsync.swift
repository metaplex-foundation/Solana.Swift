import XCTest
@testable import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class MethodsAsync: XCTestCase {
    let endpoint = RPCEndpoint(
        url: URL(string: ProcessInfo.processInfo.environment["DEVNET_VALIDATOR_URL"] ?? "") ??  URL(string: "https://api.devnet.solana.com")!,
        urlWebSocket: URL(string: ProcessInfo.processInfo.environment["DEVNET_VALIDATOR_WSS"] ?? "") ?? URL(string: "wss://api.devnet.solana.com")!,
        network: .devnet
    )
    var solana: Solana!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }

    func testGetAccountInfo() async throws {
        let info: BufferInfo<AccountInfo> = try await solana.api.getAccountInfo(account: "So11111111111111111111111111111111111111112", decodedTo: AccountInfo.self)
        XCTAssertNotNil(info.data)
        XCTAssertTrue(info.lamports > 0)
    }
    
    func testGetMultipleAccounts() async throws {
        let accounts: [BufferInfo<AccountInfo>?] = try await solana.api.getMultipleAccounts(pubkeys: ["skynetDj29GH6o6bAqoixCpDuYtWqi1rm8ZNx1hB3vq","namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX"], decodedTo: AccountInfo.self)
        XCTAssertTrue(accounts.count == 2)
        XCTAssertNotNil(accounts[0]?.data)
    }
    func testGetProgramAccounts() async throws {
        _ = try await solana.api.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: TokenSwapInfo.self)
    }
    func testGetBlockCommitment() async throws {
        let block = try await solana.api.getBlockCommitment(block: 82493733)

        XCTAssertTrue(block.totalStake > 0)
    }
  
    func testGetBalance() async throws {
        let value = try await solana.api.getBalance(account: signer.publicKey.base58EncodedString)
        XCTAssertTrue(value > 0)
    }
    func testGetClusterNodes() async throws {
        let nodes = try await solana.api.getClusterNodes()
        XCTAssertTrue(nodes.count > 0);
    }
    func testGetBlockTime() async throws {
        try await testGetRecentBlockhash()
        let slot = try! solana.api.getSlot()!.get()
        _ = try await solana.api.getBlockTime(block: slot)
    }
    // func testGetConfirmedBlock() async throws {
    //     let block = try await solana.api.getConfirmedBlock(slot: 63426807)
    //     XCTAssertEqual(63426806, block.parentSlot);
    // }
    func testGetConfirmedBlocks() async throws {
        let slot = try! solana.api.getSlot()!.get()
        let blocks = try await solana.api.getConfirmedBlocks(startSlot:slot-10, endSlot: slot-5)
        XCTAssert(blocks.count > 0)
    }
    func testGetConfirmedBlocksWithLimit() async throws {
        let blocks = try await solana.api.getConfirmedBlocksWithLimit(startSlot:109479071, limit: 10)
        XCTAssertEqual(blocks.count, 10);
    }
    func testGetConfirmedSignaturesForAddress2() async throws {
        let result = try await solana.api.getConfirmedSignaturesForAddress2(account: "Vote111111111111111111111111111111111111111", configs: RequestConfiguration(limit: 4))
        XCTAssertEqual(result.count, 4)
    }
    func testGetConfirmedTransaction() async throws {
        let transaction = try await solana.api.getConfirmedTransaction(transactionSignature: "3nRsxY29xgo4G9zb71VkZDJFvsZAJZWeXVLGfgNFwZ4Bbudv3DXy4Yw1WdJLJLf4MDNNHm78nQxCUdv9nhCFcLov")
        XCTAssertEqual(transaction.blockTime, 1675377453)
    }
    func testGetEpochInfo() async throws {
        _ = try await solana.api.getEpochInfo()
    }
    func testGetEpochSchedule() async throws {
        _ = try await solana.api.getEpochSchedule()
    }
    func testGetFeeCalculatorForBlockhash() async throws {
        let hash = try await solana.api.getRecentBlockhash()
        let fee = try await solana.api.getFeeCalculatorForBlockhash(blockhash: hash)
        XCTAssertTrue(fee.feeCalculator!.lamportsPerSignature > 0)
    }
    func testGetFeeRateGovernor() async throws {
        let feeRateGovernorInfo = try await solana.api.getFeeRateGovernor()
        
        XCTAssertTrue(feeRateGovernorInfo.feeRateGovernor!.burnPercent > 0)
        XCTAssertTrue(feeRateGovernorInfo.feeRateGovernor!.maxLamportsPerSignature > 0)
        XCTAssertTrue(feeRateGovernorInfo.feeRateGovernor!.minLamportsPerSignature > 0)
        XCTAssertTrue(feeRateGovernorInfo.feeRateGovernor!.targetLamportsPerSignature >= 0)
        XCTAssertTrue(feeRateGovernorInfo.feeRateGovernor!.targetSignaturesPerSlot >= 0)
    }
    func testGetFees() async throws {
        let feesInfo = try await solana.api.getFees()
        XCTAssertNotEqual("", feesInfo.blockhash)
        XCTAssertTrue(feesInfo.feeCalculator!.lamportsPerSignature > 0)
        XCTAssertTrue(feesInfo.lastValidSlot! > 0)
    }
    func testGetFirstAvailableBlock() async throws {
        let block = try await solana.api.getFirstAvailableBlock()
        XCTAssertTrue(0 <= block)
    }
    func testGetGenesisHash() async throws {
        _ = try await solana.api.getGenesisHash()
        XCTAssertNotNil(hash)
    }
    func testGetIdentity() async throws {
        _ = try await solana.api.getIdentity()
    }
    func testGetVersion() async throws {
        _ = try await solana.api.getVersion()
    }
    /*func testRequestAirdrop() {
        let airdrop = try! solana.api.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 10000000000)?.get()
        XCTAssertNotNil(airdrop)
    }*/
    func testGetInflationGovernor() async throws {
        _ = try await solana.api.getInflationGovernor()
    }
    func testGetInflationRate() async throws {
        _ = try await solana.api.getInflationRate()
    }
    // This tests is very expensive on time
    /*func testGetLargestAccounts() async throws {
        _ = try await solana.api.getLargestAccounts()
    }*/
    // This tests is very expensive on time
    /*func testGetLeaderSchedule() {
        let accounts = try! solana.api.getLeaderSchedule()?.get()
        XCTAssertNotNil(accounts ?? nil)
    }*/
    func testGetMinimumBalanceForRentExemption() async throws {
        _ = try await solana.api.getMinimumBalanceForRentExemption(dataLength: 32000)
    }
    func testGetRecentPerformanceSamples() async throws {
        _ = try await solana.api.getRecentPerformanceSamples(limit: 5)
    }
    func testGetVoteAccounts() async throws {
        _ = try await solana.api.getVoteAccounts()
    }
    func testGetRecentBlockhash() async throws {
        _ = try await solana.api.getRecentBlockhash()
    }
    func testMinimumLedgerSlot() async throws {
        _ = try await solana.api.minimumLedgerSlot()
    }
    func testGetSlot() async throws {
        _ = try await solana.api.getSlot()
    }
    func testGetSlotLeader() async throws {
        _ = try await solana.api.getSlotLeader()
    }
    func testGetTransactionCount() async throws {
        _ = try await solana.api.getTransactionCount()
    }
    /*func testGetStakeActivation() async throws {
        // https://explorer.solana.com/address/AUi8iPbT4sDpd3Bi6Jj7TL5LBEiXEEm2137bSkpL6Z9G
        let mainNetSolana = Solana(router: NetworkingRouter(endpoint: .mainnetBetaSolana))
        let stakeActivation = try await mainNetSolana.api.getStakeActivation(stakeAccount: "AUi8iPbT4sDpd3Bi6Jj7TL5LBEiXEEm2137bSkpL6Z9G")
        XCTAssertEqual("active", stakeActivation.state)
        XCTAssertTrue(stakeActivation.active > 0)
        XCTAssertEqual(0, stakeActivation.inactive)
    }*/
    func testGetSignatureStatuses() async throws {
        _ = try await solana.api.getSignatureStatuses(pubkeys: ["3nVfYabxKv9ohGb4nXF3EyJQnbVcGVQAm2QKzdPrsemrP4D8UEZEzK8bCWgyTFif6mjo99akvHcCbxiEKzN5L9ZG"])

    }
    
    /* Tokens */
    func testGetTokenAccountBalance() async throws {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let balance = try await solana.api.getTokenAccountBalance(pubkey: tokenAddress)
        XCTAssertNotNil(balance.uiAmount)
        XCTAssertNotNil(balance.amount)
        XCTAssertNotNil(balance.decimals)
    }

    // Doesnt work on Devnet Solana
    /*func testGetTokenAccountsByDelegate() async throws {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let tokenAccount = try await solana.api.getTokenAccountsByDelegate(pubkey: address, programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        XCTAssertTrue(tokenAccount.isEmpty);
    }*/
    
    func testGetTokenAccountsByOwner() async throws {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let accounts: [TokenAccount<AccountInfo>] = try await solana.api.getTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")
        XCTAssertTrue(accounts.isEmpty)
    }
    func testGetTokenSupply() async throws {
        let tokenSupply = try await solana.api.getTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")
        XCTAssertNotNil(tokenSupply)
        XCTAssertEqual(6, tokenSupply.decimals)
        XCTAssertTrue(tokenSupply.uiAmount > 0)
    }
    func testGetTokenLargestAccounts() async throws {
        let accounts = try await solana.api.getTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")
        XCTAssertNotNil(accounts[0])
    }
}
