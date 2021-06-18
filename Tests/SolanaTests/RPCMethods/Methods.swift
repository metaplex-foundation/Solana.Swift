import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class Methods: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }

    func testGetAccountInfo() {
        let info: Solana.BufferInfo<Solana.AccountInfo>? = try! solanaSDK.getAccountInfo(account: account.publicKey.base58EncodedString, decodedTo: Solana.AccountInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
    }
    
    func testGetMultipleAccounts() {
        let info: [Solana.BufferInfo<Solana.AccountInfo>?] = try! solanaSDK.getMultipleAccounts(pubkeys: [account.publicKey.base58EncodedString], decodedTo: Solana.AccountInfo.self).toBlocking().first()!!
        XCTAssertNotNil(info)
        XCTAssertNotNil(info[0]?.data)
    }
    func testGetProgramAccounts() {
        let info = try! solanaSDK.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: Solana.TokenSwapInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
    }
    func testGetBlockCommitment() {
        let block = try! solanaSDK.getBlockCommitment(block: 82493733).toBlocking().first()
        XCTAssertNotNil(block)
    }
  
    func testGetBalance() {
        let value = try! solanaSDK.getBalance(account: account.publicKey.base58EncodedString).toBlocking().first()
        XCTAssertNotNil(value)
    }
    func testGetClusterNodes() {
        let nodes = try! solanaSDK.getClusterNodes().toBlocking().first()
        XCTAssertNotNil(nodes)
    }
    func testGetBlockTime() {
        let date = try! solanaSDK.getBlockTime(block: 61968801).toBlocking().first()
        XCTAssertNotNil(date)
    }
    func testGetConfirmedBlock() {
        let block = try! solanaSDK.getConfirmedBlock(slot: 61998730).toBlocking().first()
        XCTAssertNotNil(block)
    }
    func testGetConfirmedBlocks() {
        let blocks = try! solanaSDK.getConfirmedBlocks(startSlot:61998720, endSlot: 61998730).toBlocking().first()
        XCTAssertNotNil(blocks)
    }
    func testGetConfirmedBlocksWithLimit() {
        let blocks = try! solanaSDK.getConfirmedBlocksWithLimit(startSlot:61998720, limit: 10).toBlocking().first()
        XCTAssertNotNil(blocks)
    }
    func testGetConfirmedSignaturesForAddress() {
        let signatures = try! solanaSDK.getConfirmedSignaturesForAddress(account: "Vote111111111111111111111111111111111111111", startSlot: 61968701, endSlot: 61968801).toBlocking().first()
        XCTAssertNotNil(signatures)
    }
    func testGetConfirmedSignaturesForAddress2() {
        let result = try! solanaSDK.getConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: Solana.RequestConfiguration(limit: 10)).toBlocking().first()
        XCTAssertEqual(result?.count, 10)
    }
    func testGetConfirmedTransaction() {
        let result = try! solanaSDK.getConfirmedTransaction(transactionSignature: "7Zk9yyJCXHapoKyHwd8AzPeW9fJWCvszR6VAcHUhvitN5W9QG9JRnoYXR8SBQPTh27piWEmdybchDt5j7xxoUth").toBlocking().first()
        XCTAssertNotNil(result)
    }
    func testGetEpochInfo() {
        let epoch = try! solanaSDK.getEpochInfo().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetEpochSheadule() {
        let epoch = try! solanaSDK.getEpochSchedule().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetFeeCalculatorForBlockhashExpired() {
        XCTAssertThrowsError(try solanaSDK.getFeeCalculatorForBlockhash(blockhash: "3pkUeCqmzESag2V2upuvxsFqbAmejBerWNMCSvUTeTQt").toBlocking().first())
    }
    func testGetFeeRateGovernor() {
        let fee = try! solanaSDK.getFeeRateGovernor().toBlocking().first()
        XCTAssertNotNil(fee)
    }
    func testGetFees() {
        let fee = try! solanaSDK.getFees().toBlocking().first()
        XCTAssertNotNil(fee)
    }
    func testGetFirstAvailableBlock() {
        let block = try! solanaSDK.getFirstAvailableBlock().toBlocking().first()
        XCTAssertNotNil(block)
    }
    func testGetGenesisHash() {
        let hash = try! solanaSDK.getGenesisHash().toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetIdentity() {
        let identity = try! solanaSDK.getIdentity().toBlocking().first()
        XCTAssertNotNil(identity)
    }
    func testGetVersion() {
        let version = try! solanaSDK.getVersion().toBlocking().first()
        XCTAssertNotNil(version)
    }
    func testRequestAirdrop() {
        let airdrop = try! solanaSDK.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 10000000000).toBlocking().first()
        XCTAssertNotNil(airdrop)
    }
    func testGetInflationGovernor() {
        let governor = try! solanaSDK.getInflationGovernor().toBlocking().first()
        XCTAssertNotNil(governor)
    }
    func testGetInflationRate() {
        let rate = try! solanaSDK.getInflationRate().toBlocking().first()
        XCTAssertNotNil(rate)
    }
    func testGetLargestAccounts() {
        let accounts = try! solanaSDK.getLargestAccounts().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetLeaderSchedule() {
        let accounts = try! solanaSDK.getLeaderSchedule().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetMinimumBalanceForRentExemption() {
        let accounts = try! solanaSDK.getMinimumBalanceForRentExemption(dataLength: 32000).toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetRecentPerformanceSamples() {
        let accounts = try! solanaSDK.getRecentPerformanceSamples(limit: 5).toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetVoteAccounts() {
        let accounts = try! solanaSDK.getVoteAccounts().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetRecentBlockhash() {
        let accounts = try! solanaSDK.getRecentBlockhash().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testMinimumLedgerSlot() {
        let accounts = try! solanaSDK.minimumLedgerSlot().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetSlot() {
        let slot = try! solanaSDK.getSlot().toBlocking().first()
        XCTAssertNotNil(slot)
    }
    func testGetSlotLeader() {
        let hash = try! solanaSDK.getSlotLeader().toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetTransactionCount() {
        let count = try! solanaSDK.getTransactionCount().toBlocking().first()
        XCTAssertNotNil(count)
    }
    func testGetStakeActivation() {
        // https://explorer.solana.com/address/HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf?cluster=devnet
        let hash = try! solanaSDK.getStakeActivation(stakeAccount: "HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf").toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetSignatureStatuses() {
        let count = try! solanaSDK.getSignatureStatuses(pubkeys: ["3o2Jk6wsPY5eEXaXr1cC3a4uZcjFVxc5VnKR5kXvXD8E6DnqGfikovk4u6Ts7zSAewmbYiUby9tAzHeUtGTLFcdK"]).toBlocking().first()
        XCTAssertNotNil(count)
    }
    
    /* Tokens */
    
    func testGetTokenAccountBalance() {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let balance = try! solanaSDK.getTokenAccountBalance(pubkey: tokenAddress).toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }
    // TODO: Find a valid combination
    /*func testGetTokenAccountsByDelegate() {
        let address = "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB"
        let balance = try solanaSDK.getTokenAccountsByDelegate(pubkey: address, mint: "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH").toBlocking().first()!
        XCTAssertNotNil(balance[0])
    }
    func testGetTokenAccountsByOwner() {
        let address = "2ST2CedQ1QT7f2G31Qws9n7GFj7C56fKnhbxnvLymFwU"
        let balance = try solanaSDK.getTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(balance[0])
    }*/
    func testGetTokenSupply() {
        let supply = try! solanaSDK.getTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(supply)
    }
    func testGetTokenLargestAccounts() {
        let accounts = try! solanaSDK.getTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(accounts[0])
    }
}
