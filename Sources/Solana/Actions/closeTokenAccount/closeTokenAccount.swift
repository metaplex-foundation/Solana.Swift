import Foundation

extension Action {
    public func closeTokenAccount(
        signer: Signer,
        tokenPubkey: String,
        onComplete: @escaping (Result<TransactionID, Error>) -> Void
    ) {
        guard let tokenPubkey = PublicKey(string: tokenPubkey) else {
            onComplete(.failure(SolanaError.invalidPublicKey))
            return
        }

        let instruction = TokenProgram.closeAccountInstruction(
            account: tokenPubkey,
            destination: signer.publicKey,
            owner: signer.publicKey
        )
        serializeAndSendWithFee(instructions: [instruction], signers: [signer]) {
            onComplete($0)
            return
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Action {
    func closeTokenAccount(
        signer: Signer,
        tokenPubkey: String
    ) async throws -> TransactionID {
        try await withCheckedThrowingContinuation { c in
            self.closeTokenAccount(signer: signer, tokenPubkey: tokenPubkey, onComplete: c.resume(with:))
        }
    }
}

extension ActionTemplates {
    public struct CloseTokenAccountAction: ActionTemplate {
        public init(signer: Signer, tokenPubkey: String) {
            self.signer = signer
            self.tokenPubkey = tokenPubkey
        }

        public typealias Success = TransactionID

        public let signer: Signer
        public let tokenPubkey: String

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<Success, Error>) -> Void) {
            actionClass.closeTokenAccount(signer: signer, tokenPubkey: tokenPubkey, onComplete: completion)
        }
    }
}
