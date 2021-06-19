import Foundation

extension Transaction {
    struct Message {
        // MARK: - Constants
        private static let RECENT_BLOCK_HASH_LENGTH = 32

        // MARK: - Properties
        var accountKeys: [Account.Meta]
        var recentBlockhash: String
        //        var instructions: [Transaction.Instruction]
        var programInstructions: [TransactionInstruction]

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
                // sort
                let signedKeys = accountKeys.filter {$0.isSigner}
                let unsignedKeys = accountKeys.filter {!$0.isSigner}
                let accountKeys = signedKeys + unsignedKeys

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
            var compiledInstructions = [CompiledInstruction]()

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
                    let compiledInstruction = CompiledInstruction(
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
        static let LENGTH = 3
        // TODO:
        var numRequiredSignatures: UInt8 = 0
        var numReadonlySignedAccounts: UInt8 = 0
        var numReadonlyUnsignedAccounts: UInt8 = 0

        var bytes: [UInt8] {
            [numRequiredSignatures, numReadonlySignedAccounts, numReadonlyUnsignedAccounts]
        }
    }

    struct CompiledInstruction {
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
}
