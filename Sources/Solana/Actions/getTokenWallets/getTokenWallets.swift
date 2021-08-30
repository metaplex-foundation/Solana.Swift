import Foundation

extension Action {
    public func getTokenWallets(account: String? = nil, onComplete: @escaping ((Result<[Wallet], Error>) -> Void)) {

        guard let account = try? account ?? auth.account.get().publicKey.base58EncodedString else {
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

        ContResult.init { cb in
            self.api.getProgramAccounts(
                publicKey: PublicKey.tokenProgramId.base58EncodedString,
                configs: configs,
                decodedTo: AccountInfo.self
            ) { cb($0) }
        }.map { accounts in
            let accountsValues = accounts.compactMap { $0.account.data.value != nil ? $0: nil }
            let pubkeyValue = accountsValues.map { ($0.pubkey, $0.account.data.value!) }
            let wallets = pubkeyValue.map { (pubkey, accountInfo) -> Wallet in
                let mintAddress = accountInfo.mint.base58EncodedString
                let token = self.supportedTokens.first(where: {$0.address == mintAddress}) ?? nil
                return Wallet(pubkey: pubkey, lamports: accountInfo.lamports, token: token, liquidity: false)
            }
            return wallets
        }.run(onComplete)
    }
}

extension ActionTemplates {
    public struct GetTokenWallets: ActionTemplate {
        public init(account: String? = nil) {
            self.account = account
        }

        public typealias Success = [Wallet]
        public let account: String?

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<[Wallet], Error>) -> Void) {
            actionClass.getTokenWallets(account: account, onComplete: completion)
        }
    }
}
