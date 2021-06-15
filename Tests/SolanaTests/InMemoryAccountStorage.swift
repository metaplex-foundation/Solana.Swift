import Foundation
@testable import Solana

extension Solana.Network {
    var testAccount: String {
        switch self {
        case .mainnetBeta:
            return "promote ignore inmate coast excess candy vanish erosion palm oxygen build powder"
        case .devnet:
            return "siege amazing camp income refuse struggle feed kingdom lawn champion velvet crystal stomach trend hen uncover roast nasty until hidden crumble city bag minute"
        default:
            fatalError("unsupported")
        }
    }
}

class InMemoryAccountStorage: SolanaAccountStorage {
    private var _account: Solana.Account?
    func save(_ account: Solana.Account) throws {
        _account = account
    }
    var account: Solana.Account? {
        _account
    }
    func clear() {
        _account = nil
    }
}
