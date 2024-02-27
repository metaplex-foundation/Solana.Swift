import Foundation
import TweetNacl

public struct Transaction {
    private static let SIGNATURE_LENGTH: Int = 64
    private static let DEFAULT_SIGNATURE = Data(capacity: 0)
    
    public private(set) var signatures = [Signature]()
    private let feePayer: PublicKey
    private let recentBlockhash: String

    public private(set) var instructions = [TransactionInstruction]()
    //        TODO: nonceInfo

    public init(signatures: [Transaction.Signature] = [Signature](), feePayer: PublicKey, instructions: [TransactionInstruction] = [TransactionInstruction](), recentBlockhash: String) {
        self.signatures = signatures
        self.feePayer = feePayer
        self.instructions = instructions
        self.recentBlockhash = recentBlockhash
    }

    // MARK: - Methods
    public mutating func sign(signers: [Signer]) -> Result<Void, Error> {
        guard signers.count > 0 else {
            return .failure(SolanaError.invalidRequest(reason: "No signers"))
        }

        // unique signers
        let signers = signers.reduce([Signer](), {signers, signer in
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
    public mutating func partialSign(signers: [Signer]) -> Result<Void, Error> {
        if signers.count == 0 {
            return .failure(SolanaError.other("No signers"))
        }

        // unique signers
        let signers = signers.reduce([Signer](), {signers, signer in
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

    private mutating func _partialSign(message: Message, signers: [Signer]) -> Result<Void, Error> {
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

            return message
        }
    }

    static func sortAccountMetas(accountMetas: [AccountMeta]) -> [AccountMeta] {
        let locale = Locale(identifier: "en_US")
        return accountMetas.sorted { (x, y) -> Bool in
            if x.isSigner != y.isSigner {return x.isSigner}
            if x.isWritable != y.isWritable {return x.isWritable}
            return x.publicKey.base58EncodedString.compare(y.publicKey.base58EncodedString, locale: locale) == .orderedAscending
        }
    }
    
    func compileMessage() -> Result<Message, Error> {
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
        accountMetas = Transaction.sortAccountMetas(accountMetas: accountMetas)

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
    
    static func from(buffer: Data) throws -> Transaction {
        // Slice up wire data
        var byteArray = buffer
        
        let signatureCount = Shortvec.decodeLength(buffer: byteArray)
        byteArray = signatureCount.1
        
        var signatures: [[UInt8]] = []
        for _ in 0...(signatureCount.0) - 1 {
            let signature = byteArray[0..<SIGNATURE_LENGTH]
            byteArray = Data(byteArray.dropFirst(SIGNATURE_LENGTH))

            signatures.append(signature.bytes)
        }
        
        return try populateTransaction(fromMessage: Message.from(buffer: byteArray), signatures: signatures)
    }
    
    static func signaturesFrom(buffer: Data) throws -> [[UInt8]] {
        // Slice up wire data
        var byteArray = buffer
        
        let signatureCount = Shortvec.decodeLength(buffer: byteArray)
        byteArray = signatureCount.1
        
        var signatures: [[UInt8]] = []
        for _ in 0...(signatureCount.0) - 1 {
            let signature = byteArray[0..<SIGNATURE_LENGTH]
            byteArray = Data(byteArray.dropFirst(SIGNATURE_LENGTH))
            
            signatures.append(signature.bytes)
        }
        
        return signatures
    }
    
    static func populateTransaction(fromMessage: Message, signatures: [[UInt8]]) throws -> Transaction {
        
        // TODO: Should check against required number of signatures if there are any
        let feePayer = fromMessage.accountKeys[0].publicKey
       
        var sigs: [Transaction.Signature] = []
        
        for (index, signature) in signatures.enumerated() {
            let signatureEncoded = Base58.encode(signature) == Base58.encode(DEFAULT_SIGNATURE.bytes) ? nil : signature
            
            let publicKey = fromMessage.accountKeys[index].publicKey
            
            sigs.append(Transaction.Signature(signature: signatureEncoded.map { Data($0) }, publicKey: publicKey))
        }
                
        return Transaction(signatures: sigs, feePayer: feePayer, instructions: fromMessage.programInstructions, recentBlockhash: fromMessage.recentBlockhash)
    }
}

public class Shortvec {
    static func decodeLength(buffer: Data) -> (Int, Data) {
        var newBytes = buffer
        var len = 0
        var size = 0
        while (true) {
            guard let elem = newBytes.firstAsInt() else {
                break
            }
            
            newBytes = Data(newBytes.dropFirst(1))
            
            len = len | (elem & 0x7f) << (size * 7)
            size += 1
            
            if ((elem & 0x80) == 0) {
                break
            }
        }
        
        return (len, newBytes)
    }
    
    public enum NextBlockError: Error {
        case outOfRange
    }
    
    static func nextBlock(buffer: Data, multiplier: Int = 1) throws -> (Data, Data) {
        let nextLengh = decodeLength(buffer: buffer)
        
        guard nextLengh.0 * multiplier < nextLengh.1.count else {
            throw NextBlockError.outOfRange
        }
        let block = Data(nextLengh.1[0..<(nextLengh.0 * multiplier)])
        
        return (block, Data(nextLengh.1.dropFirst(nextLengh.0 * multiplier)))
    }
}

public extension Data {
    func firstAsInt() -> Int? {
        return self.first.map { Int($0) }
    }
}
