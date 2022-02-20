//
//  SolanaPay.swift
//  
//
//  Created by Arturo Jamaica on 2022/02/20.
//

import Foundation
let PROTOCOL = "solana"
public enum SolanaPayError: Error {
    case pathNotProvided
    case invalidAmmount
    case unsupportedProtocol
    case canNotParse
    case couldNotDecodeURL
    case other(Error)
}
public class SolanaPay {
    func getSolanaPayURL(
        recipient: String,
        uiAmountString: String,
        label: String? = nil,
        message: String? = nil,
        memo: String? = nil,
        reference: String? = nil,
        splToken: String? = nil
    ) -> Result<URL, SolanaPayError> {
        var solanaPayURL = "\(PROTOCOL):\(recipient)?amount=\(uiAmountString)"
        if let label = label {
            solanaPayURL += "&label=\(label)"
        }
        if let message = message {
            solanaPayURL += "&message=\(message)"
        }
        if let memo = memo {
            solanaPayURL += "&memo=\(memo)"
        }
        if let reference = reference {
            solanaPayURL += "&reference=\(reference)"
        }
        if let splToken = splToken {
            solanaPayURL += "&spl-token=\(splToken)"
        }
        do{
            guard let url = URL(string: solanaPayURL) else {
                throw SolanaPayError.couldNotDecodeURL
            }
            return .success(url)
        } catch SolanaPayError.couldNotDecodeURL {
            return .failure(SolanaPayError.couldNotDecodeURL)
        } catch let e {
            return .failure(SolanaPayError.other(e))
        }
    }
    
    func parseSolanaPay(urlString: String) -> Result<SolanaPaySpecification, SolanaPayError> {
        let newURL = urlString
            .replacingOccurrences(of: "\(PROTOCOL):", with: "\(PROTOCOL)://")
            .replacingOccurrences(of: "?", with: "/?")
            .replacingOccurrences(of: "%3F", with: "/?")
            .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let components = URLComponents(
            url: URL(string: newURL!)!,
            resolvingAgainstBaseURL: false
        )!
        
        guard components.scheme == PROTOCOL else {
            return .failure(SolanaPayError.unsupportedProtocol)
        }

        
        guard let host = components.host, let address = PublicKey(string: host)  else {
            return .failure(SolanaPayError.pathNotProvided)
        }

        var doubleAmount: Double? = nil
        var splTokenPubKey: PublicKey? = nil
        if let amount: String = getParamURL(components: components, name: "amount") {
            let parsedAmount = Double(amount) ?? -1
            if parsedAmount < 0 {
                return .failure(SolanaPayError.invalidAmmount)
            }
            doubleAmount = parsedAmount
        }
        
        let label: String? = getParamURL(components: components, name: "label")
        let message: String? = getParamURL(components: components, name: "message")
        let memo: String? = getParamURL(components: components, name: "memo")
        let reference: String? = getParamURL(components: components, name: "reference")
        if let splToken: String = getParamURL(components: components, name: "spl-token") {
            splTokenPubKey = PublicKey(string: splToken) ?? nil
        }
        
        let spec = SolanaPaySpecification(address: address, label: label, splToken: splTokenPubKey, message: message, memo: memo, reference: reference, amount: doubleAmount)
        return .success(spec)
    }
    
    private func getParamURL(components: URLComponents, name: String) -> String? {
        return components.queryItems?.first(where: { $0.name == name })?.value
    }
}

public struct SolanaPaySpecification {
    let address: PublicKey
    let label: String?
    let splToken: PublicKey?
    let message: String?
    let memo: String?
    let reference: String?
    let amount: Double?
}
