//
//  HMACTests.swift
//  
//
//  Created by Dezork
//

import Foundation
import XCTest
@testable import Solana

class HMACTests: XCTestCase {

    private let key = "key".bytes
    private let data = "test".data(using: .utf8)!

    func testSha512Function() {
        let expected = """
            287a0fb89a7fbdfa5b5538636918e537a5b83065e4ff331268b7aaa115dde047a9b0f4fb\
            5b828608fc0b6327f10055f7637b058e9e0dbb9e698901a3e6dd461c
            """
        let res = hmacSha512(message: data, key: Data(key))
        
        XCTAssertEqual(expected, res?.hexString)
    }
    
    func testMD5() {
        let expected = """
            1d4a2743c056e467ff3f09c9af31de7e
            """
        let res = hmac(hmacAlgorithm: .MD5, message: data, key: Data(key))

        XCTAssertEqual(expected, res?.hexString)
    }

    func testSHA1() {
        let expected = """
            671f54ce0c540f78ffe1e26dcf9c2a047aea4fda
            """
        let res = hmac(hmacAlgorithm: .SHA1, message: data, key: Data(key))
        
        XCTAssertEqual(expected, res?.hexString)
    }

    func testSHA224() {
        let expected = """
            76b34b643e71d7d92afd4c689c0949cbe0c5445feae907aac532a5a1
            """
        let res = hmac(hmacAlgorithm: .SHA224, message: data, key: Data(key))
        
        XCTAssertEqual(expected, res?.hexString)
    }
    
    func testSHA256() {
        let expected = """
            02afb56304902c656fcb737cdd03de6205bb6d401da2812efd9b2d36a08af159
            """
        let res = hmac(hmacAlgorithm: .SHA256, message: data, key: Data(key))
        
        XCTAssertEqual(expected, res?.hexString)
    }
    
    func testSHA384() {
        let expected = """
            160a099ad9d6dadb46311cb4e6dfe98aca9ca519c2e0fedc8dc45da419b1\
            173039cc131f0b5f68b2bbc2b635109b57a8
            """
        let res = hmac(hmacAlgorithm: .SHA384, message: data, key: Data(key))
        
        XCTAssertEqual(expected, res?.hexString)
    }
    
    func testSHA512() {
        let expected = """
            287a0fb89a7fbdfa5b5538636918e537a5b83065e4ff331268b7aaa11\
            5dde047a9b0f4fb5b828608fc0b6327f10055f7637b058e9e0dbb9e698901a3e6dd461c
            """
        let res = hmac(hmacAlgorithm: .SHA512, message: data, key: Data(key))
        
        XCTAssertEqual(expected, res?.hexString)
    }
}
