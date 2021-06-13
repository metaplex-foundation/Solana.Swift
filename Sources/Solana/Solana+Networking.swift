import Foundation
import RxSwift

public extension Solana {
    enum HTTPMethod: String{
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    func request<T: Decodable>(
        urlSession: URLSession = URLSession.shared,
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
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
        } catch {
            onComplete(.failure(error))
            return
        }
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            
            Logger.log(message: String(data: data ?? Data(), encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)

            if let error = error {
                onComplete(.failure(error))
                return
            }
            
            guard let response = response, let httpURLResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpURLResponse.statusCode) else {
                onComplete(.failure(SolanaError.httpError))
                return
            }
            do {
                guard let data = data else {
                    onComplete(.failure(SolanaError.invalidResponseNoData))
                    return
                }
                let decoded = try JSONDecoder().decode(Response<T>.self, from: data)
                if let result = decoded.result {
                    onComplete(.success(result))
                } else if let responseError = decoded.error {
                    onComplete(.failure(SolanaError.invalidResponse(responseError)))
                } else {
                    onComplete(.failure(SolanaError.unknown))
                }
            } catch let serializeError {
                onComplete(.failure(serializeError))
                return
            }
        }
        task.resume()
    }

    // MARK: - Helper
    func request<T: Decodable>(
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
