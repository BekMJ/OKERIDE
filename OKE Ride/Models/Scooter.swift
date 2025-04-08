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
    @DocumentID var id: String?    // Firestore auto-generated ID
    var latitude: Double
    var longitude: Double
    var isAvailable: Bool
    var name: String              // e.g., "Scooter #1"
    // ... add other fields as needed
}

