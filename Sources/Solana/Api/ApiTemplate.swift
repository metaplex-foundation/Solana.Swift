public protocol ApiTemplate {
    associatedtype Success

    func perform(withConfigurationFrom actionClass: Api,
                 completion: @escaping (Result<Success, Error>) -> Void)
}

public extension Api {
    func perform<ApiType: ApiTemplate>(_ modeledApi: ApiType,
                                       completion: @escaping (Result<ApiType.Success, Error>) -> Void) {
        modeledApi.perform(withConfigurationFrom: self, completion: completion)
    }
}

public enum ApiTemplates {}
