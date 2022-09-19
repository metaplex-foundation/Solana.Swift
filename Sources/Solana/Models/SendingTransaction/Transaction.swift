import Foundation
import TweetNacl

public struct Transaction {
    private var signatures = [Signature]()
    let feePayer: PublicKey
    var instructions = [TransactionInstruction]()
    let recentBlockhash: String
    //        TODO: nonceInfo

    public init(signatures: [Transaction.Signature] = [Signature](), feePayer: PublicKey, instructions: [TransactionInstruction] = [TransactionInstruction](), recentBlockhash: String) {
        self.signatures = signatures
        self.feePayer = feePayer
        self.instructions = instructions
        self.recentBlockhash = recentBlockhash
    }

    // MARK: - Methods
    public mutating func sign(signers: [Account]) -> Result<Void, Error> {
        guard signers.count > 0 else {
            return .failure(SolanaError.invalidRequest(reason: "No signers"))
        }

        // unique signers
        let signers = signers.reduce([Account](), {signers, signer in
            var uniqueSigners = signers
            if !uniqueSigners.contains(where: {$0.publicKey == signer.publicKey}) {
                uniqueSigners.append(signer)
            }
            return uniqueSigners
        })

        // map signatures
        signatures = signers.map { Signature(signature: nil, publicKey: $0.publicKey) }

        // construct message
        return compile().flatMap { message in
            return _partialSign(message: message, signers: signers)
        }
    }

    public mutating func serialize(
        requiredAllSignatures: Bool = true,
        verifySignatures: Bool = false
    ) -> Result<Data, Error> {
        // message
        return serializeMessage().flatMap { serializedMessage in
            return _verifySignatures(serializedMessage: serializedMessage, requiredAllSignatures: requiredAllSignatures)
                .mapError { _ in SolanaError.invalidRequest(reason: "Signature verification failed") }
                .flatMap { _ in _serialize(serializedMessage: serializedMessage) }
        }
    }

    // MARK: - Helpers
    mutating func addSignature(_ signature: Signature) -> Result<Void, Error> {
        return compile() // Ensure signatures array is populated
            .flatMap { _ in return _addSignature(signature) }
    }

    mutating func serializeMessage() -> Result<Data, Error> {
        return compile()
            .flatMap { $0.serialize() }
    }

    mutating func verifySignatures() -> Result<Bool, Error> {
        return serializeMessage().flatMap {
            _verifySignatures(serializedMessage: $0, requiredAllSignatures: true)
        }
    }

    func findSignature(pubkey: PublicKey) -> Signature? {
        signatures.first(where: {$0.publicKey == pubkey})
    }

    // MARK: - Signing
    public mutating func partialSign(signers: [Account]) -> Result<Void, Error> {
        if signers.count == 0 {
            return .failure(SolanaError.other("No signers"))
        }

        // unique signers
        let signers = signers.reduce([Account](), {signers, signer in
            var uniqueSigners = signers
            if !uniqueSigners.contains(where: {$0.publicKey == signer.publicKey}) {
                uniqueSigners.append(signer)
            }
            return uniqueSigners
        })

        return compile().flatMap { message in
            _partialSign(message: message, signers: signers)
        }
    }

    private mutating func _partialSign(message: Message, signers: [Account]) -> Result<Void, Error> {
        message.serialize()
            .flatMap { signData in
                for signer in signers {
                    do {
                        let data = try signer.sign(serializedMessage: signData)
                        try _addSignature(Signature(signature: data, publicKey: signer.publicKey)).get()
                    } catch let error {
                        return .failure(error)
                    }
                }
                return .success(())
            }
    }

    private mutating func _addSignature(_ signature: Signature) -> Result<Void, Error> {
        guard let data = signature.signature,
              data.count == 64,
              let index = signatures.firstIndex(where: {$0.publicKey == signature.publicKey})
        else {
            return .failure(SolanaError.other("Signer not valid: \(signature.publicKey.base58EncodedString)"))
        }

        signatures[index] = signature
        return .success(())
    }

    // MARK: - Compiling
    private mutating func compile() -> Result<Message, Error> {
        compileMessage().map { message in
            let signedKeys = message.accountKeys.filter { $0.isSigner }
            if signatures.count == signedKeys.count {
                var isValid = true
                for (index, signature) in signatures.enumerated() {
                    if signedKeys[index].publicKey != signature.publicKey {
                        isValid = false
                        break
                    }
                }
                if isValid {
                    return message
                }
            }
            signatures = signedKeys.map {Signature(signature: nil, publicKey: $0.publicKey)}
            return message
        }
    }

