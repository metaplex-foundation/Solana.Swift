//
//  BufferLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation

public protocol BufferLayout: Codable {
    init?(_ keys: [String: [UInt8]])
    static func layout() -> [(key: String?, length: Int)]
}

extension BufferLayout {
    public static var BUFFER_LENGTH: Int {
        layout().reduce(0, {$0 + ($1.key != nil ? $1.length: 0)})
    }

    public static var span: UInt64 {
        UInt64(layout().reduce(0, {$0 + $1.length}))
    }
}

extension Solana {

    public struct Buffer<T: BufferLayout>: Codable {
        public let value: T?

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            // decode parsedJSON
            if let parsedData = try? container.decode(T.self) {
                value = parsedData
                return
            }

            // Unable to get parsed data, fallback to decoding base64
            let stringData = (try? container.decode([String].self).first) ?? (try? container.decode(String.self))
            guard let string = stringData, let data = Data(base64Encoded: string)?.bytes,
                  data.count >= T.BUFFER_LENGTH
            else {
                value = T([:])
                return
            }

            var dict = [String: [UInt8]]()

            let layout = T.layout()

            var from: Int = 0
            for i in 0..<layout.count {
                let to: Int = from + layout[i].length
                let bytes = Array(data[from..<to])
                if let key = layout[i].key {
                    dict[key] = bytes
                }
                from = to
            }
            value = T(dict)
        }
    }
}
