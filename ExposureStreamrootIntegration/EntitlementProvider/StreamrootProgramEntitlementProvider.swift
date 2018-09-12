//
//  StreamrootProgramEntitlementProvider.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-12.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import Exposure

/// Provider for program based entitlements from Exposure
internal protocol StreamrootProgramEntitlementProvider {
    func requestEntitlement(programId: String, channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void)
}
