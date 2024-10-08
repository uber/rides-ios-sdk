//
//  AuthorizationCodeResponseParserTests.swift
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


@testable import UberAuth
import XCTest

final class AuthorizationCodeResponseParserTests: XCTestCase {

    let responseParser = AuthorizationCodeResponseParser()
    
    func test_isValidResponse_invalidURLComponents_returnsFalse() {

        let isValid = responseParser.isValidResponse(
            url: URL(string: "scheme://host")!,
            matching: "invalid_scheme://host"
        )
    
        XCTAssertFalse(isValid)
    }
    
    func test_isValidResponse_missingSchemes_returnsFalse() {

        var isValid = responseParser.isValidResponse(
            url: URL(string: "://host")!,
            matching: "scheme://host"
        )
        
        XCTAssertFalse(isValid)
        
        isValid = responseParser.isValidResponse(
            url: URL(string: "scheme://host")!,
            matching: "://host"
        )
    
        XCTAssertFalse(isValid)
    }
    
    func test_isValidResponse_mismatchedSchemes_returnsFalse() {

        let isValid = responseParser.isValidResponse(
            url: URL(string: "scheme://host")!,
            matching: "mismatched_scheme://host"
        )
    
        XCTAssertFalse(isValid)
    }
    
    func test_isValidResponse_missingHosts_returnsFalse() {

        var isValid = responseParser.isValidResponse(
            url: URL(string: "scheme://")!,
            matching: "scheme://host"
        )
        
        XCTAssertFalse(isValid)
        
        isValid = responseParser.isValidResponse(
            url: URL(string: "scheme://host")!,
            matching: "scheme://"
        )
    
        XCTAssertFalse(isValid)
    }
    
    func test_isValidResponse_mismatchedHosts_returnsFalse() {

        let isValid = responseParser.isValidResponse(
            url: URL(string: "scheme://host")!,
            matching: "scheme://mismatched_host"
        )
    
        XCTAssertFalse(isValid)
    }
    
    func test_isValidResponse_matchingUrls_returnsTrue() {

        let isValid = responseParser.isValidResponse(
            url: URL(string: "scheme://host?code=123")!,
            matching: "scheme://host"
        )
    
        XCTAssertTrue(isValid)
    }

    func test_parse_invalidUrl_returnsFailure() {
        
        let url = URL(filePath: "invalid_scheme://host?code=123")
        
        let result = responseParser(
            url: url
        )
        
        XCTAssertEqual(result, .failure(UberAuthError.invalidResponse))
    }
    
    func test_parse_authorizationCodeParameter_returnsSuccess() {
        
        let url = URL(string: "scheme://host?code=123")!
        
        let result = responseParser(
            url: url
        )
        
        switch result {
        case .success(let client):
            XCTAssertEqual(client.authorizationCode, "123")
        case .failure:
            XCTFail()
        }
    }
    
    func test_parse_oAuthErrorParameter_returnsFailure() {
        
        let url = URL(string: "scheme://host?error=\(OAuthError.invalidRequest.rawValue)")!
        
        let result = responseParser(
            url: url
        )
        
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, .oAuth(.invalidRequest))
        }
    }
    
    func test_parse_unknownErrorParameter_returnsInvalidAuthCodeError() {
        
        let url = URL(string: "scheme://host?error=unknown_error")!
        
        let result = responseParser(
            url: url
        )
        
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertEqual(error, .invalidAuthCode)
        }
    }
}
