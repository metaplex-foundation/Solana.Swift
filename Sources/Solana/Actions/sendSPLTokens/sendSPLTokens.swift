import Foundation

extension Action {
    public func sendSPLTokens(
        mintAddress: PublicKey,
        decimals: Decimals,
        from fromPublicKey: PublicKey,
        to destinationAddress: PublicKey,
        amount: UInt64,
        onComplete: @escaping (Result<TransactionID, Error>) -> Void
    ) {
        guard let account = try? self.auth.account.get() else {
            return onComplete(.failure(SolanaError.unauthorized))
        }

        ContResult.init { cb in
            self.findSPLTokenDestinationAddress(
                mintAddress: mintAddress,
                destinationAddress: destinationAddress
            ) { cb($0) }
        }.flatMap { (destination, isUnregisteredAsocciatedToken) in

            let toPublicKey = destination

            // catch error
            guard fromPublicKey.base58EncodedString != toPublicKey.base58EncodedString else {
                return .failure(SolanaError.invalidPublicKey)
            }

            var instructions = [TransactionInstruction]()

            // create associated token address
            if isUnregisteredAsocciatedToken {
                let mint = mintAddress
                let owner = destinationAddress

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
            return .success((instructions: instructions, account: account))

        }.flatMap { (instructions, account) in
            ContResult.init { cb in
                self.serializeAndSendWithFee(instructions: instructions, signers: [account]) {
                    cb($0)
                }
            }
        }.run(onComplete)
    }
}
