//
//  RideParameters.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
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

import MapKit

/// Object to represent the parameters needed to request a ride.
public class RideParameters {
    /// ProductID to use for the ride
    public let productID: String?

    /// The pickup location to use for the ride
    public let pickupLocation: CLLocation?

    /// The nickname of the pickup location of the ride
    public let pickupNickname: String?
    
    /// The address of the pickup location of the ride
    public let pickupAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    public let pickupPlaceID: String?
    
    /// The dropoff location to use for the ride
    public let dropoffLocation: CLLocation?
    
    /// The nickname of the dropoff location for the ride
    public let dropoffNickname: String?
    
    /// The adress of the dropoff location of the ride
    public let dropoffAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    public let dropoffPlaceID: String?
    
    /// The unique identifier of the payment method selected by a user.
    public let paymentMethod: String?
    
    /// The unique identifier of the surge session for a user.
    public let surgeConfirmationID: String?

    /// Upfront fare quote used to request a ride
    public let upfrontFare: UpfrontFare?

    /// The source to use for attributing the ride. Used internal to the SDK.
    var source: String?

    public func builder() -> RideParametersBuilder {
        let builder = RideParametersBuilder()
        builder.productID = productID
        builder.pickupLocation = pickupLocation
        builder.pickupNickname = pickupNickname
        builder.pickupAddress = pickupAddress
        builder.pickupPlaceID = pickupPlaceID
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = dropoffNickname
        builder.dropoffAddress = dropoffAddress
        builder.dropoffPlaceID = dropoffPlaceID
        builder.paymentMethod = paymentMethod
        builder.surgeConfirmationID = surgeConfirmationID
        builder.source = source
        builder.upfrontFare = upfrontFare
        return builder
    }

    fileprivate init(productID: String?,
                 pickupLocation: CLLocation?,
                 pickupNickname: String?,
                 pickupAddress: String?,
                 pickupPlaceID: String?,
                 dropoffLocation: CLLocation?,
                 dropoffNickname: String?,
                 dropoffAddress: String?,
                 dropoffPlaceID: String?,
                 paymentMethod: String?,
                 surgeConfirmationID: String?,
                 source: String?,
                 upfrontFare: UpfrontFare?) {
        self.productID = productID
        self.pickupLocation = pickupLocation
        self.pickupNickname = pickupNickname
        self.pickupAddress = pickupAddress
        self.pickupPlaceID = pickupPlaceID
        self.dropoffLocation = dropoffLocation
        self.dropoffNickname = dropoffNickname
        self.dropoffAddress = dropoffAddress
        self.dropoffPlaceID = dropoffPlaceID
        self.paymentMethod = paymentMethod
        self.surgeConfirmationID = surgeConfirmationID
        self.source = source
        self.upfrontFare = upfrontFare
    }

    var userAgent: String? {
        var userAgentString: String = ""
        if let versionNumber: String = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            userAgentString = "rides-ios-v\(versionNumber)"
            if let source = source {
                userAgentString = "\(userAgentString)-\(source)"
            }
        }
        return userAgentString
    }
}

// Builder for RideParameters
public class RideParametersBuilder {
    /// ProductID to use for the ride
    public var productID: String?

    /// The pickup location to use for the ride
    public var pickupLocation: CLLocation?

    /// The nickname of the pickup location of the ride
    public var pickupNickname: String?

    /// The address of the pickup location of the ride
    public var pickupAddress: String?

    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    public var pickupPlaceID: String?

    /// The dropoff location to use for the ride
    public var dropoffLocation: CLLocation?

    /// The nickname of the dropoff location for the ride
    public var dropoffNickname: String?

    /// The adress of the dropoff location of the ride
    public var dropoffAddress: String?

    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    public var dropoffPlaceID: String?

    /// The unique identifier of the payment method selected by a user.
    public var paymentMethod: String?

    /// The unique identifier of the surge session for a user.
    public var surgeConfirmationID: String?

    /// Upfront fare quote used to request a ride
    public var upfrontFare: UpfrontFare?

    /// The source to use for attributing the ride. Used internal to the SDK.
    var source: String?

    public func build() -> RideParameters {
        return RideParameters(productID: productID,
                              pickupLocation: pickupLocation,
                              pickupNickname: pickupNickname,
                              pickupAddress: pickupAddress,
                              pickupPlaceID: pickupPlaceID,
                              dropoffLocation: dropoffLocation,
                              dropoffNickname: dropoffNickname,
                              dropoffAddress: dropoffAddress,
                              dropoffPlaceID: dropoffPlaceID,
                              paymentMethod: paymentMethod,
                              surgeConfirmationID: surgeConfirmationID,
                              source: source,
                              upfrontFare: upfrontFare)
    }
    
    public init(productID: String? = nil, pickupLocation: CLLocation? = nil, pickupNickname: String? = nil, pickupAddress: String? = nil, pickupPlaceID: String? = nil, dropoffLocation: CLLocation? = nil, dropoffNickname: String? = nil, dropoffAddress: String? = nil, dropoffPlaceID: String? = nil, paymentMethod: String? = nil, surgeConfirmationID: String? = nil, upfrontFare: UpfrontFare? = nil, source: String? = nil) {
        self.productID = productID
        self.pickupLocation = pickupLocation
        self.pickupNickname = pickupNickname
        self.pickupAddress = pickupAddress
        self.pickupPlaceID = pickupPlaceID
        self.dropoffLocation = dropoffLocation
        self.dropoffNickname = dropoffNickname
        self.dropoffAddress = dropoffAddress
        self.dropoffPlaceID = dropoffPlaceID
        self.paymentMethod = paymentMethod
        self.surgeConfirmationID = surgeConfirmationID
        self.upfrontFare = upfrontFare
        self.source = source
    }
}
