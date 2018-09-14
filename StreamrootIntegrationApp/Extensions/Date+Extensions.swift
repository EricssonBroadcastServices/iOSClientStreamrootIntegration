//
//  Date+Extensions.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-14.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

extension Date {
    public func subtract(days: UInt) -> Date? {
        var components = DateComponents()
        components.setValue(-Int(days), for: Calendar.Component.day)
        
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    public func hoursAndMinutes() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_GB")
        
        return timeFormatter.string(from: self)
    }
}
