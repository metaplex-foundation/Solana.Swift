import Foundation

public struct Pool: Hashable, Codable {
    public let address: PublicKey
    public var tokenAInfo: Mint
    public var tokenBInfo: Mint
    public let poolTokenMint: Mint
    public var swapData: TokenSwapInfo
    public var tokenABalance: TokenAccountBalance?
    public var tokenBBalance: TokenAccountBalance?

    public var authority: PublicKey? {
        poolTokenMint.mintAuthority
    }

    // MARK: - Calculations
    public func estimatedAmount(
        forInputAmount inputAmount: Lamports,
        includeFees: Bool
    ) -> Lamports? {
        guard let tokenABalance = tokenABalance?.amountInUInt64,
              let tokenBBalance = tokenBBalance?.amountInUInt64
        else {return nil}

        let i = BInt(inputAmount)

        let b = BInt(tokenBBalance)
        let a = BInt(tokenABalance)
        let d = BInt(swapData.tradeFeeDenominator)
        let n = includeFees ? BInt(swapData.tradeFeeNumerator) : 0

        let numerator = b * i * (d - n)
        let denominator = (a + i) * d

        if denominator == 0 {
            return nil
        }

        return Lamports(numerator / denominator)
    }

    public func inputAmount(
        forEstimatedAmount estimatedAmount: Lamports,
        includeFees: Bool
    ) -> Lamports? {
        guard let tokenABalance = tokenABalance?.amountInUInt64,
              let tokenBBalance = tokenBBalance?.amountInUInt64
        else {return nil}

        let e = BInt(estimatedAmount)

        let b = BInt(tokenBBalance)
        let a = BInt(tokenABalance)
        let d = BInt(swapData.tradeFeeDenominator)
        let n = includeFees ? BInt(swapData.tradeFeeNumerator) : 0

        let numerator = e * a * d
        let denominator = b * (d - n) - e * d

        return Lamports(numerator / denominator)
    }

    public func minimumReceiveAmount(
        estimatedAmount: Lamports,
        slippage: Double
    ) -> Lamports {
        Lamports(Float64(estimatedAmount) * Float64(1 - slippage))
    }

    public func fee(forInputAmount inputAmount: UInt64) -> Double? {
        guard let tokenABalance = tokenABalance?.amountInUInt64,
              let tokenBBalance = tokenBBalance?.amountInUInt64
        else {return nil}

        let i = BInt(inputAmount)

        let b = BInt(tokenBBalance)
        let a = BInt(tokenABalance)
        let d = BInt(swapData.tradeFeeDenominator)
        let n = BInt(swapData.tradeFeeNumerator)

        let numerator = b * i * n
        let denominator = (a + i) * d

        if denominator == 0 {
            return nil
        }

        return Lamports(numerator / denominator).convertToBalance(decimals: tokenBInfo.decimals)
    }

    // MARK: - Helpers
    var reversedPool: Pool {
        var pool = self
        Swift.swap(&pool.swapData.tokenAccountA, &pool.swapData.tokenAccountB)
        Swift.swap(&pool.swapData.mintA, &pool.swapData.mintB)
        Swift.swap(&pool.tokenABalance, &pool.tokenBBalance)
        Swift.swap(&pool.tokenAInfo, &pool.tokenBInfo)
        return pool
    }
}

extension Array where Element == Pool {
    public func matchedPool(sourceMint: String?, destinationMint: String?) -> Pool? {
        first(where: {
            ($0.swapData.mintA.base58EncodedString == sourceMint && $0.swapData.mintB.base58EncodedString == destinationMint) ||
                ($0.swapData.mintB.base58EncodedString == sourceMint && $0.swapData.mintA.base58EncodedString == destinationMint)
        })
        .map { pool in
            if pool.swapData.mintB.base58EncodedString == sourceMint && pool.swapData.mintA.base58EncodedString == destinationMint {
                return pool.reversedPool
            }
            return pool
        }
    }
}
