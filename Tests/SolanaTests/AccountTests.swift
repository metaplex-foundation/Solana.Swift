import XCTest
@testable import Solana
import TweetNacl

class AccountTests: XCTestCase {
    func testPublicKeyFromString() throws {
        let fromPublicKey = try Solana.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        XCTAssertEqual(fromPublicKey.bytes, [6, 26, 217, 208, 83, 135, 21, 72, 83, 126, 222, 62, 38, 24, 73, 163, 223, 183, 253, 2, 250, 188, 117, 178, 35, 200, 228, 106, 219, 133, 61, 12])
        
        let toPublicKey = try Solana.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        XCTAssertEqual(toPublicKey.bytes, [235, 122, 188, 208, 216, 117, 235, 194, 109, 161, 177, 129, 163, 51, 155, 62, 242, 163, 22, 149, 187, 122, 189, 188, 103, 130, 115, 188, 173, 205, 229, 170])
        
        let programPubkey = try Solana.PublicKey(string: "11111111111111111111111111111111")
        XCTAssertEqual(programPubkey.bytes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    }
    
    func testPublicKeyToString() throws {
        let key = try Solana.PublicKey(data: Data([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3", key.base58EncodedString)
        
        let key1 = try Solana.PublicKey(string: "CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3")
        XCTAssertEqual("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3", key1.base58EncodedString)
        
        let key2 = try Solana.PublicKey(string: "11111111111111111111111111111111")
        XCTAssertEqual("11111111111111111111111111111111", key2.base58EncodedString)
        
        let key3 = try Solana.PublicKey(data: Data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]))
        XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], key3.bytes)
    }
    
    func testCreateAccountFromSecretKey() throws {
        let secretKey = Base58.decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")
        XCTAssertNotNil(secretKey)
        
        let account = try Solana.Account(secretKey: Data(secretKey))
        
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", account.publicKey.base58EncodedString)
        XCTAssertEqual(64, account.secretKey.count)
    }
    
    #if canImport(UIKit)
    func testDerivedKeychain() throws {
        var keychain = try Keychain(seedString: "miracle pizza supply useful steak border same again youth silver access hundred", network: "mainnet-beta")
        
        keychain = try keychain.derivedKeychain(at: "m/501'/0'/0/0")
        
        let keys = try NaclSign.KeyPair.keyPair(fromSeed: keychain.privateKey!)
        
        XCTAssertEqual([UInt8](keys.secretKey), [109, 13, 53, 177, 69, 45, 146, 184, 62, 55, 105, 133, 210, 89, 131, 218, 248, 101, 47, 64, 81, 56, 229, 25, 173, 154, 12, 41, 66, 143, 230, 117, 39, 247, 185, 4, 85, 137, 50, 166, 147, 184, 221, 75, 110, 103, 16, 222, 41, 94, 247, 132, 43, 62, 172, 243, 95, 204, 190, 143, 153, 16, 10, 197])
    }
    #endif
    
    func testRestoreAccountFromSeedPhrase() throws {
        let phrase12 = "miracle pizza supply useful steak border same again youth silver access hundred"
            .components(separatedBy: " ")
        let account12 = try Solana.Account(phrase: phrase12, network: .mainnetBeta)
        XCTAssertEqual(account12.publicKey.base58EncodedString, "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr")
        
        let phrase24 = "budget resource fluid mutual ankle salt demise long burst sting doctor ozone risk magic wrap clap post pole jungle great update air interest abandon"
            .components(separatedBy: " ")
        let account24 = try Solana.Account(phrase: phrase24, network: .mainnetBeta)
        XCTAssertEqual(account24.publicKey.base58EncodedString, "9avcmC97zLPwHKXiDz6GpXyjvPn9VcN3ggqM5gsRnjvv")
    }
    
}
