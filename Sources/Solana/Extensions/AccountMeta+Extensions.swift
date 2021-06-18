import Foundation

extension Array where Element == Solana.Account.Meta {
    func index(ofElementWithPublicKey publicKey: Solana.PublicKey) -> Result<Int, Error> {
        guard let index = firstIndex(where: {$0.publicKey == publicKey}) else {
            return .failure( Solana.SolanaError.other("Could not found accountIndex"))}
        return .success(index)
    }
}
