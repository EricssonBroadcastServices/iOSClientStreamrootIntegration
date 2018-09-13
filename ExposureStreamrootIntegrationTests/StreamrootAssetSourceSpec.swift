//
//  StreamrootAssetSourceSpec.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-13.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import ExposurePlayback
import Exposure
import StreamrootSDK
import Quick
import Nimble

@testable import ExposureStreamrootIntegration

class StreamrootAssetSourceSpec: QuickSpec {
    enum MockedError: Error {
        case generalError
    }
    
    override func spec() {
        super.spec()
        
        let environment = Environment(baseUrl: "http://mocked.example.com", customer: "Customer", businessUnit: "BusinessUnit")
        let sessionToken = SessionToken(value: "token")
        let vodAssetId = "vodAssetId"
        let dnaClient =
        
        describe("StreamrootAssetSourceSpec") {
            it("Should configure VoD playable") { [weak self] in
//                let source = StreamrootAssetSource(entitlement: <#T##PlaybackEntitlement#>, assetId: <#T##String#>, response: <#T##HTTPURLResponse?#>, localManifestUrl: <#T##URL#>, dnaClient: <#T##DNAClient#>)
            }
        }
    }
}
