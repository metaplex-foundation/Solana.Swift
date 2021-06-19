import Foundation

extension Array where Element == Account.Meta {
    func index(ofElementWithPublicKey publicKey: PublicKey) -> Result<Int, Error> {
        guard let index = firstIndex(where: {$0.publicKey == publicKey}) else {
            return .failure( SolanaError.other("Could not found accountIndex"))}
        return .success(index)
    }
}
