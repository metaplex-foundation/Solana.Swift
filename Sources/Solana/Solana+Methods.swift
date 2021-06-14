import Foundation
import RxSwift

public extension Solana {
    internal func sendTransaction(serializedTransaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionID> {
        request(parameters: [serializedTransaction, configs])
            .catch { error in
                // Modify error message
                if let error = error as? SolanaError {
                    switch error {
                    case .invalidResponse(let response) where response.message != nil:
                        var message = response.message
                        if let readableMessage = response.data?.logs
                            .first(where: {$0.contains("Error:")})?
                            .components(separatedBy: "Error: ")
                            .last {
                            message = readableMessage
                        } else if let readableMessage = response.message?
                                    .components(separatedBy: "Transaction simulation failed: ")
                                    .last {
                            message = readableMessage
                        }
                        
                        return .error(SolanaError.invalidResponse(ResponseError(code: response.code, message: message, data: response.data)))
                    default:
                        break
                    }
                }
                return .error(error)
            }
    }
    func simulateTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionStatus> {
        (request(parameters: [transaction, configs]) as Single<Rpc<TransactionStatus>>)
            .map {$0.value}
    }
    
    // MARK: - Additional methods
    func getMintData(
        mintAddress: PublicKey,
        programId: PublicKey = .tokenProgramId
    ) -> Single<Mint> {
        getAccountInfo(account: mintAddress.base58EncodedString, decodedTo: Mint.self)
            .map {
                if $0.owner != programId.base58EncodedString {
                    throw SolanaError.other("Invalid mint owner")
                }
                
                if let data = $0.data.value {
                    return data
                }
                
                throw SolanaError.other("Invalid data")
            }
    }
    
    func getMultipleMintDatas(
            mintAddresses: [PublicKey],
            programId: PublicKey = .tokenProgramId
        ) -> Single<[PublicKey: Mint]> {
            getMultipleAccounts(pubkeys: mintAddresses.map {$0.base58EncodedString}, decodedTo: Mint.self)
                .map {
                    if $0?.contains(where: {$0.owner != programId.base58EncodedString}) == true
                    {
                        throw SolanaError.other("Invalid mint owner")
                    }
                    
                    guard let result = $0?.compactMap({$0.data.value}), result.count == mintAddresses.count else {
                        throw SolanaError.other("Some of mint data are missing")
                    }
                    
                    var mintDict = [PublicKey: Mint]()
                    for (index, address) in mintAddresses.enumerated() {
                        mintDict[address] = result[index]
                    }
                    
                    return mintDict
                }
        }
}