    private func compileMessage() -> Result<Message, Error> {
        // verify instructions
        guard instructions.count > 0 else {
            return .failure(SolanaError.other("No instructions provided"))
        }

        // programIds & accountMetas
        var programIds = [PublicKey]()
        var accountMetas = [AccountMeta]()

        for instruction in instructions {
            accountMetas.append(contentsOf: instruction.keys)
            if !programIds.contains(instruction.programId) {
                programIds.append(instruction.programId)
            }
        }

        for programId in programIds {
            accountMetas.append(
                .init(publicKey: programId, isSigner: false, isWritable: false)
            )
        }

        // sort accountMetas, first by signer, then by writable
        accountMetas.sort { (x, y) -> Bool in
            if x.isSigner != y.isSigner {return x.isSigner}
            if x.isWritable != y.isWritable {return x.isWritable}
            return false
        }

        // filterOut duplicate account metas, keeps writable one
        accountMetas = accountMetas.reduce([AccountMeta](), {result, accountMeta in
            var uniqueMetas = result
            if let index = uniqueMetas.firstIndex(where: {$0.publicKey == accountMeta.publicKey}) {
                // if accountMeta exists
                uniqueMetas[index].isWritable = uniqueMetas[index].isWritable || accountMeta.isWritable
            } else {
                uniqueMetas.append(accountMeta)
            }
            return uniqueMetas
        })

        // move fee payer to front
        accountMetas.removeAll(where: {$0.publicKey == feePayer})
        accountMetas.insert(
            AccountMeta(publicKey: feePayer, isSigner: true, isWritable: true),
            at: 0
        )

        // verify signers
        for signature in signatures {
            if let index = try? accountMetas.index(ofElementWithPublicKey: signature.publicKey).get() {
                if !accountMetas[index].isSigner {
                    //                        accountMetas[index].isSigner = true
                    //                        Logger.log(message: "Transaction references a signature that is unnecessary, only the fee payer and instruction signer accounts should sign a transaction. This behavior is deprecated and will throw an error in the next major version release.", event: .warning)
                    return .failure(SolanaError.invalidRequest(reason: "Transaction references a signature that is unnecessary"))
                }
            } else {
                return .failure(SolanaError.invalidRequest(reason: "Unknown signer: \(signature.publicKey.base58EncodedString)"))
            }
        }

        // header
        var header = Message.Header()

        var signedKeys = [AccountMeta]()
        var unsignedKeys = [AccountMeta]()

        for accountMeta in accountMetas {
            // signed keys
            if accountMeta.isSigner {
                signedKeys.append(accountMeta)
                header.numRequiredSignatures += 1

                if !accountMeta.isWritable {
                    header.numReadonlySignedAccounts += 1
                }
            }

            // unsigned keys
            else {
                unsignedKeys.append(accountMeta)

                if !accountMeta.isWritable {
                    header.numReadonlyUnsignedAccounts += 1
                }
            }
        }

        accountMetas = signedKeys + unsignedKeys

        return .success(Message(
            accountKeys: accountMetas,
            recentBlockhash: recentBlockhash,
            programInstructions: instructions
        ))
    }

    // MARK: - Verifying
    private mutating func _verifySignatures(
        serializedMessage: Data,
        requiredAllSignatures: Bool
    ) -> Result<Bool, Error> {
        for signature in signatures {
            if signature.signature == nil {
                if requiredAllSignatures {
                    return .success(false)
                }
            } else {
                if (try? NaclSign.signDetachedVerify(message: serializedMessage, sig: signature.signature!, publicKey: signature.publicKey.data)) != true {
                    return .success(false)
                }
            }
        }
        return .success(true)
    }

    // MARK: - Serializing
    private mutating func _serialize(serializedMessage: Data) -> Result<Data, Error> {
        // signature length
        let signaturesLength = signatures.count
        let encodedSignatureLength = Data.encodeLength(signaturesLength)

        // transaction length
        let dataLength = encodedSignatureLength.count + signaturesLength * 64 + serializedMessage.count
        var data = Data(count: dataLength)
        data.replaceSubrange(0..<encodedSignatureLength.count, with: encodedSignatureLength)

        // signature data
        for (index, signature) in signatures.enumerated() {
            if let signature = signature.signature {
                let rangeStart = encodedSignatureLength.count + index * 64
                data.replaceSubrange(rangeStart ..< rangeStart + 64, with: signature)
            }
        }

        // message data
        let messageRange = encodedSignatureLength.count + signaturesLength * 64 ..< dataLength
        data.replaceSubrange(messageRange, with: serializedMessage)

        return .success(data)
    }
}

public extension Transaction {
    struct Signature {
        var signature: Data?
        var publicKey: PublicKey

        public init(signature: Data?, publicKey: PublicKey) {
            self.signature = signature
            self.publicKey = publicKey
        }
    }
}
