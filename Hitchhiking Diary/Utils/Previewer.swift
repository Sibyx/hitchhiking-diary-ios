//
//  Previewer.swift
//  FaceFacts
//
//  Created by Paul Hudson on 22/12/2023.
//

import Foundation
import SwiftData
import MapKit

@MainActor
struct Previewer {
    let container: ModelContainer
    let trip: Trip
    let record1: TripRecord
    let record2: TripRecord

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Trip.self, configurations: config)

        trip = Trip(
            title: "Sample Trip",
            content: "This is a sample trip description.",
            status: .inProgress,
            createdAt: Date()
        )
        record1 = TripRecord(
            type: .interesting,
            content: "Interesting spot",
            location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        )
        record2 = TripRecord(
            type: .camping,
            content: "Camping site",
            location: CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2711)
        )
        
        trip.records.append(record1)
        trip.records.append(record2)

        container.mainContext.insert(trip)
    }
}
