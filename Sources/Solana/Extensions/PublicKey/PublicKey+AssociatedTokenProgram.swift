//
//  PublicKey+AssociatedTokenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 29/04/2021.
//

import Foundation

// https://github.com/solana-labs/solana-web3.js/blob/dfb4497745c9fbf01e9633037bf9898dfd5adf94/src/publickey.ts#L224

// MARK: - Constants
private var maxSeedLength = 32
private let gf1 = NaclLowLevel.gf([1])

private extension Int {
    func toBool() -> Bool {
        self != 0
    }
}

extension Solana.PublicKey {
    public static func associatedTokenAddress(
        walletAddress: Solana.PublicKey,
        tokenMintAddress: Solana.PublicKey
    ) throws -> Solana.PublicKey {
        try findProgramAddress(
            seeds: [
                walletAddress.data,
                Solana.PublicKey.tokenProgramId.data,
                tokenMintAddress.data
            ],
            programId: .splAssociatedTokenAccountProgramId
        ).0
    }

    // MARK: - Helpers
    private static func findProgramAddress(
        seeds: [Data],
        programId: Self
    ) throws -> (Self, UInt8) {
        for nonce in stride(from: UInt8(255), to: 0, by: -1) {
            let seedsWithNonce = seeds + [Data([nonce])]
            do {
                let address = try createProgramAddress(
                    seeds: seedsWithNonce,
                    programId: programId
                )
                return (address, nonce)
            } catch {
                continue
            }
        }
        throw Solana.Error.notFound
    }

    private static func createProgramAddress(
        seeds: [Data],
        programId: Solana.PublicKey
    ) throws -> Solana.PublicKey {
        // construct data
        var data = Data()
        for seed in seeds {
            if seed.bytes.count > maxSeedLength {
                throw Solana.Error.other("Max seed length exceeded")
            }
            data.append(seed)
        }
        data.append(programId.data)
        data.append("ProgramDerivedAddress".data(using: .utf8)!)

        // hash it
        let hash = data.sha256()
        let publicKeyBytes = Bignum(number: hash.hexString, withBase: 16).data

        // check it
        if isOnCurve(publicKeyBytes: publicKeyBytes).toBool() {
            throw Solana.Error.other("Invalid seeds, address must fall off the curve")
        }
        return try Solana.PublicKey(data: publicKeyBytes)
    }

    private static func isOnCurve(publicKeyBytes: Data) -> Int {
        var r = [[Int64]](repeating: NaclLowLevel.gf(), count: 4)

        var t = NaclLowLevel.gf(),
            chk = NaclLowLevel.gf(),
            num = NaclLowLevel.gf(),
            den = NaclLowLevel.gf(),
            den2 = NaclLowLevel.gf(),
            den4 = NaclLowLevel.gf(),
            den6 = NaclLowLevel.gf()

        NaclLowLevel.set25519(&r[2], gf1)
        NaclLowLevel.unpack25519(&r[1], publicKeyBytes.bytes)
        NaclLowLevel.S(&num, r[1])
        NaclLowLevel.M(&den, num, NaclLowLevel.D)
        NaclLowLevel.Z(&num, num, r[2])
        NaclLowLevel.A(&den, r[2], den)

        NaclLowLevel.S(&den2, den)
        NaclLowLevel.S(&den4, den2)
        NaclLowLevel.M(&den6, den4, den2)
        NaclLowLevel.M(&t, den6, num)
        NaclLowLevel.M(&t, t, den)

        NaclLowLevel.pow2523(&t, t)
        NaclLowLevel.M(&t, t, num)
        NaclLowLevel.M(&t, t, den)
        NaclLowLevel.M(&t, t, den)
        NaclLowLevel.M(&r[0], t, den)

        NaclLowLevel.S(&chk, r[0])
        NaclLowLevel.M(&chk, chk, den)
        if NaclLowLevel.neq25519(chk, num).toBool() {
            NaclLowLevel.M(&r[0], r[0], NaclLowLevel.I)
        }

        NaclLowLevel.S(&chk, r[0])
        NaclLowLevel.M(&chk, chk, den)

        if NaclLowLevel.neq25519(chk, num).toBool() {
            return 0
        }
        return 1
    }
}
