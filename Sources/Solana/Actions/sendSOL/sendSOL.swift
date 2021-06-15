import Foundation
import RxSwift

extension Solana {
    public typealias SPLTokenDestinationAddress = (destination: PublicKey, isUnregisteredAsocciatedToken: Bool)
    public func sendSOL(
        to destination: String,
        amount: UInt64
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(SolanaError.unauthorized)
        }
        
        do {
            let fromPublicKey = account.publicKey
            
            if fromPublicKey.base58EncodedString == destination {
                throw SolanaError.other("You can not send tokens to yourself")
            }
            
            // check
            return getAccountInfo(account: destination, decodedTo: EmptyInfo.self)
                .map {info -> Void in
                    guard info.owner == PublicKey.programId.base58EncodedString
                    else {throw SolanaError.other("Invalid account info")}
                    return
                }
                .catch { error in
                    if let solanaError = error as? SolanaError,
                       case SolanaError.couldNotRetriveAccountInfo = solanaError {
                        // let request through
                        return .just(())
                    }
                    throw error
                }
                .flatMap {
                    
                    // transaction with fee, can be a simulation
                    let instruction = SystemProgram.transferInstruction(
                        from: fromPublicKey,
                        to: try PublicKey(string: destination),
                        lamports: amount
                    )
                    
                    return self.serializeAndSendWithFee(
                        instructions: [instruction],
                        signers: [account]
                    )
                }
                .catch {error in
                    var error = error
                    if error.localizedDescription == "Invalid param: WrongSize" {
                        error = SolanaError.other("Wrong wallet address")
                    }
                    throw error
                }
        } catch {
            return .error(error)
        }
    }
}
