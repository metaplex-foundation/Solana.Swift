//
//  createAssosiatedTokenAccount+SimpleLock.swift
//  
//
//  Created by Dezork
//

import Foundation
import Solana

extension Action {
    public func getOrCreateAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey
    ) -> Result<(transactionId: TransactionID?, associatedTokenAddress: PublicKey), Error>? {
        var info: Result<(transactionId: TransactionID?, associatedTokenAddress: PublicKey), Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getOrCreateAssociatedTokenAccount(owner: owner, tokenMint: tokenMint) {
                info = $0
                lock.stop()
            }
        }
        lock.run()
        return info
    }

    public func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: Account? = nil
    ) -> Result<TransactionID, Error>? {
        var transactionId: Result<TransactionID, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.createAssociatedTokenAccount(for: owner, tokenMint: tokenMint, payer: payer) {
                transactionId = $0
                lock.stop()
            }
        }
        lock.run()
        return transactionId
    }
}

