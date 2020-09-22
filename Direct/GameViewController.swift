//
//  GameViewController.swift
//  Direct
//
//  Created by Arjon Das on 7/1/17.
//  Copyright © 2017 Arjon Das. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {
    
    @IBOutlet weak var bannerAd: GADBannerView!
    
    var interstitialAd : GADInterstitial!
    var rewardAd : GADRewardBasedVideoAd!
    var gamesceneEssentials = GameScene()
    var life : Int = 0
    var showAd : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if showAd {
            bannerAd.rootViewController = self
            bannerAd.delegate = self
            bannerAd.adUnitID = "ca-app-pub-[your publisher id]"
            bannerAd.isHidden = true
            let requestBanner = GADRequest()
            requestBanner.testDevices = [kGADSimulatorID]
            bannerAd.load(requestBanner)
            interstitialAd = initializeNewInterstitialAd()
            interstitialAd.delegate = self
            rewardAd = initializeNewRewardVideo()
            rewardAd.delegate = self
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let scene = SKScene(fileNamed: "GameScene") {
            // Configure the view.
            let view = self.view as! SKView
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            view.ignoresSiblingOrder = true
            /* Set the scale mode to scale to fit the window */
            
            if(view.scene == nil) {
                scene.scaleMode = .aspectFill
                scene.size  = view.bounds.size
                view.presentScene(scene)
            }
        }
        
    }
    
    /// Tells the delegate that the reward based video ad has rewarded the user.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        life += 1
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        if life == 1 {
            gamesceneEssentials.resurrectBall()
            life = 0
        } else {
            gamesceneEssentials.manageScoreAndExit()
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        requestNewInterstitialAd()
    }
    
    func showBannerAd() {
        if showAd {
            bannerAd.isHidden = false
        }
    }
    
    func hideBannerAd() {
        if showAd {
            bannerAd.isHidden = true
        }
    }
    
    func showInterstitialAd() {
        if showAd {
            if interstitialAd.isReady {
                interstitialAd.present(fromRootViewController: self)
            }
        }
    }
    
    func showRewardVideo() {
        if rewardAd.isReady {
            rewardAd.present(fromRootViewController: self)
        }else {
            gamesceneEssentials.failedLoadingRewardVideo()
        }
    }
    
    func initializeNewInterstitialAd() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-[your publisher id]")
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitial.load(request)
        return interstitial
    }
    
    func initializeNewRewardVideo() -> GADRewardBasedVideoAd {
        let reward = GADRewardBasedVideoAd.sharedInstance()
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        reward.load(request, withAdUnitID: "ca-app-pub-[your publisher id")
        return reward
    }
    
    func requestNewInterstitialAd() {
        if showAd {
            interstitialAd = initializeNewInterstitialAd()
        }
    }
    
    func requestNewRewardAd() {
        if showAd {
            rewardAd = initializeNewRewardVideo()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

