import Foundation

public struct Wallet: Hashable {
    // MARK: - Properties
    public var pubkey: String
    public var ammount: TokenAmount?
    public var token: Token?

    let liquidity: Bool?
    public var isLiquidity: Bool {
        liquidity == true
    }

    // MARK: - Initializer
    public init(pubkey: String, ammount: TokenAmount? = nil, token: Token?, liquidity: Bool? = false) {
        self.pubkey = pubkey
        self.ammount = ammount
        self.token = token
        self.liquidity = liquidity
    }

    // MARK: - Computed properties
    public var amount: Float64? {
        return ammount?.uiAmount
    }

    public func shortPubkey(numOfSymbolsRevealed: Int = 4) -> String {
        return pubkey.prefix(numOfSymbolsRevealed) + "..." + pubkey.suffix(numOfSymbolsRevealed)
    }

    // MARK: - Fabric methods
    public static func nativeSolana(
        pubkey: String,
        lamport: UInt64
    ) -> Wallet {
        let uiAmmount = Double(lamport)/pow(10, 9)
        return Wallet(
            pubkey: pubkey,
            ammount: TokenAmount(amount: "\(lamport)", decimals: 9, uiAmount: uiAmmount, uiAmountString: "\(uiAmmount)"),
            token: Token(
                _tags: [],
                chainId: 101,
                address: "So11111111111111111111111111111111111111112",
                symbol: "SOL",
                name: "Solana",
                logoURI: nil,
                tags: [],
                extensions: nil,
                isNative: true
            ),
            liquidity: false
        )
    }
}
