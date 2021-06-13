import Foundation

extension Solana {
    public struct EmptyInfo: BufferLayout {
        init() {}
        
        public init?(_ keys: [String: [UInt8]]) {
            self = EmptyInfo()
        }
        
        public static func layout() -> [(key: String?, length: Int)] {
            []
        }
    }
}
