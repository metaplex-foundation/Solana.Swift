import Foundation
import RxSwift

extension Solana {
    public func getOrCreateAssociatedTokenAccount(
        owner: PublicKey,
        tokenMint: PublicKey
    ) -> Single<(transactionId: TransactionID?, associatedTokenAddress: PublicKey)> {
        guard let associatedAddress = try? PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: tokenMint
        ) else {
            return .error(SolanaError.other("Could not create associated token account"))
        }
        
        // check if token account exists
        return getAccountInfo(
            account: associatedAddress.base58EncodedString,
            decodedTo: AccountInfo.self
        )
        .map {$0 as BufferInfo<AccountInfo>?}
        .catchAndReturn(nil)
        .flatMap {info in
            // if associated token account has been created
            if info?.owner == PublicKey.tokenProgramId.base58EncodedString &&
                info?.data.value != nil {
                return .just((transactionId: nil, associatedTokenAddress: associatedAddress))
            }
            
            // if not, create one
            return self.createAssociatedTokenAccount(
                for: owner,
                tokenMint: tokenMint
            ).map {(transactionId: $0, associatedTokenAddress: associatedAddress)}
        }
    }
    
    func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: Account? = nil
    ) -> Single<TransactionID> {
        // get account
        guard let payer = payer ?? accountStorage.account else {
            return .error(SolanaError.unauthorized)
        }
        
        // generate address
        do {
            let associatedAddress = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint
            )
            
            // create instruction
            let instruction = AssociatedTokenProgram
                .createAssociatedTokenAccountInstruction(
                    mint: tokenMint,
                    associatedAccount: associatedAddress,
                    owner: owner,
                    payer: payer.publicKey
                )
            
            // send transaction
            return serializeAndSendWithFee(
                instructions: [instruction],
                signers: [payer]
            )
        } catch {
            return .error(error)
        }
    }
}
