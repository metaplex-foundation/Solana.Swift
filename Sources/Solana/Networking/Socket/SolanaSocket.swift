import Starscream
import Foundation

public protocol SolanaLiveEventsDelegate: AnyObject {
    func connected()
    func accountSubscribe(notification: SOLAccountNotification)
    func signatureUnsubscribe()
    func disconnected(reason: String, code: UInt16)
    func error(error: Error?)
}

public protocol SolanaWebSocketEvents: AnyObject {
    func connected(_: [String: String])
    func disconnected(_: String, _: UInt16)
    func text(_: String)
    func binary(_: Data)
    func pong(_: Data?)
    func ping(_: Data?)
    func error(_: Error?)
    func viabilityChanged(_: Bool)
    func reconnectSuggested(_: Bool)
    func cancelled()
}

public class SolanaSocket {
    private var socket: WebSocket?
    private var enableDebugLogs: Bool
    private var request: URLRequest
    private weak var delegate: SolanaLiveEventsDelegate?
    
    init(endpoint: RPCEndpoint, enableDebugLogs: Bool = false){
        self.request = URLRequest(url: endpoint.urlWebSocket)
        self.request.timeoutInterval = 5
        self.enableDebugLogs = enableDebugLogs
    }
    
    public func start(delegate: SolanaLiveEventsDelegate) {
        self.delegate = delegate
        self.socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    public func stop(){
        self.socket?.disconnect()
        self.delegate = nil
    }
    
    public func accountSubscribe(publickey: String) -> Bool {
        let method: SocketMethod = .accountSubscribe
        let params: [Encodable] = [ publickey, ["encoding":"jsonParsed", "commitment": "recent"] ]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    public func signatureSubscribe(signature: String) -> Bool {
        let method: SocketMethod = .signatureSubscribe
        let params: [Encodable] = [signature, ["commitment": "confirmed"]]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    func accountUnsubscribe(id: String) -> Bool{
        let method: SocketMethod = .accountUnsubscribe
        let params: [Encodable] = [id]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    func signatureUnsubscribe(id: String) -> Bool{
        let method: SocketMethod = .signatureUnsubscribe
        let params: [Encodable] = [id]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    private func writeToSocket(request: SolanaRequest) -> Bool {
        guard let jsonData = try? JSONEncoder().encode(request) else { return false }
        guard let socket = socket else { return false }
        socket.write(data: jsonData)
        return true
    }
}

extension SolanaSocket: WebSocketDelegate {

    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        log(event: event)
        switch event {
        case .connected:
            delegate?.connected()
        case .disconnected(let reason, let code):
            delegate?.disconnected(reason: reason, code: code)
        case .text(let string):
            onText(string: string)
        case .binary: break
        case .ping: break
        case .pong: break
        case .viabilityChanged: break
        case .reconnectSuggested: break
        case .cancelled: break
        case .error(let error): break
            self.delegate?.error(error: error)
        }
    }
    
    private func log(event: WebSocketEvent){
        switch event {
        case .connected(let headers):
            if enableDebugLogs { debugPrint("conected with headers \(headers)") }
        case .disconnected(let reason, let code):
            if enableDebugLogs { debugPrint("disconnected with reason \(reason) \(code)") }
        case .text(let string):
            if enableDebugLogs { debugPrint("text \(string)") }
        case .binary:
            if enableDebugLogs { debugPrint("binary") }
        case .ping:
            if enableDebugLogs { debugPrint("ping") }
        case .pong:
            if enableDebugLogs { debugPrint("pong") }
        case .viabilityChanged(let visible):
            if enableDebugLogs { debugPrint("viabilityChanged \(visible)") }
        case .reconnectSuggested(let reconnect):
            if enableDebugLogs { debugPrint("reconnectSuggested \(reconnect)") }
        case .cancelled:
            if enableDebugLogs { debugPrint("cancelled") }
        case .error(let error):
            if enableDebugLogs { debugPrint("error \(error?.localizedDescription ?? "")") }
        }
    }
    
    private func onText(string: String) {
        guard let data = string.data(using: .utf8) else { return }
        do {
            // TODO: Fix this
            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
            if let jsonType = jsonResponse["method"] as? String,
               let type = SocketMethod(rawValue: jsonType) {
                switch type {
                case .accountSubscribe:
                    let notification = try JSONDecoder().decode(SOLAccountNotification.self, from: data)
                    delegate?.accountSubscribe(notification: notification)
                default: break
                }
            }
            
        } catch let error {
            delegate?.error(error: error)
        }
    }
    
}
