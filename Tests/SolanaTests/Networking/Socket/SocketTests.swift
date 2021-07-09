import XCTest
@testable import Solana

final class SocketTests: XCTestCase {
    let socket = SolanaSocket(endpoint: .devnetSolana, enableDebugLogs: true)
    
    func test_xx() {
        let expectation = XCTestExpectation()
        socket.start(delegate: self)
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testDecodingSOLAccountNotification() {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80221533},"value":{"data":["","base64"],"executable":false,"lamports":41083620,"owner":"11111111111111111111111111111111","rentEpoch":185}},"subscription":46133}}"#
        let result = try! JSONDecoder().decode(SOLAccountNotification.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.result?.value.lamports, 41083620)
        XCTAssertThrowsError(try JSONDecoder().decode(TokenAccountNotification.self, from: string.data(using: .utf8)!))
    }
    
    func testDecodingTokenAccountNotification() {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80216037},"value":{"data":{"parsed":{"info":{"isNative":false,"mint":"kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6","owner":"6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm","state":"initialized","tokenAmount":{"amount":"390000101","decimals":5,"uiAmount":3900.00101,"uiAmountString":"3900.00101"}},"type":"account"},"program":"spl-token","space":165},"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":185}},"subscription":42765}}"#
                
        let result = try! JSONDecoder().decode(TokenAccountNotification.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.params?.result?.value.data.parsed.info.tokenAmount.amount, "390000101")
    }
    
    func testDecodingSignatureNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"signatureNotification","params":{"result":{"context":{"slot":80768508},"value":{"err":null}},"subscription":43601}}"#
        
        let result = try JSONDecoder().decode(SocketResponse<SignatureNotification>.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.method, "signatureNotification")
    }
}

extension SocketTests: SolanaLiveEventsDelegate {
    func connected() {
        _ = socket.accountSubscribe(publickey: "9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g") // air drop
        _ = socket.signatureSubscribe(signature: "3FKbHYJpGH2QHuZrueYiL3DcLorLKTAfetWQXShvW2VWppwdzbr7mGvcg7MWwXQWL1p7o1C7CEiV4ZA1fed2L5b2")
    }
    
    func disconnected(reason: String, code: UInt16) {
        debugPrint(reason)
    }
    
    func error(error: Error?) {
        
    }
    
    func accountSubscribe(notification: SOLAccountNotification) {
        
    }
    
    func signatureUnsubscribe() {
        
    }
}
