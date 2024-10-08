//
//  RequestDeeplink.swift
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


import CoreLocation
import UIKit
import UberAuth
import UberCore

/**
 *  Builds and executes a deeplink to the native Uber app to request a ride.
 */
public class RequestDeeplink: BaseDeeplink {
    static let sourceString = "deeplink"

    private let rideParameters: RideParameters
    private let fallbackType: DeeplinkFallbackType
    private let configurationProvider: ConfigurationProviding

    /**
     Initialize a ride request deeplink. If the Uber app is not installed, fallback to the App Store.
     */
    public convenience init(rideParameters: RideParameters = RideParametersBuilder().build()) {
        self.init(rideParameters: rideParameters, fallbackType: DeeplinkFallbackType.appStore)
    }

    /**
     Initialize a ride request deeplink.
     */
    public init(rideParameters: RideParameters, 
                fallbackType: DeeplinkFallbackType,
                configurationProvider: ConfigurationProviding = ConfigurationProvider()) {
        self.rideParameters = rideParameters
        self.fallbackType = fallbackType
        self.rideParameters.source = rideParameters.source ?? RequestDeeplink.sourceString
        self.configurationProvider = configurationProvider

        let queryItems = RequestURLUtil.buildRequestQueryParameters(rideParameters)
        let scheme = "uber"
        let domain = ""

        super.init(scheme: scheme, host: domain, path: "", queryItems: queryItems)!
    }

    public override var fallbackURLs: [URL] {
        var urls = super.fallbackURLs
        if let fallbackURL = buildFallbackURL() {
            urls.append(fallbackURL)
        }
        return urls
    }

    private func buildFallbackURL() -> URL? {
        switch fallbackType {
        case .mobileWeb:
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                urlComponents.scheme = "https"
                urlComponents.host = "m.uber.com"
                return urlComponents.url
            }
        case .appStore:
            let deeplink = RidesAppStoreDeeplink(
                userAgent: rideParameters.userAgent,
                clientID: configurationProvider.clientID ?? "",
                sdkVersion: configurationProvider.sdkVersion
            )
            return deeplink.url
        default:
            break
        }
        return nil
    }
}
