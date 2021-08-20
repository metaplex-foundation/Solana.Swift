//
//  sendSOL+SimpleLock.swift
//  
//
//  Created by Dezork
//

import Foundation
import Solana

extension Api {
    func getBalance(account: String? = nil, commitment: Commitment? = nil) -> Result<UInt64, Error>? {
        var balance: Result<UInt64, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getBalance(account: account, commitment: commitment) {
                balance = $0
                lock.stop()
            }
        }
        lock.run()
        return balance
    }
}

extension Action {

    func sendSOL(
        to destination: String,
        amount: UInt64
    ) -> Result<TransactionID, Error>? {
        var transaction: Result<TransactionID, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.sendSOL(to: destination, amount: amount) {
                transaction = $0
                lock.stop()
            }
        }
        lock.run()
        return transaction
    }

}
