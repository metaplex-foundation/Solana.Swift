//
//  SolanaPayTest.swift
//  
//
//  Created by Arturo Jamaica on 2022/02/20.
//

import Foundation
import XCTest
@testable import Solana

class SolanaPayTest: XCTestCase {
    func testIsURLSolanaPayValid(){
        let solanaPay = SolanaPay()
        let urlString = "solana:7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc?amount=2.0&spl-token=J8Lic4vaLVKGxDro1XGeUDnmDDP6dUA7nSRdQKdcN5cS&memo=Hello word&reference=ABCD&message=Thanks for this&label=payment"
        let specification = try! solanaPay.parseSolanaPay(urlString: urlString).get()
        XCTAssertEqual(specification.address, PublicKey(string: "7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc"))
        XCTAssertEqual(specification.amount, 2.0)
        XCTAssertEqual(specification.splToken, PublicKey(string: "J8Lic4vaLVKGxDro1XGeUDnmDDP6dUA7nSRdQKdcN5cS"))
    }
    
    func testIsURLSolanaPayInValid(){
        let solanaPay = SolanaPay()
        let urlString = "solana:7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc?amount=-2.0&spl-token=J8Lic4vaLVKGxDro1XGeUDnmDDP6dUA7nSRdQKdcN5cS&memo=Hello word&reference=ABCD&message=Thanks for this&label=payment"
        XCTAssertThrowsError(try solanaPay.parseSolanaPay(urlString: urlString).get())
    }
    
    func testCreateSolanaPayUrl(){
        let solanaPay = SolanaPay()
        let url = try! solanaPay.getSolanaPayURL(recipient: "7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc", uiAmountString: "1.0").get()
        XCTAssertEqual(url.absoluteString, "solana:7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc?amount=1.0")
    }
}
