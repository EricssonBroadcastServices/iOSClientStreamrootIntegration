//
//  Program+Extensions.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-14.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import Exposure

extension Program: ListContent {
    var type: String {
        return self.type
    }
    
    var title: String {
        let local = asset?.localized?.filter{ $0.locale == "en" }.first
        if let result = local?.title { return result }
        if let result = asset?.localized?.first?.title { return result }
        return assetId
    }
    
    var desc: String? {
        return startDate?.hoursAndMinutes()
    }
}

