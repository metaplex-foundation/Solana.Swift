import Foundation

public extension Api {

    func getMintData(mintAddress: PublicKey, programId: PublicKey = .tokenProgramId, onComplete: @escaping ((Result<Mint, Error>) -> Void)) {
        getAccountInfo(account: mintAddress.base58EncodedString, decodedTo: Mint.self) { result in
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

    func getMultipleMintDatas(mintAddresses: [PublicKey], programId: PublicKey = .tokenProgramId, onComplete: @escaping (Result<[PublicKey: Mint], Error>) -> Void) {

        return ContResult.init { cb in
            self.getMultipleAccounts(pubkeys: mintAddresses.map { $0.base58EncodedString }, decodedTo: Mint.self) {
                cb($0)
            }
        }.flatMap {
            let account = $0
            if account.contains(where: {$0.owner != programId.base58EncodedString}) == true {
                return .failure(SolanaError.other("Invalid mint owner"))
            }

            let values = account.compactMap { $0.data.value }
            guard values.count == mintAddresses.count else {
                return .failure(SolanaError.other("Some of mint data are missing"))
            }

            var mintDict = [PublicKey: Mint]()
            for (index, address) in mintAddresses.enumerated() {
                mintDict[address] = values[index]
            }
            return .success(mintDict)
        }.run(onComplete)
    }
}
