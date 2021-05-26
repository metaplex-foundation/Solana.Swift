//
//  TransactionParser.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/04/2021.
//

import Foundation
import RxSwift

public protocol SolanaSDKTransactionParserType {
    func parse(transactionInfo: Solana.TransactionInfo, myAccount: String?, myAccountSymbol: String?) -> Single<Solana.AnyTransaction>
}

public extension Solana {
    struct TransactionParser: SolanaSDKTransactionParserType {
        // MARK: - Properties
        private let solanaSDK: Solana

        // MARK: - Initializers
        public init(solanaSDK: Solana) {
            self.solanaSDK = solanaSDK
        }

        // MARK: - Methods
        public func parse(
            transactionInfo: TransactionInfo,
            myAccount: String?,
            myAccountSymbol: String?
        ) -> Single<AnyTransaction> {
            // get data
            let innerInstructions = transactionInfo.meta?.innerInstructions
            let instructions = transactionInfo.transaction.message.instructions

            // single
            var single: Single<AnyHashable?>

            // swap (un-parsed type)
            if let instructionIndex = getSwapInstructionIndex(instructions: instructions) {
                let instruction = instructions[instructionIndex]
                single = parseSwapTransaction(
                    index: instructionIndex,
                    instruction: instruction,
                    innerInstructions: innerInstructions,
                    myAccountSymbol: myAccountSymbol
                )
                    .map {$0 as AnyHashable}
            }

            // create account
            else if instructions.count == 2,
               instructions.first?.parsed?.type == "createAccount",
               instructions.last?.parsed?.type == "initializeAccount" {
                single = parseCreateAccountTransaction(
                    instruction: instructions[0],
                    initializeAccountInstruction: instructions.last
                )
                    .map {$0 as AnyHashable}
            }

            // close account
            else if instructions.count == 1,
               instructions.first?.parsed?.type == "closeAccount" {
                single = parseCloseAccountTransaction(
                    closedTokenPubkey: instructions.first?.parsed?.info.account,
                    preBalances: transactionInfo.meta?.preBalances,
                    preTokenBalance: transactionInfo.meta?.preTokenBalances?.first
                )
                    .map {$0 as AnyHashable}
            }

            // transfer
            else if instructions.count == 1 || instructions.count == 4 || instructions.count == 2,
               instructions.last?.parsed?.type == "transfer" || instructions.last?.parsed?.type == "transferChecked",
               let instruction = instructions.last {
                single = parseTransferTransaction(
                    instruction: instruction,
                    postTokenBalances: transactionInfo.meta?.postTokenBalances ?? [],
                    myAccount: myAccount,
                    accountKeys: transactionInfo.transaction.message.accountKeys
                )
                    .map {$0 as AnyHashable}
            }

            // unknown transaction
            else {
                single = .just(nil)
            }

            return single
                .map {
                    AnyTransaction(signature: nil, value: $0, slot: nil, blockTime: nil, fee: transactionInfo.meta?.fee, blockhash: transactionInfo.transaction.message.recentBlockhash)
                }
        }

        // MARK: - Create account
        private func parseCreateAccountTransaction(
            instruction: ParsedInstruction,
            initializeAccountInstruction: ParsedInstruction?
        ) -> Single<CreateAccountTransaction> {
            let info = instruction.parsed?.info
            let initializeAccountInfo = initializeAccountInstruction?.parsed?.info

            let fee = info?.lamports?.convertToBalance(decimals: Decimals.SOL)
            let token = getTokenWithMint(initializeAccountInfo?.mint)

            return .just(
                CreateAccountTransaction(
                    fee: fee,
                    newWallet: Wallet(
                        pubkey: info?.newAccount,
                        lamports: nil,
                        token: token
                    )
                )
            )
        }

