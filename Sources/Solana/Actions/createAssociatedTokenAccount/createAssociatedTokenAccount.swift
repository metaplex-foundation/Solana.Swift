import Foundation
import RxSwift

extension Action {

    public func getOrCreateAssociatedTokenAccount(
        owner: PublicKey,
        tokenMint: PublicKey,
        onComplete: @escaping (Result<(transactionId: TransactionID?, associatedTokenAddress: PublicKey), Error>) -> Void
    ) {
        guard case let .success(associatedAddress) = PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: tokenMint
        ) else {
            onComplete(.failure(SolanaError.other("Could not create associated token account")))
            return
        }

        api.getAccountInfo(
            account: associatedAddress.base58EncodedString,
            decodedTo: AccountInfo.self
        ) { acountInfoResult in
            switch acountInfoResult {
            case .success(let info):
                if info.owner == PublicKey.tokenProgramId.base58EncodedString &&
                    info.data.value != nil {
                    onComplete(.success((transactionId: nil, associatedTokenAddress: associatedAddress)))
                    return
                }
                self.createAssociatedTokenAccount(
                    for: owner,
                    tokenMint: tokenMint
                ) { createAssociatedResult in
                    switch createAssociatedResult {
                    case .success(let transactionId):
                        onComplete(.success((transactionId: transactionId, associatedTokenAddress: associatedAddress)))
                        return
                    case .failure(let error):
                        onComplete(.failure(error))
                        return
                    }
                }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }

    public func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: Account? = nil,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        // get account
        guard let payer = try? payer ?? auth.account.get() else {
            return onComplete(.failure(SolanaError.unauthorized))
        }

        guard case let .success(associatedAddress) = PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint
            ) else {
                onComplete(.failure(SolanaError.other("Could not create associated token account")))
                return
            }

            // create instruction
            let instruction = AssociatedTokenProgram
                .createAssociatedTokenAccountInstruction(
                    mint: tokenMint,
                    associatedAccount: associatedAddress,
                    owner: owner,
                    payer: payer.publicKey
                )

            // send transaction
            serializeAndSendWithFee(
                instructions: [instruction],
                signers: [payer]
            ) { serializeResult in
                switch serializeResult {
                case .success(let reesult):
                    onComplete(.success(reesult))
                case .failure(let error):
                    onComplete(.failure(error))
                    return
                }
            }
    }
}
