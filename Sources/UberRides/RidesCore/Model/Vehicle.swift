//
//  Vehicle.swift
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

import Foundation

// MARK: Vehicle

/**
 *  Contains information for an Uber driver's car.
 */
public class Vehicle: Codable {
    
    /// The license plate number of the vehicle.
    public private(set) var licensePlate: String?
    
    /// The vehicle make or brand.
    public private(set) var make: String?
    
    /// The vehicle model or type.
    public private(set) var model: String?
    
    /// The URL to a stock photo of the vehicle
    public private(set) var pictureURL: URL?

    enum CodingKeys: String, CodingKey {
        case make         = "make"
        case model        = "model"
        case licensePlate = "license_plate"
        case pictureURL   = "picture_url"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        licensePlate = try container.decodeIfPresent(String.self, forKey: .licensePlate)
        make = try container.decodeIfPresent(String.self, forKey: .make)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        pictureURL = try container.decodeIfPresent(URL.self, forKey: .pictureURL)
    }
}
