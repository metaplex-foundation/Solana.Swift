import Foundation
import RxSwift

private var mintDatasCache = [Solana.Mint]()
private let swapProgramId = "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8"
extension Solana {
    struct ParsedSwapInfo: Codable {
        let address: String
        let info: TokenSwapInfo
        var mintDatas: ParsedSwapInfoMintDatas?
    }
    
    struct ParsedSwapInfoMintDatas: Codable {
        var mintA: Mint?
        var mintB: Mint?
        var tokenPool: Mint?
    }
    
    public func getSwapPools() -> Single<[Pool]> {
        getPools(swapProgramId: swapProgramId)
            .map {
                $0.filter {
                    $0.tokenABalance?.amountInUInt64 != 0 &&
                        $0.tokenBBalance?.amountInUInt64 != 0
                }
            }
    }
    
    func getPools(swapProgramId: String) -> Single<[Pool]> {
        getProgramAccounts(publicKey: swapProgramId, decodedTo: TokenSwapInfo.self)
            .flatMap { programs -> Single<[ParsedSwapInfo]> in
                
                // get parsed swap info
                let result = programs.compactMap {program -> ParsedSwapInfo? in
                    guard let swapData = program.account.data.value else {
                        return nil
                    }
                    guard swapData.mintA.base58EncodedString != "11111111111111111111111111111111",
                          swapData.mintB.base58EncodedString != "11111111111111111111111111111111",
                          swapData.tokenPool.base58EncodedString != "11111111111111111111111111111111"
                    else { return nil }
                    return ParsedSwapInfo(address: program.pubkey, info: swapData)
                }
                
                // get all mint addresses
                let mintAddresses = result.reduce([PublicKey](), {
                    var result = $0
                    if !result.contains($1.info.mintA) {
                        result.append($1.info.mintA)
                    }
                    if !result.contains($1.info.mintB) {
                        result.append($1.info.mintB)
                    }
                    if !result.contains($1.info.tokenPool) {
                        result.append($1.info.tokenPool)
                    }
                    return result
                })
                
                // split array to form multiple requests (max address per request is 100)
                let requestChunks = mintAddresses.chunked(into: 100)
                    .map {self.getMultipleMintDatas(mintAddresses: $0)}
                
                return Single.zip(requestChunks)
                    .map {results -> [PublicKey: Mint] in
                        var joinedResult = [PublicKey: Mint]()
                        for result in results {
                            for (key, value) in result {
                                joinedResult[key] = value
                            }
                        }
                        return joinedResult
                    }
                    .map {mintDatas in
                        var parsedInfo = result
                        for i in 0..<parsedInfo.count {
                            let swapInfo = parsedInfo[i].info
                            parsedInfo[i].mintDatas = .init(
                                mintA: mintDatas[swapInfo.mintA],
                                mintB: mintDatas[swapInfo.mintB],
                                tokenPool: mintDatas[swapInfo.tokenPool]
                            )
                        }
                        return parsedInfo
                    }
                
            }
            .map { parsedSwapInfos in
                parsedSwapInfos.map {self.getPool(parsedSwapInfo: $0)}
                    .compactMap {$0}
            }
    }
    
    private func getPool(parsedSwapInfo: ParsedSwapInfo) -> Pool? {
        guard let address = try? PublicKey(string: parsedSwapInfo.address),
              let tokenAInfo = parsedSwapInfo.mintDatas?.mintA,
              let tokenBInfo = parsedSwapInfo.mintDatas?.mintB,
              let poolTokenMintInfo = parsedSwapInfo.mintDatas?.tokenPool
        else {return nil}
        return Pool(
            address: address,
            tokenAInfo: tokenAInfo,
            tokenBInfo: tokenBInfo,
            poolTokenMint: poolTokenMintInfo,
            swapData: parsedSwapInfo.info
        )
    }
    
    public func getPoolWithTokenBalances(pool: Pool) -> Single<Pool> {
        Single.zip(
            getTokenAccountBalance(pubkey: pool.swapData.tokenAccountA.base58EncodedString),
            getTokenAccountBalance(pubkey: pool.swapData.tokenAccountB.base58EncodedString)
        )
        .map { (tokenABalance, tokenBBalance) in
            var pool = pool
            pool.tokenABalance = tokenABalance
            pool.tokenBBalance = tokenBBalance
            return pool
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