        // MARK: - Close account
        private func parseCloseAccountTransaction(
            closedTokenPubkey: String?,
            preBalances: [Lamports]?,
            preTokenBalance: TokenBalance?
        ) -> Single<CloseAccountTransaction> {
            var reimbursedAmountLamports: Lamports?

            if (preBalances?.count ?? 0) > 1 {
                reimbursedAmountLamports = preBalances![1]
            }

            let reimbursedAmount = reimbursedAmountLamports?.convertToBalance(decimals: Decimals.SOL)
            let token = getTokenWithMint(preTokenBalance?.mint)

            return .just(
                CloseAccountTransaction(
                    reimbursedAmount: reimbursedAmount,
                    closedWallet: Wallet(
                        pubkey: closedTokenPubkey,
                        lamports: nil,
                        token: token
                    )
                )
            )
        }

        // MARK: - Transfer
        private func parseTransferTransaction(
            instruction: ParsedInstruction,
            postTokenBalances: [TokenBalance],
            myAccount: String?,
            accountKeys: [Account.Meta]
        ) -> Single<TransferTransaction> {
            // construct wallets
            var source: Wallet?
            var destination: Wallet?

            // get pubkeys
            let sourcePubkey = instruction.parsed?.info.source
            let destinationPubkey = instruction.parsed?.info.destination

            // get lamports
            let lamports = instruction.parsed?.info.lamports ?? UInt64(instruction.parsed?.info.amount ?? instruction.parsed?.info.tokenAmount?.amount ?? "0")

            // SOL to SOL
            if instruction.programId == PublicKey.programId.base58EncodedString {
                source = Wallet.nativeSolana(pubkey: sourcePubkey, lamport: nil)
                destination = Wallet.nativeSolana(pubkey: destinationPubkey, lamport: nil)

                return .just(
                    TransferTransaction(
                        source: source,
                        destination: destination,
                        amount: lamports?.convertToBalance(decimals: source!.token.decimals),
                        myAccount: myAccount
                    )
                )
            } else {
                // SPL to SPL token
                if let tokenBalance = postTokenBalances.first(where: {!$0.mint.isEmpty}) {
                    let token = getTokenWithMint(tokenBalance.mint)

                    source = Wallet(pubkey: sourcePubkey, lamports: nil, token: token)
                    destination = Wallet(pubkey: destinationPubkey, lamports: nil, token: token)

                    // if the wallet that is opening is SOL, then modify myAccount
                    var myAccount = myAccount
                    if sourcePubkey != myAccount && destinationPubkey != myAccount,
                       accountKeys.count >= 4 {
                        // send
                        if myAccount == accountKeys[0].publicKey.base58EncodedString {
                            myAccount = sourcePubkey
                        }

                        if myAccount == accountKeys[3].publicKey.base58EncodedString {
                            myAccount = destinationPubkey
                        }
                    }

                    return .just(
                        TransferTransaction(
                            source: source,
                            destination: destination,
                            amount: lamports?.convertToBalance(decimals: source?.token.decimals),
                            myAccount: myAccount
                        )
                    )
                } else {
                    return getAccountInfo(account: sourcePubkey, retryWithAccount: destinationPubkey)
                        .map { info in
                            // update source
                            let token = getTokenWithMint(info?.mint.base58EncodedString)
                            source = Wallet(pubkey: sourcePubkey, lamports: nil, token: token)
                            destination = Wallet(pubkey: destinationPubkey, lamports: nil, token: token)

                            return TransferTransaction(
                                source: source,
                                destination: destination,
                                amount: lamports?.convertToBalance(decimals: source?.token.decimals),
                                myAccount: myAccount
                            )
                        }
                }
            }
        }

        // MARK: - Swap
        private func getSwapInstructionIndex(
            instructions: [ParsedInstruction]
        ) -> Int? {
            instructions.firstIndex(
                where: {
                    $0.programId == solanaSDK.endpoint.network.swapProgramId.base58EncodedString /*swap ocra*/ ||
                        $0.programId == "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL" /*main deprecated*/ ||
                        $0.programId == "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8" /*main deprecated*/
                })
        }

