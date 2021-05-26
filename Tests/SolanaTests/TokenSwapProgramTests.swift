//
//  TokenSwapProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 20/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import Solana

class TokenSwapProgramTests: XCTestCase {
    let publicKey = try! Solana.PublicKey(string: "11111111111111111111111111111111")

    func testSwapInstruction() throws {
        let instruction = Solana.TokenSwapProgram.swapInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            userTransferAuthority: publicKey,
            userSource: publicKey,
            poolSource: publicKey,
            poolDestination: publicKey,
            userDestination: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            hostFeeAccount: publicKey,
            swapProgramId: publicKey,
            tokenProgramId: publicKey,
            amountIn: 100000,
            minimumAmountOut: 0
        )

        XCTAssertEqual(Base58.decode("tSBHVn49GSCW4DNB1EYv9M"), instruction.data)
    }

    func testDepositInstruction() throws {
        let instruction = Solana.TokenSwapProgram.depositInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            sourceA: publicKey,
            sourceB: publicKey,
            intoA: publicKey,
            intoB: publicKey,
            poolToken: publicKey,
            poolAccount: publicKey,
            tokenProgramId: publicKey,
            swapProgramId: publicKey,
            poolTokenAmount: 507788,
            maximumTokenA: 51,
            maximumTokenB: 1038
        )

        XCTAssertEqual(Base58.decode("22WQQtPPUknk68tx2dUGRL1Q4Vj2mkg6Hd"), instruction.data)
    }

    func testWithdrawInstruction() throws {
        let instruction = Solana.TokenSwapProgram.withdrawInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            sourcePoolAccount: publicKey,
            fromA: publicKey,
            fromB: publicKey,
            userAccountA: publicKey,
            userAccountB: publicKey,
            swapProgramId: publicKey,
            tokenProgramId: publicKey,
            poolTokenAmount: 498409,
            minimumTokenA: 49,
            minimumTokenB: 979
        )

        XCTAssertEqual(Base58.decode("2aJyv2ixHWcYWoAKJkYMzSPwTrGUfnSR9R"), instruction.data)
    }
}
