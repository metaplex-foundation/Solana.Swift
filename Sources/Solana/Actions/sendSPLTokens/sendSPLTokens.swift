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
                
                guard let fromPublicKey = try? PublicKey(string: fromPublicKey) else {
                    onComplete(.failure( SolanaError.invalidPublicKey))
                    return
                }
                var instructions = [TransactionInstruction]()
                
                // create associated token address
                if isUnregisteredAsocciatedToken {
                    guard let mint = try? PublicKey(string: mintAddress) else {
                        onComplete(.failure(SolanaError.invalidPublicKey))
                        return
                    }
                    guard let owner = try? PublicKey(string: destinationAddress) else {
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
        
        /*return findSPLTokenDestinationAddress(
            mintAddress: mintAddress,
            destinationAddress: destinationAddress
        )
        .flatMap {result in
            // get address
            let toPublicKey = result.destination
            
            // catch error
            if fromPublicKey == toPublicKey.base58EncodedString {
                throw SolanaError.other("You can not send tokens to yourself")
            }
            
            let fromPublicKey = try PublicKey(string: fromPublicKey)
            
            var instructions = [TransactionInstruction]()
            
            // create associated token address
            if result.isUnregisteredAsocciatedToken {
                let mint = try PublicKey(string: mintAddress)
                let owner = try PublicKey(string: destinationAddress)
                
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
            
            return self.serializeAndSendWithFee(instructions: instructions, signers: [account])
        }
        .catch {error in
            var error = error
            if error.localizedDescription == "Invalid param: WrongSize" {
                error = SolanaError.other("Wrong wallet address")
            }
            throw error
        }*/
    }
}
