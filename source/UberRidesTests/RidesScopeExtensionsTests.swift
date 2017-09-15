//
//  RidesScopeUtilTests.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
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

import XCTest
@testable import UberRides

class RidesScopeExtensionsTests: XCTestCase {

    func testRidesScopeToString_withValidScopes()
    {
        let scopes : [RidesScope] = Array(arrayLiteral: RidesScope.profile, RidesScope.places)
        
        let expectedString = "\(RidesScope.profile.rawValue) \(RidesScope.places.rawValue)"
        let scopeString = scopes.toRidesScopeString()
        
        XCTAssertEqual(expectedString, scopeString)
    }
    
    func testRidesScopeToString_withNoScopes()
    {
        let scopes : [RidesScope] = [RidesScope]()
        
        let expectedString = ""
        let scopeString = scopes.toRidesScopeString()
        
        XCTAssertEqual(expectedString, scopeString)
    }
    
    func testRidesScopeToString_withValidScopesUsingSet()
    {
        let scopes : Set<RidesScope> = Set<RidesScope>(arrayLiteral: RidesScope.profile, RidesScope.places)
        
        let scopeString = scopes.toRidesScopeString()
        
        var testSet : Set<RidesScope> = Set<RidesScope>()
        for scopeString in scopeString.components(separatedBy: " ") {
            guard let scope = RidesScopeFactory.ridesScopeForString(scopeString) else {
                continue
            }
            testSet.insert(scope)
        }
        
        XCTAssertEqual(scopes, testSet)
    }
    
    func testRidesScopeToString_withNoScopes_usingSet()
    {
        let scopes : Set<RidesScope> = Set<RidesScope>()
        
        let expectedString = ""
        let scopeString = scopes.toRidesScopeString()
        
        XCTAssertEqual(expectedString, scopeString)
    }
    
    func testStringToRidesScope_withValidScopes()
    {
        let expectedScopes : [RidesScope] = Array(arrayLiteral: RidesScope.profile, RidesScope.places)
        
        let scopeString = "\(RidesScope.profile.rawValue) \(RidesScope.places.rawValue)"

        let scopes = scopeString.toRidesScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }

    func testStringToRidesScope_withInvalidScopes()
    {
        let expectedScopes : [RidesScope] = [RidesScope]()
        
        let scopeString = "not actual values"
        
        let scopes = scopeString.toRidesScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }
    
    func testStringToRidesScope_withNoScopes()
    {
        let expectedScopes : [RidesScope] = [RidesScope]()
        
        let scopeString = ""
        
        let scopes = scopeString.toRidesScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }
    
    func testStringToRidesScope_withInvalidAndValidScopes()
    {
        let expectedScopes : [RidesScope] = Array(arrayLiteral: RidesScope.places)
        
        let scopeString = "not actual values \(RidesScope.places.rawValue)"
        
        let scopes = scopeString.toRidesScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }
    
    func testStringToRidesScope_caseInsensitive()
    {
        let expectedScopes : [RidesScope] = Array(arrayLiteral: RidesScope.places, RidesScope.history)
        
        let scopeString = "plAcEs HISTORY"
        
        let scopes = scopeString.toRidesScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }
}
