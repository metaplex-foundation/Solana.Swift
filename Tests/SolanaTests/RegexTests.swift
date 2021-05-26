//
//  RegexTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 18/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class RegexTests: XCTestCase {

    func testPubkeyRegex() throws {
        let regex = NSRegularExpression.publicKey
        XCTAssertTrue(regex.matches("3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"))
        XCTAssertTrue(regex.matches("5iqF9UNh6AB7hPkJiGFLixJuPeMqp9VVq7iJ9t8c3ZF"))
        XCTAssertTrue(regex.matches("CEUFMRm2cdr6UqCfPXAQnWqnndNVWuyk3QiC5gBN2k5"))
        XCTAssertTrue(regex.matches("JnfsZ5HahZnvnKsRZMsAf3D92e92C33NyufnrqAt2WL"))
        XCTAssertTrue(regex.matches("299wbEddCsswPqT9gv2gNAE6bxETMBKVuTrwdwtgvSMV"))
        XCTAssertTrue(regex.matches("2NrFPGGW8BKKU8hD48G3HhTXXRycd7fYbUKNEnmeLA97"))
        XCTAssertTrue(regex.matches("2kAQ6EL8Xhp1VXjM6JmwzVexFkWHYJoLnJNHRMWdkHKE"))
        XCTAssertTrue(regex.matches("36sp9nNMm4jja1h8wcvBYKyUYaqvHV1sfuBSJ5ddjcMd"))
        XCTAssertTrue(regex.matches("3Jc5CLBGd9dPfiXQ6K6ANu69g9mg9gHyKXxA2Gsk9qFa"))
        XCTAssertTrue(regex.matches("41r5NV6uj386xwXmeKwQ8V6mTH6Y4aouth5yQzeReFJt"))

        XCTAssertFalse(regex.matches("3h1zGmCwsRJnVk5BuR"))
        XCTAssertFalse(regex.matches("41r5NV6uj386xwXmeKwQ8V6mTH6Y4aouth5yQzeReFJt333"))
        XCTAssertFalse(regex.matches("41r5NV6uj386xwXm-KwQ8V6mTH6Y4+outh5yQzeReFJt"))
    }

}
