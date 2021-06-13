import Foundation
import RxSwift

public extension Solana {
    func getMultipleAccounts<T: BufferLayout>(pubkeys: [String], decodedTo: T.Type) -> Single<[BufferInfo<T>]?> {
            let configs = RequestConfiguration(encoding: "base64")
            return (request(parameters: [pubkeys, configs]) as Single<Rpc<[BufferInfo<T>]?>>)
                .map {$0.value}
    }
    func getProgramAccounts<T: BufferLayout>(publicKey: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"), decodedTo: T.Type) -> Single<[ProgramAccount<T>]> {
        request(parameters: [publicKey, configs])
    }
    func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAccountBalance> {
        (request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAccountBalance>>)
            .map {
                if UInt64($0.value.amount) == nil {
                    throw SolanaError.invalidResponse(ResponseError(code: nil, message: "Could not retrieve balance", data: nil))
                }
                return $0.value
            }
    }
    func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount<AccountInfo>]> {
        (request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount<AccountInfo>]>>)
            .map {$0.value}
    }
    func getTokenAccountsByOwner(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount<AccountInfo>]> {
        (request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount<AccountInfo>]>>)
            .map {$0.value}
    }
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) -> Single<[TokenAmount]> {
        (request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<[TokenAmount]>>)
            .map {$0.value}
    }
    func getTokenSupply(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAmount> {
        (request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAmount>>)
            .map {$0.value}
    }
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
