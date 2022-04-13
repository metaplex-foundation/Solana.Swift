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

extension PublicKey {
    public static func associatedTokenAddress(
        walletAddress: PublicKey,
        tokenMintAddress: PublicKey
    ) -> Result<PublicKey, Error> {
        return findProgramAddress(
            seeds: [
                walletAddress.data,
                PublicKey.tokenProgramId.data,
                tokenMintAddress.data
            ],
            programId: .splAssociatedTokenAccountProgramId
        ).map { $0.0 }
    }

    // MARK: - Helpers
    public static func findProgramAddress(
        seeds: [Data],
        programId: Self
    ) -> Result<(Self, UInt8), Error> {
        for nonce in stride(from: UInt8(255), to: 0, by: -1) {
            let seedsWithNonce = seeds + [Data([nonce])]
            if case .success(let publicKey) = createProgramAddress(seeds: seedsWithNonce, programId: programId) {
                return .success((publicKey, nonce))
            }
        }
        return .failure(SolanaError.notFoundProgramAddress)
    }

    private static func createProgramAddress(
        seeds: [Data],
        programId: PublicKey
    ) ->  Result<PublicKey, Error> {
        // construct data
        var data = Data()
        for seed in seeds {
            if seed.bytes.count > maxSeedLength {
                return .failure(SolanaError.other("Max seed length exceeded"))
            }
            data.append(seed)
        }
        data.append(programId.data)
        data.append("ProgramDerivedAddress".data(using: .utf8)!)

        // hash it
        let hash = sha256(data: data)
        let publicKeyBytes = Bignum(number: hash.hexString, withBase: 16).data

        // check it
        if isOnCurve(publicKeyBytes: publicKeyBytes).toBool() {
            return .failure(SolanaError.other("Invalid seeds, address must fall off the curve"))
        }
        guard let newKey = PublicKey(data: publicKeyBytes) else {
            return .failure(SolanaError.invalidPublicKey)
        }
        return .success(newKey)
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
