import Foundation

public extension Api {
    func getProgramAccounts<T: BufferLayout>(
        publicKey: PublicKey,
        configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"),
        decodedTo: T.Type,
        onComplete: @escaping (Result<[ProgramAccount<T>], Error>) -> Void
    ) {
        router.request(parameters: [publicKey, configs]) { (result: Result<[ProgramAccount<T>], Error>) in
            switch result {
            case .success(let programs):
                onComplete(.success(programs))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
