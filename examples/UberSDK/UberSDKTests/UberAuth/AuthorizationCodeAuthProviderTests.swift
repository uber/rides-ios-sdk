//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


@testable import UberAuth
import XCTest

final class AuthorizationCodeAuthProviderTests: XCTestCase {

    private let configurationProvider = ConfigurationProvidingMock(
        clientID: "test_client_id",
        redirectURI: "test://"
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
                
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.openHandler = { _, _, _ in }
        
        configurationProvider.isInstalledHandler = { _, _ in
            true
        }
        
        let provider = AuthorizationCodeAuthProvider(
            configurationProvider: configurationProvider,
            applicationLauncher: applicationLauncher
        )
        
        XCTAssertEqual(applicationLauncher.openCallCount, 0)
        
        provider.execute(
            authDestination: .native(appPriority: UberApp.allCases),
            prefill: nil,
            completion: { _ in }
        )
        
        XCTAssertEqual(applicationLauncher.openCallCount, 1)
    }
    
    func test_executeNativeLogin_noDestinations_triggersInAppLogin() {
                
        let applicationLauncher = ApplicationLaunchingMock()
        applicationLauncher.openHandler = { _, _, _ in }
        
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
}
