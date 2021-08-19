//
//  Methods+SimpleLock.swift
//
//  Created by Dezork
//

import Foundation
import Solana

extension Api {
    func getAccountInfo<T: BufferLayout>(account: String, decodedTo: T.Type) -> Result<BufferInfo<T>, Error>? {
        var result: Result<BufferInfo<T>, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getAccountInfo(account: account, decodedTo: decodedTo) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getMultipleAccounts<T: BufferLayout>(pubkeys: [String], decodedTo: T.Type) -> Result<[BufferInfo<T>], Error>? {
        var result: Result<[BufferInfo<T>], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getMultipleAccounts(pubkeys: pubkeys, decodedTo: decodedTo) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    func getProgramAccounts<T: BufferLayout>(publicKey: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"), decodedTo: T.Type) -> Result<[ProgramAccount<T>], Error>? {
        var result: Result<[ProgramAccount<T>], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getProgramAccounts(publicKey: publicKey, configs: configs, decodedTo: decodedTo) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    func getBlockCommitment(block: UInt64) -> Result<BlockCommitment, Error>? {
        var result: Result<BlockCommitment, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getBlockCommitment(block: block) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getClusterNodes() -> Result<[ClusterNodes], Error>? {
        var result: Result<[ClusterNodes], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getClusterNodes {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getBlockTime(block: UInt64) -> Result<Date?, Error>? {
        var result: Result<Date?, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getBlockTime(block: block) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getConfirmedBlock(slot: UInt64, encoding: String = "json") -> Result<ConfirmedBlock, Error>? {
        var result: Result<ConfirmedBlock, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getConfirmedBlock(slot: slot, encoding: encoding) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) -> Result<[UInt64], Error>? {
        var result: Result<[UInt64], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getConfirmedBlocks(startSlot: startSlot, endSlot: endSlot) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) -> Result<[UInt64], Error>? {
        var result: Result<[UInt64], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getConfirmedBlocksWithLimit(startSlot: startSlot, limit: limit) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil) -> Result<[SignatureInfo], Error>? {
        var result: Result<[SignatureInfo], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getConfirmedSignaturesForAddress2(account: account, configs: configs) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getConfirmedTransaction(transactionSignature: String) -> Result<TransactionInfo, Error>? {
        var result: Result<TransactionInfo, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getConfirmedTransaction(transactionSignature: transactionSignature) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getEpochInfo(commitment: Commitment? = nil) -> Result<EpochInfo, Error>? {
        var result: Result<EpochInfo, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getEpochInfo(commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getEpochSchedule() -> Result<EpochSchedule, Error>? {
        var result: Result<EpochSchedule, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getEpochSchedule {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getRecentBlockhash(commitment: Commitment? = nil) ->  Result<String, Error>? {
        var result: Result<String, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getRecentBlockhash(commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getFeeRateGovernor() -> Result<Fee, Error>? {
        var result: Result<Fee, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getFeeRateGovernor {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil) -> Result<Fee, Error>? {
        var result: Result<Fee, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getFeeCalculatorForBlockhash(blockhash: blockhash, commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getFees(commitment: Commitment? = nil) -> Result<Fee, Error>? {
        var result: Result<Fee, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getFees(commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getFirstAvailableBlock() -> Result<UInt64, Error>? {
        var result: Result<UInt64, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getFirstAvailableBlock {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getGenesisHash() -> Result<String, Error>? {
        var result: Result<String, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getGenesisHash {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getIdentity() -> Result<Identity, Error>? {
        var result: Result<Identity, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getIdentity {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getVersion() -> Result<Version, Error>? {
        var result: Result<Version, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getVersion {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getInflationGovernor(commitment: Commitment? = nil) -> Result<InflationGovernor, Error>? {
        var result: Result<InflationGovernor, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getInflationGovernor(commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getInflationRate() -> Result<InflationRate, Error>? {
        var result: Result<InflationRate, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getInflationRate {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getLargestAccounts() -> Result<[LargestAccount], Error>? {
        var result: Result<[LargestAccount], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getLargestAccounts {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent") -> Result<UInt64, Error>? {
        var result: Result<UInt64, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getMinimumBalanceForRentExemption(dataLength: dataLength, commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getRecentPerformanceSamples(limit: UInt64) -> Result<[PerformanceSample], Error>? {
        var result: Result<[PerformanceSample], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getRecentPerformanceSamples(limit: limit) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getVoteAccounts(commitment: Commitment? = nil) ->  Result<VoteAccounts, Error>? {
        var result: Result<VoteAccounts, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getVoteAccounts(commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func minimumLedgerSlot() -> Result<UInt64, Error>? {
        var result: Result<UInt64, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.minimumLedgerSlot {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getSlot(commitment: Commitment? = nil) -> Result<UInt64, Error>? {
        var result: Result<UInt64, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getSlot {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getSlotLeader(commitment: Commitment? = nil) -> Result<String, Error>? {
        var result: Result<String, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getSlotLeader(commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getTransactionCount(commitment: Commitment? = nil) -> Result<UInt64, Error>? {
        var result: Result<UInt64, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getTransactionCount(commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil) -> Result<StakeActivation, Error>? {
        var result: Result<StakeActivation, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getStakeActivation(stakeAccount: stakeAccount, configs: configs) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getSignatureStatuses(pubkeys: [String], configs: RequestConfiguration? = nil) -> Result<[SignatureStatus?], Error>? {
        var result: Result<[SignatureStatus?], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getSignatureStatuses(pubkeys: pubkeys, configs: configs) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) -> Result<TokenAccountBalance, Error>? {
        var result: Result<TokenAccountBalance, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getTokenAccountBalance(pubkey: pubkey, commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Result<[TokenAccount<AccountInfo>], Error>? {
        var result: Result<[TokenAccount<AccountInfo>], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getTokenAccountsByDelegate(pubkey: pubkey, mint: mint, programId: programId, configs: configs) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getTokenAccountsByOwner(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Result<[TokenAccount<AccountInfo>], Error>? {
        var result: Result<[TokenAccount<AccountInfo>], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getTokenAccountsByOwner(pubkey: pubkey, mint: mint, programId: programId, configs: configs) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
    
    func getTokenSupply(pubkey: String, commitment: Commitment? = nil) -> Result<TokenAmount, Error>? {
        var result: Result<TokenAmount, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getTokenSupply(pubkey: pubkey, commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }

    func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) -> Result<[TokenAmount], Error>? {
        var result: Result<[TokenAmount], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.getTokenLargestAccounts(pubkey: pubkey, commitment: commitment) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        return result
    }
}
