import XCTest
@testable import Solana

class MockSolanaLiveEventsDelegate: SolanaSocketEventsDelegate {
    
    var onConected: (() -> Void)? = nil
    var onDisconnected: (() -> Void)? = nil
    var onAccountNotification: ((Response<BufferInfo<AccountInfo>>) -> Void)? = nil
    var onSignatureNotification: ((Response<SignatureNotification>) -> Void)? = nil
    var onLogsNotification: ((Response<LogsNotification>) -> Void)? = nil
    var onProgramNotification: ((Response<ProgramNotification<[String]>>) -> Void)? = nil
    var onSubscribed: ((UInt64, String) -> Void)? = nil
    var onUnsubscribed: ((String) -> Void)? = nil

    func connected() {
        onConected?()
    }
    
    
    func accountNotification(notification: Response<BufferInfo<AccountInfo>>) {
        onAccountNotification?(notification)
    }
    
    
    func signatureNotification(notification: Response<SignatureNotification>) {
        onSignatureNotification?(notification)
    }
    
    func logsNotification(notification: Response<LogsNotification>) {
        onLogsNotification?(notification)
    }
    
    func programNotification(notification: Response<ProgramNotification<[String]>>) {
        onProgramNotification?(notification)
    }
    
    func subscribed(socketId: UInt64, id: String) {
        onSubscribed?(socketId, id)
    }
    
    func unsubscribed(id: String) {
        onUnsubscribed?(id)
    }
    
    func disconnected(reason: String, code: UInt16) {
        onDisconnected?()
    }
    
    func error(error: Error?) {
        
    }
}

final class SocketTests: XCTestCase {
    let socket = SolanaSocket(endpoint: .devnetSolana, enableDebugLogs: true)
    
    func testSocketConnected() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        delegate.onConected = {
            expectation.fulfill()
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketAccountSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.accountSubscribe(publickey: "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g").get()
        }
        delegate.onSubscribed = { (socket, id) in
            expectation.fulfill()
            XCTAssertEqual(expected_id, id)
            self.socket.stop()
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketAccountUnSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.accountSubscribe(publickey: "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g").get()
        }
        delegate.onSubscribed = { (socket, id) in
            XCTAssertEqual(expected_id, id)
            _ = try! self.socket.accountUnsubscribe(socketId: socket).get()
        }
        delegate.onUnsubscribed = { (id) in
            expectation.fulfill()
            self.socket.stop()
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    // This tests can fail if no one ask for Airdrop. The Account subscribed is the airdrop account
    func testSocketAccountNotification() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.accountSubscribe(publickey: "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g").get()
        }
        delegate.onSubscribed = { (socket, id) in
            XCTAssertEqual(expected_id, id)
            
        }
        delegate.onAccountNotification = { notification in
            XCTAssertNotNil(notification.params?.result)
            expectation.fulfill()
            self.socket.stop()
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketLogsSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.logsSubscribe(mentions: ["9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g"]).get()
        }
        delegate.onSubscribed = { (socket, id) in
            expectation.fulfill()
            XCTAssertEqual(expected_id, id)
            self.socket.stop()
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketLogsUnSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.logsSubscribe(mentions: ["9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g"]).get()
        }
        delegate.onSubscribed = { (socketId, id) in
            _ = try! self.socket.logsUnsubscribe(socketId: socketId).get()
            XCTAssertEqual(expected_id, id)
        }
        
