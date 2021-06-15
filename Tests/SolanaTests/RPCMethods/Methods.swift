import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class Methods: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }

    func testGetAccountInfo() throws {
        let info: Solana.BufferInfo<Solana.AccountInfo>? = try solanaSDK.getAccountInfo(account: account.publicKey.base58EncodedString, decodedTo: Solana.AccountInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
    }
    
    func testGetMultipleAccounts() throws {
        let info: [Solana.BufferInfo<Solana.AccountInfo>?] = try solanaSDK.getMultipleAccounts(pubkeys: [account.publicKey.base58EncodedString], decodedTo: Solana.AccountInfo.self).toBlocking().first()!!
        XCTAssertNotNil(info)
        XCTAssertNotNil(info[0]?.data)
    }
    func testGetProgramAccounts() throws {
        let info = try solanaSDK.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: Solana.TokenSwapInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
    }
    func testGetBlockCommitment() throws {
        let block = try solanaSDK.getBlockCommitment(block: 82493733).toBlocking().first()
        XCTAssertNotNil(block)
    }
  
    func testGetBalance() throws {
        let value = try solanaSDK.getBalance(account: account.publicKey.base58EncodedString).toBlocking().first()
        XCTAssertNotNil(value)
    }
    func testGetClusterNodes() throws {
        let nodes = try solanaSDK.getClusterNodes().toBlocking().first()
        XCTAssertNotNil(nodes)
    }
    func testGetBlockTime() throws {
        let date = try solanaSDK.getBlockTime(block: 61968801).toBlocking().first()
        XCTAssertNotNil(date)
    }
    func testGetConfirmedBlock() throws {
        let block = try solanaSDK.getConfirmedBlock(slot: 61998730).toBlocking().first()
        XCTAssertNotNil(block)
    }
    func testGetConfirmedBlocks() throws {
        let blocks = try solanaSDK.getConfirmedBlocks(startSlot:61998720, endSlot: 61998730).toBlocking().first()
        XCTAssertNotNil(blocks)
    }
    func testGetConfirmedBlocksWithLimit() throws {
        let blocks = try solanaSDK.getConfirmedBlocksWithLimit(startSlot:61998720, limit: 10).toBlocking().first()
        XCTAssertNotNil(blocks)
    }
    func testGetConfirmedSignaturesForAddress() throws {
        let signatures = try solanaSDK.getConfirmedSignaturesForAddress(account: "Vote111111111111111111111111111111111111111", startSlot: 61968701, endSlot: 61968801).toBlocking().first()
        XCTAssertNotNil(signatures)
    }
    func testGetConfirmedSignaturesForAddress2() throws {
        let result = try solanaSDK.getConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: Solana.RequestConfiguration(limit: 10)).toBlocking().first()
        XCTAssertEqual(result?.count, 10)
    }
    func testGetConfirmedTransaction() throws {
        let result = try solanaSDK.getConfirmedTransaction(transactionSignature: "5dxrTLhZGwPzaYyE7xpTh5HgQdyV6hnseKGDHuhKAeTapw2TbTHtNh1aA2ecrbbGM2ZQ5gD6G7jzcd98Vro5L1DU").toBlocking().first()
        XCTAssertNotNil(result)
    }
    func testGetEpochInfo() throws {
        let epoch = try solanaSDK.getEpochInfo().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetEpochSheadule() throws {
        let epoch = try solanaSDK.getEpochSchedule().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetFeeCalculatorForBlockhashExpired() throws {
        XCTAssertThrowsError(try solanaSDK.getFeeCalculatorForBlockhash(blockhash: "3pkUeCqmzESag2V2upuvxsFqbAmejBerWNMCSvUTeTQt").toBlocking().first())
    }
    func testGetFeeRateGovernor() throws {
        let fee = try solanaSDK.getFeeRateGovernor().toBlocking().first()
        XCTAssertNotNil(fee)
    }
    func testGetFees() throws {
        let fee = try solanaSDK.getFees().toBlocking().first()
        XCTAssertNotNil(fee)
    }
    func testGetFirstAvailableBlock() throws {
        let block = try solanaSDK.getFirstAvailableBlock().toBlocking().first()
        XCTAssertNotNil(block)
    }
    func testGetGenesisHash() throws {
        let hash = try solanaSDK.getGenesisHash().toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetIdentity() throws {
        let identity = try solanaSDK.getIdentity().toBlocking().first()
        XCTAssertNotNil(identity)
    }
    func testGetVersion() throws {
        let version = try solanaSDK.getVersion().toBlocking().first()
        XCTAssertNotNil(version)
    }
    func testRequestAirdrop() throws {
        let airdrop = try solanaSDK.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 10000000000).toBlocking().first()
        XCTAssertNotNil(airdrop)
    }
    func testGetInflationGovernor() throws {
        let governor = try solanaSDK.getInflationGovernor().toBlocking().first()
        XCTAssertNotNil(governor)
    }
    func testGetInflationRate() throws {
        let rate = try solanaSDK.getInflationRate().toBlocking().first()
        XCTAssertNotNil(rate)
    }
    func testGetLargestAccounts() throws {
        let accounts = try solanaSDK.getLargestAccounts().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetLeaderSchedule() throws {
        let accounts = try solanaSDK.getLeaderSchedule().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetMinimumBalanceForRentExemption() throws {
        let accounts = try solanaSDK.getMinimumBalanceForRentExemption(dataLength: 32000).toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetRecentPerformanceSamples() throws {
        let accounts = try solanaSDK.getRecentPerformanceSamples(limit: 5).toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetVoteAccounts() throws {
        let accounts = try solanaSDK.getVoteAccounts().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetRecentBlockhash() throws {
        let accounts = try solanaSDK.getRecentBlockhash().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testMinimumLedgerSlot() throws {
        let accounts = try solanaSDK.minimumLedgerSlot().toBlocking().first()
        XCTAssertNotNil(accounts)
    }
    func testGetSlot() throws {
        let slot = try solanaSDK.getSlot().toBlocking().first()
        XCTAssertNotNil(slot)
    }
    func testGetSlotLeader() throws {
        let hash = try solanaSDK.getSlotLeader().toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetTransactionCount() throws {
        let count = try solanaSDK.getTransactionCount().toBlocking().first()
        XCTAssertNotNil(count)
    }
    func testGetStakeActivation() throws {
        // https://explorer.solana.com/address/HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf?cluster=devnet
        let hash = try solanaSDK.getStakeActivation(stakeAccount: "HDDhNo3H2t3XbLmRswHdTu5L8SvSMypz9UVFu68Wgmaf").toBlocking().first()
        XCTAssertNotNil(hash)
    }
    func testGetSignatureStatuses() throws {
        let count = try solanaSDK.getSignatureStatuses(pubkeys: ["3o2Jk6wsPY5eEXaXr1cC3a4uZcjFVxc5VnKR5kXvXD8E6DnqGfikovk4u6Ts7zSAewmbYiUby9tAzHeUtGTLFcdK"]).toBlocking().first()
        XCTAssertNotNil(count)
    }
    
    /* Tokens */
    
    func testGetTokenAccountBalance() throws {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let balance = try solanaSDK.getTokenAccountBalance(pubkey: tokenAddress).toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }
    // TODO: Find a valid combination
    /*func testGetTokenAccountsByDelegate() throws {
        let address = "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB"
        let balance = try solanaSDK.getTokenAccountsByDelegate(pubkey: address, mint: "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH").toBlocking().first()!
        XCTAssertNotNil(balance[0])
    }
    func testGetTokenAccountsByOwner() throws {
        let address = "2ST2CedQ1QT7f2G31Qws9n7GFj7C56fKnhbxnvLymFwU"
        let balance = try solanaSDK.getTokenAccountsByOwner(pubkey: address, mint: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(balance[0])
    }*/
    func testGetTokenSupply() throws {
        let supply = try solanaSDK.getTokenSupply(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(supply)
    }
    func testGetTokenLargestAccounts() throws {
        let accounts = try solanaSDK.getTokenLargestAccounts(pubkey: "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8").toBlocking().first()!
        XCTAssertNotNil(accounts[0])
    }
}

// RestAPITransactionTests
extension Methods {
    // MARK: - Send

    /*func testSwapToken() throws {
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

    /*func testSendSPLTokenToSolAccountViaAToken() throws {
        _ = try solanaSDK.sendSPLTokens(
            mintAddress: "So11111111111111111111111111111111111111112",
            decimals: 6,
            from: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx",
            to: "5Tg8VjmWQPgnEWDLACH5B3WsYAGhsQwsrWgFb4NaTPYZ",
            amount: 0.001.toLamport(decimals: 6)
        ).toBlocking().first()
    }*/
}
