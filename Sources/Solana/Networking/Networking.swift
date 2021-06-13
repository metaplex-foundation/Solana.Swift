import Foundation

public extension Solana {
    enum HTTPMethod: String{
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum RPCError: Error{
        case httpError
        case invalidResponseNoData
        case invalidResponse(ResponseError)
        case unknownResponse
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
        let requestAPI = SolanaRequest(method: bcMethod, params: params)
        
        Logger.log(message: "\(method.rawValue) \(bcMethod) [id=\(requestAPI.id)] \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")", event: .request, apiMethod: bcMethod)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
        } catch let ecodingError {
            onComplete(.failure(ecodingError))
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
                onComplete(.failure(RPCError.httpError))
                return
            }
            
            guard let responseData = data else {
                onComplete(.failure(RPCError.invalidResponseNoData))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(Response<T>.self, from: responseData)
                if let result = decoded.result {
                    onComplete(.success(result))
                    return
                } else if let responseError = decoded.error {
                    onComplete(.failure(RPCError.invalidResponse(responseError)))
                    return
                } else {
                    onComplete(.failure(RPCError.unknownResponse))
                    return
                }
            } catch let serializeError {
                onComplete(.failure(serializeError))
                return
            }
        }
        task.resume()
    }
}
