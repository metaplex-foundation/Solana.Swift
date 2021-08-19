//
//  getMintData+SimpleLock.swift
//  
//
//  Created by Dezork
//

import Foundation
import Solana

extension Action {

    func getMintData(mintAddress: PublicKey, programId: PublicKey = .tokenProgramId) -> Result<Mint, Error>? {
        var mintResult: Result<Mint, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getMintData(mintAddress: mintAddress, programId: programId) { result in
                switch result {
                case .success(let mint):
                    mintResult = .success(mint)
                case .failure(let error):
                    mintResult = .failure(error)
                }
                lock.stop()
            }
        }
        lock.run()
        return mintResult
    }

    func getMultipleMintDatas(mintAddresses: [PublicKey], programId: PublicKey = .tokenProgramId) -> Result<[PublicKey: Mint], Error>? {
        var mintResult: Result<[PublicKey: Mint], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getMultipleMintDatas(mintAddresses: mintAddresses, programId: programId) { result in
                switch result {
                case .success(let mint):
                    mintResult = .success(mint)
                case .failure(let error):
                    mintResult = .failure(error)
                }
                lock.stop()
            }
        }
        lock.run()
        return mintResult
    }

    func getSwapPools() -> Result<[Pool], Error>? {
        var resultPools: Result<[Pool], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getPools(swapProgramId: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8") { result in
                switch result {
                case .success(let pools):
                    resultPools = .success(pools)
                case .failure(let error):
                    resultPools = .failure(error)
                }
                lock.stop()
            }
        }
        lock.run()
        return resultPools
    }
}