        delegate.onUnsubscribed = { id in
            expectation.fulfill()
            self.socket.stop()
        }
        
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketLogsNotification() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.logsSubscribe(mentions: ["9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g"]).get()
        }
        delegate.onSubscribed = { (socket, id) in
            XCTAssertEqual(expected_id, id)
        }
        
        delegate.onLogsNotification = { notification in
            XCTAssertNotNil(notification.params?.result)
            expectation.fulfill()
            self.socket.stop()
        }
        
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketLogsNotificationAll() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.logsSubscribeAll().get()
        }
        delegate.onSubscribed = { (socket, id) in
            XCTAssertEqual(expected_id, id)
        }
        
        delegate.onLogsNotification = { notification in
            XCTAssertNotNil(notification.params?.result)
            expectation.fulfill()
            self.socket.stop()
        }
        
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketSignatureSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.signatureSubscribe(signature: "Nfq1kEFqe5dBbTnprNZZVfnzvYJAKpUoibhYFBbaBXp37L7bAip89Qbs6mtiybQprY2GucMTgkxWPx81dNWh2Mh").get()
        }
        delegate.onSubscribed = { (socket, id) in
            expectation.fulfill()
            XCTAssertEqual(expected_id, id)
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketProgramSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.programSubscribe(publickey: "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g").get()
        }
        delegate.onSubscribed = { (socket, id) in
            expectation.fulfill()
            XCTAssertEqual(expected_id, id)
            self.socket.stop()
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketProgramUnSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.programSubscribe(publickey: "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g").get()
        }
        delegate.onSubscribed = { (socketId, id) in
            XCTAssertEqual(expected_id, id)
            _ = try! self.socket.programUnsubscribe(socketId: socketId).get()
        }
        
        delegate.onUnsubscribed = { id in
            expectation.fulfill()
            self.socket.stop()
        }
        
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketProgramNotification() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        delegate.onConected = {
            expected_id = try! self.socket.programSubscribe(publickey: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA").get()
        }
        delegate.onSubscribed = { (socket, id) in
            XCTAssertEqual(expected_id, id)
        }
        
        delegate.onProgramNotification = { notification in
            XCTAssertNotNil(notification.params?.result)
            expectation.fulfill()
            self.socket.stop()
        }
        
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    
    func testSocketSubscription() {
        let string = """
                {
                   "jsonrpc":"2.0",
                   "result":22529999,
                   "id":"ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E"
                }
            """
        let result = try! JSONDecoder().decode(SocketSubscription.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.id, "ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E")
        XCTAssertEqual(result.result, 22529999)
    }
    
    func testDecodingSOLAccountNotification() {
        let string = """
            {
                "jsonrpc":"2.0",
                "method":"accountNotification",
                "params":{
                   "result":{
                      "context":{
                         "slot":80221533
                      },
                      "value":{
                         "data":[
                            "",
                            "base64"
                         ],
                         "executable":false,
                         "lamports":41083620,
                         "owner":"11111111111111111111111111111111",
                         "rentEpoch":185
                      }
                   },
                   "subscription":46133
                }
             }
        """
        let result = try! JSONDecoder().decode(Response<BufferInfo<AccountInfo>>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.result?.value.lamports, 41083620)
    }
    
    func testDecodingProgramNotification() {
        let string = """
            {
              "jsonrpc": "2.0",
              "method": "programNotification",
              "params": {
                "result": {
                  "context": {
                    "slot": 5208469
                  },
                  "value": {
                    "pubkey": "H4vnBqifaSACnKa7acsxstsY1iV1bvJNxsCY7enrd1hq",
                    "account": {
                      "data": ["11116bv5nS2h3y12kD1yUKeMZvGcKLSjQgX6BeV7u1FrjeJcKfsHPXHRDEHrBesJhZyqnnq9qJeUuF7WHxiuLuL5twc38w2TXNLxnDbjmuR", "base58"],
                      "executable": false,
                      "lamports": 33594,
                      "owner": "11111111111111111111111111111111",
                      "rentEpoch": 636
                    },
                  }
                },
                "subscription": 24040
              }
            }
        """
        let result = try! JSONDecoder().decode(Response<ProgramNotification<[String]>>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.subscription, 24040)
    }
    
    func testDecodingProgramNotification2() {
        let string = """
            {
               "jsonrpc":"2.0",
               "method":"programNotification",
               "params":{
                  "result":{
                     "context":{
                        "slot":67598736
                     },
                     "value":{
                        "account":{
                           "data":"nBuzaooPfhgHcAYxbpZVcXFw1EVjyEKxicgjr8u5NXLBX7xfCGw2E1YiSeeGXLbrKu5MAquX1zwR9P12vhAr1HgSXyTyR66VeevvJcyFKeEDSPWMzh723b8KLxtfd2TyPYYG5HYXx3HcH3Dbxvx17QxADJtRaHYTvde9pB98PsP9FcHWrzkCUZi4bhWtQYeUACGkYCQtMo2hbJuWqBG5rzS45rr9W2YJK",
                           "executable":false,
                           "lamports":2039280,
                           "owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                           "rentEpoch":156
                        },
                        "pubkey":"9FENcWRd1bf8P97e2exQtV3eEZCkaRa3KFFjTkYXpBHQ"
                     }
                  },
                  "subscription":22601084
               }
            }
        """
        let result = try! JSONDecoder().decode(Response<ProgramNotification<String>>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.subscription, 22601084)
    }
    
    
    func testDecodingTokenAccountNotification() {
        let string = """
        {
           "jsonrpc":"2.0",
           "method":"accountNotification",
           "params":{
              "result":{
                 "context":{
                    "slot":80216037
                 },
                 "value":{
                    "data":{
                       "parsed":{
                          "info":{
                             "isNative":false,
                             "mint":"kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6",
                             "owner":"6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm",
                             "state":"initialized",
                             "tokenAmount":{
                                "amount":"390000101",
                                "decimals":5,
                                "uiAmount":3900.00101,
                                "uiAmountString":"3900.00101"
                             }
                          },
                          "type":"account"
                       },
                       "program":"spl-token",
                       "space":165
                    },
                    "executable":false,
                    "lamports":2039280,
                    "owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                    "rentEpoch":185
                 }
              },
              "subscription":42765
           }
        }
        """
        
        let result = try! JSONDecoder().decode(Response<AccountNotification<TokenAccountNotificationData>>.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.params?.result?.value.data?.parsed.info.tokenAmount.amount, "390000101")
    }
    
    func testDecodingSignatureNotification() throws {
        let string = """
            {
               "jsonrpc":"2.0",
               "method":"signatureNotification",
               "params":{
                  "result":{
                     "context":{
                        "slot":80768508
                     },
                     "value":{
                        "err":null
                     }
                  },
                  "subscription":43601
               }
            }
            """
        
        let result = try JSONDecoder().decode(Response<SignatureNotification>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.method, "signatureNotification")
    }
}
