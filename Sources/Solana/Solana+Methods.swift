import Foundation
import RxSwift

public extension Solana {

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
