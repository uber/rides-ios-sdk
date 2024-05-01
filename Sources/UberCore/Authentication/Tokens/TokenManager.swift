//
//  TokenManager.swift
//  UberCore
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation

/// @mockable
public protocol TokenManaging {
    
    /// Saves the provided Access Token to the on device keychain using the supplied `identifier`
    ///
    /// - Parameters:
    ///   - token: The Access Token to save
    ///   - identifier: A string used to identify the Access Token upon retrieval
    /// - Returns: A boolean indicating whether or not the save operation was successful
    func saveToken(_ token: AccessToken, identifier: String) -> Bool
    
    /// Retrieves an Access Token from the on device keychain
    ///
    /// - Parameter identifier: The identifier string used when saving the Access Token
    /// - Returns: An optional Access Token if found
    func getToken(identifier: String) -> AccessToken?
    
    
    /// Removes the Access Token corresponding with the supplied `identifier`
    ///
    /// - Parameter identifier: The identifier string used when saving the Access Token
    /// - Returns: A boolean indicating whether or not the delete operation was successful
    func deleteToken(identifier: String) -> Bool
}

public final class TokenManager: TokenManaging {
    
    public static let defaultAccessTokenIdentifier = "UberAccessTokenKey"
    
    private let keychainUtility: KeychainUtilityProtocol
    
    public init(keychainUtility: KeychainUtilityProtocol = KeychainUtility()) {
        self.keychainUtility = keychainUtility
    }
    
    // MARK: Save
    
    /// Saves the provided Access Token to the on device keychain using the supplied `identifier`
    ///
    /// - Parameters:
    ///   - token: The Access Token to save
    ///   - identifier: A string used to identify the Access Token upon retrieval
    /// - Returns: A boolean indicating whether or not the save operation was successful
    @discardableResult
    public func saveToken(_ token: AccessToken, identifier: String = TokenManager.defaultAccessTokenIdentifier) -> Bool {
        keychainUtility.save(token, for: identifier)
    }
    
    // MARK: Get
    
    /// Retrieves an Access Token from the on device keychain
    ///
    /// - Parameter identifier: The identifier string used when saving the Access Token
    /// - Returns: An optional Access Token if found
    @discardableResult
    public func getToken(identifier: String = TokenManager.defaultAccessTokenIdentifier) -> AccessToken? {
        keychainUtility.get(key: identifier)
    }
    
    // MARK: Delete
    
    /// Removes the Access Token corresponding with the supplied `identifier`
    ///
    /// - Parameter identifier: The identifier string used when saving the Access Token
    /// - Returns: A boolean indicating whether or not the delete operation was successful
    @discardableResult
    public func deleteToken(identifier: String = TokenManager.defaultAccessTokenIdentifier) -> Bool {
        deleteCookies()
        return keychainUtility.delete(key: identifier)
    }
    
    // MARK: Private Interface
    
    /// Removes all cookies in the shared cookie store corresponding with the auth.uber.com domain
    private func deleteCookies() {
        guard let loginUrl = URL(string: OAuth.regionHost) else {
            return
        }
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        if let cookies = sharedCookieStorage.cookies(for: loginUrl) {
            for cookie in cookies {
                sharedCookieStorage.deleteCookie(cookie)
            }
        }
    }
}
