import Foundation

extension Action {
    public func getTokenWallets(account: PublicKey, onComplete: @escaping ((Result<[Wallet], Error>) -> Void)) {

        let memcmp = EncodableWrapper(
            wrapped:
                ["offset": EncodableWrapper(wrapped: 32),
                 "bytes": EncodableWrapper(wrapped: account)]
        )

        let configs = RequestConfiguration(commitment: "recent", encoding: "base64", dataSlice: nil, filters: [
            ["memcmp": memcmp],
            ["dataSize": .init(wrapped: 165)]
        ])

        ContResult.init { cb in
            self.api.getProgramAccounts(
                publicKey: PublicKey.tokenProgramId,
                configs: configs,
                decodedTo: AccountInfo.self
            ) { cb($0) }
        }.map { accounts in
            let accountsValues = accounts.compactMap { $0.account.data.value != nil ? $0: nil }
            let pubkeyValue = accountsValues.map { ($0.pubkey, $0.account.data.value!) }
            let wallets = pubkeyValue.map { (pubkey, accountInfo) -> Wallet in
                let mintAddress = accountInfo.mint.base58EncodedString
                let token = self.supportedTokens.first(where: {$0.address == mintAddress}) ?? .unsupported(mint: mintAddress)
                return Wallet(pubkey: pubkey, lamports: accountInfo.lamports, token: token, liquidity: false)
            }
            return wallets
        }.run(onComplete)
    }
}
