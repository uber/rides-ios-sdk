//
//  UberScope.swift
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

import UIKit

/**
 Category of scope that describes its level of access.
 
 - General:    scopes that can be used without review.
 - Privileged: scopes that require approval before opened to your users in production.
 */
public enum ScopeType : Int {
    case general, privileged
}

/**
 Scopes control the various API endpoints your application can access.

 - AllTrips:       Get details of the trip the user is currently taking.
 - History:        Pull trip data of a user's historical pickups and drop-offs.
 - HistoryLite:    Same as History without city information.
 - Places:         Save and retrieve user's favorite places.
 - Profile:        Access basic profile information on a user's Uber account.
 - Request:        Make requests for Uber rides on behalf of users.
 - RideReceipt:    Get receipt details for requests made by application.
 - RideWidgets:    The scope for using the Ride Request Widget.
 */
public enum UberScopeType: Int {
    case allTrips
    case history
    case historyLite
    case places
    case profile
    case request
    case requestReceipt
    case rideWidgets
    case custom
    
    var type: ScopeType {
        switch(self) {
        case .history: fallthrough
        case .historyLite: fallthrough
        case .places: fallthrough
        case .profile: fallthrough
        case .rideWidgets:
            return .general
        case .allTrips: fallthrough
        case .request: fallthrough
        case .requestReceipt: fallthrough
        case .custom:
            return .privileged
        }
    }
}

/**
 *  Object representing an access scope to the Uber API
 */
public class UberScope: Equatable, Hashable {
    /// The UberScopeType of this UberScope
    public let uberScopeType: UberScopeType
    /// The ScopeType of this UberScope (General / Privileged)
    public let scopeType: ScopeType
    /// The String raw value of the scope
    public let rawValue: String

    public init(uberScopeType: UberScopeType) {
        assert(uberScopeType != .custom, "Custom scope type should use the `scopeString` initializer")
        self.uberScopeType = uberScopeType
        scopeType = uberScopeType.type
        rawValue = UberScope.toString(uberScopeType)
    }

    public init(scopeString: String) {
        self.uberScopeType = UberScope.toScope(scopeString)
        scopeType = uberScopeType.type
        rawValue = scopeString.lowercased()
    }

    public static func ==(lhs: UberScope, rhs: UberScope) -> Bool {
        lhs.uberScopeType == rhs.uberScopeType && lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uberScopeType.rawValue)
    }
    
    /// Convenience variable for the AllTrips scope
    public static let allTrips = UberScope(uberScopeType: .allTrips)
    
    /// Convenience variable for the History scope
    public static let history = UberScope(uberScopeType: .history)
    
    /// Convenience variable for the HistoryLite scope
    public static let historyLite = UberScope(uberScopeType: .historyLite)
    
    /// Convenience variable for the Places scope
    public static let places = UberScope(uberScopeType: .places)
    
    /// Convenience variable for the Profile scope
    public static let profile = UberScope(uberScopeType: .profile)
    
    /// Convenience variable for the Request scope
    public static let request = UberScope(uberScopeType: .request)
    
    /// Convenience variable for the RequestReceipt scope
    public static let requestReceipt = UberScope(uberScopeType: .requestReceipt)
    
    /// Convenience variable for the RideWidgets scope
    public static let rideWidgets = UberScope(uberScopeType: .rideWidgets)

    private static func toString(_ uberScopeType: UberScopeType) -> String {
        switch uberScopeType {
        case .allTrips:
            return "all_trips"
        case .history:
            return "history"
        case .historyLite:
            return "history_lite"
        case .places:
            return "places"
        case .profile:
            return "profile"
        case .request:
            return "request"
        case .requestReceipt:
            return "request_receipt"
        case .rideWidgets:
            return "ride_widgets"
        default:
            return ""
        }
    }

    private static func toScope(_ rawString: String) -> UberScopeType {
        switch rawString.lowercased() {
        case "all_trips":
            return .allTrips
        case "history":
            return .history
        case "history_lite":
            return .historyLite
        case "places":
            return .places
        case "profile":
            return .profile
        case "request":
            return .request
        case "request_receipt":
            return .requestReceipt
        case "ride_widgets":
            return .rideWidgets
        default:
            return .custom
        }
    }
}

/**
 Extending String to allow for easy conversion from space delminated scope string
 to array of UberScopes
 */
public extension String {
    /**
     Converts a string of space delimited scopes into an array of RideScopes
     - returns: An array of UberScope representing the string
     */
    func toUberScopesArray() -> [UberScope] {
        // backend sends scope string delimited by both space and plus !!!

        let separatedScopes = components(separatedBy: " ").flatMap { (str: String) in
            str.components(separatedBy: "+")
        }

        let scopesArray = separatedScopes.map { (scopeString: String) in
            UberScope(scopeString: scopeString)
        }

        return scopesArray
    }
}

/**
 Extends SequenceType of UberScope to allow for easy conversion to a space
 delimited scope string
 */
public extension Sequence where Iterator.Element == UberScope {
    /**
     Converts an array of UberScopes into a space delimited String
     - parameter scopes: The array of UberScopes to convert
     - returns: A string representing the scopes
     */
    func toUberScopeString() -> String
    {
        var scopeStringArray = [String]()
        for scope in self {
            scopeStringArray.append(scope.rawValue)
        }
        
        return scopeStringArray.joined(separator: " ")
    }
}
