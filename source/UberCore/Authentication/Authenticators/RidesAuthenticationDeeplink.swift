//
//  RidesAuthenticationDeeplink.swift
//  UberRides
//
//  Copyright © 2018 Uber Technologies, Inc. All rights reserved.
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

/**
 *  A Deeplinking object for authenticating a user via the native Uber rides app
 */
@objc(UBSDKRidesAuthenticationDeeplink) public class RidesAuthenticationDeeplink: BaseDeeplink {

    /**
     Initializes an Authentication Deeplink to request the provided scopes

     - parameter scopes: An array of UberScopes you would like to request

     - returns: An initialized AuthenticationDeeplink
     */
    @objc public init(scopes: [UberScope], requestUri: String? = nil) {
        let queryItems = AuthenticationURLUtility.buildQueryParameters(scopes: scopes, requestUri: requestUri)
        let scheme = "uberauth"
        let domain = "connect"

        super.init(scheme: scheme, host: domain, path: "", queryItems: queryItems)!
    }
}
