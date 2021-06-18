import Foundation
import RxSwift

extension Solana {
    public func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String,
        onComplete: @escaping (Result<SPLTokenDestinationAddress, Error>) -> ()
    ) {
        
        ContResult<BufferInfo<Solana.AccountInfo>, Error>.init { cb in
            self.getAccountInfo(
                account: destinationAddress,
                decodedTo: Solana.AccountInfo.self
            ){ cb($0) }
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
                    self.getAccountInfo(
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
