//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension Solana {
    /// Traditional sending without FeeRelayer
    /// - Parameters:
    ///   - instructions: transaction's instructions
    ///   - recentBlockhash: recentBlockhash
    ///   - signers: signers
    ///   - isSimulation: define if this is a simulation or real transaction
    /// - Returns: transaction id
    func serializeAndSendWithFee(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        isSimulation: Bool
    ) -> Single<String> {
        let maxAttemps = 3
        var numberOfTries = 0
        return serializeTransaction(
            instructions: instructions,
            recentBlockhash: recentBlockhash,
            signers: signers
        )
            .flatMap {
                if isSimulation {
                    return self.simulateTransaction(transaction: $0)
                        .map {result -> String in
                            if result.err != nil {
                                throw Error.other("Simulation error")
                            }
                            return "<simulated transaction id>"
                        }
                } else {
                    return self.sendTransaction(serializedTransaction: $0)
                }
            }
            .catch {error in
                if numberOfTries <= maxAttemps,
                   let error = error as? Solana.Error {
                    var shouldRetry = false
                    switch error {
                    case .other(let message) where message == "Blockhash not found":
                        shouldRetry = true
                    case .invalidResponse(let response) where response.message == "Blockhash not found":
                        shouldRetry = true
                    default:
                        break
                    }

                    if shouldRetry {
                        numberOfTries += 1
                        return self.serializeAndSendWithFee(instructions: instructions, signers: signers, isSimulation: isSimulation)
                    }
                }
                throw error
            }
    }

    private func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        feePayer: PublicKey? = nil
    ) -> Single<String> {
        // get recentBlockhash
        let getRecentBlockhashRequest: Single<String>
        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest = .just(recentBlockhash)
        } else {
            getRecentBlockhashRequest = getRecentBlockhash()
        }

        guard let feePayer = feePayer ?? accountStorage.account?.publicKey else {
            return .error(Error.invalidRequest(reason: "Fee-payer not found"))
        }

        // serialize transaction
        return getRecentBlockhashRequest
            .map {recentBlockhash -> String in
                var transaction = Transaction(
                    feePayer: feePayer,
                    instructions: instructions,
                    recentBlockhash: recentBlockhash
                )
                try transaction.sign(signers: signers)
                guard let serializedTransaction = try transaction.serialize().bytes.toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return serializedTransaction
            }
    }
}
