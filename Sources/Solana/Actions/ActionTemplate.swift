import Foundation

public protocol ActionTemplate {
    associatedtype Success

    func perform(withConfigurationFrom actionClass: Action,
                 completion: @escaping (Result<Success, Error>) -> Void)
}

public extension Action {
    func perform<ActionType: ActionTemplate>(_ modeledAction: ActionType,
                                             completion: @escaping (Result<ActionType.Success, Error>) -> Void) {
        modeledAction.perform(withConfigurationFrom: self, completion: completion)
    }
}


public enum ActionTemplates {}
