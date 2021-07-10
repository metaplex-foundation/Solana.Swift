import XCTest
@testable import Solana

class MockSolanaLiveEventsDelegate: SolanaSocketEventsDelegate {
    
        
    var onConected: (() -> Void)? = nil
    var onDisconnected: (() -> Void)? = nil
    var onAccountNotification: ((Response<AccountNotification<[String]>>) -> Void)? = nil
    var onSignatureNotification: ((Response<SignatureNotification>) -> Void)? = nil
    var onSubscribed: ((UInt64, String) -> Void)? = nil
    var onUnsubscribed: ((String) -> Void)? = nil

    func connected() {
        onConected?()
    }
    
    
    func accountNotification(notification: Response<AccountNotification<[String]>>) {
        onAccountNotification?(notification)
    }
    
    
    func signatureNotification(notification: Response<SignatureNotification>) {
        onSignatureNotification?(notification)
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
        }
        socket.start(delegate: delegate)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketAccountUnSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        var expected_id: String?
        var expected_socket: UInt64?
        delegate.onConected = {
            expected_id = try! self.socket.accountSubscribe(publickey: "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g").get()
        }
        delegate.onSubscribed = { (socket, id) in
            XCTAssertEqual(expected_id, id)
            expected_socket = socket
            try! self.socket.accountUnsubscribe(socketId: socket).get()
        }
        delegate.onUnsubscribed = { (socket) in
            expectation.fulfill()
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
        let result = try! JSONDecoder().decode(Response<AccountNotification<[String]>>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.result?.value.lamports, 41083620)
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
