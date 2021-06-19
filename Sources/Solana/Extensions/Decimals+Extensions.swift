import Foundation

extension Decimals {
    static var SOL: Decimals { 9 }
}

extension Solana {
    public var solDecimals: Decimals {
        supportedTokens.first(where: {$0.symbol == "SOL"})?.decimals ?? 9
    }
}
