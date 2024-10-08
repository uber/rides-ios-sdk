//
//  AuthorizationCodeAuthProviderTests.swift
//  UberSDKTests
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


@testable import UberCore
@testable import UberAuth
import XCTest

final class AuthorizationCodeAuthProviderTests: XCTestCase {

    private let configurationProvider = ConfigurationProvidingMock(
        clientID: "test_client_id",
        redirectURI: "test://app"
    )
    
    func test_executeInAppLogin_createsAuthenticationSession() {
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider
        )
                
        XCTAssertNil(provider.currentSession)
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertNotNil(provider.currentSession)
    }
    
    func test_executeInAppLogin_existingSessionBlocksRequest() {
        
        let provider = AuthorizationCodeAuthProvider()
        
        let authSession = AuthenticationSessioningMock()
        provider.currentSession = authSession
        
        XCTAssertEqual(authSession.startCallCount, 0)
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertEqual(authSession.startCallCount, 0)
    }
    
    func test_executeInAppLogin_noTokenExchange_doesNotIncludeCodeChallenge() {

        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, completion in
            completion?(true)
        }

        var hasCalledAuthenticationSessionBuilder: Bool = false

        let authenticationSessionBuilder: AuthorizationCodeAuthProvider.AuthenticationSessionBuilder = { _, _, url, _ in
            XCTAssertFalse(url.absoluteString.contains("code_challenge"))
            XCTAssertFalse(url.absoluteString.contains("code_challenge_method"))
            hasCalledAuthenticationSessionBuilder = true
            return AuthenticationSessioningMock()
        }
        
        let provider = AuthorizationCodeAuthProvider(
            authenticationSessionBuilder: authenticationSessionBuilder,
            shouldExchangeAuthCode: false,
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
                
        provider.execute(
            authDestination: .inApp,
            completion: { result in }
        )
        
        let url = URL(string: "test://app?code=123")!
        _ = provider.handle(response: url)
        
        XCTAssertTrue(hasCalledAuthenticationSessionBuilder)
    }
    
    func test_executeInAppLogin_prompt_includedInAuthorizeRequest() {

        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, completion in
            completion?(true)
        }

        var hasCalledAuthenticationSessionBuilder: Bool = false
        let prompt: Prompt = [.login, .consent]
        let promptString = prompt.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let authenticationSessionBuilder: AuthorizationCodeAuthProvider.AuthenticationSessionBuilder = { _, _, url, _ in
            XCTAssertTrue(url.query()!.contains("prompt=\(promptString)"))
            hasCalledAuthenticationSessionBuilder = true
            return AuthenticationSessioningMock()
        }
        
        let provider = AuthorizationCodeAuthProvider(
            authenticationSessionBuilder: authenticationSessionBuilder,
            prompt: [.login, .consent],
            shouldExchangeAuthCode: false,
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
                
        provider.execute(
            authDestination: .inApp,
            completion: { result in }
        )
        
        XCTAssertTrue(hasCalledAuthenticationSessionBuilder)
    }
    
    func test_executeNativeLogin_prompt_includedInAuthorizeRequest() {

        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let expectation = XCTestExpectation()
        
        let prompt: Prompt = [.consent]
        let promptString = prompt.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { url, completion in
            XCTAssertTrue(url.query()!.contains("prompt=\(promptString)"))
            expectation.fulfill()
            completion?(true)
        }
        
        let provider = AuthorizationCodeAuthProvider(
            prompt: [.consent],
            shouldExchangeAuthCode: false,
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
        
                      
        provider.execute(
            authDestination: .native(),
            completion: { _ in }
        )
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func test_executeNativeLogin_prompt_doesNotIncluideLogin() {

        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let expectation = XCTestExpectation()
        
        let prompt: Prompt = [.consent]
        let promptString = prompt.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { url, completion in
            XCTAssertTrue(url.query()!.contains("prompt=\(promptString)"))
            expectation.fulfill()
            completion?(true)
        }
        
        let provider = AuthorizationCodeAuthProvider(
            prompt: [.consent, .login],
            shouldExchangeAuthCode: false,
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
        
                      
        provider.execute(
            authDestination: .native(),
            completion: { _ in }
        )
        
        wait(for: [expectation], timeout: 0.2)
    }

    func test_execute_existingSession_returnsExistingAuthSessionError() {
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider
        )
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { _ in }
        )
        
        let expectation = XCTestExpectation()
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { result in
                switch result {
                case .failure(.existingAuthSession):
                    expectation.fulfill()
                default:
                    XCTFail()
                }
            }
        )
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_invalidRedirectURI_returnsInvalidRequestError() {
        
        let configurationProvider = ConfigurationProvidingMock(
            clientID: "",
            redirectURI: "uber"
        )
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider
        )
        
        let expectation = XCTestExpectation()
        
        provider.execute(
            authDestination: .inApp,
            prefill: nil,
            completion: { result in
                switch result {
                case .failure(.invalidRequest):
                    expectation.fulfill()
                default:
                    XCTFail()
                }
            }
        )
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_executeNativeLogin_queriesInstalledApps() {
                
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider
        )
            
        var apps = UberApp.allCases
        let appCount = apps.count
        
        configurationProvider.isInstalledHandler = { app, defaultIfUnregistered in
            // Ensure called once per app
            if !apps.contains(app) {
                XCTFail()
            }
            apps.removeAll(where: { $0 == app })
            return false
        }
        
        XCTAssertEqual(configurationProvider.isInstalledCallCount, 0)
        
        provider.execute(
            authDestination: .native(appPriority: apps),
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertEqual(configurationProvider.isInstalledCallCount, appCount)
    }
    
    func test_executeNativeLogin_stopsAfterFirstAppFound() {
                
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider
        )
            
        var apps = UberApp.allCases
        let appCount = apps.count
        
        configurationProvider.isInstalledHandler = { app, _ in
            // Ensure called once per app
            if !apps.contains(app) {
                XCTFail()
            }
            apps.removeAll(where: { $0 == app })
            return true
        }
        
        XCTAssertEqual(configurationProvider.isInstalledCallCount, 0)
        
        provider.execute(
            authDestination: .native(appPriority: apps),
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertEqual(configurationProvider.isInstalledCallCount, 1)
        XCTAssertEqual(apps.count, appCount - 1)
    }
    
    func test_executeNativeLogin_triggersApplicationLauncher() {
        
        let expectation = XCTestExpectation()
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, completion in
            expectation.fulfill()
            completion?(true)
        }
        
        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
        
        provider.execute(
            authDestination: .native(appPriority: UberApp.allCases),
            prefill: nil,
            completion: { _ in }
        )
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func test_executeNativeLogin_noDestinations_triggersInAppLogin() {
                
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, _ in }
        
        configurationProvider.isInstalledHandler = { _, _ in
            false
        }
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
        
        XCTAssertNil(provider.currentSession)
        
        provider.execute(
            authDestination: .native(appPriority: UberApp.allCases),
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertNotNil(provider.currentSession)
    }
    
    func test_executeNativeLogin_noOpens_triggersInAppLogin() {
                
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, completion in
            completion?(false)
        }
        
        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
                
        let expectation = XCTestExpectation()
        
        let authenticationSession = AuthenticationSessioningMock()
        let authenticationSessionBuilder: AuthorizationCodeAuthProvider.AuthenticationSessionBuilder = { _, _, _, _ in
            expectation.fulfill()
            return authenticationSession
        }
        
        let provider = AuthorizationCodeAuthProvider(
            authenticationSessionBuilder: authenticationSessionBuilder,
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
                
        XCTAssertEqual(authenticationSession.startCallCount, 0)
        
        provider.execute(
            authDestination: .native(appPriority: UberApp.allCases),
            prefill: nil,
            completion: { _ in }
        )
        
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(authenticationSession.startCallCount, 1)
    }
    
    func test_executeNativeLogin_noTokenExchange_doesNotIncludeCodeChallenge() {

        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { url, completion in
            XCTAssertFalse(url.absoluteString.contains("code_challenge"))
            XCTAssertFalse(url.absoluteString.contains("code_challenge_method"))
            completion?(false)
        }
        
        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
                
        let expectation = XCTestExpectation()
        
        let authenticationSession = AuthenticationSessioningMock()
        let authenticationSessionBuilder: AuthorizationCodeAuthProvider.AuthenticationSessionBuilder = { _, _, _, _ in
            expectation.fulfill()
            return authenticationSession
        }
        
        let provider = AuthorizationCodeAuthProvider(
            authenticationSessionBuilder: authenticationSessionBuilder,
            shouldExchangeAuthCode: false,
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
                
        XCTAssertEqual(applicationLauncher.launchCallCount, 0)
        
        provider.execute(
            authDestination: .native(appPriority: [.eats]),
            prefill: nil,
            completion: { _ in }
        )
        
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertEqual(applicationLauncher.launchCallCount, 1)
    }
    
    func test_handleResponse_true_callsResponseParser() {
        
        let responseParser = AuthorizationCodeResponseParsingMock()
        responseParser.isValidResponseHandler = { _, _ in
            true
        }
        responseParser.callAsFunctionHandler = { _ in
            .success(Client())
        }
        
        let provider = AuthorizationCodeAuthProvider(
            responseParser: responseParser
        )
                
        let url = URL(string: "scheme://host?code=123")!
        
        let completion: AuthorizationCodeAuthProvider.Completion = { _ in }
        provider.execute(authDestination: .native(appPriority: []), prefill: nil, completion: completion)
        
        XCTAssertEqual(responseParser.isValidResponseCallCount, 0)
        XCTAssertEqual(responseParser.callAsFunctionCallCount, 0)
        
        let handled = provider.handle(
            response: url
        )
        
        XCTAssertEqual(responseParser.isValidResponseCallCount, 1)
        XCTAssertEqual(responseParser.callAsFunctionCallCount, 1)
        XCTAssertTrue(handled)
    }
    
    func test_handleResponse_false_doesNotTriggerParse() {
        
        let responseParser = AuthorizationCodeResponseParsingMock()
        responseParser.isValidResponseHandler = { _, _ in
            false
        }
        responseParser.callAsFunctionHandler = { _ in
            .success(Client())
        }
        
        let provider = AuthorizationCodeAuthProvider(
            responseParser: responseParser
        )
        
        let url = URL(string: "scheme://host?code=123")!
        
        let completion: AuthorizationCodeAuthProvider.Completion = { _ in }
        provider.execute(authDestination: .native(appPriority: []), prefill: nil, completion: completion)
        
        XCTAssertEqual(responseParser.isValidResponseCallCount, 0)
        XCTAssertEqual(responseParser.callAsFunctionCallCount, 0)
        
        let handled = provider.handle(
            response: url
        )
        
        XCTAssertEqual(responseParser.isValidResponseCallCount, 1)
        XCTAssertEqual(responseParser.callAsFunctionCallCount, 0)
        XCTAssertFalse(handled)
    }
    
    func test_prefill_executesParRequest() {
        
        var hasCalledParRequest = false
        
        let networkProvider = NetworkProvidingMock()
        networkProvider.executeHandler = { request, _ in
            if request is ParRequest {
                hasCalledParRequest = true
            }
        }
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider,
            networkProvider: networkProvider
        )
        
        provider.execute(
            authDestination: .native(appPriority: [.rides]),
            prefill: Prefill(),
            completion: { _ in }
        )
        
        XCTAssertTrue(hasCalledParRequest)
    }
    
    func test_noPrefill_doesNotExecuteParRequest() {
        
        var hasCalledParRequest = false
        
        let networkProvider = NetworkProvidingMock()
        networkProvider.executeHandler = { request, _ in
            if request is ParRequest {
                hasCalledParRequest = true
            }
        }
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider,
            networkProvider: networkProvider
        )
        
        provider.execute(
            authDestination: .native(appPriority: [.rides]),
            completion: { _ in }
        )
        
        XCTAssertFalse(hasCalledParRequest)
    }
    
    func test_nativeAuth_tokenExchange_triggersTokenRequest() {
        
        var hasCalledTokenRequest = false
        
        let networkProvider = NetworkProvidingMock()
        networkProvider.executeHandler = { request, _ in
            if request is TokenRequest {
                hasCalledTokenRequest = true
            }
        }
        
        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, completion in
            completion?(true)
        }
        
        let provider = AuthorizationCodeAuthProvider(
            shouldExchangeAuthCode: true,
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher,
            networkProvider: networkProvider
        )
        
        provider.execute(
            authDestination: .native(appPriority: [.rides]),
            completion: { result in }
        )
        
        let url = URL(string: "test://app?code=123")!
        _ = provider.handle(response: url)
        
        XCTAssertTrue(hasCalledTokenRequest)
    }
    
    func test_nativeAuth_noTokenExchange_doesNotTriggerTokenRequest() {
        
        var hasCalledTokenRequest = false
        
        let networkProvider = NetworkProvidingMock()
        networkProvider.executeHandler = { request, _ in
            if request is TokenRequest {
                hasCalledTokenRequest = true
            }
        }
        
        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, completion in
            completion?(true)
        }
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher,
            networkProvider: networkProvider
        )
        
        provider.execute(
            authDestination: .native(appPriority: [.rides]),
            completion: { result in }
        )
        
        let url = URL(string: "test://app?code=123")!
        _ = provider.handle(response: url)
        
        XCTAssertFalse(hasCalledTokenRequest)
    }
    
    func test_nativeAuth_tokenExchange() {
        
        let token = AccessToken(
            tokenString: "123",
            tokenType: "test_token"
        )
        
        let networkProvider = NetworkProvidingMock()
        networkProvider.executeHandler = { request, completion in
            if request is TokenRequest {
                let completion = completion as! (Result<TokenRequest.Response, UberAuthError>) -> ()
                completion(.success(token))
            }
            else if request is ParRequest {
                let completion = completion as! (Result<ParRequest.Response, UberAuthError>) -> ()
                completion(.success(Par(requestURI: nil, expiresIn: .now)))
            }
        }
        
        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.launchHandler = { _, completion in
            completion?(true)
        }
        
        let provider = AuthorizationCodeAuthProvider(
            shouldExchangeAuthCode: true, 
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher,
            networkProvider: networkProvider
        )
        
        let expectation = XCTestExpectation()
        
        provider.execute(
            authDestination: .native(appPriority: [.rides]),
            completion: { result in
                expectation.fulfill()
                
                switch result {
                case .failure:
                    XCTFail()
                case .success(let client):
                    XCTAssertEqual(
                        client,
                        Client(
                            accessToken: AccessToken(
                                tokenString: "123",
                                tokenType: "test_token"
                            )
                        )
                    )
                }
            }
        )
        
        let url = URL(string: "test://app?code=123")!
        _ = provider.handle(response: url)
        
        wait(for: [expectation], timeout: 0.1)
    }
}
