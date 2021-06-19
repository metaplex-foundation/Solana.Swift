# Solana
[![Swift](https://github.com/ajamaica/Solana.Swift/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/ajamaica/Solana.Swift/actions/workflows/swift.yml)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.png?v=103)](https://opensource.org/licenses/mit-license.php)  
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)

This is a open source library on pure swift for Solana protocol.

The objective is to create a cross platform, fully functional, highly tested and less depencies as posible. The project is still at initial stage. Lots of changes chan happen to the exposed api.

# Features
- [x] Sign and send transactions.
- [x] Key pair generation
- [x] RPC configuration.
- [x] SPM integration
- [ ] Sockets
- [ ] Fully tested
- [ ] Few libraries requirement

## Requirements

- iOS 11.0+ / macOS 10.13+ / tvOS 11.0+ / watchOS 3.0+
- Swift 5.3+

## Installation

From Xcode 11, you can use [Swift Package Manager](https://swift.org/package-manager/) to add Solana.swift to your project.

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/ajamaica/Solana.Swift`
- Select "brach" with "master"

If you encounter any problem or have a question on adding the package to an Xcode project, I suggest reading the [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)  guide article from Apple.

## Other

### Ideas and plans

The code and api will be evoling for this initial fork please keep that in mind. I am planning adding support for othr development layers like React Native or flutter.

RxSwift maybe be removed from the library or at least moved to a diferent sublibrary. Every call will have a unit test.

### Disclaimer 

It was originally fork from the [P2p-org library](https://github.com/p2p-org/solana-swift "P2p-org library"). Now is way far than the original implementation. Most of parts where rewriten.

### Support it 

SOL: CN87nZuhnFdz74S9zn3bxCcd5ZxW55nwvgAv5C2Tz3K7
