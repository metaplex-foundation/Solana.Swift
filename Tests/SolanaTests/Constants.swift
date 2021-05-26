//
//  Constants.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 25/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import Solana

struct Constants {
    static let testingPublicKey = try! Solana.PublicKey(string: "11111111111111111111111111111111")
}
