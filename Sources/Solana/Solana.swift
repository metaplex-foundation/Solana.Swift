//
//  SolanaSDK.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import Foundation
import Alamofire
import RxSwift

public protocol SolanaAccountStorage {
    func save(_ account: Solana.Account) throws
    var account: Solana.Account? {get}
    func clear()
}

public class Solana {
    // MARK: - Properties
    public let accountStorage: SolanaAccountStorage
    var endpoint: RpcApiEndPoint
    var _swapPool: [Pool]?
    public private(set) var supportedTokens = [Token]()

    // MARK: - Initializer
    public init(endpoint: RpcApiEndPoint, accountStorage: SolanaAccountStorage) {
        self.endpoint = endpoint
        self.accountStorage = accountStorage

        // get supported tokens
        let parser = TokensListParser()
        supportedTokens = (try? parser.parse(network: endpoint.network.cluster)) ?? []
    }
    
    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        bcMethod: String = #function,
        parameters: [Encodable?] = [],
        onComplete: @escaping (Result<T, Error>) -> ()
    ) {
        let url = endpoint.url
        let params = parameters.compactMap {$0}
        
        let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)
        let requestAPI = RequestAPI(method: bcMethod, params: params)
        
        Logger.log(message: "\(method.rawValue) \(bcMethod) [id=\(requestAPI.id)] \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")", event: .request, apiMethod: bcMethod)
        
        var urlRequest: URLRequest!
        do {
            urlRequest = try URLRequest(url: url, method: method, headers: [.contentType("application/json")])
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
        } catch {
            onComplete(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            Logger.log(message: String(data: data ?? Data(), encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)

            if let error = error {
                onComplete(.failure(error))
                return
            }
            
            guard let response = response, let httpURLResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpURLResponse.statusCode) else {
                onComplete(.failure(SolanaError.unknown))
                return
            }
            
            guard let data = data,
                  let result = try? JSONDecoder().decode(Response<T>.self, from: data).result else {
                onComplete(.failure(SolanaError.unknown))
                return
            }
            onComplete(.success(result))
        }
        task.resume()
    }

    // MARK: - Helper
    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        bcMethod: String = #function,
        parameters: [Encodable?] = []
    ) -> Single<T> {
        return Single.create { emitter in
            self.request(method: method, bcMethod: bcMethod, parameters: parameters) { (result: Result<T, Error>) in
                switch result {
                case .success(let r):
                    emitter(.success(r))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
