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
@objc(UBSDKRideParameters) public class RideParameters: NSObject {
    /// ProductID to use for the ride
    @objc public let productID: String?

    /// The pickup location to use for the ride
    @objc public let pickupLocation: CLLocation?

    /// The nickname of the pickup location of the ride
    @objc public let pickupNickname: String?
    
    /// The address of the pickup location of the ride
    @objc public let pickupAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    @objc public let pickupPlaceID: String?
    
    /// The dropoff location to use for the ride
    @objc public let dropoffLocation: CLLocation?
    
    /// The nickname of the dropoff location for the ride
    @objc public let dropoffNickname: String?
    
    /// The adress of the dropoff location of the ride
    @objc public let dropoffAddress: String?
    
    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    @objc public let dropoffPlaceID: String?
    
    /// The unique identifier of the payment method selected by a user.
    @objc public let paymentMethod: String?
    
    /// The unique identifier of the surge session for a user.
    @objc public let surgeConfirmationID: String?

    /// Upfront fare quote used to request a ride
    @objc public let upfrontFare: UpfrontFare?
  
    /// The number of seats required for uberPOOL. Default and maximum value is 2.
    @objc public let seatCount: NSNumber?

    /// The source to use for attributing the ride. Used internal to the SDK.
    @objc var source: String?

    @objc public func builder() -> RideParametersBuilder {
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
        builder.seatCount = seatCount
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
                 upfrontFare: UpfrontFare?,
                 seatCount: NSNumber?) {
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
        self.seatCount = seatCount
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
@objc(UBSDKRideParametersBuilder) public class RideParametersBuilder: NSObject {
    /// ProductID to use for the ride
    @objc public var productID: String?

    /// The pickup location to use for the ride
    @objc public var pickupLocation: CLLocation?

    /// The nickname of the pickup location of the ride
    @objc public var pickupNickname: String?

    /// The address of the pickup location of the ride
    @objc public var pickupAddress: String?

    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    @objc public var pickupPlaceID: String?

    /// The dropoff location to use for the ride
    @objc public var dropoffLocation: CLLocation?

    /// The nickname of the dropoff location for the ride
    @objc public var dropoffNickname: String?

    /// The adress of the dropoff location of the ride
    @objc public var dropoffAddress: String?

    /// This is the name of an Uber saved place. Only “home” or “work” is acceptable.
    @objc public var dropoffPlaceID: String?

    /// The unique identifier of the payment method selected by a user.
    @objc public var paymentMethod: String?

    /// The unique identifier of the surge session for a user.
    @objc public var surgeConfirmationID: String?

    /// Upfront fare quote used to request a ride
    @objc public var upfrontFare: UpfrontFare?

    /// The number of seats required for uberPOOL. Default and maximum value is 2.
    @objc public var seatCount: NSNumber?
  
    /// The source to use for attributing the ride. Used internal to the SDK.
    @objc var source: String?

    @objc public func build() -> RideParameters {
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
                              upfrontFare: upfrontFare,
                              seatCount: seatCount)
    }
}
