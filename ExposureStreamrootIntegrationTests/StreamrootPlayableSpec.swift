//
//  StreamrootPlayableSpec.swift
//  ExposureStreamrootIntegration
//
//  Created by Fredrik Sjöberg on 2018-09-13.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

import Nimble
import Quick
import Exposure
import ExposurePlayback
import StreamrootSDK

@testable import ExposureStreamrootIntegration

internal class MockedAssetEntitlementProvider: StreamrootPlayable.StreamrootEntitlementProvider {
    var mockedRequestEntitlement: (String, SessionToken, Environment, (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) -> Void = { _,_,_,_ in }
    func requestEntitlement(assetId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) {
        mockedRequestEntitlement(assetId, sessionToken, environment, callback)
    }
    
    func requestEntitlement(channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) {
        mockedRequestEntitlement(channelId, sessionToken, environment, callback)
    }
    
    func requestEntitlement(programId: String, channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?, HTTPURLResponse?) -> Void) {
        mockedRequestEntitlement(programId, sessionToken, environment, callback)
    }
    
}


class StreamrootPlayableSpec: QuickSpec, DNAClientDelegate {
    func playbackTime() -> Double {
        return 0
    }
    
    func loadedTimeRanges() -> [NSValue] {
        return []
    }
    
    func updatePeakBitRate(_ bitRate: Double) {
        // Do nothing
    }
    
    
    enum MockedError: Error {
        case generalError
    }
    
    override func spec() {
        super.spec()
        
        let environment = Environment(baseUrl: "http://mocked.example.com", customer: "Customer", businessUnit: "BusinessUnit")
        let sessionToken = SessionToken(value: "token")
        let vodAssetId = "vodAssetId"
        let channelAssetId = "channelAssetId"
        let programAssetId = "programAssetId"
        
        describe("StreamrootPlayableSpec") {
            it("Should configure VoD playable") { [weak self] in
                guard let `self` = self else { return }
                let playable = StreamrootPlayable(assetId: vodAssetId, dnaDelegate: self)
                
                expect(playable.assetId).to(equal(vodAssetId))
                expect(playable.mediaType).to(equal("ASSET"))
                expect(playable.programId).to(beNil())
            }
            
            it("Should configure Channel playable") { [weak self] in
                guard let `self` = self else { return }
                let playable = StreamrootPlayable(channelId: channelAssetId, dnaDelegate: self)
                
                expect(playable.assetId).to(equal(channelAssetId))
                expect(playable.mediaType).to(equal("CHANNEL"))
                expect(playable.programId).to(beNil())
                expect(playable.channelId).to(equal(channelAssetId))
            }
            
            it("Should configure Program playable") { [weak self] in
                guard let `self` = self else { return }
                let playable = StreamrootPlayable(programId: programAssetId, channelId: channelAssetId, dnaDelegate: self)
                
                expect(playable.assetId).to(equal(programAssetId))
                expect(playable.mediaType).to(equal("PROGRAM"))
                expect(playable.programId).to(equal(programAssetId))
                expect(playable.channelId).to(equal(channelAssetId))
            }
            
            it("Should fail to prepare source when encountering error") {
                let provider = MockedAssetEntitlementProvider()
                provider.mockedRequestEntitlement = { _,_,_, callback in
                    callback(nil,ExposureError.generalError(error: MockedError.generalError), nil)
                }
                var playable = StreamrootPlayable(assetId: vodAssetId, dnaDelegate: self)
                playable.entitlementProvider = provider
                var source: ExposureSource? = nil
                var error: ExposureError? = nil
                playable.prepareSource(environment: environment, sessionToken: sessionToken) { src, err in
                    source = src
                    error = err
                }

                expect(source).toEventually(beNil())
                expect(error).toEventuallyNot(beNil())
            }
        }
    }
}
