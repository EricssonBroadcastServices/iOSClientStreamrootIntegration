//
//  PlayerViewController.swift
//  StreamrootIntegrationApp
//
//  Created by Fredrik Sjöberg on 2018-09-13.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Exposure
import Player
import ExposurePlayback
import ExposureStreamrootIntegration
import StreamrootSDK

class PlayerViewController: UIViewController {
    
    
    var player: Player<HLSNative<ExposureContext>>!
    var playable: StreamrootPlayable!

    @IBOutlet weak var videoCanvas: UIView!
    @IBOutlet weak var statsCanvas: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    
    
    @IBAction func rewindAction(_ sender: Any) {
        player.seek(toPosition: player.playheadPosition - 30 * 1000)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        player.isPlaying ? player.pause() : player.play()
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        player.seek(toPosition: player.playheadPosition + 30 * 1000)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rewindButton.isEnabled = false
        fastForwardButton.isEnabled = false
        
        player.configure(playerView: videoCanvas)
        
        player
            .onError{ [weak self] player, source, error in
                self?.showMessage(title: "\(error.code): " + error.message, message: error.info ?? "")
                (source as? StreamrootSource)?.dnaClient.stop()
            }
            .onPlaybackCreated{ [weak self] player, source in
                guard let `self` = self else { return }
                (source as? StreamrootSource)?.dnaClient.displayStats(onView: self.statsCanvas)
            }
            .onEntitlementResponse{ [weak self] player, source, entitlement in
                self?.rewindButton.isEnabled = entitlement.rwEnabled
                self?.fastForwardButton.isEnabled = entitlement.ffEnabled
            }
            .onPlaybackStarted{ [weak self] player, source in
                self?.togglePlayPauseButton(paused: false)
            }
            .onPlaybackPaused{ [weak self] player, source in
                self?.togglePlayPauseButton(paused: true)
            }
            .onPlaybackResumed{ [weak self] player, source in
                self?.togglePlayPauseButton(paused: false)
            }
            .onPlaybackCompleted{ player, source in
                (source as? StreamrootSource)?.dnaClient.stop()
            }
            .onPlaybackAborted { player, source in
                (source as? StreamrootSource)?.dnaClient.stop()
            }
        
        player.startPlayback(playable: playable)
    }
    
    fileprivate func togglePlayPauseButton(paused: Bool) {
        if !paused {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: UIControlState.normal)
        }
        else {
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: UIControlState.normal)
        }
    }
    
    #if os(iOS)
    // MARK: Device Orientation
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    #endif
}

extension PlayerViewController: DNAClientDelegate {
    func playbackTime() -> Double {
        return Double(player.playheadPosition / 1000)
    }
    
    func loadedTimeRanges() -> [NSValue] {
        return player.bufferedRanges.map{ NSValue(timeRange: $0) }
    }
    
    func updatePeakBitRate(_ bitRate: Double) {
        player.tech.preferredMaxBitrate = Int64(bitRate)
    }
}
