//
//  Scooter.swift
//  ForeRide
//
//  Created by NPL-Weng on 4/1/25.
//
import Foundation
import FirebaseFirestore
import CoreLocation

struct Scooter: Identifiable, Codable {
    @DocumentID var id: String?
    var latitude: Double
    var longitude: Double
    var isAvailable: Bool
    var name: String
    var batteryLevel: Int // for example, battery level as a percentage (0-100)
    // ... add other fields as needed
}


