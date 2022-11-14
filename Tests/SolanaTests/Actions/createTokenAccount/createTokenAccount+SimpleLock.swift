//
//  createTokenAccount+SimpleLock.swift
//  
//
//  Created by Dezork
//
import Foundation
import Solana

extension Action {
    public func createTokenAccount(
        mintAddress: String,
        payer: Signer
    ) -> Result<(signature: String, newPubkey: String), Error>? {
        var transactionResult: Result<(signature: String, newPubkey: String), Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch {
            self.createTokenAccount(mintAddress: mintAddress, payer: payer) {
                transactionResult = $0
                lock.stop()
            }
        }
        lock.run()
        return transactionResult!
    }
}
