//
//  Item.swift
//  Pomodoro
//
//  Created by Francisco Zapata on 14/4/26.
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
