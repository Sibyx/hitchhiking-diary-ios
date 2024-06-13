//
//  Item.swift
//  Hitchhiking Diary
//
//  Created by Jakub Dubec on 13/06/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
