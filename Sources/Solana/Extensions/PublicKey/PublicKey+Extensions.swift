import Foundation

public extension PublicKey {
    static let tokenProgramId = PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!
    static let sysvarRent = PublicKey(string: "SysvarRent111111111111111111111111111111111")!
    @available(*, deprecated, renamed: "systemProgramId")
    static let programId = PublicKey(string: "11111111111111111111111111111111")!
    static let systemProgramId = PublicKey(string: "11111111111111111111111111111111")!
    static let wrappedSOLMint = PublicKey(string: "So11111111111111111111111111111111111111112")!
    static let ownerValidationProgramId = PublicKey(string: "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5")!
    static let swapHostFeeAddress = PublicKey(string: "AHLwq66Cg3CuDJTFtwjPfwjJhifiv6rFwApQNKgX57Yg")!
    static let splAssociatedTokenAccountProgramId = PublicKey(string: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!
}
