//
//  SolanaSDK+Swap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation
import RxSwift

extension Solana {
    public func swap(
        account: Account? = nil,
        pool: Pool? = nil,
        source: PublicKey,
        sourceMint: PublicKey,
        destination: PublicKey? = nil,
        destinationMint: PublicKey,
        slippage: Double,
        amount: UInt64,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        // verify account
        guard let owner = account ?? accountStorage.account
        else {return .error(Error.unauthorized)}

        // reuse variables
        var pool = pool

        // reduce pools
        var getPoolRequest: Single<Pool>
        if let pool = pool {
            getPoolRequest = .just(pool)
        } else {
            getPoolRequest = getSwapPools()
                .map {pools -> Pool in
                    // filter pool that match requirement
                    if let matchPool = pools.matchedPool(
                        sourceMint: sourceMint.base58EncodedString,
                        destinationMint: destinationMint.base58EncodedString
                    ) {
                        pool = matchPool
                        return matchPool
                    }
                    throw Error.other("Unsupported swapping tokens")
                }
        }

        // get pool
        return getPoolRequest
            .flatMap { pool -> Single<[Any]> in
                Single.zip([
                    self.getAccountInfoData(
                        account: pool.swapData.tokenAccountA.base58EncodedString,
                        tokenProgramId: .tokenProgramId
                    )
                        .map {$0 as Any},

                    self.getMinimumBalanceForRentExemption(dataLength: UInt64(AccountInfo.BUFFER_LENGTH))
                        .map {$0 as Any}
                ])
            }
            .flatMap {params in
                guard let pool = pool,
                      let poolAuthority = pool.authority,
                      let estimatedAmount = pool.estimatedAmount(forInputAmount: amount, includeFees: true),
                      let tokenBBalance = UInt64(pool.tokenBBalance?.amount ?? "")
                else {return .error(Error.other("Swap pool is not valid"))}
                // get variables
                let tokenAInfo      = params[0] as! AccountInfo
                let minimumBalanceForRentExemption
                                    = params[1] as! UInt64

                let minAmountIn = pool.minimumReceiveAmount(estimatedAmount: estimatedAmount, slippage: slippage)

                // find account
                var source = source
                var destination = destination

                // add userTransferAuthority
                let userTransferAuthority = try Account(network: self.endpoint.network)

                // form signers
                var signers = [owner, userTransferAuthority]

                // form instructions
                var instructions = [TransactionInstruction]()
                var cleanupInstructions = [TransactionInstruction]()

                // create fromToken if it is native
                if tokenAInfo.isNative {
                    let newAccount = try self.createWrappedSolAccount(
                        fromAccount: source,
                        amount: amount,
                        payer: owner.publicKey,
                        instructions: &instructions,
                        cleanupInstructions: &cleanupInstructions,
                        signers: &signers,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption
                    )

                    source = newAccount.publicKey
                }

                // check toToken
                let isMintBWSOL = destinationMint == .wrappedSOLMint
                if destination == nil || isMintBWSOL {
                    // create toToken if it doesn't exist
                    let newAccount = try self.createAccountByMint(
                        owner: owner.publicKey,
                        mint: destinationMint,
                        instructions: &instructions,
                        cleanupInstructions: &cleanupInstructions,
                        signers: &signers,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption
                    )

                    destination = newAccount.publicKey
                }

                // approve
                instructions.append(
                    TokenProgram.approveInstruction(
                        tokenProgramId: .tokenProgramId,
                        account: source,
                        delegate: userTransferAuthority.publicKey,
                        owner: owner.publicKey,
                        amount: amount
                    )
                )

                // TODO: - Host fee
//                let hostFeeAccount = try self.createAccountByMint(
//                    owner: .swapHostFeeAddress,
//                    mint: pool.swapData.tokenPool,
//                    instructions: &instructions,
//                    cleanupInstructions: &cleanupInstructions,
//                    signers: &signers,
//                    minimumBalanceForRentExemption: minimumBalanceForRentExemption
//                )

                // swap
                instructions.append(
                    TokenSwapProgram.swapInstruction(
                        tokenSwap: pool.address,
                        authority: poolAuthority,
                        userTransferAuthority: userTransferAuthority.publicKey,
                        userSource: source,
                        poolSource: pool.swapData.tokenAccountA,
                        poolDestination: pool.swapData.tokenAccountB,
                        userDestination: destination!,
                        poolMint: pool.swapData.tokenPool,
                        feeAccount: pool.swapData.feeAccount,
                        hostFeeAccount: nil,
                        swapProgramId: self.endpoint.network.swapProgramId,
                        tokenProgramId: .tokenProgramId,
                        amountIn: amount,
                        minimumAmountOut: minAmountIn
                    )
                )

                return self.serializeAndSendWithFee(
                    instructions: instructions + cleanupInstructions,
                    signers: signers,
                    isSimulation: isSimulation
                )
            }
    }

    // MARK: - Helpers
    private func getAccountInfoData(account: String, tokenProgramId: PublicKey) -> Single<AccountInfo> {
        getAccountInfo(account: account, decodedTo: AccountInfo.self)
            .map {
                if $0.owner != tokenProgramId.base58EncodedString {
                    throw Error.other("Invalid account owner")
                }
                if let info = $0.data.value {
                    return info
                }
                throw Error.other("Invalid data")
            }
    }

    private func createWrappedSolAccount(
        fromAccount: PublicKey,
        amount: UInt64,
        payer: PublicKey,
        instructions: inout [TransactionInstruction],
        cleanupInstructions: inout [TransactionInstruction],
        signers: inout [Account],
        minimumBalanceForRentExemption: UInt64
    ) throws -> Account {
        let newAccount = try Account(network: endpoint.network)

        instructions.append(
            SystemProgram.createAccountInstruction(
                from: fromAccount,
                toNewPubkey: newAccount.publicKey,
                lamports: amount + minimumBalanceForRentExemption
            )
        )

        instructions.append(
            TokenProgram.initializeAccountInstruction(
                account: newAccount.publicKey,
                mint: .wrappedSOLMint,
                owner: payer
            )
        )

        cleanupInstructions.append(
            TokenProgram.closeAccountInstruction(
                account: newAccount.publicKey,
                destination: payer,
                owner: payer
            )
        )

        signers.append(newAccount)

        return newAccount
    }

    private func createAccountByMint(
        owner: PublicKey,
        mint: PublicKey,
        instructions: inout [TransactionInstruction],
        cleanupInstructions: inout [TransactionInstruction],
        signers: inout [Account],
        minimumBalanceForRentExemption: UInt64
    ) throws -> Account {
        let newAccount = try Account(network: endpoint.network)

        instructions.append(
            SystemProgram.createAccountInstruction(
                from: owner,
                toNewPubkey: newAccount.publicKey,
                lamports: minimumBalanceForRentExemption
            )
        )

        instructions.append(
            TokenProgram.initializeAccountInstruction(
                account: newAccount.publicKey,
                mint: mint,
                owner: owner
            )
        )

        if mint == .wrappedSOLMint {
            cleanupInstructions.append(
                TokenProgram.closeAccountInstruction(
                    account: newAccount.publicKey,
                    destination: owner,
                    owner: owner
                )
            )
        }

        signers.append(newAccount)
        return newAccount
    }
}
