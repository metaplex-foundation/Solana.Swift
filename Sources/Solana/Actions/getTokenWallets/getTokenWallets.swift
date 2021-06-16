import Foundation

extension Solana {
    public func getTokenWallets(account: String? = nil, onComplete: @escaping ((Result<[Wallet], Error>) -> ())){
        
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString else {
            return onComplete(.failure(SolanaError.unauthorized))
        }
        
        let memcmp = EncodableWrapper(
            wrapped:
                ["offset": EncodableWrapper(wrapped: 32),
                 "bytes": EncodableWrapper(wrapped: account)]
        )
        
        let configs = RequestConfiguration(commitment: "recent", encoding: "base64", dataSlice: nil, filters: [
            ["memcmp": memcmp],
            ["dataSize": .init(wrapped: 165)]
        ])
        
        getProgramAccounts(
            publicKey: PublicKey.tokenProgramId.base58EncodedString,
            configs: configs,
            decodedTo: AccountInfo.self
        ) { result in
            switch result {
            case .success(let accounts):
                let accountsValues = accounts.compactMap { $0.account.data.value != nil ? $0: nil }
                let pubkeyValue = accountsValues.map { ($0.pubkey, $0.account.data.value!) }
                let wallets = pubkeyValue.map { (pubkey, accountInfo) -> Wallet in
                    let mintAddress = accountInfo.mint.base58EncodedString
                    let token = self.supportedTokens.first(where: {$0.address == mintAddress}) ?? .unsupported(mint: mintAddress)
                    return Wallet(pubkey: pubkey, lamports: accountInfo.lamports, token: token, liquidity: false)
                }
                onComplete(.success(wallets))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
