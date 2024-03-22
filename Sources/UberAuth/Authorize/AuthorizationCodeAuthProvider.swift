//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import UberCore

public final class AuthorizationCodeAuthProvider: AuthProviding {
    
    // MARK: Public Properties
    
    public let clientID: String
    
    public let redirectURI: String
    
    public typealias Completion = (Result<Client, UberAuthError>) -> Void
    
    public static let defaultScopes = ["profile"]

    // MARK: Private Properties

    private let applicationLauncher: ApplicationLaunching
    
    private var completion: Completion?
    
    private let configurationProvider: ConfigurationProviding
    
    var currentSession: AuthenticationSessioning?
    
    private let pkce = PKCE()
    
    private let presentationAnchor: ASPresentationAnchor
    
    private let responseParser: AuthorizationCodeResponseParsing
    
    private let shouldExchangeAuthCode: Bool
    
    // MARK: Initializers
    
    public init(presentationAnchor: ASPresentationAnchor = .init(),
                scopes: [String] = AuthorizationCodeAuthProvider.defaultScopes,
                shouldExchangeAuthCode: Bool = true,
                configurationProvider: ConfigurationProviding = DefaultConfigurationProvider(),
                applicationLauncher: ApplicationLaunching = UIApplication.shared,
                responseParser: AuthorizationCodeResponseParsing = AuthorizationCodeResponseParser()) {
                
        guard let clientID: String = configurationProvider.clientID else {
            preconditionFailure("No clientID specified in Info.plist")
        }
        
        guard let redirectURI: String = configurationProvider.redirectURI else {
            preconditionFailure("No redirectURI specified in Info.plist")
        }
        
        self.applicationLauncher = applicationLauncher
        self.clientID = clientID
        self.configurationProvider = configurationProvider
        self.presentationAnchor = presentationAnchor
        self.redirectURI = redirectURI
        self.responseParser = responseParser
        self.shouldExchangeAuthCode = shouldExchangeAuthCode
    }
    
    // MARK: AuthProviding
    
    public func execute(authDestination: AuthDestination,
                        prefill: Prefill?,
                        completion: @escaping Completion) {
        self.completion = completion
        
        // TODO: Implement PAR
        
        executeLogin(
            authDestination: authDestination,
            requestURI: nil,
            completion: completion
        )
    }
    
    public func handle(response url: URL) -> Bool {
        guard responseParser.isValidResponse(url: url, matching: redirectURI) else {
            return false
        }
        completion?(responseParser(url: url))
        return true
    }
    
    // MARK: - Private
    
    private func executeLogin(authDestination: AuthDestination,
                              requestURI: String?,
                              completion: @escaping Completion) {
        switch authDestination {
        case .inApp:
            executeInAppLogin(
                requestURI: requestURI,
                completion: completion
            )
        case .native(let appPriority):
            executeNativeLogin(
                appPriority: appPriority,
                requestURI: requestURI,
                completion: completion
            )
        }
    }
    
    /// Performs login using an embedded browser within the third party client.
    /// - Parameters:
    ///   - completion: A closure to handle the login result
    private func executeInAppLogin(requestURI: String?,
                                   completion: @escaping Completion) {
        
        // Only execute one authentication session at a time
        guard currentSession == nil else {
            completion(.failure(.existingAuthSession))
            return
        }
        
        let request = AuthorizeRequest(
            app: nil,
            clientID: clientID,
            codeChallenge: pkce.codeChallenge,
            redirectURI: redirectURI,
            requestURI: requestURI
        )
        
        guard let url = request.url(baseUrl: Constants.baseUrl) else {
            completion(.failure(.invalidRequest("Invalid base URL")))
            return
        }
        
        guard let callbackURL = URL(string: redirectURI),
              let callbackURLScheme = callbackURL.scheme else {
            completion(.failure(.invalidRequest("Invalid redirect URI")))
            return
        }
        
        currentSession = AuthenticationSession(
            anchor: presentationAnchor,
            callbackURLScheme: callbackURLScheme,
            url: url,
            completion: { result in
                if self.shouldExchangeAuthCode,
                   case .success(let client) = result,
                   let code = client.authorizationCode {
                    // TODO: Exchange auth code here
                    self.currentSession = nil
                    return
                }
                completion(result)
                self.currentSession = nil
            }
        )
        
        currentSession?.start()
    }
        
    /// Performs login using one of the native Uber applications if available.
    ///
    /// There are three possible destinations for auth through this method:
    ///     1. The native Uber app
    ///     2. The OS supplied Safari browser
    ///     3. In app auth through ASWebAuthenticationSession
    ///
    /// This method will run through the desired native app destinations supplied in `appPriority`.
    /// For each one it will:
    ///     * Use the configuration provider to determine if the app is installed, using UIApplication's openUrl.
    ///       If the app's scheme has not been registered in the Info.plist and is not queryable it will default to true
    ///       and continue with the auth flow. If it is registered but not installed, we will continue to the next app.
    ///     * Build a universal link specific to the current app destination
    ///     * Attempt to launch the app using the `applicationLauncher`. If the app is installed, the native app
    ///       should be launched (1), if not the OS supplied browser will be launched (2)
    ///
    /// If all app destinations have been exhausted and no url has been launched we fall back to in app auth (3)
    ///
    /// - Parameters:
    ///   - appPriority: An ordered list of Uber applications to use to perform login
    ///   - completion: A closure to handle the login result
    private func executeNativeLogin(appPriority: [UberApp],
                                    requestURI: String?,
                                    completion: @escaping Completion) {
     
        var nativeLaunched = false
        
        func launch(app: UberApp, completion: ((Bool) -> Void)?) {
            guard configurationProvider.isInstalled(
                app: app,
                defaultIfUnregistered: true
            ) else {
                completion?(false)
                return
            }
            
            let request = AuthorizeRequest(
                app: app,
                clientID: clientID,
                codeChallenge: pkce.codeChallenge,
                redirectURI: redirectURI,
                requestURI: requestURI
            )
            
            guard let url = request.url(baseUrl: Constants.baseUrl) else {
                completion?(false)
                return
            }
            
            applicationLauncher.open(
                url,
                options: [:],
                completionHandler: { opened in
                    if opened { nativeLaunched = true }
                    completion?(opened)
                }
            )
        }
        
        // Executes the asynchronous operation `launch` serially for each app in appPriority
        // Stops the execution after the first app is successfully launched
        AsyncDispatcher.exec(
            for: appPriority,
            with: { _ in },
            asyncMethod: launch(app:completion:),
            continue: { !$0 }, // Do not continue if app launched
            finally: { [weak self] in
                guard !nativeLaunched else {
                    return
                }
                
                // If no native app was launched, fall back to in app login
                 self?.executeInAppLogin(
                    requestURI: requestURI,
                    completion: completion
                )
            }
        )
    }
    
    // MARK: Constants
    
    private enum Constants {
        static let clientIDKey = "ClientID"
        static let redirectURI = "RedirectURI"
        static let baseUrl = "https://auth.uber.com/v2"
    }
}
