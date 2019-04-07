//
//  RideParametersTest.swift
//  UberRides
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
import MapKit
@testable import UberRides

class RideParametersTest: XCTestCase {
    private var versionNumber: String?
    private var baseUserAgent: String?
    
    override func setUp() {
        super.setUp()
        versionNumber = Bundle(for: RideParameters.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        baseUserAgent = "rides-ios-v\(versionNumber!)"
    }
    
    func testBuilder_withNoParams() {
        let params = RideParametersBuilder().build()
        XCTAssertNotNil(params)
        XCTAssertNil(params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.productID)
        XCTAssertEqual(params.userAgent, baseUserAgent)
    }
    
    func testBuilder_correctUseCurrentLocation() {
        let testPickup = CLLocation(latitude: 32.0, longitude: -32.0)
        let builder = RideParametersBuilder()
        builder.pickupLocation = testPickup
        let params = builder.build()
        XCTAssertEqual(testPickup, params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.productID)
        XCTAssertEqual(params.userAgent, baseUserAgent)
    }
    
    func testBuilder_withAllParameters() {

        let testPickupLocation = CLLocation(latitude: 32.0, longitude: -32.0)
        let testDropoffLocation = CLLocation(latitude: 62.0, longitude: -62.0)
        let testPickupNickname = "testPickup"
        let testPickupAddress = "123 pickup address"
        let testDropoffNickname = "testDropoff"
        let testDropoffAddress = "123 dropoff address"
        let testProductID = "test ID"
        let testSource = "test source"
        let testPaymentID = "test payment id"
        let testSurgeConfirm = "test surge confirm"
        let testSeatCount = 1 as NSNumber
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        let builder = RideParametersBuilder()
        builder.pickupLocation = testPickupLocation
        builder.pickupNickname = testPickupNickname
        builder.pickupAddress = testPickupAddress
        builder.dropoffLocation = testDropoffLocation
        builder.dropoffNickname = testDropoffNickname
        builder.dropoffAddress = testDropoffAddress
        builder.paymentMethod = testPaymentID
        builder.surgeConfirmationID = testSurgeConfirm
        builder.productID = testProductID
        builder.source = testSource
        builder.seatCount = testSeatCount
        let params = builder.build()

        XCTAssertEqual(params.pickupLocation, testPickupLocation)
        XCTAssertEqual(params.pickupAddress, testPickupAddress)
        XCTAssertEqual(params.pickupNickname, testPickupNickname)
        XCTAssertEqual(params.dropoffLocation, testDropoffLocation)
        XCTAssertEqual(params.dropoffAddress, testDropoffAddress)
        XCTAssertEqual(params.dropoffNickname, testDropoffNickname)
        XCTAssertEqual(params.productID, testProductID)
        XCTAssertEqual(params.userAgent, expectedUserAgent)
        XCTAssertEqual(params.paymentMethod, testPaymentID)
        XCTAssertEqual(params.surgeConfirmationID, testSurgeConfirm)
        XCTAssertEqual(params.seatCount, testSeatCount)
    }
    
    func testBuilder_withAllParams_usingPlaceIDs() {
        let testPickupPlace = "home"
        let testDropoffPlace = "work"
        let testProductID = "test ID"
        let testSource = "test source"
        let testPaymentID = "test payment id"
        let testSurgeConfirm = "test surge confirm"
        let expectedUserAgent = "\(baseUserAgent!)-\(testSource)"
        let builder = RideParametersBuilder()
        builder.pickupPlaceID = testPickupPlace
        builder.dropoffPlaceID = testDropoffPlace
        builder.paymentMethod = testPaymentID
        builder.surgeConfirmationID = testSurgeConfirm
        builder.productID = testProductID
        builder.source = testSource
        let params = builder.build()
        
        XCTAssertEqual(params.pickupPlaceID, testPickupPlace)
        XCTAssertEqual(params.dropoffPlaceID, testDropoffPlace)
        XCTAssertNil(params.dropoffNickname)
        XCTAssertNil(params.dropoffAddress)
        XCTAssertNil(params.dropoffLocation)
        XCTAssertNil(params.pickupLocation)
        XCTAssertNil(params.pickupAddress)
        XCTAssertNil(params.pickupNickname)
        XCTAssertEqual(params.productID, testProductID)
        XCTAssertEqual(params.userAgent, expectedUserAgent)
        XCTAssertEqual(params.paymentMethod, testPaymentID)
        XCTAssertEqual(params.surgeConfirmationID, testSurgeConfirm)
    }
}
