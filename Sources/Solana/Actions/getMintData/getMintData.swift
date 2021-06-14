import Foundation
import RxSwift

public extension Solana {
    
    func getMintData(mintAddress: PublicKey, programId: PublicKey = .tokenProgramId, onComplete: @escaping ((Result<Mint, Error>) -> ())){
        getAccountInfo(account: mintAddress.base58EncodedString, decodedTo: Mint.self){ result in
            switch result {
            case .success(let account):
                if account.owner != programId.base58EncodedString {
                    onComplete(.failure(SolanaError.other("Invalid mint owner")))
                    return
                }
                if let data = account.data.value {
                    onComplete(.success(data))
                    return
                }
                onComplete(.failure(SolanaError.other("Invalid data")))
                return
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }
    
    func getMintData(mintAddress: PublicKey, programId: PublicKey = .tokenProgramId) -> Single<Mint> {
        Single.create { emitter in
            self.getMintData(mintAddress: mintAddress, programId: programId) { result in
                switch result {
                case .success(let mint):
                    return emitter(.success(mint))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func getMultipleMintDatas(mintAddresses: [PublicKey], programId: PublicKey = .tokenProgramId, onComplete: @escaping (Result<[PublicKey: Mint], Error>) -> ()){
        getMultipleAccounts(pubkeys: mintAddresses.map {$0.base58EncodedString}, decodedTo: Mint.self) { result in
            switch result {
            case .success(let account):
                if account.contains(where: {$0.owner != programId.base58EncodedString}) == true
                {
                    onComplete(.failure(SolanaError.other("Invalid mint owner")))
                    return
                }
                
                let values = account.compactMap { $0.data.value }
                guard values.count == mintAddresses.count else {
                    onComplete(.failure(SolanaError.other("Some of mint data are missing")))
                    return
                }
                
                var mintDict = [PublicKey: Mint]()
                for (index, address) in mintAddresses.enumerated() {
                    mintDict[address] = values[index]
                }
                
                onComplete(.success(mintDict))
                return
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }
    
    func getMultipleMintDatas(mintAddresses: [PublicKey], programId: PublicKey = .tokenProgramId) -> Single<[PublicKey: Mint]> {
        Single.create { emitter in
            self.getMultipleMintDatas(mintAddresses: mintAddresses, programId: programId) { result in
                switch result {
                case .success(let mint):
                    return emitter(.success(mint))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
