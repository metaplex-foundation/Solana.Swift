@testable import Solana
import XCTest

class Methods: XCTestCase {
    let endpoint = RPCEndpoint(
        url: URL(string: ProcessInfo.processInfo.environment["DEVNET_VALIDATOR_URL"] ?? "") ??  URL(string: "https://api.devnet.solana.com")!,
        urlWebSocket: URL(string: ProcessInfo.processInfo.environment["DEVNET_VALIDATOR_WSS"] ?? "") ?? URL(string: "wss://api.devnet.solana.com")!,
        network: .devnet
    )
    var solana: SolanaCore!
    var account: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = SolanaCore(router: NetworkingRouter(endpoint: endpoint))
        account = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }

    func testGetPureAccountInfo() {
        let info: BufferInfoPureData? = try! solana.api.getAccountInfo(account: "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF")?.get()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
        XCTAssertTrue(info!.lamports > 0)
    }
    
    func testGetAccountInfo() {
        let info: BufferInfo<AccountInfo>? = try! solana.api.getAccountInfo(account: "So11111111111111111111111111111111111111112", decodedTo: AccountInfo.self)?.get()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
        XCTAssertTrue(info!.lamports > 0)
    }

    func testGetAccountInfoForSolTransfer() {
        //zero balance account
        let info: BufferInfo<AccountInfo>? = try! solana.api.getAccountInfoForSolTransfer(account: "JCsD7AYV1pfsr7MUvBZXQRC7dec2XVamr4RCAjzSRQPp", decodedTo: AccountInfo.self, allowUnfundedRecipient: true)?.get()
        XCTAssertNil(info?.data.value)
    }

    func testGetMultipleAccounts() {
        let accounts: [BufferInfo<AccountInfo>?] = try! solana.api.getMultipleAccounts(pubkeys: ["skynetDj29GH6o6bAqoixCpDuYtWqi1rm8ZNx1hB3vq", "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX"], decodedTo: AccountInfo.self)!.get()
        XCTAssertNotNil(accounts)
        XCTAssertTrue(accounts.count == 2)
        XCTAssertNotNil(accounts[0]?.data)
    }

    func testGetProgramAccounts() {
        let info = try! solana.api.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: TokenSwapInfo.self)?.get()
        XCTAssertNotNil(info)
    }

    func testGetBlockCommitment() {
        let block = try! solana.api.getBlockCommitment(block: 82493733)?.get()
        XCTAssertNotNil(block)
        XCTAssertTrue(block!.totalStake > 0)
    }

    func testGetBalance() {
        let value = try! solana.api.getBalance(account: account.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(value)
        XCTAssertTrue(value! > 0)
    }

    func testGetClusterNodes() {
        let nodes = try! solana.api.getClusterNodes()?.get()
        XCTAssertNotNil(nodes)
        XCTAssertTrue(nodes!.count > 0)
    }

    func testGetBlockTime() {
        let slot = try! solana.api.getSlot()?.get()
        let date = try! solana.api.getBlockTime(block: slot!)?.get()
        XCTAssertNotNil(date!)
    }

    /* func testGetConfirmedBlock() {
         let block = try! solana.api.getConfirmedBlock(slot: 109479081)?.get()
         XCTAssertNotNil(block)
         XCTAssertEqual(109479081, block!.parentSlot);
     } */
    func testGetConfirmedBlocks() {
        let slot = try! solana.api.getSlot()?.get()
        let blocks = try! solana.api.getConfirmedBlocks(startSlot: slot! - 10, endSlot: slot!)?.get()
        XCTAssertNotNil(blocks)
        XCTAssert(blocks!.count > 1)
    }

    func testGetConfirmedBlocksWithLimit() {
        let slot = try! solana.api.getSlot()?.get()
        let blocks = try! solana.api.getConfirmedBlocksWithLimit(startSlot: slot!, limit: 10)?.get()
        XCTAssertNotNil(blocks)
        XCTAssertEqual(blocks!.count > 0, true)
    }

    func testGetConfirmedSignaturesForAddress2() {
        let result = try! solana.api.getConfirmedSignaturesForAddress2(account: "Vote111111111111111111111111111111111111111", configs: RequestConfiguration(limit: 4))?.get()
        XCTAssertEqual(result?.count, 4)
    }

    func testGetConfirmedTransaction() {
        let result = try! solana.api.getConfirmedSignaturesForAddress2(account: "Vote111111111111111111111111111111111111111", configs: RequestConfiguration(limit: 4))?.get()
        let transaction = try! solana.api.getConfirmedTransaction(transactionSignature: (result?.first!.signature)!)?.get()
        XCTAssertNotNil(transaction)
        XCTAssertEqual(result?.first!.slot!, transaction!.slot)
    }

    func testGetEpochInfo() {
        let epoch = try! solana.api.getEpochInfo()?.get()
        XCTAssertNotNil(epoch)
    }

    func testGetEpochSheadule() {
        let epoch = try! solana.api.getEpochSchedule()?.get()
        XCTAssertNotNil(epoch)
    }

    func testGetFeeCalculatorForBlockhash() {
        let hash = try! solana.api.getRecentBlockhash()?.get()
        let fee = try! solana.api.getFeeCalculatorForBlockhash(blockhash: hash!)?.get()
        XCTAssertNotNil(fee)
        XCTAssertTrue(fee!.feeCalculator!.lamportsPerSignature > 0)
    }

    func testGetFeeRateGovernor() {
        let feeRateGovernorInfo = try! solana.api.getFeeRateGovernor()?.get()
        XCTAssertNotNil(feeRateGovernorInfo)

        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.burnPercent > 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.maxLamportsPerSignature > 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.minLamportsPerSignature > 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.targetLamportsPerSignature >= 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.targetSignaturesPerSlot >= 0)
    }

    func testGetFees() {
        let feesInfo = try! solana.api.getFees()?.get()
        XCTAssertNotNil(feesInfo)
        XCTAssertNotEqual("", feesInfo!.blockhash)
        XCTAssertTrue(feesInfo!.feeCalculator!.lamportsPerSignature > 0)
        XCTAssertTrue(feesInfo!.lastValidSlot! > 0)
    }

    func testGetFirstAvailableBlock() {
        let block = try! solana.api.getFirstAvailableBlock()?.get()
        XCTAssertNotNil(block)
        XCTAssertTrue(0 <= block!)
    }

    func testGetGenesisHash() {
        let hash = try! solana.api.getGenesisHash()?.get()
        XCTAssertNotNil(hash)
    }

    func testGetIdentity() {
        let identity = try! solana.api.getIdentity()?.get()
        XCTAssertNotNil(identity)
    }

    func testGetVersion() {
        let version = try! solana.api.getVersion()?.get()
        XCTAssertNotNil(version)
    }

    /* func testRequestAirdrop() {
         let airdrop = try! solana.api.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 10000000000)?.get()
         XCTAssertNotNil(airdrop)
     } */
    func testGetInflationGovernor() {
        let governor = try! solana.api.getInflationGovernor()?.get()
        XCTAssertNotNil(governor)
    }

    func testGetInflationRate() {
        let rate = try! solana.api.getInflationRate()?.get()
        XCTAssertNotNil(rate)
    }
    
    // This tests doesnt run on devnet Solana.
    /*func testGetLargestAccounts() {
        let accounts = try! solana.api.getLargestAccounts()?.get()
        XCTAssertNotNil(accounts)
    }*/

    // This tests is very expensive on time
    /* func testGetLeaderSchedule() {
         let accounts = try! solana.api.getLeaderSchedule()?.get()
         XCTAssertNotNil(accounts ?? nil)
     } */
    func testGetMinimumBalanceForRentExemption() {
        let accounts = try! solana.api.getMinimumBalanceForRentExemption(dataLength: 32000)?.get()
        XCTAssertNotNil(accounts)
    }

    func testGetRecentPerformanceSamples() {
        let accounts = try! solana.api.getRecentPerformanceSamples(limit: 5)?.get()
        XCTAssertNotNil(accounts)
    }

    func testGetVoteAccounts() {
        let accounts = try! solana.api.getVoteAccounts()?.get()
        XCTAssertNotNil(accounts)
    }

    func testGetRecentBlockhash() {
        let accounts = try! solana.api.getRecentBlockhash()?.get()
        XCTAssertNotNil(accounts)
    }

    func testMinimumLedgerSlot() {
        let accounts = try! solana.api.minimumLedgerSlot()?.get()
        XCTAssertNotNil(accounts)
    }

    func testGetSlot() {
        let slot = try! solana.api.getSlot()?.get()
        XCTAssertNotNil(slot)
    }

    func testGetSlotLeader() {
        let hash = try! solana.api.getSlotLeader()?.get()
        XCTAssertNotNil(hash)
    }

    func testGetTransactionCount() {
        let count = try! solana.api.getTransactionCount()?.get()
        XCTAssertNotNil(count)
    }

    /*func testGetStakeActivation() {
        // https://explorer.solana.com/address/AUi8iPbT4sDpd3Bi6Jj7TL5LBEiXEEm2137bSkpL6Z9G
        let mainNetSolana = SolanaCore(router: NetworkingRouter(endpoint: .mainnetBetaSolana))
        let stakeActivation = try! mainNetSolana.api.getStakeActivation(stakeAccount: "AUi8iPbT4sDpd3Bi6Jj7TL5LBEiXEEm2137bSkpL6Z9G")?.get()
        XCTAssertNotNil(stakeActivation)
        XCTAssertEqual("inactive", stakeActivation!.state)
        XCTAssertTrue(stakeActivation!.active > 0)
        XCTAssertEqual(0, stakeActivation!.inactive)
        XCTAssertNotNil(hash)
    }*/

    func testGetSignatureStatuses() {
        let count = try! solana.api.getSignatureStatuses(pubkeys: ["3nVfYabxKv9ohGb4nXF3EyJQnbVcGVQAm2QKzdPrsemrP4D8UEZEzK8bCWgyTFif6mjo99akvHcCbxiEKzN5L9ZG"])?.get()
        XCTAssertNotNil(count)
    }

    /* Tokens */
    func testGetTokenAccountBalance() {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let balance = try! solana.api.getTokenAccountBalance(pubkey: tokenAddress)?.get()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }
    
    // Doesnt work on Devnet Solana
    /*func testGetTokenAccountsByDelegate() {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let tokenAccount = try! solana.api.getTokenAccountsByDelegate(pubkey: address, programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")?.get()
        XCTAssertNotNil(tokenAccount)
        XCTAssertTrue(tokenAccount!.isEmpty);
    }*/
    
    func testGetTokenAccountsByOwner() {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let result: Result<[TokenAccount<AccountInfo>], Error>? = solana.api.getTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")
        let accounts: [TokenAccount<AccountInfo>] = try! result!.get()
        XCTAssertTrue(accounts.isEmpty)
    }

    func testGetTokenSupply() {
        let tokenSupply = try! solana.api.getTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!.get()
        XCTAssertNotNil(tokenSupply)
        XCTAssertEqual(6, tokenSupply.decimals)
        XCTAssertTrue(tokenSupply.uiAmount > 0)
    }

    func testGetTokenLargestAccounts() {
        let accounts = try! solana.api.getTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!.get()
        XCTAssertNotNil(accounts[0])
    }
}
