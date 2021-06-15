import Foundation
import RxSwift

extension Solana {
    public func sendSPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(SolanaError.unauthorized)
        }
        
        return findSPLTokenDestinationAddress(
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
        }
    }
}
