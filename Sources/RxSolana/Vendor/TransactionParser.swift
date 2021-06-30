import Foundation
import RxSwift
import Solana


extension TransactionParser {
    
    // MARK: - Methods
    public func parse(
        transactionInfo: TransactionInfo,
        myAccount: PublicKey?,
        myAccountSymbol: String?
    ) -> Single<AnyTransaction> {
        Single.create { emitter in
            self.parse(transactionInfo: transactionInfo, myAccount: myAccount, myAccountSymbol: myAccountSymbol) {
                switch $0 {
                case .success(let transaction):
                    emitter(.success(transaction))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

