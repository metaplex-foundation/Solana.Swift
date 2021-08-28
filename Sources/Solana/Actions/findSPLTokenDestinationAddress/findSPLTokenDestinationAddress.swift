import Foundation

extension Action {
    public typealias SPLTokenDestinationAddress = (destination: PublicKey, isUnregisteredAsocciatedToken: Bool)
    public func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String,
        onComplete: @escaping (Result<SPLTokenDestinationAddress, Error>) -> Void
    ) {

        ContResult<BufferInfo<AccountInfo>, Error>.init { cb in
            self.api.getAccountInfo(
                account: destinationAddress,
                decodedTo: AccountInfo.self
            ) { cb($0) }
        }.flatMap { info in
            let toTokenMint = info.data.value?.mint.base58EncodedString
            var toPublicKeyString: String = ""
            if mintAddress == toTokenMint {
                // detect if destination address is already a SPLToken address
                toPublicKeyString = destinationAddress
            } else if info.owner == PublicKey.programId.base58EncodedString {
                // detect if destination address is a SOL address
                guard let owner = PublicKey(string: destinationAddress) else {
                    return .failure(SolanaError.invalidPublicKey)
                }
                guard let tokenMint = PublicKey(string: mintAddress) else {
                    return .failure(SolanaError.invalidPublicKey)
                }

                // create associated token address
                guard case let .success(address) = PublicKey.associatedTokenAddress(
                    walletAddress: owner,
                    tokenMintAddress: tokenMint
                ) else {
                    return .failure(SolanaError.invalidPublicKey)
                }

                toPublicKeyString = address.base58EncodedString
            }

            guard let toPublicKey = PublicKey(string: toPublicKeyString) else {
                return .failure(SolanaError.invalidPublicKey)
            }

            if destinationAddress != toPublicKey.base58EncodedString {
                // check if associated address is already registered
                return ContResult.init { cb in
                    self.api.getAccountInfo(
                        account: toPublicKey.base58EncodedString,
                        decodedTo: AccountInfo.self
                    ) { cb($0)}
                }.flatMap { info1 in
                    var isUnregisteredAsocciatedToken = true
                    // if associated token account has been registered
                    if info1.owner == PublicKey.tokenProgramId.base58EncodedString &&
                        info.data.value != nil {
                        isUnregisteredAsocciatedToken = false
                    }
                    return .success((destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken))
                }
            } else {
                return .success((destination: toPublicKey, isUnregisteredAsocciatedToken: false))
            }
        }.run(onComplete)
    }
}

extension ActionTemplates {
    public struct FindSPLTokenDestinationAddress: ActionTemplate {
        public init(mintAddress: String, destinationAddress: String) {
            self.mintAddress = mintAddress
            self.destinationAddress = destinationAddress
        }

        public typealias Success = Action.SPLTokenDestinationAddress
        public let mintAddress: String
        public let destinationAddress: String

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<Action.SPLTokenDestinationAddress, Error>) -> Void) {
            actionClass.findSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destinationAddress, onComplete: completion)
        }
    }
}
