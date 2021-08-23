import Foundation

public protocol SolanaSDKTransactionParserType {
    func parse(transactionInfo: TransactionInfo, myAccount: String?, myAccountSymbol: String?, onComplete: @escaping (Result<AnyTransaction, Error>) -> Void)
}

public struct TransactionParser: SolanaSDKTransactionParserType {

    // MARK: - Properties
    private let solanaSDK: Solana

    // MARK: - Initializers
    public init(solanaSDK: Solana) {
        self.solanaSDK = solanaSDK
    }

    // MARK: - Methods
    public func parse(transactionInfo: TransactionInfo, myAccount: String?, myAccountSymbol: String?, onComplete: @escaping (Result<AnyTransaction, Error>) -> Void) {
        // get data
        let innerInstructions = transactionInfo.meta?.innerInstructions
        let instructions = transactionInfo.transaction.message.instructions

        // single
        var single: ContResult<AnyHashable?, Error>

        // swap (un-parsed type)
        if let instructionIndex = getSwapInstructionIndex(instructions: instructions) {
            let checkingInnerInstructions = innerInstructions?.first?.instructions
            // swap
            if checkingInnerInstructions?.count == 2,
               checkingInnerInstructions![0].parsed?.type == "transfer",
               checkingInnerInstructions![1].parsed?.type == "transfer" {
                let instruction = instructions[instructionIndex]
                single = ContResult<SwapTransaction, Error> { cb in
                    parseSwapTransaction(
                        index: instructionIndex,
                        instruction: instruction,
                        innerInstructions: innerInstructions,
                        myAccountSymbol: myAccountSymbol
                    ) { cb($0) }
                }.map {$0 as AnyHashable}
            }

            // Later: provide liquidity to pool (unsupported yet)
            else if checkingInnerInstructions?.count == 3,
                    checkingInnerInstructions![0].parsed?.type == "transfer",
                    checkingInnerInstructions![1].parsed?.type == "transfer",
                    checkingInnerInstructions![2].parsed?.type == "mintTo" {
                single = .success(nil)
            }

            // Later: burn?
            else if checkingInnerInstructions?.count == 3,
                    checkingInnerInstructions![0].parsed?.type == "burn",
                    checkingInnerInstructions![1].parsed?.type == "transfer",
                    checkingInnerInstructions![2].parsed?.type == "transfer" {
                single = .success(nil)
            }

            // unsupported
            else {
                single = .success(nil)
            }
        }

        // create account
        else if instructions.count == 2,
                instructions.first?.parsed?.type == "createAccount",
                instructions.last?.parsed?.type == "initializeAccount" {
            single = ContResult.pure(parseCreateAccountTransaction(
                instruction: instructions[0],
                initializeAccountInstruction: instructions.last
            )).map {$0 as AnyHashable}
        }

        // close account
        else if instructions.count == 1,
                instructions.first?.parsed?.type == "closeAccount" {
            single = ContResult<CloseAccountTransaction, Error>.pure(
                parseCloseAccountTransaction(
                    closedTokenPubkey: instructions.first?.parsed?.info.account,
                    preBalances: transactionInfo.meta?.preBalances,
                    preTokenBalance: transactionInfo.meta?.preTokenBalances?.first
                )
            ).map {$0 as AnyHashable}
        }

        // transfer
        else if instructions.count == 1 || instructions.count == 4 || instructions.count == 2,
                instructions.last?.parsed?.type == "transfer" || instructions.last?.parsed?.type == "transferChecked",
                let instruction = instructions.last {
            single = ContResult<TransferTransaction, Error> { cb in

                parseTransferTransaction(
                    instruction: instruction,
                    postTokenBalances: transactionInfo.meta?.postTokenBalances ?? [],
                    myAccount: myAccount,
                    accountKeys: transactionInfo.transaction.message.accountKeys
                ) { cb($0) }

            } .map {$0 as AnyHashable}
        }

        // unknown transaction
        else {
            single = .success(nil)
        }

        single.map {
                AnyTransaction(signature: nil, value: $0, slot: nil, blockTime: nil, fee: transactionInfo.meta?.fee, blockhash: transactionInfo.transaction.message.recentBlockhash)
            }.run(onComplete)
    }

