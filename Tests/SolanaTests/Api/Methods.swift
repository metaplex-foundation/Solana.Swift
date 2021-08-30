import XCTest
@testable import Solana

class Methods: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account { try! solana.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solana.api.auth.save(account).get()
    }

    func testGetAccountInfo() {
        let info: BufferInfo<AccountInfo>? = try! solana.api.getAccountInfo(account: "So11111111111111111111111111111111111111112", decodedTo: AccountInfo.self)?.get()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
        XCTAssertTrue(info!.lamports > 0)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetAccountInfoAsync() async {
        let template = ApiTemplates.GetAccountInfo(account: "So11111111111111111111111111111111111111112", decodedTo: AccountInfo.self)
        let value: BufferInfo<AccountInfo>? = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertNotNil(value?.data)
        XCTAssertTrue(value!.lamports > 0)
    }

    func testGetMultipleAccounts() {
        let accounts: [BufferInfo<AccountInfo>?] = try! solana.api.getMultipleAccounts(pubkeys: ["skynetDj29GH6o6bAqoixCpDuYtWqi1rm8ZNx1hB3vq","namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX"], decodedTo: AccountInfo.self)!.get()
        XCTAssertNotNil(accounts)
        XCTAssertTrue(accounts.count == 2)
        XCTAssertNotNil(accounts[0]?.data)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetMultipleAccountsAsync() async {
        let template = ApiTemplates.GetMultipleAccounts(pubkeys: ["skynetDj29GH6o6bAqoixCpDuYtWqi1rm8ZNx1hB3vq","namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX"], decodedTo: AccountInfo.self)
        let value: [BufferInfo<AccountInfo>?] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value.count == 2)
        XCTAssertNotNil(value[0]?.data)
    }
    
    func testGetProgramAccounts() {
        let info = try! solana.api.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: TokenSwapInfo.self)?.get()
        XCTAssertNotNil(info)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetProgramAccountsAsync() async {
        let template = ApiTemplates.GetProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: TokenSwapInfo.self)
        let value: [ProgramAccount<TokenSwapInfo>] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetBlockCommitment() {
        let block = try! solana.api.getBlockCommitment(block: 82493733)?.get()
        XCTAssertNotNil(block)
        XCTAssertTrue(block!.totalStake > 0)
    }
  
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetBlockCommitmentAsync() async {
        let template = ApiTemplates.GetBlockCommitment(block: 82493733)
        let value: BlockCommitment = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value.totalStake > 0)
    }
    
    func testGetBalance() {
        let value = try! solana.api.getBalance(account: account.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(value)
        XCTAssertTrue(value! > 0)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetBalanceAsync() async {
        let template = ApiTemplates.GetBalance(account: account.publicKey.base58EncodedString)
        let value: UInt64 = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value > 0)
    }
    
    func testGetClusterNodes() {
        let nodes = try! solana.api.getClusterNodes()?.get()
        XCTAssertNotNil(nodes)
        XCTAssertTrue(nodes!.count > 0);
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetClusterNodesAsync() async {
        let template = ApiTemplates.GetClusterNodes()
        let value: [ClusterNodes] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value.count > 0)
    }
    
    func testGetBlockTime() {
        let date = try! solana.api.getBlockTime(block: 63426807)?.get()
        XCTAssertNotNil(date!)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetBlockTimeAsync() async {
        let template = ApiTemplates.GetBlockTime(block: 63426807)
        let value: Date? = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetConfirmedBlock() {
        let block = try! solana.api.getConfirmedBlock(slot: 63426807)?.get()
        XCTAssertNotNil(block)
        XCTAssertEqual(63426806, block!.parentSlot);
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetConfirmedBlockAsync() async {
        let template = ApiTemplates.GetConfirmedBlock(slot: 63426807)
        let value: ConfirmedBlock = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertEqual(63426806, value.parentSlot)
    }
    
    func testGetConfirmedBlocks() {
        let blocks = try! solana.api.getConfirmedBlocks(startSlot:63426807, endSlot: 63426808)?.get()
        XCTAssertNotNil(blocks)
        XCTAssertEqual(blocks!.count, 2);
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetConfirmedBlocksAsync() async {
        let template = ApiTemplates.GetConfirmedBlocks(startSlot:63426807, endSlot: 63426808)
        let value: [UInt64] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertEqual(value.count, 2)
    }
    
    func testGetConfirmedBlocksWithLimit() {
        let blocks = try! solana.api.getConfirmedBlocksWithLimit(startSlot:63426800, limit: 10)?.get()
        XCTAssertNotNil(blocks)
        XCTAssertEqual(blocks!.count, 10);
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetConfirmedBlocksWithLimitAsync() async {
        let template = ApiTemplates.GetConfirmedBlocksWithLimit(startSlot:63426800, limit: 10)
        let value: [UInt64] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertEqual(value.count, 10)
    }
    
    func testGetConfirmedSignaturesForAddress2() {
        let result = try! solana.api.getConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: RequestConfiguration(limit: 4))?.get()
        XCTAssertEqual(result?.count, 4)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetConfirmedSignaturesForAddress2Async() async {
        let template = ApiTemplates.GetConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: RequestConfiguration(limit: 4))
        let value: [SignatureInfo] = try! await solana.api.perform(template)
        XCTAssertEqual(value.count, 4)
    }
    
    func testGetConfirmedTransaction() {
        let transaction = try! solana.api.getConfirmedTransaction(transactionSignature: "7Zk9yyJCXHapoKyHwd8AzPeW9fJWCvszR6VAcHUhvitN5W9QG9JRnoYXR8SBQPTh27piWEmdybchDt5j7xxoUth")?.get()
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction!.blockTime, 1623983206)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetConfirmedTransactionAsync() async {
        let template = ApiTemplates.GetConfirmedTransaction(transactionSignature: "7Zk9yyJCXHapoKyHwd8AzPeW9fJWCvszR6VAcHUhvitN5W9QG9JRnoYXR8SBQPTh27piWEmdybchDt5j7xxoUth")
        let value: TransactionInfo = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertEqual(value.blockTime, 1623983206)
    }
    
    func testGetEpochInfo() {
        let epoch = try! solana.api.getEpochInfo()?.get()
        XCTAssertNotNil(epoch)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetEpochInfoAsync() async {
        let template = ApiTemplates.GetEpochInfo()
        let value: EpochInfo = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetEpochSchedule() {
        let epoch = try! solana.api.getEpochSchedule()?.get()
        XCTAssertNotNil(epoch)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetEpochScheduleAsync() async {
        let template = ApiTemplates.GetEpochSchedule()
        let value: EpochSchedule = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetFeeCalculatorForBlockhash() {
        let hash = try! solana.api.getRecentBlockhash()?.get()
        let fee = try! solana.api.getFeeCalculatorForBlockhash(blockhash: hash!)?.get()
        XCTAssertNotNil(fee)
        XCTAssertTrue(fee!.feeCalculator!.lamportsPerSignature > 0)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetFeeCalculatorForBlockhashAsync() async {
        let hash = try! await solana.api.perform(ApiTemplates.GetRecentBlockhash())
        let template = ApiTemplates.GetFeeCalculatorForBlockhash(blockhash: hash)
        let value: Fee = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value.feeCalculator!.lamportsPerSignature > 0)
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
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetFeeRateGovernorAsync() async {
        let template = ApiTemplates.GetFeeRateGovernor()
        let value: Fee = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value.feeRateGovernor!.burnPercent > 0)
        XCTAssertTrue(value.feeRateGovernor!.maxLamportsPerSignature > 0)
        XCTAssertTrue(value.feeRateGovernor!.minLamportsPerSignature > 0)
        XCTAssertTrue(value.feeRateGovernor!.targetLamportsPerSignature >= 0)
        XCTAssertTrue(value.feeRateGovernor!.targetSignaturesPerSlot >= 0)
    }
    
    func testGetFees() {
        let feesInfo = try! solana.api.getFees()?.get()
        XCTAssertNotNil(feesInfo)
        XCTAssertNotEqual("", feesInfo!.blockhash)
        XCTAssertTrue(feesInfo!.feeCalculator!.lamportsPerSignature > 0)
        XCTAssertTrue(feesInfo!.lastValidSlot! > 0)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetFeesAsync() async {
        let template = ApiTemplates.GetFees()
        let value: Fee = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertNotEqual("", value.blockhash)
        XCTAssertTrue(value.feeCalculator!.lamportsPerSignature > 0)
        XCTAssertTrue(value.lastValidSlot! > 0)
    }
    
    func testGetFirstAvailableBlock() {
        let block = try! solana.api.getFirstAvailableBlock()?.get()
        XCTAssertNotNil(block)
        XCTAssertTrue(0 <= block!)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetFirstAvailableBlocksAsync() async {
        let template = ApiTemplates.GetFirstAvailableBlock()
        let value: UInt64 = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(0 <= value)
    }
    
    func testGetGenesisHash() {
        let hash = try! solana.api.getGenesisHash()?.get()
        XCTAssertNotNil(hash)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetGenesisHashAsync() async {
        let template = ApiTemplates.GetGenesisHash()
        let value: String = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetIdentity() {
        let identity = try! solana.api.getIdentity()?.get()
        XCTAssertNotNil(identity)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetIdentityAsync() async {
        let template = ApiTemplates.GetIdentity()
        let value: Identity = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetVersion() {
        let version = try! solana.api.getVersion()?.get()
        XCTAssertNotNil(version)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetVersionAsync() async {
        let template = ApiTemplates.GetVersion()
        let value: Version = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    /*func testRequestAirdrop() {
        let airdrop = try! solana.api.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 10000000000)?.get()
        XCTAssertNotNil(airdrop)
    }*/
    func testGetInflationGovernor() {
        let governor = try! solana.api.getInflationGovernor()?.get()
        XCTAssertNotNil(governor)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetInflationGovernorAsync() async {
        let template = ApiTemplates.GetInflationGovernor()
        let value: InflationGovernor = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetInflationRate() {
        let rate = try! solana.api.getInflationRate()?.get()
        XCTAssertNotNil(rate)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetInflationRateAsync() async {
        let template = ApiTemplates.GetInflationRate()
        let value: InflationRate = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetLargestAccounts() {
        let accounts = try! solana.api.getLargestAccounts()?.get()
        XCTAssertNotNil(accounts)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetLargestAccountsAsync() async {
        let template = ApiTemplates.GetLargestAccounts()
        let value: [LargestAccount] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    // This tests is very expensive on time
    /*func testGetLeaderSchedule() {
        let accounts = try! solana.api.getLeaderSchedule()?.get()
        XCTAssertNotNil(accounts ?? nil)
    }*/
    func testGetMinimumBalanceForRentExemption() {
        let accounts = try! solana.api.getMinimumBalanceForRentExemption(dataLength: 32000)?.get()
        XCTAssertNotNil(accounts)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetMinimumBalanceForRentExemptionAsync() async {
        let template = ApiTemplates.GetMinimumBalanceForRentExemption(dataLength: 32000)
        let value: UInt64 = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetRecentPerformanceSamples() {
        let accounts = try! solana.api.getRecentPerformanceSamples(limit: 5)?.get()
        XCTAssertNotNil(accounts)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetRecentPerformanceSamplesAsync() async {
        let template = ApiTemplates.GetRecentPerformanceSamples(limit: 5)
        let value: [PerformanceSample] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetVoteAccounts() {
        let accounts = try! solana.api.getVoteAccounts()?.get()
        XCTAssertNotNil(accounts)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetVoteAccountsAsync() async {
        let template = ApiTemplates.GetVoteAccounts()
        let value: VoteAccounts = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetRecentBlockhash() {
        let accounts = try! solana.api.getRecentBlockhash()?.get()
        XCTAssertNotNil(accounts)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetRecentBlockhashAsync() async {
        let template = ApiTemplates.GetRecentBlockhash()
        let value: String = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testMinimumLedgerSlot() {
        let accounts = try! solana.api.minimumLedgerSlot()?.get()
        XCTAssertNotNil(accounts)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testMinimumLedgerSlotAsync() async {
        let template = ApiTemplates.MinimumLedgerSlot()
        let value: UInt64 = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetSlot() {
        let slot = try! solana.api.getSlot()?.get()
        XCTAssertNotNil(slot)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetSlotAsync() async {
        let template = ApiTemplates.GetSlot()
        let value: UInt64 = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetSlotLeader() {
        let hash = try! solana.api.getSlotLeader()?.get()
        XCTAssertNotNil(hash)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetSlotLeaderAsync() async {
        let template = ApiTemplates.GetSlotLeader()
        let value: String = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetTransactionCount() {
        let count = try! solana.api.getTransactionCount()?.get()
        XCTAssertNotNil(count)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetTransactionCountAsync() async {
        let template = ApiTemplates.GetTransactionCount()
        let value: UInt64 = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    func testGetStakeActivation() {
        // https://explorer.solana.com/address/HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf?cluster=devnet
        let stakeActivation = try! solana.api.getStakeActivation(stakeAccount: "HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf")?.get()
        XCTAssertNotNil(stakeActivation);
        XCTAssertEqual("active", stakeActivation!.state);
        XCTAssertTrue(stakeActivation!.active > 0);
        XCTAssertEqual(0, stakeActivation!.inactive);
        XCTAssertNotNil(hash)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetStakeActivationAsync() async {
        // https://explorer.solana.com/address/HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf?cluster=devnet
        let template = ApiTemplates.GetStakeActivation(stakeAccount: "HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf")
        let value: StakeActivation = try! await solana.api.perform(template)
        XCTAssertNotNil(value);
        XCTAssertEqual("active", value.state);
        XCTAssertTrue(value.active > 0);
        XCTAssertEqual(0, value.inactive);
        XCTAssertNotNil(value)
    }
    
    func testGetSignatureStatuses() {
        let count = try! solana.api.getSignatureStatuses(pubkeys: ["3nVfYabxKv9ohGb4nXF3EyJQnbVcGVQAm2QKzdPrsemrP4D8UEZEzK8bCWgyTFif6mjo99akvHcCbxiEKzN5L9ZG"])?.get()
        XCTAssertNotNil(count)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetSignatureStatusesAsync() async {
        let template = ApiTemplates.GetSignatureStatuses(pubkeys: ["3nVfYabxKv9ohGb4nXF3EyJQnbVcGVQAm2QKzdPrsemrP4D8UEZEzK8bCWgyTFif6mjo99akvHcCbxiEKzN5L9ZG"])
        let value: [SignatureStatus?] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
    }
    
    /* Tokens */
    func testGetTokenAccountBalance() {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let balance = try! solana.api.getTokenAccountBalance(pubkey: tokenAddress)?.get()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetTokenAccountBalanceAsync() async {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let template = ApiTemplates.GetTokenAccountBalance(pubkey: tokenAddress)
        let value: TokenAccountBalance = try! await solana.api.perform(template)
        XCTAssertNotNil(value.uiAmount)
        XCTAssertNotNil(value.amount)
        XCTAssertNotNil(value.decimals)
    }

    func testGetTokenAccountsByDelegate() {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let tokenAccount = try! solana.api.getTokenAccountsByDelegate(pubkey: address, programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")?.get()
        XCTAssertNotNil(tokenAccount)
        XCTAssertTrue(tokenAccount!.isEmpty);
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetTokenAccountsByDelegateAsync() async {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let template = ApiTemplates.GetTokenAccountsByDelegate(pubkey: address, programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        let value: [TokenAccount<AccountInfo>] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value.isEmpty)
    }
    
    func testGetTokenAccountsByOwner() {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let balance = try! solana.api.getTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")?.get()
        XCTAssertTrue(balance!.isEmpty)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetTokenAccountsByOwnerAsync() async {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let template = ApiTemplates.GetTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")
        let value: [TokenAccount<AccountInfo>] = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertTrue(value.isEmpty)
    }
    
    func testGetTokenSupply() {
        let tokenSupply = try! solana.api.getTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!.get()
        XCTAssertNotNil(tokenSupply)
        XCTAssertEqual(6, tokenSupply.decimals)
        XCTAssertTrue(tokenSupply.uiAmount > 0)
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetTokenSupplyAsync() async {
        let template = ApiTemplates.GetTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")
        let value: TokenAmount = try! await solana.api.perform(template)
        XCTAssertNotNil(value)
        XCTAssertEqual(6, value.decimals)
        XCTAssertTrue(value.uiAmount > 0)
    }
    
    func testGetTokenLargestAccounts() {
        let accounts = try! solana.api.getTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")!.get()
        XCTAssertNotNil(accounts[0])
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    func testGetTokenLargestAccountsAsync() async {
        let template = ApiTemplates.GetTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8")
        let value: [TokenAmount] = try! await solana.api.perform(template)
        XCTAssertNotNil(value[0])
    }
}
