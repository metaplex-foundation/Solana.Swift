import Foundation
import RxSwift

extension Solana {
    public func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String,
        onComplete: @escaping (Result<SPLTokenDestinationAddress, Error>) -> ()
    ) {
        getAccountInfo(
            account: destinationAddress,
            decodedTo: Solana.AccountInfo.self
        ){ getAccountInfoResult in
            switch getAccountInfoResult {
            case .success(let info):
                let toTokenMint = info.data.value?.mint.base58EncodedString

                var toPublicKeyString: String = ""
                if mintAddress == toTokenMint {
                    // detect if destination address is already a SPLToken address
                    toPublicKeyString = destinationAddress
                    
                } else if info.owner == PublicKey.programId.base58EncodedString {
                    // detect if destination address is a SOL address
                    guard let owner = try? PublicKey(string: destinationAddress) else {
                        onComplete(.failure(SolanaError.invalidRequest(reason: "XXX")))
                        return
                    }
                    guard let tokenMint = try? PublicKey(string: mintAddress) else {
                        onComplete(.failure(SolanaError.invalidRequest(reason: "XXX")))
                        return
                    }
                    
                    // create associated token address
                    guard let address = try? PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: tokenMint
                    ) else {
                        onComplete(.failure(SolanaError.invalidRequest(reason: "XXX")))
                        return
                    }
                    toPublicKeyString = address.base58EncodedString
                }
                
                guard let toPublicKey = try? PublicKey(string: toPublicKeyString) else {
                    onComplete(.failure(SolanaError.invalidRequest(reason: "XXX")))
                    return
                }
                
                if destinationAddress != toPublicKey.base58EncodedString {
                    // check if associated address is already registered
                    self.getAccountInfo(
                        account: toPublicKey.base58EncodedString,
                        decodedTo: AccountInfo.self
                    ) { accountInfoResult in
                        switch accountInfoResult {
                        case .success(let info):
                            var isUnregisteredAsocciatedToken = true
                            // if associated token account has been registered
                            if info.owner == PublicKey.tokenProgramId.base58EncodedString &&
                                info.data.value != nil {
                                isUnregisteredAsocciatedToken = false
                            }
                            onComplete(.success((destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken)))
                        case .failure(let error):
                            onComplete(.failure(error))
                        }
                    }
                } else {
                    onComplete(.success((destination: toPublicKey, isUnregisteredAsocciatedToken: false)))
                }
                
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
