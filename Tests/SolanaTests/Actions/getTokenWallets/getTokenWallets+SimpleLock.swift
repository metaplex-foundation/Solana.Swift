//
//  getTokenWallets+SimpleLock.swift
//  
//
//  Created by Dezork
//

import Foundation
import Solana

extension Action {
    func getTokenWallets(account: String) -> Result<[Wallet], Error>? {
        var walletResult: Result<[Wallet], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getTokenWallets(account: account) { result in
                walletResult = result
                lock.stop()
            }
        }
        lock.run()
        return walletResult
        
    }
}