        private func parseSwapTransaction(
            index: Int,
            instruction: ParsedInstruction,
            innerInstructions: [InnerInstruction]?,
            myAccountSymbol: String?
        ) -> Single<SwapTransaction> {
            // get data
            guard let data = instruction.data else {return .just(SwapTransaction.empty)}
            let buf = Base58.decode(data)

            // get instruction index
            guard let instructionIndex = buf.first,
                  instructionIndex == 1,
                  let swapInnerInstruction = innerInstructions?.first(where: {$0.index == index})
            else { return .just(SwapTransaction.empty) }

            // get instructions
            let transfersInstructions = swapInnerInstruction.instructions.filter {$0.parsed?.type == "transfer"}
            guard transfersInstructions.count >= 2 else {return .just(SwapTransaction.empty)}

            let sourceInstruction = transfersInstructions[0]
            let destinationInstruction = transfersInstructions[1]
            let sourceInfo = sourceInstruction.parsed?.info
            let destinationInfo = destinationInstruction.parsed?.info

            // group request
            var requests = [Single<AccountInfo?>]()

            // get source
            var sourcePubkey: PublicKey?
            if let sourceString = sourceInfo?.source {
                sourcePubkey = try? PublicKey(string: sourceString)
                requests.append(
                    getAccountInfo(account: sourceString, retryWithAccount: sourceInfo?.destination)
                )
            }

            var destinationPubkey: PublicKey?
            if let destinationString = destinationInfo?.destination {
                destinationPubkey = try? PublicKey(string: destinationString)
                requests.append(
                    getAccountInfo(account: destinationString, retryWithAccount: destinationInfo?.source)
                )
            }

            // get token account info
            return Single.zip(requests)
                .map { params in
                    // get source, destination account info
                    let sourceAccountInfo = params[0]
                    let destinationAccountInfo = params[1]

                    // source
                    let sourceToken = getTokenWithMint(sourceAccountInfo?.mint.base58EncodedString)
                    let source = Wallet(
                        pubkey: sourcePubkey?.base58EncodedString,
                        lamports: sourceAccountInfo?.lamports,
                        token: sourceToken
                    )

                    // destination
                    let destinationToken = getTokenWithMint(destinationAccountInfo?.mint.base58EncodedString)
                    let destination = Wallet(
                        pubkey: destinationPubkey?.base58EncodedString,
                        lamports: destinationAccountInfo?.lamports,
                        token: destinationToken
                    )

                    let sourceAmount = UInt64(sourceInfo?.amount ?? "0")?.convertToBalance(decimals: source.token.decimals)
                    let destinationAmount = UInt64(destinationInfo?.amount ?? "0")?.convertToBalance(decimals: destination.token.decimals)

                    // get decimals
                    return SwapTransaction(
                        source: source,
                        sourceAmount: sourceAmount,
                        destination: destination,
                        destinationAmount: destinationAmount,
                        myAccountSymbol: myAccountSymbol
                    )
                }
                .catchAndReturn(
                    Solana.SwapTransaction(
                        source: nil,
                        sourceAmount: nil,
                        destination: nil,
                        destinationAmount: nil,
                        myAccountSymbol: myAccountSymbol
                    )
                )
        }

        // MARK: - Helpers
        private func getTokenWithMint(_ mint: String?) -> Token {
            guard let mint = mint else {return .unsupported(mint: nil)}
            return solanaSDK.supportedTokens.first(where: {$0.address == mint}) ?? .unsupported(mint: mint)
        }

        private func getAccountInfo(account: String?, retryWithAccount retryAccount: String? = nil) -> Single<AccountInfo?> {
            guard let account = account else {return .just(nil)}
            return solanaSDK.getAccountInfo(
                account: account,
                decodedTo: AccountInfo.self
            )
                .map {$0.data.value}
                .catchAndReturn(nil)
                .flatMap {
                    if $0 == nil,
                       let retryAccount = retryAccount {
                        return getAccountInfo(account: retryAccount)
                    }
                    return .just($0)
                }
        }
    }
}
