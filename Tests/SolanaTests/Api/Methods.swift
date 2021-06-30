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
        let info: BufferInfo<AccountInfo>? = try! solana.api.getAccountInfo(account: account.publicKey, decodedTo: AccountInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
    }
    
    func testGetMultipleAccounts() {
        let info: [BufferInfo<AccountInfo>?] = try! solana.api.getMultipleAccounts(pubkeys: [account.publicKey.base58EncodedString], decodedTo: AccountInfo.self).toBlocking().first()!!
        XCTAssertNotNil(info)
        XCTAssertNotNil(info[0]?.data)
    }
    func testGetProgramAccounts() {
        let info = try! solana.api.getProgramAccounts(publicKey: PublicKey(string:"SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8")!, decodedTo: TokenSwapInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
    }
    func testGetBlockCommitment() {
        let block = try! solana.api.getBlockCommitment(block: 82493733).toBlocking().first()
        XCTAssertNotNil(block)
    }
  
    func testGetBalance() {
        let value = try! solana.api.getBalance(account: account.publicKey.base58EncodedString).toBlocking().first()
        XCTAssertNotNil(value)
    }
    func testGetClusterNodes() {
        let nodes = try! solana.api.getClusterNodes().toBlocking().first()
        XCTAssertNotNil(nodes)
    }
    func testGetBlockTime() {
        let date = try! solana.api.getBlockTime(block: 63426807).toBlocking().first()
        XCTAssertNotNil(date!)
    }
    func testGetConfirmedBlock() {
        let block = try! solana.api.getConfirmedBlock(slot: 63426807).toBlocking().first()
        XCTAssertNotNil(block)
    }
    func testGetConfirmedBlocks() {
        let blocks = try! solana.api.getConfirmedBlocks(startSlot:63426807, endSlot: 63426808).toBlocking().first()
        XCTAssertNotNil(blocks)
    }
    func testGetConfirmedBlocksWithLimit() {
        let blocks = try! solana.api.getConfirmedBlocksWithLimit(startSlot:63426800, limit: 10).toBlocking().first()
        XCTAssertNotNil(blocks)
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
        let result = try! solana.api.getConfirmedTransaction(transactionSignature: "7Zk9yyJCXHapoKyHwd8AzPeW9fJWCvszR6VAcHUhvitN5W9QG9JRnoYXR8SBQPTh27piWEmdybchDt5j7xxoUth").toBlocking().first()
        XCTAssertNotNil(result)
    }
    func testGetEpochInfo() {
        let epoch = try! solana.api.getEpochInfo().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetEpochSheadule() {
        let epoch = try! solana.api.getEpochSchedule().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetFeeCalculatorForBlockhashExpired() {
        XCTAssertThrowsError(try solana.api.getFeeCalculatorForBlockhash(blockhash: "3pkUeCqmzESag2V2upuvxsFqbAmejBerWNMCSvUTeTQt").toBlocking().first())
    }
    func testGetFeeRateGovernor() {
        let fee = try! solana.api.getFeeRateGovernor().toBlocking().first()
        XCTAssertNotNil(fee)
    }
    func testGetFees() {
        let fee = try! solana.api.getFees().toBlocking().first()
        XCTAssertNotNil(fee)
    }
    func testGetFirstAvailableBlock() {
        let block = try! solana.api.getFirstAvailableBlock().toBlocking().first()
        XCTAssertNotNil(block)
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
    func testGetLeaderSchedule() {
        let accounts = try! solana.api.getLeaderSchedule().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
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
        let hash = try! solana.api.getStakeActivation(stakeAccount: "HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf").toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetSignatureStatuses() {
        let count = try! solana.api.getSignatureStatuses(pubkeys: ["3o2Jk6wsPY5eEXaXr1cC3a4uZcjFVxc5VnKR5kXvXD8E6DnqGfikovk4u6Ts7zSAewmbYiUby9tAzHeUtGTLFcdK"]).toBlocking().first()
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
    // TODO: Find a valid combination
    /*func testGetTokenAccountsByDelegate() {
        let address = "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB"
        let balance = try solana.api.getTokenAccountsByDelegate(pubkey: address, mint: "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH").toBlocking().first()!
        XCTAssertNotNil(balance[0])
    }
    func testGetTokenAccountsByOwner() {
        let address = "2ST2CedQ1QT7f2G31Qws9n7GFj7C56fKnhbxnvLymFwU"
        let balance = try solana.api.getTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(balance[0])
    }*/
    func testGetTokenSupply() {
        let supply = try! solana.api.getTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(supply)
    }
    func testGetTokenLargestAccounts() {
        let accounts = try! solana.api.getTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(accounts[0])
    }
}
