//
//  SolanaSDK+Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

extension Solana {
    public func getSwapPools() -> Single<[Pool]> {
        if let pools = _swapPool {return .just(pools)}
        return getPools(swapProgramId: endpoint.network.swapProgramId.base58EncodedString)
            .map {
                $0.filter {
                    $0.tokenABalance?.amountInUInt64 != 0 &&
                        $0.tokenBBalance?.amountInUInt64 != 0
                }
            }
            .do(onSuccess: {self._swapPool = $0})
    }

    func getPools(swapProgramId: String) -> Single<[Pool]> {
        getProgramAccounts(publicKey: swapProgramId, decodedTo: TokenSwapInfo.self)
            .map { programs -> [(address: String, swapData: TokenSwapInfo)] in
                programs.compactMap {program in
                    guard let swapData = program.account.data.value else {
                        return nil
                    }
                    guard swapData.mintA.base58EncodedString != "11111111111111111111111111111111",
                          swapData.mintB.base58EncodedString != "11111111111111111111111111111111",
                          swapData.tokenPool.base58EncodedString != "11111111111111111111111111111111"
                    else {return nil}
                    return (address: program.pubkey, swapData: swapData)
                }
            }
//            .do(onSuccess: {programs in
//                var programs = programs.map {$0.swapData}
//                Logger.log(message: String(data: try JSONEncoder().encode(programs), encoding: .utf8)!, event: .response)
//                
//            })
            .flatMap {
                Single.zip(
                    try $0.compactMap {
                        self.getPoolInfo(
                            address: try PublicKey(string: $0.address),
                            swapData: $0.swapData
                        )
                    }
                )
            }
    }

    func getPoolInfo(address: PublicKey, swapData: TokenSwapInfo) -> Single<Pool> {
        Single.zip([
            self.getMintData(mintAddress: swapData.mintA)
                .map {$0 as Any},
            self.getMintData(mintAddress: swapData.mintB)
                .map {$0 as Any},
            self.getMintData(mintAddress: swapData.tokenPool)
                .map {$0 as Any},
            self.getTokenAccountBalance(pubkey: swapData.tokenAccountA.base58EncodedString)
                .map {$0 as Any},
            self.getTokenAccountBalance(pubkey: swapData.tokenAccountB.base58EncodedString)
                .map {$0 as Any}
        ])
            .map { mintDatas in
                guard let tokenAInfo = mintDatas[0] as? Mint,
                      let tokenBInfo = mintDatas[1] as? Mint,
                      let poolTokenMint = mintDatas[2] as? Mint,
                      let tokenABalance = mintDatas[3] as? TokenAccountBalance,
                      let tokenBBalance = mintDatas[4] as? TokenAccountBalance
                else {
                    throw Error.other("Invalid pool")
                }
                return Pool(address: address, tokenAInfo: tokenAInfo, tokenBInfo: tokenBInfo, poolTokenMint: poolTokenMint, swapData: swapData, tokenABalance: tokenABalance, tokenBBalance: tokenBBalance)
            }
    }
}
