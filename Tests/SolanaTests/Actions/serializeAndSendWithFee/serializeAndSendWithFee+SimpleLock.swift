//
//  serializeAndSendWithFee+SimpleLock.swift
//
//  Created by Dezork
//

import Foundation
import Solana

extension Action {
    func serializeAndSendWithFee(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0
    ) -> Result<String, Error>? {
        var transaction: Result<String, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.serializeAndSendWithFee(instructions: instructions,
                                          recentBlockhash: recentBlockhash,
                                          signers: signers,
                                          maxAttemps: maxAttemps,
                                          numberOfTries: numberOfTries) {
                transaction = $0
                lock.stop()
            }
        }
        lock.run()
        return transaction
    }
    
    func serializeAndSendWithFeeSimulation(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0
    ) -> Result<String, Error>? {
        var transaction: Result<String, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.serializeAndSendWithFeeSimulation(instructions: instructions,
                                                    recentBlockhash: recentBlockhash,
                                                    signers: signers,
                                                    maxAttemps: maxAttemps,
                                                    numberOfTries: numberOfTries) {
                transaction = $0
                lock.stop()
            }
        }
        lock.run()
        return transaction
    }
}
