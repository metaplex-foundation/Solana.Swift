import Foundation
import XCTest
@testable import Solana

class TransactionParserTests: XCTestCase {
    let endpoint = Solana.RpcApiEndPoint.mainnetBetaSolana
    var solanaSDK: Solana!
    var parser: Solana.TransactionParser!
    
    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
        
        parser = Solana.TransactionParser(solanaSDK: solanaSDK)
    }
    
    func testDecodingSwapTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SwapTransaction")
        
        let myAccountSymbol = "SOL"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: myAccountSymbol)
            .toBlocking().first()?.value as! Solana.SwapTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua")
        XCTAssertEqual(transaction.sourceAmount, 0.001)
        
        XCTAssertEqual(transaction.destination?.token.symbol, myAccountSymbol)
        XCTAssertEqual(transaction.destinationAmount, 0.000364885)
    }
    
    func testDecodingCreateAccountTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("CreateAccountTransaction")
        
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: nil)
            .toBlocking().first()?.value as! Solana.CreateAccountTransaction
        
        XCTAssertEqual(transaction.fee, 0.00203928)
        XCTAssertEqual(transaction.newWallet?.token.symbol, "ETH")
        XCTAssertEqual(transaction.newWallet?.pubkey, "8jpWBKSoU7SXz9gJPJS53TEXXuWcg1frXLEdnfomxLwZ")
    }
    
    func testDecodingCloseAccountTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("CloseAccountTransaction")
        
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: nil, myAccountSymbol: nil)
            .toBlocking().first()?.value as! Solana.CloseAccountTransaction
        
        XCTAssertEqual(transaction.reimbursedAmount, 0.00203928)
        XCTAssertEqual(transaction.closedWallet?.token.symbol, "ETH")
    }
    
    func testDecodingSendSOLTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SendSOLTransaction")
        
        let myAccount = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! Solana.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.amount, 0.01)
    }
    
    func testDecodingSendSOLTransactionPaidByP2PORG() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SendSOLTransactionPaidByP2PORG")
        
        let myAccount = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! Solana.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SOL")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(transaction.amount, 0.00001)
    }
    
    func testDecodingSendSPLToSOLTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SendSPLToSOLTransaction")
        let myAccount = "22hXC9c4SGccwCkjtJwZ2VGRfhDYh9KSRCviD8bs4Xbg"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! Solana.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "wUSDT")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "GCmbXJRc6mfnNNbnh5ja2TwWFzVzBp8MovsrTciw1HeS")
        XCTAssertEqual(transaction.amount, 0.004325)
    }
    
    func testDecodingSendSPLToSPLTransaction() throws {
        let transactionInfo = try transactionInfoFromJSONFileName("SendSPLToSPLTransaction")
        let myAccount = "BjUEdE292SLEq9mMeKtY3GXL6wirn7DqJPhrukCqAUua"
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()?.value as! Solana.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "SRM")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.destination?.pubkey, "3YuhjsaohzpzEYAsonBQakYDj3VFWimhDn7bci8ERKTh")
        XCTAssertEqual(transaction.amount, 0.012111)
    }
    
    func testDecodingSendTokenToNewAssociatedTokenAddress() throws {
        // transfer type
        let transactionInfo = try transactionInfoFromJSONFileName("SendTokenToNewAssociatedTokenAddress")
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: "MAPS")
            .toBlocking().first()?.value as! Solana.TransferTransaction
        
        XCTAssertEqual(transaction.source?.token.symbol, "MAPS")
        XCTAssertEqual(transaction.source?.pubkey, myAccount)
        XCTAssertEqual(transaction.amount, 0.001)
        
        // transfer checked type
        let transactionInfo2 = try transactionInfoFromJSONFileName("SendTokenToNewAssociatedTokenAddressTransferChecked")
        let transaction2 = try parser.parse(transactionInfo: transactionInfo2, myAccount: myAccount, myAccountSymbol: "MAPS")
            .toBlocking().first()?.value as! Solana.TransferTransaction
        
        XCTAssertEqual(transaction2.source?.token.symbol, "MAPS")
        XCTAssertEqual(transaction2.source?.pubkey, myAccount)
        XCTAssertEqual(transaction2.amount, 0.001)
    }
    
    func testDecodingProvideLiquidityToPoolTransaction() throws {
        // transfer type
        let transactionInfo = try transactionInfoFromJSONFileName("ProvideLiquidityToPoolTransaction")
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()!
        
        XCTAssertNil(transaction.value)
    }
    
    func testDecodingBurnLiquidityInPoolTransaction() throws {
        // transfer type
        let transactionInfo = try transactionInfoFromJSONFileName("BurnLiquidityInPoolTransaction")
        let myAccount = "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd"
        
        let transaction = try parser.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: nil)
            .toBlocking().first()!
        
        XCTAssertNil(transaction.value)
    }
    
    private func transactionInfoFromJSONFileName(_ name: String) throws -> Solana.TransactionInfo {
        //let path = Bundle(for: Self.self).path(forResource: name, ofType: "json")
        let data = stubbedResponse(name)
        let transactionInfo = try JSONDecoder().decode(Solana.TransactionInfo.self, from: data)
        return transactionInfo
    }
}

func stubbedResponse(_ filename: String) -> Data {
    @objc class SolanaTests: NSObject { }
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("Resources/\(filename).json")
    return try! Data(contentsOf: resourceURL)
}
