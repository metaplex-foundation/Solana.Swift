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
        mintAddress: String
    ) -> Result<(signature: String, newPubkey: String), Error>? {
        var transactionResult: Result<(signature: String, newPubkey: String), Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch {
            self.createTokenAccount(mintAddress: mintAddress) {
                switch $0 {
                case .success(let transaction):
                    transactionResult = .success(transaction)
                case .failure(let error):
                    transactionResult = .failure(error)
                }
                lock.stop()
            }
        }
        lock.run()
        return transactionResult!
    }
}
