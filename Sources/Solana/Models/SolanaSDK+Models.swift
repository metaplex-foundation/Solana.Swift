import Foundation

public typealias PublicKeyString = String
public typealias TransactionID = String
public typealias Lamports = UInt64
public typealias Decimals = UInt8

public struct Response<T: Decodable>: Decodable {
    public let jsonrpc: String
    public let id: String?
    public let result: T?
    public let error: ResponseError?
    public let method: String?

    // socket
    public let params: Params<T>?
}

public struct Params<T: Decodable>: Decodable {
    public let result: Rpc<T>?
    public let subscription: UInt64?
}

public struct ResponseError: Decodable {
    public let code: Int?
    public let message: String?
    public let data: ResponseErrorData?
}
public struct ResponseErrorData: Decodable {
    // public let err: ResponseErrorDataError
    public let logs: [String]
}
public struct Rpc<T: Decodable>: Decodable {
    public let context: Context
    public let value: T
}
public struct Context: Decodable {
    public let slot: UInt64
}
public struct BlockCommitment: Decodable {
    public let commitment: [UInt64]?
    public let totalStake: UInt64
}
public struct ClusterNodes: Decodable {
    public let featureSet: UInt64?
    public let pubkey: String
    public let gossip: String
    public let tpu: String?
    public let rpc: String?
    public let version: String?
}
public struct ConfirmedBlock: Decodable {
    public let blockhash: String
    public let previousBlockhash: String
    public let parentSlot: UInt64
    public let transactions: [TransactionInfoFromBlock]
    public let rewards: [Reward]
    public let blockTime: UInt64?
}
public struct Reward: Decodable {
    public let pubkey: String
    public let lamports: Lamports
    public let postBalance: Lamports
    public let rewardType: String?
}
public struct EpochInfo: Decodable {
    public let absoluteSlot: UInt64
    public let blockHeight: UInt64
    public let epoch: UInt64
    public let slotIndex: UInt64
    public let slotsInEpoch: UInt64
}
public struct EpochSchedule: Decodable {
    public let slotsPerEpoch: UInt64
    public let leaderScheduleSlotOffset: UInt64
    public let warmup: Bool
    public let firstNormalEpoch: UInt64
    public let firstNormalSlot: UInt64
}
public struct Fee: Decodable {
    public let feeCalculator: FeeCalculator?
    public let feeRateGovernor: FeeRateGovernor?
    public let blockhash: String?
    public let lastValidSlot: UInt64?
}
public struct FeeCalculator: Decodable {
    public let lamportsPerSignature: Lamports
}
public struct FeeRateGovernor: Decodable {
    public let burnPercent: UInt64
    public let maxLamportsPerSignature: Lamports
    public let minLamportsPerSignature: Lamports
    public let targetLamportsPerSignature: Lamports
    public let targetSignaturesPerSlot: UInt64
}
public struct Identity: Decodable {
    public let identity: String
}
public struct InflationGovernor: Decodable {
    public let foundation: Float64
    public let foundationTerm: Float64
    public let initial: Float64
    public let taper: Float64
    public let terminal: Float64
}
public struct InflationRate: Decodable {
    public let epoch: Float64
    public let foundation: Float64
    public let total: Float64
    public let validator: Float64
}
public struct LargestAccount: Decodable {
    public let lamports: Lamports
    public let address: String
}
public struct ProgramAccount<T: BufferLayout>: Decodable {
    public let account: BufferInfo<T>
    public let pubkey: String
}

public struct BufferInfoJson<T: Decodable>: Decodable {
    public let data: T?
    public let lamports: Lamports
    public let owner: String
    public let executable: Bool
    public let rentEpoch: UInt64
}

public struct BufferInfo<T: BufferLayout>: Decodable {
    public let data: Buffer<T>
    public let lamports: Lamports
    public let owner: String
    public let executable: Bool
    public let rentEpoch: UInt64
}

public struct BufferInfoPureData: Decodable {
    public let data: PureData?
    public let lamports: Lamports
    public let owner: String
    public let executable: Bool
    public let rentEpoch: UInt64
}

public struct PerformanceSample: Decodable {
    public let numSlots: UInt64
    public let numTransactions: UInt64
    public let samplePeriodSecs: UInt
    public let slot: UInt64
}
public struct SignatureInfo: Decodable, Hashable {
    public let signature: String
    public let slot: UInt64?
    public let err: TransactionError?
    public let memo: String?

    public init(signature: String) {
        self.signature = signature
        self.slot = nil
        self.err = nil
        self.memo = nil
    }
}
public struct SignatureStatus: Decodable {
    public let slot: UInt64
    public let confirmations: UInt64?
    public let err: TransactionError?
    public let confirmationStatus: Commitment?
}
public struct TransactionInfo: Decodable {
    public let blockTime: UInt64?
    public let meta: TransactionMeta?
    public let transaction: ConfirmedTransaction
    public let slot: UInt64?
}
public struct TransactionInfoFromBlock: Decodable {
    public let blockTime: UInt64?
    public let meta: TransactionMeta?
    public let transaction: ConfirmedTransactionFromBlock
    public let slot: UInt64?
}
public struct TransactionMeta: Decodable {
    public let err: TransactionError?
    public let fee: Lamports?
    public let innerInstructions: [InnerInstruction]?
    public let logMessages: [String]?
    public let postBalances: [Lamports]?
    public let postTokenBalances: [TokenBalance]?
    public let preBalances: [Lamports]?
    public let preTokenBalances: [TokenBalance]?
}
public struct TransactionError: Decodable, Hashable {

}
public struct InnerInstruction: Decodable {
    let index: UInt32
    let instructions: [ParsedInstruction]
}
public struct TokenBalance: Decodable {
    let accountIndex: UInt64
    let mint: String
    let uiTokenAmount: TokenAccountBalance
}
public struct TransactionStatus: Decodable {
    public let err: TransactionError?
    public let logs: [String]
}
public struct StakeActivation: Decodable {
    public let active: UInt64
    public let inactive: UInt64
    public let state: String
}
public struct Supply: Decodable {
    public let circulating: Lamports
    public let nonCirculating: Lamports
    public let nonCirculatingAccounts: [String]
    public let total: Lamports
}
public struct TokenAccountBalance: Codable, Equatable, Hashable {
    init(uiAmount: Float64?, amount: String, decimals: UInt8?, uiAmountString: String?) {
        self.uiAmount = uiAmount
        self.amount = amount
        self.decimals = decimals
        self.uiAmountString = uiAmountString
    }

    public let uiAmount: Float64?
    public let amount: String
    public let decimals: UInt8?
    public let uiAmountString: String?

    public var amountInUInt64: UInt64? {
        return UInt64(amount)
    }
}
public struct TokenAccount<T: BufferLayout>: Decodable {
    public let pubkey: String
    public let account: BufferInfo<T>
}
public struct TokenAmount: Codable, Hashable {
    public let amount: String
    public let decimals: UInt8
    public let uiAmount: Float64
    public let uiAmountString: String
}
public struct Version: Decodable {
    public let solanaCore: String

    private enum CodingKeys: String, CodingKey {
        case solanaCore = "solana-core"
    }
}
public struct VoteAccounts: Decodable {
    public let current: [VoteAccount]
    public let delinquent: [VoteAccount]
}
public struct VoteAccount: Decodable {
    public let commission: Int
    public let epochVoteAccount: Bool
    public let epochCredits: [[UInt64]]
    public let nodePubkey: String
    public let lastVote: UInt64
    public let activatedStake: UInt64
    public let votePubkey: String
}
