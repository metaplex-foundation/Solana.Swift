import Foundation
import RxSwift
import Solana

public extension NetworkingRouter {
    func request<T: Decodable>(
        method: HTTPMethod = .post,
        bcMethod: String = #function,
        parameters: [Encodable?] = []
    ) -> Single<T> {
        return Single.create { emitter in
            self.request(method: method, bcMethod: bcMethod, parameters: parameters) { (result: Result<T, Error>) in
                switch result {
                case .success(let r):
                    emitter(.success(r))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
