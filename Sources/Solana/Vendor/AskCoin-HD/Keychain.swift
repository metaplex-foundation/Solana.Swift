//
//  ASKKeychain.swift
//  AskCoin-HD
//
//  Created by 仇弘扬 on 2017/8/14.
//  Copyright © 2017年 askcoin. All rights reserved.
//
import Foundation

let BTCKeychainMainnetPrivateVersion: UInt32 = 0x0488ADE4
let BTCKeychainMainnetPublicVersion: UInt32 = 0x0488B21E

let BTCKeychainTestnetPrivateVersion: UInt32 = 0x04358394
let BTCKeychainTestnetPublicVersion: UInt32 = 0x043587CF

let BTCMasterKeychainPath = "m"
let BTCKeychainHardenedSymbol = "'"
let BTCKeychainPathSeparator = "/"

public class Keychain: NSObject {

	enum KeyDerivationError: Error {
		case indexInvalid
		case pathInvalid
		case privateKeyNil
		case publicKeyNil
		case chainCodeNil
		case notMasterKey
	}

	public var privateKey: Data?
	private var chainCode: Data?

	fileprivate var isMasterKey = false
    var isTestnet = false

	var depth: UInt8 = 0
	var hardened = false
	var index: UInt32 = 0

	override init() {

	}

    public convenience init?(seedString: String, network: String) throws {
        guard let seedData = Mnemonic(phrase: seedString.components(separatedBy: " ")) else {
            return nil
        }
        guard let keyData = "Bitcoin seed".data(using: .utf8) else {
            return nil
        }
        guard let hmac = hmacSha512(message: Data(seedData.seed), key: keyData) else {
            return nil
        }
        self.init(hmac: hmac.bytes)
        isMasterKey = true
        isTestnet = network == "devnet" || network == "testnet"
	}

	public init(hmac: [UInt8]) {
		privateKey = Data(hmac[0..<32])
		chainCode = Data(hmac[32..<64])
	}

	public lazy var identifier: Data? = {
		if let pubKey = self.publicKey {
			return pubKey.ask_BTCHash160()
		}
		return nil
	}()

	public var parentFingerprint: UInt32 = 0

	public lazy var fingerprint: UInt32 = {
		if let id = self.identifier {
			return UInt32(bytes: id.bytes[0..<4])
		}
		return 0
	}()

	private lazy var publicKey: Data? = {
		guard let prvKey = self.privateKey else {
			return nil
		}
		return CKSecp256k1.generatePublicKey(withPrivateKey: prvKey, compression: true)
	}()

	// MARK: - Extended private key
	public lazy var extendedPrivateKey: String = {
		self.extendedPrivateKeyData.ask_base58Check()
	}()

	public lazy var extendedPrivateKeyData: Data = {
		guard self.privateKey != nil else {
			return Data()
		}

		var toReturn = Data()

		let version = !isTestnet ? BTCKeychainMainnetPrivateVersion : BTCKeychainTestnetPrivateVersion
		toReturn += self.extendedKeyPrefix(with: version)

		toReturn += UInt8(0).ask_hexToData()

		if let prikey = self.privateKey {
			toReturn += prikey
		}

		return toReturn
	}()

	// MARK: - Extended public key
	public lazy var extendedPublicKey: String = {
		self.extendedPublicKeyData.ask_base58Check()
	}()

	public lazy var extendedPublicKeyData: Data = {
		guard self.publicKey != nil else {
			return Data()
		}

		var toReturn = Data()

		let version = !isTestnet ? BTCKeychainMainnetPublicVersion : BTCKeychainTestnetPublicVersion
		toReturn += self.extendedKeyPrefix(with: version)

		if let pubkey = self.publicKey {
			toReturn += pubkey
		}

		return toReturn
	}()

	func extendedKeyPrefix(with version: UInt32) -> Data {
		var toReturn = Data()

		let versionData = version.ask_hexToData()
		toReturn += versionData

		let depthData = depth.ask_hexToData()
		toReturn += depthData

		let parentFPData = parentFingerprint.ask_hexToData()
		toReturn += parentFPData

		let childIndex = hardened ? (0x80000000 | index) : index
		let childIndexData = childIndex.ask_hexToData()
		toReturn += childIndexData

		if let cCode = chainCode {
			toReturn += cCode
		} else {
			print(KeyDerivationError.chainCodeNil)
		}

		return toReturn
	}

	public func derivedKeychain(at path: String) throws -> Keychain {

		if path == BTCMasterKeychainPath || path == BTCKeychainPathSeparator || path == "" {
			return self
		}

		var paths = path.components(separatedBy: BTCKeychainPathSeparator)
		if path.hasPrefix(BTCMasterKeychainPath) {
			paths.removeFirst()
		}

		var kc = self

		for indexString in paths {
			var isHardened = false
			var temp = indexString
			if indexString.hasSuffix(BTCKeychainHardenedSymbol) {
				isHardened = true
				temp = temp.substring(to: temp.index(temp.endIndex, offsetBy: -1))
			}
			if let index = UInt32(temp) {
				kc = try kc.derivedKeychain(at: index, hardened: isHardened)
				continue
			}
			throw KeyDerivationError.pathInvalid
		}

		return kc
	}

	public func derivedKeychain(at index: UInt32, hardened: Bool = true) throws -> Keychain {

		let edge: UInt32 = 0x80000000

		guard (edge & UInt32(index)) == 0 else {
			throw KeyDerivationError.indexInvalid
		}

		guard let prvKey = privateKey else {
			throw KeyDerivationError.privateKeyNil
		}

		guard let pubKey = publicKey else {
			throw KeyDerivationError.publicKeyNil
		}

		guard let chCode = chainCode else {
			throw KeyDerivationError.chainCodeNil
		}

		var data = Data()

		if hardened {
			let padding: UInt8 = 0
			data += padding.ask_hexToData()
			data += prvKey
		} else {
			data += pubKey
		}

		let indexBE = hardened ? (edge + index) : index
		data += indexBE.ask_hexToData()

        let digestArray = hmacSha512(message: data, key: chCode)!.bytes

		let factor = BInt(data: Data(digestArray[0..<32]))
		let curveOrder = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")

        let derivedKeychain = Keychain(hmac: digestArray)

		let pkNum = BInt(data: Data(prvKey))

		let pkData = ((pkNum + factor) % curveOrder).data

		derivedKeychain.privateKey = pkData
		derivedKeychain.depth = depth + 1
		derivedKeychain.parentFingerprint = fingerprint
		derivedKeychain.index = index
		derivedKeychain.hardened = hardened

		return derivedKeychain
	}

}
