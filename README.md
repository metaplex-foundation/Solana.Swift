# Solana + RxSolana
[![Swift](https://github.com/ajamaica/Solana.Swift/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/ajamaica/Solana.Swift/actions/workflows/swift.yml)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.png?v=103)](https://opensource.org/licenses/mit-license.php)  
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)

This is a open source library on pure swift for Solana protocol.

The objective is to create a cross platform, fully functional, highly tested and less depencies as posible. The project is still at initial stage. Lots of changes chan happen to the exposed api.

Please check my wallet [Summer](https://github.com/ajamaica/Summer).

# Features
- [x] Sign and send transactions.
- [x] Key pair generation
- [x] RPC configuration.
- [x] SPM integration
- [x] Few libraries requirement (TweetNACL, Starscream). Rxswift is optional.
- [x] Fully tested (53%)
- [x] Sockets
- [ ] Type-safe Transaction templates
- [ ] Documentation with guides and examples
- [ ] Program template library for common tasks

# Usage

### Initialization
Set the NetworkingRouter and setup your enviroment. You can also pass your own **URLSession** with your own settings. Use this router to initialize the sdk with an object that conforms the SolanaAccountStorage protocol
```swift
let network = NetworkingRouter(endpoint: .devnetSolana)
let solana = Solana(router: network, accountStorage: self.accountStorage)
```
### Keypair generation

SolanaAccountStorage interface is used to return the generated accounts. The actual storage of the accout is handled by the client. Please make sure this account is stored correctly (you can encrypt it on the keychain). The retrived accout is Serializable. Inside Account you will fine the phrase, publicKey and secretKey.

Example using Memory (NOT RECOMEMDED).
```swift
class InMemoryAccountStorage: SolanaAccountStorage {
    
    private var _account: Account?
    func save(_ account: Account) -> Result<Void, Error> {
        _account = account
        return .success(())
    }
    var account: Result<Account, Error> {
        if let account = _account {
            return .success(account)
        }
        return .failure(SolanaError.unauthorized)
    }
    func clear() -> Result<Void, Error> {
        _account = nil
        return .success(())
    }
}
```

Example using KeychainSwift.
```swift
enum SolanaAccountStorageError: Error {
    case unauthorized
}
struct KeychainAccountStorageModule: SolanaAccountStorage {
    private let tokenKey = "Summer"
    private let keychain = KeychainSwift()
    
    func save(_ account: Account) -> Result<Void, Error> {
        do {
            let data = try JSONEncoder().encode(account)
            keychain.set(data, forKey: tokenKey)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    var account: Result<Account, Error> {
        // Read from the keychain
        guard let data = keychain.getData(tokenKey) else { return .failure(SolanaAccountStorageError.unauthorized)  }
        if let account = try? JSONDecoder().decode(Account.self, from: data) {
            return .success(account)
        }
        return .failure(SolanaAccountStorageError.unauthorized)
    }
    func clear() -> Result<Void, Error> {
        keychain.clear()
        return .success(())
    }
}
```
### RPC api calls

We support [45](https://github.com/ajamaica/Solana.Swift/tree/master/Sources/Solana/Api "Check the Api folder") rpc api calls with and without Rx. Normal calls will return a callback (onComplete) and RxSolana will return Single  . If the call requires address in base58 format, if is null it will default to the one returned by SolanaAccountStorage.

Example using callback

Gets Accounts info.
```swift
solana.api.getAccountInfo(account: account.publicKey.base58EncodedString, decodedTo: AccountInfo.self) { result in
// process result
}
```
Gets Balance
```swift
 solana.api.getBalance(account: account.publicKey.base58EncodedString){ result in
 // process result
 }
```

#### Example using RX

Gets Accounts info.
```swift
solana.api.getAccountInfo(account: account.publicKey.base58EncodedString, decodedTo: AccountInfo.self).subscribe()
```
Gets Balance

```swift
 solana.api.getBalance(account: account.publicKey.base58EncodedString).subscribe()
```

### Actions

Actions are predifined program interfaces that construct the required inputs for the most common tasks in Solana ecosystems. You can see them as bunch of code that implements solana task using rpc calls. This also support optional Rx

We support 12.
- closeTokenAccount: Closes token account
- getTokenWallets: get token accounts
- createAssociatedTokenAccount: Opens associated token account
- sendSOL : Sends SOL native token
- createTokenAccount: Opens token account
- sendSPLTokens: Sends tokens
- findSPLTokenDestinationAddress : Finds address of a token of a address
- **serializeAndSendWithFee**: Serializes and signs the transaction. Then it it send to the blockchain.
- getMintData: Get mint data for token
- serializeTransaction: Serializes transaction
- getPools: Get all available pools. Very intensive
- swap: Swaps 2 tokens from pool.

#### Example with callback

Create an account token

```swift
solana.action.createTokenAccount( mintAddress: mintAddress) { result in
// process
}
```
Sending sol
```swift
let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: 10
){ result in
 // process
}
```
#### Example with Rx

Create an account token
```swift
solana.action.createTokenAccount( mintAddress: mintAddress) .subscribe()
```

Sending sol
```swift
let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
solana.action.sendSOL(
            to: toPublicKey,
            amount: 10
).subscribe()
```
## Requirements

- iOS 11.0+ / macOS 10.13+ / tvOS 11.0+ / watchOS 3.0+
- Swift 5.3+

## Installation

From Xcode 11, you can use [Swift Package Manager](https://swift.org/package-manager/) to add Solana.swift to your project.

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/ajamaica/Solana.Swift`
- Select "brach" with "master"
- Select Solana and RxSwift (fully optional)

If you encounter any problem or have a question on adding the package to an Xcode project, I suggest reading the [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)  guide article from Apple.

## Other

### Ideas and plans

The code and api will be evoling for this initial fork please keep that in mind. I am planning adding support for othr development layers like React Native or flutter.

RxSwift maybe be removed from the library or at least moved to a diferent sublibrary. Every call will have a unit test.

### Support it 

SOL: CN87nZuhnFdz74S9zn3bxCcd5ZxW55nwvgAv5C2Tz3K7
