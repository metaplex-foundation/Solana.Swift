//
//  NetworkingRouterMock.swift
//
//
//  Created by Dezork
    

import Foundation
import Solana
import XCTest

final class NetworkingRouterMock: SolanaRouter {
    
    private enum Constants {
        static let mockFolder = "Mocks/"
    }

    var endpoint: RPCEndpoint = .devnetSolana

    private(set) var requestCalled = [NetworkRouterRequestData]()
    var expectedResults: [Result<Mock, Error>] = []

    func request<T>(method: HTTPMethod,
                    bcMethod: String,
                    parameters: [Encodable?],
                    onComplete: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        let data = NetworkRouterRequestData(method: method,
                                            bcMethod: bcMethod,
                                            parameters: parameters)
        requestCalled.append(data)
        guard !expectedResults.isEmpty else {
            onComplete(.failure(NetworkRouterMockError(message: "expectedResults is empty")))
            return
        }

        switch expectedResults.removeFirst() {
        case .success(let result):
            switch result {
            case .json(let filename):
                decode(filename: filename, onComplete: onComplete)
            }
        case .failure(let error):
            onComplete(.failure(error))
        }
    }

    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func request<T>(method: HTTPMethod, bcMethod: String, parameters: [Encodable?]) async throws -> T where T : Decodable {
        try await withCheckedThrowingContinuation { c in
            self.request(method: method, bcMethod: bcMethod, parameters: parameters, onComplete: c.resume(with:))
        }
    }
}

// MARK: - Private

private extension NetworkingRouterMock {

    func getData(from filename: String) throws -> Data {
        let path = Constants.mockFolder + filename
        guard let url = Bundle.module.url(forResource: path, withExtension: "json") else {
            throw NetworkRouterMockError(message: "couldn't find \(filename) in \(Constants.mockFolder)")
        }
        return try Data(contentsOf: url,
                        options: .mappedIfSafe)
    }
    
    func decode<T>(filename: String,
                   onComplete: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        do {
            let data = try getData(from: filename)
            let decoded = try JSONDecoder().decode(Response<T>.self, from: data)
            if let result = decoded.result {
                onComplete(.success(result))
                return
            }
            if let error = decoded.error {
                onComplete(.failure(RPCError.invalidResponse(error)))
                return
            }
            onComplete(.failure(NetworkRouterMockError(message: "couldn't decode \(filename)")))
        } catch {
            onComplete(.failure(error))
        }
    }
}

// MARK: - Entities

enum Mock {
    case json(filename: String)
}

struct NetworkRouterRequestData {
    let method: HTTPMethod
    let bcMethod: String
    let parameters: [Encodable?]
}

struct NetworkRouterMockError: Error {
    let message: String
}
