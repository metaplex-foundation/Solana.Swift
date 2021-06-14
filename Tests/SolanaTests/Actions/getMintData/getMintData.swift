import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class getMintData: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }
    
    func testGetMintData() throws {
        let data = try solanaSDK.getMintData(mintAddress: Solana.PublicKey(string: "8wzZaGf89zqx7PRBoxk9T6QyWWQbhwhdU555ZxRnceG3")).toBlocking().first()
        XCTAssertNotNil(data)
    }
    
    func testGetMultipleMintDatas() throws {
        let datas = try solanaSDK.getMultipleMintDatas(mintAddresses: [Solana.PublicKey(string: "8wzZaGf89zqx7PRBoxk9T6QyWWQbhwhdU555ZxRnceG3")]).toBlocking().first()
        XCTAssertNotNil(datas)
    }
    
    func testGetPools() throws {
        let pools = try solanaSDK.getSwapPools().toBlocking().first()
        XCTAssertNotNil(pools)
        XCTAssertNotEqual(pools!.count, 0)
    }
}
