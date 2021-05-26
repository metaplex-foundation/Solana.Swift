//
//  SolanaSDK.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import Foundation
import RxAlamofire
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
    var endpoint: APIEndPoint
    var _swapPool: [Pool]?
    public private(set) var supportedTokens = [Token]()

    // MARK: - Initializer
    public init(endpoint: APIEndPoint, accountStorage: SolanaAccountStorage) {
        self.endpoint = endpoint
        self.accountStorage = accountStorage

        // get supported tokens
        let parser = TokensListParser()
        supportedTokens = (try? parser.parse(network: endpoint.network.cluster)) ?? []
    }

    // MARK: - Helper
    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        path: String = "",
        bcMethod: String = #function,
        parameters: [Encodable?] = []
    ) -> Single<T> {
        guard let url = URL(string: endpoint.url + path) else {
            return .error(Error.invalidRequest(reason: "Invalid URL"))
        }
        let params = parameters.compactMap {$0}

        let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)

        let requestAPI = RequestAPI(method: bcMethod, params: params)

        Logger.log(message: "\(method.rawValue) \(bcMethod) [id=\(requestAPI.id)] \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")", event: .request, apiMethod: bcMethod)

        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: [.contentType("application/json")])
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)

            return RxAlamofire.request(urlRequest)
                .responseData()
                .map {(response, data) -> T in
                    // Print
                    Logger.log(message: String(data: data, encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)

                    // Print
                    guard (200..<300).contains(response.statusCode) else {
                        // Decode errror
                        throw Error.invalidResponse(ResponseError(code: response.statusCode, message: nil, data: nil))
                    }
                    let response = try JSONDecoder().decode(Response<T>.self, from: data)
                    if let result = response.result {
                        return result
                    }
                    if let error = response.error {
                        throw Error.invalidResponse(error)
                    }
                    throw Error.unknown
                }
                .take(1)
                .asSingle()
        } catch {
            return .error(error)
        }
    }
}
