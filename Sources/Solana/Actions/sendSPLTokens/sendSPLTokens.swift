import Foundation

extension Solana {
    public func sendSPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        onComplete: @escaping (Result<TransactionID, Error>) -> ()
    ) {
        guard let account = self.accountStorage.account else {
            return onComplete(.failure(SolanaError.unauthorized))
        }
        
        findSPLTokenDestinationAddress(
            mintAddress: mintAddress,
            destinationAddress: destinationAddress
        ) { splTokeenAddressResult in
            switch splTokeenAddressResult {
            case .success((let destination, let isUnregisteredAsocciatedToken)):
                let toPublicKey = destination
                
                // catch error
                guard fromPublicKey != toPublicKey.base58EncodedString else {
                    onComplete(.failure(SolanaError.invalidPublicKey))
                    return
                }
                
                guard let fromPublicKey = PublicKey(string: fromPublicKey) else {
                    onComplete(.failure( SolanaError.invalidPublicKey))
                    return
                }
                var instructions = [TransactionInstruction]()
                
                // create associated token address
                if isUnregisteredAsocciatedToken {
                    guard let mint = PublicKey(string: mintAddress) else {
                        onComplete(.failure(SolanaError.invalidPublicKey))
                        return
                    }
                    guard let owner = PublicKey(string: destinationAddress) else {
                        onComplete(.failure(SolanaError.invalidPublicKey))
                        return
                    }
                    
                    let createATokenInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                        mint: mint,
                        associatedAccount: toPublicKey,
                        owner: owner,
                        payer: account.publicKey
                    )
                    instructions.append(createATokenInstruction)
                }
                
                // send instruction
                let sendInstruction = TokenProgram.transferInstruction(
                    tokenProgramId: .tokenProgramId,
                    source: fromPublicKey,
                    destination: toPublicKey,
                    owner: account.publicKey,
                    amount: amount
                )
                
                instructions.append(sendInstruction)
                
                self.serializeAndSendWithFee(instructions: instructions, signers: [account]) { transactionResult in
                    switch transactionResult {
                    case .success(let transaction):
                        onComplete(.success(transaction))
                    case .failure(let error):
                        onComplete(.failure(error))
                    }
                }
                
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }
}
