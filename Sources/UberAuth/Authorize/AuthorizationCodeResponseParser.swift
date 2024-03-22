//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

/// @mockable
public protocol AuthorizationCodeResponseParsing {
    func isValidResponse(url: URL, matching redirectURI: String) -> Bool
    func callAsFunction(url: URL) -> Result<Client, UberAuthError>
}

///
/// A struct that validates and extracts values from a url containing an authorization code response
///
public struct AuthorizationCodeResponseParser: AuthorizationCodeResponseParsing {
    
    public init() {}
    
    /// Determines whether the provided url corresponds to an authorization code response
    /// by verifying that the url matches the expected redirect URI
    ///
    /// - Parameters:
    ///   - url: The url to parse
    ///   - redirectURI: The expected redirect url
    /// - Returns: A boolean indicating whether or not the URLs match
    public func isValidResponse(url: URL, matching redirectURI: String) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let expectedComponents = URLComponents(string: redirectURI) else {
            return false
        }

        // Verify incoming scheme matches redirect_uri scheme
        guard let scheme = components.scheme?.lowercased(),
              let expectedScheme = expectedComponents.scheme?.lowercased(),
              scheme == expectedScheme else {
            return false
        }
        
        // Verify incoming host matches redirect_uri host
        guard let scheme = components.host?.lowercased(),
              let expectedScheme = expectedComponents.host?.lowercased(),
              scheme == expectedScheme else {
            return false
        }
                
        return true
    }
    
    /// Parses the provided url and attempts to pull an authorization code  or an error
    /// from the query parameters
    ///
    /// - Parameter url: The url to parse
    /// - Returns: A Result containing a client object built from the parsed values
    public func callAsFunction(url: URL) -> Result<Client, UberAuthError> {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .failure(.invalidResponse)
        }
        
        if let authorizationCode = components.queryItems?.first(where: {
            $0.name == "code"
        })?.value {
            return .success(
                Client(authorizationCode: authorizationCode)
            )
        }
        
        let error: UberAuthError
        if let errorString = components.queryItems?.first(where: { $0.name == "error" })?.value,
           let oAuthError = OAuthError(rawValue: errorString) {
            error = .oAuth(oAuthError)
        } else {
            error = .invalidAuthCode
        }
        
        return .failure(error)
    }
}

