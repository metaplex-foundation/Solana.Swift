//
//  SolanaSDK+CreateTokenAccount.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation
import RxSwift

extension Solana {
    public func getCreatingTokenAccountFee() -> Single<UInt64> {
        getMinimumBalanceForRentExemption(dataLength: AccountInfo.span)
    }

    public func createTokenAccount(
        mintAddress: String,
        isSimulation: Bool = false
    ) -> Single<(signature: String, newPubkey: String)> {
        guard let payer = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }

        var newAccount: Account!
        return Single.zip(getRecentBlockhash(), getCreatingTokenAccountFee())
            .flatMap { (recentBlockhash, minBalance) in

                let mintAddress = try PublicKey(string: mintAddress)

                // create new account for token
                newAccount = try Account(network: self.endpoint.network)

                // instructions
                let createAccountInstruction = SystemProgram.createAccountInstruction(
                    from: payer.publicKey,
                    toNewPubkey: newAccount.publicKey,
                    lamports: minBalance
                )

                let initializeAccountInstruction = TokenProgram.initializeAccountInstruction(
                    account: newAccount.publicKey,
                    mint: mintAddress,
                    owner: payer.publicKey
                )

                // forming transaction
                let instructions = [
                    createAccountInstruction,
                    initializeAccountInstruction
                ]

                // serialize transaction
                return self.serializeAndSendWithFee(
                    instructions: instructions,
                    recentBlockhash: recentBlockhash,
                    signers: [payer, newAccount],
                    isSimulation: isSimulation
                )
                    .map {($0, newAccount.publicKey.base58EncodedString)}
            }
    }
}
