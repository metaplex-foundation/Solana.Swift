import Foundation

public struct DerivablePath: Hashable {
    // MARK: - Nested type
    public enum DerivableType: String, CaseIterable {
        case bip32Deprecated
        case bip44Change
        case bip44
        var prefix: String {
            switch self {
            case .bip32Deprecated:
                return "m/501'"
            case .bip44, .bip44Change:
                return "m/44'/501'"
            }
        }
    }

    // MARK: - Properties
    public let type: DerivableType
    public let walletIndex: Int
    public let accountIndex: Int?

    public init(type: DerivablePath.DerivableType, walletIndex: Int, accountIndex: Int? = nil) {
        self.type = type
        self.walletIndex = walletIndex
        self.accountIndex = accountIndex
    }

    public static var `default`: Self {
        .init(
            type: .bip44Change,
            walletIndex: 0,
            accountIndex: 0
        )
    }

    public var rawValue: String {
        var value = type.prefix
        switch type {
        case .bip32Deprecated:
            value += "/\(walletIndex)'/0/\(accountIndex ?? 0)"
        case .bip44:
            value += "/\(walletIndex)'"
        case .bip44Change:
            value += "/\(walletIndex)'/0'"
        }
        return value
    }
}