    // MARK: - Create account
    fileprivate func parseCreateAccountTransaction(
        instruction: ParsedInstruction,
        initializeAccountInstruction: ParsedInstruction?
    ) -> Result<CreateAccountTransaction, Error> {
        let info = instruction.parsed?.info
        let initializeAccountInfo = initializeAccountInstruction?.parsed?.info

        let fee = info?.lamports?.convertToBalance(decimals: Decimals.SOL)
        let token = getTokenWithMint(initializeAccountInfo?.mint)

        return .success(
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
    fileprivate func parseCloseAccountTransaction(
        closedTokenPubkey: String?,
        preBalances: [Lamports]?,
        preTokenBalance: TokenBalance?
    ) -> Result<CloseAccountTransaction, Error> {
        var reimbursedAmountLamports: Lamports?

        if (preBalances?.count ?? 0) > 1 {
            reimbursedAmountLamports = preBalances![1]
        }

        let reimbursedAmount = reimbursedAmountLamports?.convertToBalance(decimals: Decimals.SOL)
        let token = getTokenWithMint(preTokenBalance?.mint)

        return .success(
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
    fileprivate func parseTransferTransaction(
        instruction: ParsedInstruction,
        postTokenBalances: [TokenBalance],
        myAccount: String?,
        accountKeys: [Account.Meta],
        onComplete: @escaping (Result<TransferTransaction, Error>) -> Void
    ) {
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

            return onComplete(.success(
                                TransferTransaction(
                                    source: source,
                                    destination: destination,
                                    amount: lamports?.convertToBalance(decimals: source!.token.decimals),
                                    myAccount: myAccount
                                ))
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

                return onComplete(.success(
                                    TransferTransaction(
                                        source: source,
                                        destination: destination,
                                        amount: lamports?.convertToBalance(decimals: source?.token.decimals),
                                        myAccount: myAccount
                                    ))
                )
            } else {

                ContResult<AccountInfo?, Error>.init { cb in
                    getAccountInfo(account: sourcePubkey, retryWithAccount: destinationPubkey) { cb($0) }
                }.map { info in
                    let token = getTokenWithMint(info?.mint.base58EncodedString)
                    source = Wallet(pubkey: sourcePubkey, lamports: nil, token: token)
                    destination = Wallet(pubkey: destinationPubkey, lamports: nil, token: token)

                    return TransferTransaction(
                        source: source,
                        destination: destination,
                        amount: lamports?.convertToBalance(decimals: source?.token.decimals),
                        myAccount: myAccount
                    )
                }.run(onComplete)
            }
        }
    }

    // MARK: - Swap
    fileprivate func getSwapInstructionIndex(
        instructions: [ParsedInstruction]
    ) -> Int? {
        instructions.firstIndex(
            where: {
                $0.programId == "DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1" /*swap ocra*/ ||
                    $0.programId == "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL" /*main deprecated*/ ||
                    $0.programId == "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8" /*main deprecated*/
            })
    }

    fileprivate func parseSwapTransaction(
        index: Int,
        instruction: ParsedInstruction,
        innerInstructions: [InnerInstruction]?,
        myAccountSymbol: String?,
        onComplete: @escaping (Result<SwapTransaction, Error>) -> Void
    ) {
        // get data
        guard let data = instruction.data else {
            onComplete(.success(SwapTransaction.empty))
            return
        }
        let buf = Base58.decode(data)

        // get instruction index
        guard let instructionIndex = buf.first,
              instructionIndex == 1,
              let swapInnerInstruction = innerInstructions?.first(where: {$0.index == index})
        else {
            onComplete(.success(SwapTransaction.empty))
            return
        }

        // get instructions
        let transfersInstructions = swapInnerInstruction.instructions.filter {$0.parsed?.type == "transfer"}
        guard transfersInstructions.count >= 2 else {
            onComplete(.success(SwapTransaction.empty))
            return
        }

        let sourceInstruction = transfersInstructions[0]
        let destinationInstruction = transfersInstructions[1]
        let sourceInfo = sourceInstruction.parsed?.info
        let destinationInfo = destinationInstruction.parsed?.info

        // group request
        var request1: ContResult<AccountInfo?, Error>!

        var request2: ContResult<AccountInfo?, Error>!

        // get source
        var sourcePubkey: PublicKey?
        if let sourceString = sourceInfo?.source {
            sourcePubkey = PublicKey(string: sourceString)
            request1 = ContResult<AccountInfo?, Error>.init { cb in
                getAccountInfo(account: sourceString, retryWithAccount: sourceInfo?.destination) { cb($0) }
            }
        }

        var destinationPubkey: PublicKey?
        if let destinationString = destinationInfo?.destination {
            destinationPubkey = PublicKey(string: destinationString)
            request2 = ContResult<AccountInfo?, Error>.init { cb in
                getAccountInfo(account: destinationString, retryWithAccount: destinationInfo?.source) { cb($0) }
            }
        }
        // get token account info
        ContResult<[AccountInfo?], Error>.map2(request1, request2) { result1, result2 in
            return [result1, result2]
        }.map { params -> SwapTransaction in
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
        }.recover { _ in
            .success(SwapTransaction(
                source: nil,
                sourceAmount: nil,
                destination: nil,
                destinationAmount: nil,
                myAccountSymbol: myAccountSymbol
            ))
        }.run(onComplete)
    }

    // MARK: - Helpers
    fileprivate func getTokenWithMint(_ mint: String?) -> Token {
        guard let mint = mint else {return .unsupported(mint: nil)}
        return solanaSDK.supportedTokens.first(where: {$0.address == mint}) ?? .unsupported(mint: mint)
    }

    fileprivate func getAccountInfo(account: String?, retryWithAccount retryAccount: String? = nil, onComplete: @escaping (Result<AccountInfo?, Error>) -> Void) {

        guard let account = account else { return onComplete(.success(nil)) }

        ContResult.init { cb in
            solanaSDK.api.getAccountInfo(
                account: account,
                decodedTo: AccountInfo.self
            ) { cb($0) }
        }.map { $0.data.value }
        .recover {
            if case SolanaError.nullValue = $0, let retryAccount = retryAccount {
                return ContResult<AccountInfo?, Error>.init { cb in
                    self.getAccountInfo(account: retryAccount, retryWithAccount: nil) { cb($0) }
                }
            }
            return .failure($0)
        }
        .run(onComplete)
    }
}
