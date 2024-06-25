//
//  MapAnnotationItem.swift
//  Hitchhiking Diary
//
//  Created by Jakub Dubec on 25/06/2024.
//

import Foundation
import MapKit

struct MapAnnotationItem: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}
