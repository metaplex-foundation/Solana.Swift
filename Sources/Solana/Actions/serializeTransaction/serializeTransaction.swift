import Foundation

extension Action {
    public func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {
        guard let feePayer = signers.first?.publicKey else {
            onComplete(.failure(NSError(domain: "accounts not found", code: 404)))
            return
        }
        let getRecentBlockhashRequest: (Result<String, Error>) -> Void = { result in
            switch result {
            case .success(let recentBlockhash):

                var transaction = Transaction(
                    feePayer: feePayer,
                    instructions: instructions,
                    recentBlockhash: recentBlockhash
                )

                transaction.sign(signers: signers)
                .flatMap { transaction.serialize() }
                .flatMap {
                    let base64 = $0.bytes.toBase64()
                    return .success(base64)
                }
                .onSuccess { onComplete(.success($0)) }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }

        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest(.success(recentBlockhash))
        } else {
            self.api.getRecentBlockhash { getRecentBlockhashRequest($0) }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Action {
    func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account]
    ) async throws -> String {
        try await withCheckedThrowingContinuation { c in
            self.serializeTransaction(
                instructions: instructions,
                recentBlockhash: recentBlockhash,
                signers: signers,
                onComplete: c.resume(with:)
            )
        }
    }
}

extension ActionTemplates {
    public struct SerializeTransaction: ActionTemplate {
        public init(instructions: [TransactionInstruction], signers: [Account], recentBlockhash: String? = nil) {
            self.instructions = instructions
            self.recentBlockhash = recentBlockhash
            self.signers = signers
        }

        public typealias Success = String

        public let instructions: [TransactionInstruction]
        public let recentBlockhash: String?
        public let signers: [Account]

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<String, Error>) -> Void) {
            actionClass.serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers, onComplete: completion)
        }
    }
}
