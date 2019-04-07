//
//  RideRequestDataBuilder.swift
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

import CoreLocation

// MARK: RideRequestDataBuilder

/**
 *  Builds a RideRequest object through chaining.
 */
class RideRequestDataBuilder {
    
    let dropoffKey = "end"
    let addressKey = "address"
    let latitudeKey = "latitude"
    let longitudeKey = "longitude"
    let nicknameKey = "nickname"
    let paymentMethodKey = "payment_method_id"
    let pickupKey = "start"
    let placeIDKey = "place_id"
    let productIDKey = "product_id"
    let surgeConfirmationKey = "surge_confirmation_id"
    let upfrontFareKey = "fare_id"
    let seatCountKey = "seat_count"
    
    private var rideParameters: RideParameters
    
    init(rideParameters: RideParameters) {
        self.rideParameters = rideParameters
    }
    
    func build() -> Data? {
        var data = [String: Any]()
        
        if let productID = rideParameters.productID {
            data[productIDKey] = productID
        }
        
        if let pickupLocation = rideParameters.pickupLocation {
            data["\(pickupKey)_\(latitudeKey)"] = pickupLocation.coordinate.latitude
            data["\(pickupKey)_\(longitudeKey)"] = pickupLocation.coordinate.longitude
        } else if let pickupPlace = rideParameters.pickupPlaceID {
            data["\(pickupKey)_\(placeIDKey)"] = pickupPlace
        }
        
        if let pickupNickname = rideParameters.pickupNickname {
            data["\(pickupKey)_\(nicknameKey)"] = pickupNickname
        }
        
        if let pickupAddress = rideParameters.pickupAddress {
            data["\(pickupKey)_\(addressKey)"] = pickupAddress
        }
        
        if let dropoffLocation = rideParameters.dropoffLocation {
            data["\(dropoffKey)_\(latitudeKey)"] = dropoffLocation.coordinate.latitude
            data["\(dropoffKey)_\(longitudeKey)"] = dropoffLocation.coordinate.longitude
        } else if let dropoffPlace = rideParameters.dropoffPlaceID {
            data["\(dropoffKey)_\(placeIDKey)"] = dropoffPlace
        }
        
        if let dropoffNickname = rideParameters.dropoffNickname {
            data["\(dropoffKey)_\(nicknameKey)"] = dropoffNickname
        }
        
        if let dropoffAddress = rideParameters.dropoffAddress {
            data["\(dropoffKey)_\(addressKey)"] = dropoffAddress
        }
        
        if let paymentMethod = rideParameters.paymentMethod {
            data["\(paymentMethodKey)"] = paymentMethod
        }
        
        if let surgeConfirmation = rideParameters.surgeConfirmationID {
            data["\(surgeConfirmationKey)"] = surgeConfirmation
        }

        if let upfrontFareID = rideParameters.upfrontFare?.fareID {
            data[upfrontFareKey] = upfrontFareID
        }
      
        if let seatCount = rideParameters.seatCount {
          data[seatCountKey] = seatCount
        }
        
        var bodyData: Data?
        do {
            bodyData = try JSONSerialization.data(withJSONObject: data, options: [])
            return bodyData
        } catch { }
        return nil
    }
}
