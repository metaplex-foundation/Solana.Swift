//
//  TranscationParser+SimpleLock.swift
//
//  Created by Dezork
//

import Foundation
import Solana

extension TransactionParser {

    func parse(
        transactionInfo: TransactionInfo,
        myAccount: String?,
        myAccountSymbol: String?
    ) -> Result<AnyTransaction, Error>? {
        var transaction: Result<AnyTransaction, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch {
            parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: myAccountSymbol) {
                transaction = $0
                lock.stop()
            }
        }
        lock.run()
        return transaction
    }
}
