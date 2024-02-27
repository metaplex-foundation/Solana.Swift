import Foundation

struct CompiledInstruction {
    let programIdIndex: Int
    let accounts: [Int]
    let data: [UInt8]
}

extension Transaction {
    public struct Message {
        static let PUBKEY_LENGTH = 32
        
        // MARK: - Constants
        private static let RECENT_BLOCK_HASH_LENGTH = 32

        // MARK: - Properties
        var accountKeys: [AccountMeta]
        var recentBlockhash: String
        //        var instructions: [Transaction.Instruction]
        var programInstructions: [TransactionInstruction]
        
        public init(accountKeys: [AccountMeta], recentBlockhash: String, programInstructions: [TransactionInstruction]) {
            self.accountKeys = accountKeys
            self.recentBlockhash = recentBlockhash
            self.programInstructions = programInstructions
        }

        func serialize() -> Result<Data, Error> {
            // Construct data
            //            let bufferSize: Int =
            //                Header.LENGTH // header
            //                + keyCount.count // number of account keys
            //                + Int(accountKeys.count) * PublicKey.LENGTH // account keys
            //                + RECENT_BLOCK_HASH_LENGTH // recent block hash
            //                + instructionsLength.count
            //                + compiledInstructionsLength

            var data = Data(/*capacity: bufferSize*/)
            
            // Compiled instruction
            return encodeHeader().map { data.append($0) }
                .flatMap { _ in return encodeAccountKeys().map { data.append($0) } }
                .flatMap { _ in return encodeRecentBlockhash().map { data.append($0) }}
                .flatMap { _ in return encodeInstructions().map { data.append($0) }}
                .map { data }
        }

        private func encodeHeader() -> Result<Data, Error> {
            var header = Header()
            for meta in accountKeys {
                if meta.isSigner {
                    // signed
                    header.numRequiredSignatures += 1

                    // signed & readonly
                    if !meta.isWritable {
                        header.numReadonlySignedAccounts += 1
                    }
                } else {
                    // unsigned & readonly
                    if !meta.isWritable {
                        header.numReadonlyUnsignedAccounts += 1
                    }
                }
            }
            return .success(Data(header.bytes))
        }

        private func encodeAccountKeys() -> Result<Data, Error> {
            // length
            return encodeLength(accountKeys.count).map { keyCount in
                // construct data
                var data = Data(capacity: keyCount.count + accountKeys.count * PublicKey.LENGTH)
                // append data
                data.append(keyCount)
                for meta in accountKeys {
                    data.append(meta.publicKey.data)
                }
                return data
            }
        }

        private func encodeRecentBlockhash() -> Result<Data, Error> {
            return .success(Data(Base58.decode(recentBlockhash)))
        }

        private func encodeInstructions() -> Result<Data, Error> {
            var compiledInstructions = [SerialiseCompiledInstruction]()

            for instruction in programInstructions {

                let keysSize = instruction.keys.count

                var keyIndices = Data()
                for i in 0..<keysSize {
                    do {
                        let index = try accountKeys.index(ofElementWithPublicKey: instruction.keys[i].publicKey).get()
                        keyIndices.append(UInt8(index))
                    } catch let error {
                        return .failure(error)
                    }
                }

                do {
                    let compiledInstruction = SerialiseCompiledInstruction(
                        programIdIndex: UInt8(try accountKeys.index(ofElementWithPublicKey: instruction.programId).get()),
                        keyIndicesCount: [UInt8](Data.encodeLength(keysSize)),
                        keyIndices: [UInt8](keyIndices),
                        dataLength: [UInt8](Data.encodeLength(instruction.data.count)),
                        data: instruction.data
                    )
                    compiledInstructions.append(compiledInstruction)
                } catch let error {
                    return .failure(error)
                }
            }

            return encodeLength(compiledInstructions.count).flatMap { instructionsLength in
                .success(instructionsLength + compiledInstructions.reduce(Data(), {$0 + $1.serializedData}))
            }
        }

        private func encodeLength(_ length: Int) -> Result<Data, Error> {
            return .success(Data.encodeLength(length))
        }
    }
}

extension Transaction.Message {
    // MARK: - Nested type
    public struct Header: Decodable {
        // TODO:
        var numRequiredSignatures: UInt8 = 0
        var numReadonlySignedAccounts: UInt8 = 0
        var numReadonlyUnsignedAccounts: UInt8 = 0
        
        init() {}
        
        init(numRequiredSignatures: UInt8, numReadonlySignedAccounts: UInt8, numReadonlyUnsignedAccounts: UInt8) {
            self.numRequiredSignatures = numRequiredSignatures
            self.numReadonlySignedAccounts = numReadonlySignedAccounts
            self.numReadonlyUnsignedAccounts = numReadonlyUnsignedAccounts
        }
        
        var bytes: [UInt8] {
            [numRequiredSignatures, numReadonlySignedAccounts, numReadonlyUnsignedAccounts]
        }
    }

    struct SerialiseCompiledInstruction {
        let programIdIndex: UInt8
        let keyIndicesCount: [UInt8]
        let keyIndices: [UInt8]
        let dataLength: [UInt8]
        let data: [UInt8]

        var length: Int {
            1 + keyIndicesCount.count + keyIndices.count + dataLength.count + data.count
        }

