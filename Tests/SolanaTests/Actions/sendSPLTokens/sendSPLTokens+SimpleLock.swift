//
//  sendSPLTokens+SimpleLock.swift
//  
//
//  Created by Dezork
//

import Foundation
import Solana

extension Api {
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) -> Result<String, Error>? {
        var airdrop: Result<String, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.requestAirdrop(account: account, lamports: lamports, commitment: commitment) {
                airdrop = $0
                lock.stop()
            }
        }
        lock.run()
        return airdrop
    }
}

extension Action {
    public func sendSPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64
    ) -> Result<TransactionID, Error>? {
        var transaction: Result<TransactionID, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.sendSPLTokens(mintAddress: mintAddress,
                                from: fromPublicKey,
                                to: destinationAddress,
                                amount: amount) {
                transaction = $0
                lock.stop()
            }
        }
        lock.run()
        return transaction
    }
}
