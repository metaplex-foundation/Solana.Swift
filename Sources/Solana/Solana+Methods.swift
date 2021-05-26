//
//  SolanaSDK+Methods.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/27/20.
//
// NOTE: THIS FILE IS GENERATED FROM APIGEN PACKAGE, DO NOT MAKE CHANGES DIRECTLY INTO IT, PLEASE EDIT METHODS.JSON AND methodsGen.js TO MAKE CHANGES (IN ../APIGen FOLDER)

import Foundation
import RxSwift

public extension Solana {
    func getAccountInfo<T: BufferLayout>(account: String, decodedTo: T.Type) -> Single<BufferInfo<T>> {
        let configs = RequestConfiguration(encoding: "base64")
		return (request(parameters: [account, configs]) as Single<Rpc<BufferInfo<T>?>>)
            .map {
                guard let value = $0.value else {
                    throw Error.other("Could not retrieve account info")
                }
                return value
            }
	}
	func getBalance(account: String? = nil, commitment: Commitment? = nil) -> Single<UInt64> {
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString
        else {return .error(Error.unauthorized)}

		return (request(parameters: [account, RequestConfiguration(commitment: commitment)]) as Single<Rpc<UInt64>>)
			.map {$0.value}
	}
	func getBlockCommitment(block: String) -> Single<BlockCommitment> {
		request(parameters: [block])
	}
	func getBlockTime(block: UInt64) -> Single<Date?> {
		(request(parameters: [block]) as Single<Int64?>)
            .map {timestamp in
                guard let timestamp = timestamp else {return nil}
                return Date(timeIntervalSince1970: TimeInterval(timestamp))
            }
	}
	func getClusterNodes() -> Single<ClusterNodes> {
		request()
	}
	func getConfirmedBlock(slot: UInt64, encoding: String = "json") -> Single<ConfirmedBlock?> {
		request(parameters: [slot, encoding])
	}
	func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) -> Single<[UInt64]> {
		request(parameters: [startSlot, endSlot])
	}
	func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) -> Single<[UInt64]> {
		request(parameters: [startSlot, limit])
	}
	func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) -> Single<[String]> {
		request(parameters: [account, startSlot, endSlot])
	}
	func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil) -> Single<[SignatureInfo]> {
		request(parameters: [account, configs])
	}
	func getConfirmedTransaction(transactionSignature: String) -> Single<TransactionInfo> {
        request(parameters: [transactionSignature, "jsonParsed"])
	}
	func getEpochInfo(commitment: Commitment? = nil) -> Single<EpochInfo> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getEpochSchedule() -> Single<EpochSchedule> {
		request()
	}
	func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil) -> Single<Fee> {
		(request(parameters: [blockhash, RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	func getFeeRateGovernor() -> Single<Fee> {
		(request() as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	func getFees(commitment: Commitment? = nil) -> Single<Fee> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	func getFirstAvailableBlock() -> Single<UInt64> {
		request()
	}
	func getGenesisHash() -> Single<String> {
		request()
	}
	func getIdentity() -> Single<String> {
		request()
	}
	func getInflationGovernor(commitment: Commitment? = nil) -> Single<InflationGovernor> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getInflationRate() -> Single<InflationRate> {
		request()
	}
	func getLargestAccounts() -> Single<[LargestAccount]> {
		(request() as Single<Rpc<[LargestAccount]>>)
			.map {$0.value}
	}
	func getLeaderSchedule(epoch: UInt64? = nil, commitment: Commitment? = nil) -> Single<[String: [Int]]?> {
		request(parameters: [epoch, RequestConfiguration(commitment: commitment)])
	}
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent") -> Single<UInt64> {
		request(parameters: [dataLength, RequestConfiguration(commitment: commitment)])
	}
	func getMultipleAccounts(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<[BufferInfo<AccountInfo>]?> {
		(request(parameters: [pubkeys, configs]) as Single<Rpc<[BufferInfo<AccountInfo>]?>>)
			.map {$0.value}
	}
    func getProgramAccounts<T: BufferLayout>(publicKey: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"), decodedTo: T.Type) -> Single<[ProgramAccount<T>]> {
        request(parameters: [publicKey, configs])
    }
	func getRecentBlockhash(commitment: Commitment? = nil) -> Single<String> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
            .map {$0.blockhash}
            .map { recentBlockhash in
                if recentBlockhash == nil {
                    throw Error.other("Blockhash not found")
                }
                return recentBlockhash!
            }
	}
	func getRecentPerformanceSamples(limit: UInt64) -> Single<[PerformanceSample]> {
		request(parameters: [limit])
	}
	func getSignatureStatuses(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<[SignatureStatus?]> {
		(request(parameters: [pubkeys, configs]) as Single<Rpc<[SignatureStatus?]>>)
			.map {$0.value}
	}
	func getSlot(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getSlotLeader(commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil) -> Single<StakeActivation> {
		request(parameters: [stakeAccount, configs])
	}
	func getSupply(commitment: Commitment? = nil) -> Single<Supply> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Supply>>)
			.map {$0.value}
	}
	func getTransactionCount(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAccountBalance> {
		(request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAccountBalance>>)
            .map {
                if UInt64($0.value.amount) == nil {
                    throw Error.invalidResponse(ResponseError(code: nil, message: "Could not retrieve balance", data: nil))
                }
                return $0.value
            }
	}
    func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount<AccountInfo>]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount<AccountInfo>]>>)
			.map {$0.value}
	}
    func getTokenAccountsByOwner(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount<AccountInfo>]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount<AccountInfo>]>>)
			.map {$0.value}
	}
	func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) -> Single<[TokenAmount]> {
		(request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<[TokenAmount]>>)
			.map {$0.value}
	}
	func getTokenSupply(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAmount> {
		(request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAmount>>)
			.map {$0.value}
	}
	func getVersion() -> Single<Version> {
		request()
	}
	func getVoteAccounts(commitment: Commitment? = nil) -> Single<VoteAccounts> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func minimumLedgerSlot() -> Single<UInt64> {
		request()
	}
	func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [account, lamports, RequestConfiguration(commitment: commitment)])
	}
	internal func sendTransaction(serializedTransaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionID> {
		request(parameters: [serializedTransaction, configs])
            .catchError { error in
                // Modify error message
                if let error = error as? Error {
                    switch error {
                    case .invalidResponse(let response) where response.message != nil:
                        var message = response.message
                        if let readableMessage = response.data?.logs
                            .first(where: {$0.contains("Error:")})?
                            .components(separatedBy: "Error: ")
                            .last {
                            message = readableMessage
                        } else if let readableMessage = response.message?
                            .components(separatedBy: "Transaction simulation failed: ")
                            .last {
                            message = readableMessage
                        }

                        return .error(Error.invalidResponse(ResponseError(code: response.code, message: message, data: response.data)))
                    default:
                        break
                    }
                }
                return .error(error)
            }
	}
	func simulateTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionStatus> {
		(request(parameters: [transaction, configs]) as Single<Rpc<TransactionStatus>>)
			.map {$0.value}
	}
	func setLogFilter(filter: String) -> Single<String?> {
		request(parameters: [filter])
	}
	func validatorExit() -> Single<Bool> {
		request()
	}

    // MARK: - Additional methods
    func getMintData(
        mintAddress: PublicKey,
        programId: PublicKey = .tokenProgramId
    ) -> Single<Mint> {
        getAccountInfo(account: mintAddress.base58EncodedString, decodedTo: Mint.self)
            .map {
                if $0.owner != programId.base58EncodedString {
                    throw Error.other("Invalid mint owner")
                }

                if let data = $0.data.value {
                    return data
                }

                throw Error.other("Invalid data")
            }
    }
}
