//
//  SolanaSDK+Send.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation
import RxSwift

extension Solana {
    public typealias SPLTokenDestinationAddress = (destination: PublicKey, isUnregisteredAsocciatedToken: Bool)

    /// Send SOL to another account with or without fee
    /// - Parameters:
    ///   - toPublicKey: destination address
    ///   - amount: amount to send
    ///   - withoutFee: send without fee. if it's true, the transaction can not be a simulation
    ///   - isSimulation: define if this is a simulation or real transaction
    /// - Returns: transaction id
    public func sendSOL(
        to destination: String,
        amount: UInt64,
        withoutFee: Bool = true,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }

        do {
            let fromPublicKey = account.publicKey

            if fromPublicKey.base58EncodedString == destination {
                throw Error.other("You can not send tokens to yourself")
            }

            // check
            return getAccountInfo(account: destination, decodedTo: EmptyInfo.self)
                .map {info -> Void in
                    guard info.owner == PublicKey.programId.base58EncodedString
                    else {throw Error.other("Invalid account info")}
                    return
                }
                .catch { error in
                    if (error as? Error) == Error.other("Could not retrieve account info") {
                        // let request through
                        return .just(())
                    }
                    throw error
                }
                .flatMap {

                    // transaction with fee, can be a simulation
                    let instruction = SystemProgram.transferInstruction(
                        from: fromPublicKey,
                        to: try PublicKey(string: destination),
                        lamports: amount
                    )

                    return self.serializeAndSendWithFee(
                        instructions: [instruction],
                        signers: [account],
                        isSimulation: isSimulation
                    )
                }
                .catch {error in
                    var error = error
                    if error.localizedDescription == "Invalid param: WrongSize" {
                        error = Error.other("Wrong wallet address")
                    }
                    throw error
                }
        } catch {
            return .error(error)
        }
    }

    /// Send SPLTokens to another account
    /// - Parameters:
    ///   - mintAddress: the mint address to define Token
    ///   - fromPublicKey: source wallet address
    ///   - destinationAddress: destination wallet address
    ///   - amount: amount to send
    ///   - withoutFee: send without fee. if it's true, the transaction can not be a simulation
    ///   - isSimulation: define if this is a simulation or real transaction
    /// - Returns: transaction id
    public func sendSPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }

        return findSPLTokenDestinationAddress(
            mintAddress: mintAddress,
            destinationAddress: destinationAddress
        )
            .flatMap {result in
                // get address
                let toPublicKey = result.destination

                // catch error
                if fromPublicKey == toPublicKey.base58EncodedString {
                    throw Error.other("You can not send tokens to yourself")
                }

                let fromPublicKey = try PublicKey(string: fromPublicKey)

                var instructions = [TransactionInstruction]()

                // create associated token address
                if result.isUnregisteredAsocciatedToken {
                    let mint = try PublicKey(string: mintAddress)
                    let owner = try PublicKey(string: destinationAddress)

                    let createATokenInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                        mint: mint,
                        associatedAccount: toPublicKey,
                        owner: owner,
                        payer: account.publicKey
                    )
                    instructions.append(createATokenInstruction)
                }

                // send instruction
                let sendInstruction = TokenProgram.transferInstruction(
                    tokenProgramId: .tokenProgramId,
                    source: fromPublicKey,
                    destination: toPublicKey,
                    owner: account.publicKey,
                    amount: amount
                )

                instructions.append(sendInstruction)

                return self.serializeAndSendWithFee(instructions: instructions, signers: [account], isSimulation: isSimulation)
            }
            .catch {error in
                var error = error
                if error.localizedDescription == "Invalid param: WrongSize" {
                    error = Error.other("Wrong wallet address")
                }
                throw error
            }
    }

    // MARK: - Helpers
    public func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String
    ) -> Single<SPLTokenDestinationAddress> {
        getAccountInfo(
            account: destinationAddress,
            decodedTo: Solana.AccountInfo.self
        )
            .map {info -> String in
                let toTokenMint = info.data.value?.mint.base58EncodedString

                // detect if destination address is already a SPLToken address
                if mintAddress == toTokenMint {
                    return destinationAddress
                }

                // detect if destination address is a SOL address
                if info.owner == PublicKey.programId.base58EncodedString {
                    let owner = try PublicKey(string: destinationAddress)
                    let tokenMint = try PublicKey(string: mintAddress)

                    // create associated token address
                    let address = try PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: tokenMint
                    )
                    return address.base58EncodedString
                }

                // token is of another type
                throw Error.invalidRequest(reason: "Wallet address is not valid")
            }
            .catch { error in
                // let request through if result of getAccountInfo is null (it may be a new SOL address)
                if (error as? Error) == Error.other("Could not retrieve account info") {
                    let owner = try PublicKey(string: destinationAddress)
                    let tokenMint = try PublicKey(string: mintAddress)

                    // create associated token address
                    let address = try PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: tokenMint
                    )
                    return .just(address.base58EncodedString)
                }

                // throw another error
                throw error
            }
            .flatMap {toPublicKey -> Single<SPLTokenDestinationAddress> in
                let toPublicKey = try PublicKey(string: toPublicKey)
                // if destination address is an SOL account address
                if destinationAddress != toPublicKey.base58EncodedString {
                    // check if associated address is already registered
                    return self.getAccountInfo(
                        account: toPublicKey.base58EncodedString,
                        decodedTo: AccountInfo.self
                    )
                        .map {$0 as BufferInfo<AccountInfo>?}
                        .catchAndReturn(nil)
                        .flatMap {info in
                            var isUnregisteredAsocciatedToken = true

                            // if associated token account has been registered
                            if info?.owner == PublicKey.tokenProgramId.base58EncodedString &&
                                info?.data.value != nil {
                                isUnregisteredAsocciatedToken = false
                            }

                            // if not, create one in next step
                            return .just((destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken))
                        }
                }
                return .just((destination: toPublicKey, isUnregisteredAsocciatedToken: false))
            }
    }
}
