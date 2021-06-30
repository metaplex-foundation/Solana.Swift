import Foundation
import RxSwift

extension Action {
    public typealias SPLTokenDestinationAddress = (destination: PublicKey, isUnregisteredAsocciatedToken: Bool)
    public func findSPLTokenDestinationAddress(
        mintAddress: PublicKey,
        destinationAddress: PublicKey,
        onComplete: @escaping (Result<SPLTokenDestinationAddress, Error>) -> Void
    ) {

        ContResult<BufferInfo<AccountInfo>, Error>.init { cb in
            self.api.getAccountInfo(
                account: destinationAddress,
                decodedTo: AccountInfo.self
            ) { cb($0) }
        }.flatMap { info in
            let toTokenMint = info.data.value?.mint.base58EncodedString
            var toPublicKeyTemp: PublicKey? = nil
            if mintAddress.base58EncodedString == toTokenMint {
                // detect if destination address is already a SPLToken address
                toPublicKeyTemp = destinationAddress
            } else if info.owner == PublicKey.programId.base58EncodedString {
                // detect if destination address is a SOL address
                let owner = destinationAddress
                let tokenMint = mintAddress

                // create associated token address
                guard case let .success(address) = PublicKey.associatedTokenAddress(
                    walletAddress: owner,
                    tokenMintAddress: tokenMint
                ) else {
                    return .failure(SolanaError.invalidPublicKey)
                }

                toPublicKeyTemp = address
            }

            guard let toPublicKey = toPublicKeyTemp else {
                return .failure(SolanaError.invalidPublicKey)
            }
            
            if destinationAddress.base58EncodedString != toPublicKey.base58EncodedString {
                // check if associated address is already registered
                return ContResult.init { cb in
                    self.api.getAccountInfo(
                        account: toPublicKey,
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
