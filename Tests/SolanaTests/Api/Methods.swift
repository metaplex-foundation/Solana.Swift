import XCTest
import RxSwift
import RxBlocking
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
        let info: BufferInfo<AccountInfo>? = try! solana.api.getAccountInfo(account: "E4tVZ5LktRkiGzXHi95u37gEpqRm8GZ6VKQ9oUy6LnaV", decodedTo: AccountInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
        XCTAssertTrue(info!.lamports > 0)
    }
    
    func testGetMultipleAccounts() {
        let accounts: [BufferInfo<AccountInfo>?] = try! solana.api.getMultipleAccounts(pubkeys: ["skynetDj29GH6o6bAqoixCpDuYtWqi1rm8ZNx1hB3vq","namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX"], decodedTo: AccountInfo.self).toBlocking().first()!!
        XCTAssertNotNil(accounts)
        XCTAssertTrue(accounts.count == 2)
        XCTAssertNotNil(accounts[0]?.data)
    }
    func testGetProgramAccounts() {
        let info = try! solana.api.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: TokenSwapInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
    }
    func testGetBlockCommitment() {
        let block = try! solana.api.getBlockCommitment(block: 82493733).toBlocking().first()
        XCTAssertNotNil(block)
        XCTAssertTrue(block!.totalStake > 0)
    }
  
    func testGetBalance() {
        let value = try! solana.api.getBalance(account: account.publicKey.base58EncodedString).toBlocking().first()
        XCTAssertNotNil(value)
        XCTAssertTrue(value! > 0)
    }
    func testGetClusterNodes() {
        let nodes = try! solana.api.getClusterNodes().toBlocking().first()
        XCTAssertNotNil(nodes)
        XCTAssertTrue(nodes!.count > 0);
    }
    func testGetBlockTime() {
        let date = try! solana.api.getBlockTime(block: 63426807).toBlocking().first()
        XCTAssertNotNil(date!)
    }
    func testGetConfirmedBlock() {
        let block = try! solana.api.getConfirmedBlock(slot: 63426807).toBlocking().first()
        XCTAssertNotNil(block)
        XCTAssertEqual(63426806, block!.parentSlot);
    }
    func testGetConfirmedBlocks() {
        let blocks = try! solana.api.getConfirmedBlocks(startSlot:63426807, endSlot: 63426808).toBlocking().first()
        XCTAssertNotNil(blocks)
        XCTAssertEqual(blocks!.count, 2);
    }
    func testGetConfirmedBlocksWithLimit() {
        let blocks = try! solana.api.getConfirmedBlocksWithLimit(startSlot:63426800, limit: 10).toBlocking().first()
        XCTAssertNotNil(blocks)
        XCTAssertEqual(blocks!.count, 10);
    }
    func testGetConfirmedSignaturesForAddress() {
        let signatures = try! solana.api.getConfirmedSignaturesForAddress(account: "Vote111111111111111111111111111111111111111", startSlot: 61968701, endSlot: 61968801).toBlocking().first()
        XCTAssertNotNil(signatures)
    }
    func testGetConfirmedSignaturesForAddress2() {
        let result = try! solana.api.getConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: RequestConfiguration(limit: 10)).toBlocking().first()
        XCTAssertEqual(result?.count, 10)
    }
    func testGetConfirmedTransaction() {
        let transaction = try! solana.api.getConfirmedTransaction(transactionSignature: "7Zk9yyJCXHapoKyHwd8AzPeW9fJWCvszR6VAcHUhvitN5W9QG9JRnoYXR8SBQPTh27piWEmdybchDt5j7xxoUth").toBlocking().first()
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction!.blockTime, 1623983206)
    }
    func testGetEpochInfo() {
        let epoch = try! solana.api.getEpochInfo().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetEpochSheadule() {
        let epoch = try! solana.api.getEpochSchedule().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetFeeCalculatorForBlockhash() {
        let hash = try! solana.api.getRecentBlockhash().toBlocking().first()
        let fee = try! solana.api.getFeeCalculatorForBlockhash(blockhash: hash!).toBlocking().first()
        XCTAssertNotNil(fee)
        XCTAssertTrue(fee!.feeCalculator!.lamportsPerSignature > 0)
    }
    func testGetFeeRateGovernor() {
        let feeRateGovernorInfo = try! solana.api.getFeeRateGovernor().toBlocking().first()
        XCTAssertNotNil(feeRateGovernorInfo)
        
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.burnPercent > 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.maxLamportsPerSignature > 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.minLamportsPerSignature > 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.targetLamportsPerSignature >= 0)
        XCTAssertTrue(feeRateGovernorInfo!.feeRateGovernor!.targetSignaturesPerSlot >= 0)
    }
    func testGetFees() {
        let feesInfo = try! solana.api.getFees().toBlocking().first()
        XCTAssertNotNil(feesInfo)
        XCTAssertNotEqual("", feesInfo!.blockhash)
        XCTAssertTrue(feesInfo!.feeCalculator!.lamportsPerSignature > 0)
        XCTAssertTrue(feesInfo!.lastValidSlot! > 0)
    }
    func testGetFirstAvailableBlock() {
        let block = try! solana.api.getFirstAvailableBlock().toBlocking().first()
        XCTAssertNotNil(block)
        XCTAssertTrue(0 <= block!)
    }
    func testGetGenesisHash() {
        let hash = try! solana.api.getGenesisHash().toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetIdentity() {
        let identity = try! solana.api.getIdentity().toBlocking().first()
        XCTAssertNotNil(identity)
    }
    func testGetVersion() {
        let version = try! solana.api.getVersion().toBlocking().first()
        XCTAssertNotNil(version)
    }
    func testRequestAirdrop() {
        let airdrop = try! solana.api.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 10000000000).toBlocking().first()
        XCTAssertNotNil(airdrop)
    }
    func testGetInflationGovernor() {
        let governor = try! solana.api.getInflationGovernor().toBlocking().first()
        XCTAssertNotNil(governor)
    }
    func testGetInflationRate() {
        let rate = try! solana.api.getInflationRate().toBlocking().first()
        XCTAssertNotNil(rate)
    }
    func testGetLargestAccounts() {
        let accounts = try! solana.api.getLargestAccounts().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    // This tests is very expensive on time
    /*func testGetLeaderSchedule() {
        let accounts = try! solana.api.getLeaderSchedule().toBlocking().first()
        XCTAssertNotNil(accounts ?? nil)
    }*/
    func testGetMinimumBalanceForRentExemption() {
        let accounts = try! solana.api.getMinimumBalanceForRentExemption(dataLength: 32000).toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetRecentPerformanceSamples() {
        let accounts = try! solana.api.getRecentPerformanceSamples(limit: 5).toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetVoteAccounts() {
        let accounts = try! solana.api.getVoteAccounts().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetRecentBlockhash() {
        let accounts = try! solana.api.getRecentBlockhash().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testMinimumLedgerSlot() {
        let accounts = try! solana.api.minimumLedgerSlot().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetSlot() {
        let slot = try! solana.api.getSlot().toBlocking().first()
        XCTAssertNotNil(slot)
    }
    func testGetSlotLeader() {
        let hash = try! solana.api.getSlotLeader().toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetTransactionCount() {
        let count = try! solana.api.getTransactionCount().toBlocking().first()
        XCTAssertNotNil(count)
    }
    func testGetStakeActivation() {
        // https://explorer.solana.com/address/HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf?cluster=devnet
        let stakeActivation = try! solana.api.getStakeActivation(stakeAccount: "HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf").toBlocking().first()
        XCTAssertNotNil(stakeActivation);
        XCTAssertEqual("active", stakeActivation!.state);
        XCTAssertTrue(stakeActivation!.active > 0);
        XCTAssertEqual(0, stakeActivation!.inactive);
        XCTAssertNotNil(hash)
    }
    func testGetSignatureStatuses() {
        let count = try! solana.api.getSignatureStatuses(pubkeys: ["3nVfYabxKv9ohGb4nXF3EyJQnbVcGVQAm2QKzdPrsemrP4D8UEZEzK8bCWgyTFif6mjo99akvHcCbxiEKzN5L9ZG"]).toBlocking().first()
        XCTAssertNotNil(count)

    }
    
    /* Tokens */
    func testGetTokenAccountBalance() {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let balance = try! solana.api.getTokenAccountBalance(pubkey: tokenAddress).toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }

    func testGetTokenAccountsByDelegate() {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let tokenAccount = try! solana.api.getTokenAccountsByDelegate(pubkey: address, programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA").toBlocking().first()
        XCTAssertNotNil(tokenAccount)
        XCTAssertTrue(tokenAccount!.isEmpty);
    }
    
    func testGetTokenAccountsByOwner() {
        let address = "AoUnMozL1ZF4TYyVJkoxQWfjgKKtu8QUK9L4wFdEJick"
        let balance = try! solana.api.getTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()
        XCTAssertTrue(balance!.isEmpty)
    }
    func testGetTokenSupply() {
        let tokenSupply = try! solana.api.getTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(tokenSupply)
        XCTAssertEqual(6, tokenSupply.decimals)
        XCTAssertTrue(tokenSupply.uiAmount > 0)
    }
    func testGetTokenLargestAccounts() {
        let accounts = try! solana.api.getTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(accounts[0])
    }
}
