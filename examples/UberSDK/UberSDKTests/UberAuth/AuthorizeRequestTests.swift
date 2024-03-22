//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


@testable import UberAuth
import XCTest

final class AuthorizeRequestTests: XCTestCase {

    func test_generatedUrl() {
        
        let request = AuthorizeRequest(
            app: nil,
            clientID: "test_client_id",
            codeChallenge: "code_challenge",
            redirectURI: "redirect_uri",
            requestURI: "request_url"
        )
        
        let urlRequest = request.urlRequest(baseUrl: "https://auth.uber.com")!
        let url = urlRequest.url!
        
        XCTAssertEqual(url.host(), "auth.uber.com")
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.path(), "/oauth/v2/universal/authorize")
        XCTAssertTrue(url.query()!.contains("response_type=code"))
        XCTAssertTrue(url.query()!.contains("client_id=test_client_id"))
        XCTAssertTrue(url.query()!.contains("code_challenge=code_challenge"))
        XCTAssertTrue(url.query()!.contains("request_uri=request_url"))
        XCTAssertTrue(url.query()!.contains("code_challenge_method=S256"))
        XCTAssertTrue(url.query()!.contains("redirect_uri=redirect_uri"))
    }
    
    func test_appSpecific_generatedUrls() {
            
        UberApp.allCases.forEach { app in
            let request = AuthorizeRequest(
                app: app,
                clientID: "test_client_id",
                codeChallenge: "code_challenge",
                redirectURI: "redirect_uri",
                requestURI: "request_url"
            )
            
            let urlRequest = request.urlRequest(baseUrl: "https://auth.uber.com")!
            let url = urlRequest.url!
            
            XCTAssertEqual(url.host(), "auth.uber.com")
            XCTAssertEqual(url.scheme, "https")
            XCTAssertEqual(url.path(), "/oauth/v2/\(app.urlIdentifier)/authorize")
            XCTAssertTrue(url.query()!.contains("response_type=code"))
            XCTAssertTrue(url.query()!.contains("client_id=test_client_id"))
            XCTAssertTrue(url.query()!.contains("code_challenge=code_challenge"))
            XCTAssertTrue(url.query()!.contains("request_uri=request_url"))
            XCTAssertTrue(url.query()!.contains("code_challenge_method=S256"))
            XCTAssertTrue(url.query()!.contains("redirect_uri=redirect_uri"))
        }
    }

}
