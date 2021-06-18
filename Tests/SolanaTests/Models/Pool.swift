import Foundation
import XCTest
@testable import Solana

class Pool: XCTestCase {
    var pool: Solana.Pool!
    override func setUpWithError() throws {
        pool = Solana.Pool(
            address: Solana.PublicKey(string: "95DKMPsJWAir7d1K3kSAyyqaad2RoQ4daxFKXS8XshUe")!,
            tokenAInfo: .init(
                mintAuthorityOption: 0,
                mintAuthority: nil,
                supply: 0,
                decimals: 9,
                isInitialized: true,
                freezeAuthorityOption: 0,
                freezeAuthority: nil
            ),
            tokenBInfo: .init(
                mintAuthorityOption: 0,
                mintAuthority: nil,
                supply: 9998952948380399,
                decimals: 6,
                isInitialized: true,
                freezeAuthorityOption: 0,
                freezeAuthority: nil
            ),
            poolTokenMint: .init(
                mintAuthorityOption: 1,
                mintAuthority: Solana.PublicKey(string: "7fR7tU2qpEMH575rC5XejDYbNf8DqVi9ZFq3VGKJypjC")!,
                supply: 6693416,
                decimals: 8,
                isInitialized: true,
                freezeAuthorityOption: 0,
                freezeAuthority: nil
            ),
            swapData: .init(
                version: 1,
                isInitialized: true,
                nonce: 252,
                tokenProgramId: Solana.PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!,
                tokenAccountA: Solana.PublicKey(string: "EFs4FuHmb3bbC4BUD4tu188x4k5UMmxPbm6PZQjDnxL6")!,
                tokenAccountB: Solana.PublicKey(string: "8Vu3KXjZJPUdUf7cRWR9ukXuahoV9vNU5ExEo52SNH4G")!,
                tokenPool: Solana.PublicKey(string: "9JURZeTahE3YZvtkNdSJRLFUcqXqE5yQjYFhuM9cqcm7")!,
                mintA: Solana.PublicKey(string: "So11111111111111111111111111111111111111112")!,
                mintB: Solana.PublicKey(string: "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt")!,
                feeAccount: Solana.PublicKey(string: "FuKSC9kecoxjWtvMKWjEHBNq7FiGGke25QfGekrUMwYA")!,
                tradeFeeNumerator: 25,
                tradeFeeDenominator: 10000,
                ownerTradeFeeNumerator: 5,
                ownerTradeFeeDenominator: 10000,
                ownerWithdrawFeeNumerator: 0,
                ownerWithdrawFeeDenominator: 0,
                hostFeeNumerator: 20,
                hostFeeDenominator: 100,
                curveType: 0,
                payer: Solana.PublicKey(string: "11111111111111111111111111111111")!
            ),
            tokenABalance: .init(
                uiAmount: 125.511223013,
                amount: "125511223013",
                decimals: 9,
                uiAmountString: "125.511223013"
            ),
            tokenBBalance: .init(
                uiAmount: 678.859522,
                amount: "678859522",
                decimals: 6,
                uiAmountString: "678.859522"
            )
        )
    }
    
    func testAmountCalculation() throws {
        let inputAmount: Double = 1
        let expectedEstimatedAmount = 5.352587
        
        let originalInputAmount: UInt64 = inputAmount.toLamport(decimals: pool.tokenAInfo.decimals)
        let estimatedAmountResult = pool.estimatedAmount(forInputAmount: originalInputAmount, includeFees: true)
        
        XCTAssertEqual(estimatedAmountResult?.convertToBalance(decimals: 6), expectedEstimatedAmount)
    }
}
