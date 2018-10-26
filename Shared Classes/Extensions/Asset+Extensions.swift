//
//  Asset+Extensions.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-14.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import Exposure

extension Asset: ListContent {
    var listType: String {
        return self.listType
    }
    
    var title: String {
        let local = localized?.filter{ $0.locale == "en" }.first
        if let result = local?.title {
            return result
        }
        return originalTitle ?? assetId
    }
    
    var desc: String? {
        return nil
    }
}
