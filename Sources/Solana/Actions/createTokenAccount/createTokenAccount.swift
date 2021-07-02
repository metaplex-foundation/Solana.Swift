import Foundation

extension Action {

    public func getCreatingTokenAccountFee(onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        self.api.getMinimumBalanceForRentExemption(dataLength: AccountInfo.BUFFER_LENGTH, onComplete: onComplete)
    }

    public func createTokenAccount(
        mintAddress: String,
        onComplete: @escaping ((Result<(signature: String, newPubkey: String), Error>) -> Void)
    ) {
        guard let payer = try? self.auth.account.get() else {
            onComplete(.failure(SolanaError.unauthorized))
            return
        }

        self.api.getRecentBlockhash { resultBlockhash in
            switch resultBlockhash {
            case .success(let recentBlockhash):
                self.callGetCreateTokenAccountFee(mintAddress: mintAddress,
                                                  payer: payer,
                                                  recentBlockhash: recentBlockhash,
                                                  onComplete: onComplete)
                return
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }

    fileprivate func callGetCreateTokenAccountFee(
        mintAddress: String,
        payer: Account,
        recentBlockhash: String,
        onComplete: @escaping ((Result<(signature: String, newPubkey: String), Error>) -> Void)
    ) {
        self.getCreatingTokenAccountFee { resultFee in
            switch resultFee {
            case .success(let minBalance):
                self.signAndSend(mintAddress: mintAddress,
                     payer: payer,
                     recentBlockhash: recentBlockhash,
                     minBalance: minBalance,
                     onComplete: onComplete
                )
                return
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }

    fileprivate func signAndSend(mintAddress: String,
                          payer: Account,
                          recentBlockhash: String,
                          minBalance: UInt64,
                          onComplete: @escaping ((Result<(signature: String, newPubkey: String), Error>) -> Void)) {

        guard let mintAddress = PublicKey(string: mintAddress) else {
            onComplete(.failure(SolanaError.unauthorized))
            return
        }
        // create new account for token
        guard let newAccount = Account(network: self.router.endpoint.network) else {
            onComplete(.failure(SolanaError.unauthorized))
            return
        }

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

        self.serializeAndSendWithFee(
            instructions: instructions,
            recentBlockhash: recentBlockhash,
            signers: [payer, newAccount]
        ) { result in
            switch result {
            case .success(let transaction):
                onComplete(.success((transaction, newAccount.publicKey.base58EncodedString)))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
