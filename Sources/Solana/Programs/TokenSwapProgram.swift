//
//  TokenSwapProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/01/2021.
//

import Foundation

public extension Solana {
    struct TokenSwapProgram {
        // MARK: - Nested type
        private enum Index: UInt8, BytesEncodable {
            case initialize = 0
            case swap = 1
            case deposit = 2
            case withdraw = 3
        }

        // MARK: - Swap
        public static func swapInstruction(
            tokenSwap: PublicKey,
            authority: PublicKey,
            userTransferAuthority: PublicKey,
            userSource: PublicKey,
            poolSource: PublicKey,
            poolDestination: PublicKey,
            userDestination: PublicKey,
            poolMint: PublicKey,
            feeAccount: PublicKey,
            hostFeeAccount: PublicKey?,
            swapProgramId: PublicKey,
            tokenProgramId: PublicKey,
            amountIn: UInt64,
            minimumAmountOut: UInt64
        ) -> TransactionInstruction {
            var keys = [
                Account.Meta(publicKey: tokenSwap, isSigner: false, isWritable: false),
                Account.Meta(publicKey: authority, isSigner: false, isWritable: false),
                Account.Meta(publicKey: userTransferAuthority, isSigner: true, isWritable: false),
                Account.Meta(publicKey: userSource, isSigner: false, isWritable: true),
                Account.Meta(publicKey: poolSource, isSigner: false, isWritable: true),
                Account.Meta(publicKey: poolDestination, isSigner: false, isWritable: true),
                Account.Meta(publicKey: userDestination, isSigner: false, isWritable: true),
                Account.Meta(publicKey: poolMint, isSigner: false, isWritable: true),
                Account.Meta(publicKey: feeAccount, isSigner: false, isWritable: true),
                Account.Meta(publicKey: tokenProgramId, isSigner: false, isWritable: false)
            ]

            if let hostFeeAccount = hostFeeAccount {
                keys.append(Account.Meta(publicKey: hostFeeAccount, isSigner: false, isWritable: true))
            }

            return TransactionInstruction(
                keys: keys,
                programId: swapProgramId,
                data: [Index.swap, amountIn, minimumAmountOut]
            )
        }

        // MARK: - Deposit
        public static func depositInstruction(
            tokenSwap: PublicKey,
            authority: PublicKey,
            sourceA: PublicKey,
            sourceB: PublicKey,
            intoA: PublicKey,
            intoB: PublicKey,
            poolToken: PublicKey,
            poolAccount: PublicKey,
            tokenProgramId: PublicKey,
            swapProgramId: PublicKey,
            poolTokenAmount: UInt64,
            maximumTokenA: UInt64,
            maximumTokenB: UInt64
        ) -> TransactionInstruction {

            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: tokenSwap, isSigner: false, isWritable: false),
                    Account.Meta(publicKey: authority, isSigner: false, isWritable: false),
                    Account.Meta(publicKey: sourceA, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: sourceB, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: intoA, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: intoB, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: poolToken, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: poolAccount, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: tokenProgramId, isSigner: false, isWritable: true)
                ],
                programId: swapProgramId,
                data: [Index.deposit, poolTokenAmount, maximumTokenA, maximumTokenB]
            )
        }

        // MARK: - Withdraw
        public static func withdrawInstruction(
            tokenSwap: PublicKey,
            authority: PublicKey,
            poolMint: PublicKey,
            feeAccount: PublicKey,
            sourcePoolAccount: PublicKey,
            fromA: PublicKey,
            fromB: PublicKey,
            userAccountA: PublicKey,
            userAccountB: PublicKey,
            swapProgramId: PublicKey,
            tokenProgramId: PublicKey,
            poolTokenAmount: UInt64,
            minimumTokenA: UInt64,
            minimumTokenB: UInt64
        ) -> TransactionInstruction {

            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: tokenSwap, isSigner: false, isWritable: false),
                    Account.Meta(publicKey: authority, isSigner: false, isWritable: false),
                    Account.Meta(publicKey: poolMint, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: sourcePoolAccount, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: fromA, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: fromB, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: userAccountA, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: userAccountB, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: feeAccount, isSigner: false, isWritable: false),
                    Account.Meta(publicKey: tokenProgramId, isSigner: false, isWritable: false)
                ],
                programId: swapProgramId,
                data: [Index.withdraw, poolTokenAmount, minimumTokenA, minimumTokenB])
        }

        //        public static func initialize(
        //            tokenSwapAccount: PublicKey,
        //            authority: PublicKey,
        //            tokenAccountA: PublicKey,
        //            tokenAccountB: PublicKey,
        //            tokenPool: PublicKey,
        //            feeAccount: PublicKey,
        //            tokenAccountPool: PublicKey,
        //            tokenProgramId: PublicKey,
        //            swapProgramId: PublicKey,
        //            nonce: UInt8,
        //            curveType: UInt8,
        //            tradeFeeNumerator: UInt64,
        //            tradeFeeDenominator: UInt64,
        //            ownerTradeFeeNumerator: UInt64,
        //            ownerTradeFeeDenominator: UInt64,
        //            ownerWithdrawFeeNumerator: UInt64,
        //            ownerWithdrawFeeDenominator: UInt64,
        //            hostFeeNumerator: UInt64,
        //            hostFeeDenominator: UInt64
        //        ) -> TransactionInstruction {
        //            let keys = [
        //                Account.Meta(publicKey: tokenSwapAccount, isSigner: false, isWritable: true),
        //                Account.Meta(publicKey: authority, isSigner: false, isWritable: false),
        //                Account.Meta(publicKey: authority, isSigner: false, isWritable: false),
        //                Account.Meta(publicKey: tokenAccountA, isSigner: false, isWritable: false),
        //                Account.Meta(publicKey: tokenAccountB, isSigner: false, isWritable: false),
        //                Account.Meta(publicKey: tokenPool, isSigner: false, isWritable: true),
        //                Account.Meta(publicKey: feeAccount, isSigner: false, isWritable: false),
        //                Account.Meta(publicKey: tokenAccountPool, isSigner: false, isWritable: true),
        //                Account.Meta(publicKey: tokenProgramId, isSigner: false, isWritable: false)
        //            ]
        //            var data = TransactionType.initialize.encode([
        //                nonce,
        //                tradeFeeNumerator,
        //                tradeFeeDenominator,
        //                ownerTradeFeeNumerator,
        //                ownerTradeFeeDenominator,
        //                ownerWithdrawFeeNumerator,
        //                ownerWithdrawFeeDenominator,
        //                hostFeeNumerator,
        //                hostFeeDenominator,
        //                curveType,
        //                Data(capacity: 32)
        //            ])
        //            return TransactionInstruction(keys: keys, programId: <#T##SolanaSDK.PublicKey#>, data: data.bytes)
        //        }
    }
}