        var serializedData: Data {
            Data([programIdIndex] + keyIndicesCount + keyIndices + dataLength + data)
        }
    }
    
    static func from(buffer: Data) throws -> Transaction.Message {
        // Slice up wire data
        var byteArray = buffer
        
        guard let prefix = byteArray.first else { throw SolanaError.invalidRequest(reason: "Could not parse number of required signatures") }
        let maskedPrefix =  prefix & 0x7f
        guard prefix != maskedPrefix else {
            throw SolanaError.invalidRequest(reason: "Could not parse legacy type")
        }
        byteArray = Data(byteArray.dropFirst())

        guard let numRequiredSignatures = byteArray.first else { throw SolanaError.invalidRequest(reason: "Could not parse number of required signatures") }
        byteArray = Data(byteArray.dropFirst())
        
        guard let numReadonlySignedAccounts = byteArray.first else { throw SolanaError.invalidRequest(reason: "Could not parse number of signed accounts") }
        byteArray = Data(byteArray.dropFirst())
        
        guard let numReadonlyUnsignedAccounts = byteArray.first else { throw SolanaError.invalidRequest(reason: "Could not parse number of unsigned accounts") }
        byteArray = Data(byteArray.dropFirst())
              
        let accountsBlock = try Shortvec.nextBlock(buffer: byteArray, multiplier: PUBKEY_LENGTH)
        byteArray = accountsBlock.1
        
        let accountKeys = accountsBlock.0
            .bytes
            .chunked(into: PUBKEY_LENGTH)
            .map { Base58.encode($0) }
        
        let recentBlockhash = byteArray[0..<PUBKEY_LENGTH].bytes
        byteArray = Data(byteArray.dropFirst(PUBKEY_LENGTH))
        
        let instructionsBlock = Shortvec.decodeLength(buffer: byteArray)
        byteArray = instructionsBlock.1
        
        var instructions: [CompiledInstruction] = []
        for _ in 0...(instructionsBlock.0 - 1) {
            guard let programIdIndex = byteArray.firstAsInt() else { break }
            
            byteArray = Data(byteArray.dropFirst())
            
            do {
                let accountBlock = try Shortvec.nextBlock(buffer: byteArray)
                byteArray = accountBlock.1
                
                let accounts = accountBlock.0.bytes.map{ Int($0) }
                
                let dataBlock = try Shortvec.nextBlock(buffer: byteArray)
                byteArray = dataBlock.1
                
                let compiledInstruction = CompiledInstruction(programIdIndex: programIdIndex, accounts: accounts, data: dataBlock.0.bytes)
                instructions.append(compiledInstruction)
            } catch {
                break
            }
        }
        
        let header = Header(
            numRequiredSignatures: numRequiredSignatures,
            numReadonlySignedAccounts: numReadonlySignedAccounts,
            numReadonlyUnsignedAccounts: numReadonlyUnsignedAccounts
        )
        
        let accountMetas = keysToAccountMetas(accountKeys: accountKeys, header: header)
        let accountMetasAsDictionary = Dictionary(uniqueKeysWithValues: accountMetas.map{ ($0.publicKey.base58EncodedString, $0) })
        
        var programInstructions: [TransactionInstruction] = []
        for instruction in instructions {
            // TODO: Not sure if it should continue or throw, but I don't think it can happen here
            guard let programId = PublicKey(string: accountKeys[instruction.programIdIndex]) else { continue }

            var keys: [AccountMeta] = []
            if !instruction.accounts.isEmpty {
                for j in 0...(instruction.accounts.count - 1) {
                    let accountIndex = instruction.accounts[j]
                    if accountIndex < accountKeys.count {
                        let pubKey = accountKeys[accountIndex]
                        // TODO: Not sure if it should continue or throw, but I don't think it can happen here
                        guard let accountMeta = accountMetasAsDictionary[pubKey] else { continue }
                        keys.append(accountMeta)
                    }
                }
            }

            let transactionInstruction = TransactionInstruction(keys: keys, programId: programId, data: instruction.data)
            programInstructions.append(transactionInstruction)
        }
        
        return Transaction.Message(accountKeys: accountMetas, recentBlockhash: Base58.encode(recentBlockhash), programInstructions: programInstructions)
    }
    
    static func keysToAccountMetas(accountKeys: [String], header: Header) -> [AccountMeta] {
        var accountMetas: [AccountMeta] = []
        
        for (index, key) in accountKeys.enumerated() {
            guard let account = PublicKey(string: key) else { continue }
            let isSigner = header.isAccountSigner(index: index)
            let isWritable = header.isAccountWritable(index: index, accountKeysCount: accountKeys.count)
            
            let accountMeta = AccountMeta(publicKey: account, isSigner: isSigner, isWritable: isWritable)
            accountMetas.append(accountMeta)
        }
        
        return accountMetas
    }
}

extension Transaction.Message.Header {
    func isAccountSigner(index: Int) -> Bool {
        return index < self.numRequiredSignatures
    }
    
    func isAccountWritable(index: Int, accountKeysCount: Int) -> Bool {
        return index < self.numRequiredSignatures - self.numReadonlySignedAccounts ||
        (index >= self.numRequiredSignatures &&
         index < accountKeysCount - Int(self.numReadonlyUnsignedAccounts))
    }
}
