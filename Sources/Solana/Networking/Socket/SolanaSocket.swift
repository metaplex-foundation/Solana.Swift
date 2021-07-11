import Starscream
import Foundation

enum SolanaSocketError: Error {
    case disconnected
    case couldNotSerialize
}
public protocol SolanaSocketEventsDelegate: AnyObject {
    func connected()
    func accountNotification(notification: Response<AccountNotification<[String]>>)
    func signatureNotification(notification: Response<SignatureNotification>)
    func logsNotification(notification: Response<LogsNotification>)
    func unsubscribed(id: String)
    func subscribed(socketId: UInt64, id: String)
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
    private weak var delegate: SolanaSocketEventsDelegate?
    
    init(endpoint: RPCEndpoint, enableDebugLogs: Bool = false){
        self.request = URLRequest(url: endpoint.urlWebSocket)
        self.request.timeoutInterval = 5
        self.enableDebugLogs = enableDebugLogs
    }
    
    public func start(delegate: SolanaSocketEventsDelegate) {
        self.delegate = delegate
        self.socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    public func stop(){
        self.socket?.disconnect()
        self.delegate = nil
    }
    
    public func accountSubscribe(publickey: String) -> Result<String, Error> {
        let method: SocketMethod = .accountSubscribe
        let params: [Encodable] = [ publickey, ["encoding":"jsonParsed", "commitment": "recent"] ]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    func accountUnsubscribe(socketId: UInt64) -> Result<String, Error> {
        let method: SocketMethod = .accountUnsubscribe
        let params: [Encodable] = [socketId]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    public func signatureSubscribe(signature: String) -> Result<String, Error> {
        let method: SocketMethod = .signatureSubscribe
        let params: [Encodable] = [signature, ["commitment": "confirmed"]]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    func signatureUnsubscribe(socketId: UInt64) -> Result<String, Error> {
        let method: SocketMethod = .signatureUnsubscribe
        let params: [Encodable] = [socketId]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    public func logsSubscribe(mentions: [String]) -> Result<String, Error> {
        let method: SocketMethod = .logsSubscribe
        let params: [Encodable] = [["mentions": mentions], ["commitment": "confirmed"]]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    public func logsSubscribeAll() -> Result<String, Error> {
        let method: SocketMethod = .logsSubscribe
        let params: [Encodable] = [["all"], ["commitment": "confirmed"]]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    func logsUnsubscribe(socketId: UInt64) -> Result<String, Error> {
        let method: SocketMethod = .logsUnsubscribe
        let params: [Encodable] = [socketId]
        let request = SolanaRequest(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }
    
    private func writeToSocket(request: SolanaRequest) -> Result<String, Error> {
        guard let jsonData = try? JSONEncoder().encode(request) else { return Result.failure(SolanaSocketError.couldNotSerialize) }
        guard let socket = socket else { return Result.failure(SolanaSocketError.disconnected) }
        socket.write(data: jsonData)
        return Result.success(request.id)
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
            // TODO: Fix this mess code
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            if let jsonType = jsonResponse["method"] as? String,
               let type = SocketMethod(rawValue: jsonType) {
                
                switch type {
                case .accountNotification:
                    let notification = try JSONDecoder().decode(Response<AccountNotification<[String]>>.self, from: data)
                    delegate?.accountNotification(notification: notification)
                case .signatureNotification:
                    let notification = try JSONDecoder().decode(Response<SignatureNotification>.self, from: data)
                    delegate?.signatureNotification(notification: notification)
                case .logsNotification:
                    let notification = try JSONDecoder().decode(Response<LogsNotification>.self, from: data)
                    delegate?.logsNotification(notification: notification)
                default: break
                }
                
            } else {
                if let subscription = try? JSONDecoder().decode(Response<UInt64>.self, from: data),
                   let socketId = subscription.result,
                   let id = subscription.id{
                    delegate?.subscribed(socketId: socketId, id: id)
                }
                
                if let subscription = try? JSONDecoder().decode(Response<Bool>.self, from: data),
                   subscription.result == true,
                   let id = subscription.id{
                    delegate?.unsubscribed(id: id)
                }
            }
        } catch let error {
            delegate?.error(error: error)
        }
    }
    
}
