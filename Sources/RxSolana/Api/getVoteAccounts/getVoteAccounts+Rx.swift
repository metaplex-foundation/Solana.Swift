import Foundation
import RxSwift
import Solana

public extension Api {
    func getVoteAccounts(commitment: Commitment? = nil) ->  Single<VoteAccounts> {
        Single.create { emitter in
            self.getVoteAccounts(commitment: commitment) {
                switch $0 {
                case .success(let suply):
                    emitter(.success(suply))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
