import Foundation
import RxSwift

private let swapProgramId = "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8"
extension Solana {
    
    /*public func swap(
        account: Account? = nil,
        pool: Pool? = nil,
        source: PublicKey,
        sourceMint: PublicKey,
        destination: PublicKey? = nil,
        destinationMint: PublicKey,
        slippage: Double,
        amount: UInt64
    ) -> Single<SwapResponse> {
        // verify account
        guard let owner = account ?? accountStorage.account
        else {return .error(SolanaError.unauthorized)}
        
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
                    throw SolanaError.other("Unsupported swapping tokens")
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
                      let _ = UInt64(pool.tokenBBalance?.amount ?? "")
                else {return .error(SolanaError.other("Swap pool is not valid"))}
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
                var newWalletPubkey: String?
                
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
                    newWalletPubkey = destination?.base58EncodedString
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
                        swapProgramId: try PublicKey(string: swapProgramId),
                        tokenProgramId: .tokenProgramId,
                        amountIn: amount,
                        minimumAmountOut: minAmountIn
                    )
                )
                
                return self.serializeAndSendWithFee(
                    instructions: instructions + cleanupInstructions,
                    signers: signers
                )
                .map {.init(transactionId: $0, newWalletPubkey: newWalletPubkey)}
            }
    }*/
    
    private func getAccountInfoData(account: String, tokenProgramId: PublicKey) -> Single<AccountInfo> {
        Single.create { emitter in
            self.getAccountInfoData(account: account, tokenProgramId: tokenProgramId) {
                switch $0 {
                case .success(let accountInfo):
                    emitter(.success(accountInfo))
                    return
                case .failure(let error):
                    emitter(.failure(error))
                    return
                }
            }
            return Disposables.create()
        }
    }
}
