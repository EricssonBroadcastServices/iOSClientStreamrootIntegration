//
//  AppDelegate.swift
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var rootNav: UINavigationController?

    static var mainStoryboard: String {
        #if os(iOS)
        return "Main"
        #else
        return "Main-tvOS"
        #endif
    }
    
    static var playerViewController: String {
        #if os(iOS)
        return "PlayerViewController"
        #else
        return "PlayerViewController-tvOS"
        #endif
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let root = window?.rootViewController as? UINavigationController {
            let viewController = UIStoryboard(name: AppDelegate.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: "List") as! ListViewController
            rootNav = root
            root.navigationBar.isTranslucent = false
            let conf = validateEnvironment()
            switch conf {
            case .valid(environment: let env):
                let login = UIStoryboard(name: AppDelegate.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                login.environment = env
                _ = login.view
                login.customerLabel.text = env.businessUnit
                login.businessUnitLabel.text = env.customer
                login.onDidAuthenticate = { [weak self, weak root] in
                    guard let `self` = self else { return }
                    let main = UIStoryboard(name: AppDelegate.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: "List") as! ListViewController
                    self.conf(mainView: main, environment: env, sessionToken: $0)
                    root?.pushViewController(main, animated: true)
                }
                
                if let token = sessionToken() {
                    self.conf(mainView: viewController, environment: env, sessionToken: token)
                    root.setViewControllers([login, viewController], animated: false)
                }
                else {
                    root.setViewControllers([login], animated: false)
                }
            default:
                viewController.content = [
                    ListItem(title: conf.errorMessage ?? "Unknown Error", type: "ERROR")
                ]
                root.setViewControllers([viewController], animated: false)
            }
        }
        
        return true
    }
    
    func conf(mainView viewController: ListViewController, environment: Environment, sessionToken: SessionToken) {
        viewController.navigationItem.title = "Streamroot Integration"
        
        viewController.onDidSelect = { [weak self] content in
            self?.createRequest(listContent: content, environment: environment, sessionToken: sessionToken)
        }
        
        viewController.content = [
            ListItem(title: "Channels", type: "TV_CHANNEL"),
            ListItem(title: "Movies", type: "MOVIE")
        ]
    }
    
    enum ConfigStatus: Error {
        case missingExposureEntry
        case missingBaseUrl
        case missingCustomer
        case missingBusinessUnit
        case valid(environment: Environment)
        
        var errorMessage: String? {
            switch self {
            case .missingExposureEntry: return "Exposure entry not found in Info.plist"
            case .missingBaseUrl: return "BaseUrl entry not found in Info.plist"
            case .missingCustomer: return "Customer entry not found in Info.plist"
            case .missingBusinessUnit: return "BusinessUnit entry not found in Info.plist"
            default: return nil
            }
        }
    }
    
    func sessionToken() -> SessionToken? {
        if let token = (Bundle.main.object(forInfoDictionaryKey: "Exposure") as? [String: String])?["SessionToken"], token != "" {
            return SessionToken(value: token)
        }
        guard let token = UserDefaults.standard.string(forKey: "exposureSessionToken") else { return nil }
        return SessionToken(value: token)
    }
    
    func validateEnvironment() -> ConfigStatus {
        guard let exposure = Bundle.main.object(forInfoDictionaryKey: "Exposure") as? [String: String] else {
            return .missingExposureEntry
        }
        
        guard let baseUrl = exposure["BaseUrl"], baseUrl != "" else { return .missingBaseUrl }
        guard let customer = exposure["Customer"], customer != "" else { return .missingCustomer }
        guard let businessUnit = exposure["BusinessUnit"], businessUnit != "" else { return .missingBusinessUnit }
        let env = Environment(baseUrl: baseUrl, customer: customer, businessUnit: businessUnit)
        return .valid(environment: env)
    }
    
    func createRequest(listContent: ListContent, environment: Environment, sessionToken: SessionToken) {
        let viewController = UIStoryboard(name: AppDelegate.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: "List") as! ListViewController
        let query = "&pageSize=50&onlyPublished=true"
        switch listContent.type {
        case "TV_CHANNEL":
            viewController.navigationItem.title = "Channels"
            viewController.onDidSelect = { [weak self, weak viewController] in
                guard let channel = $0 as? Asset, let viewController = viewController else { return }
                self?.createEpgRequest(channel: channel, presenter: viewController, environment: environment, sessionToken: sessionToken)
            }
            let exposureRequest = ExposureApi<AssetList>(environment: environment, endpoint: "content/asset/", query: "assetType=TV_CHANNEL"+query, method: .get, sessionToken: sessionToken)
            handleListRequest(apiRequest: exposureRequest, presenter: viewController)
        case "MOVIE":
            viewController.navigationItem.title = "Movies"
            viewController.onDidSelect = { [weak self, weak viewController] in
                guard let asset = $0 as? Asset, let viewController = viewController else { return }
                self?.play(asset: asset, presenter: viewController, environment: environment, sessionToken: sessionToken)
            }
            let exposureRequest = ExposureApi<AssetList>(environment: environment, endpoint: "content/asset/", query: "assetType=MOVIE"+query, method: .get, sessionToken: sessionToken)
            handleListRequest(apiRequest: exposureRequest, presenter: viewController)
        default:
            return
        }
        rootNav?.pushViewController(viewController, animated: true)
    }
    
    func handleListRequest(apiRequest: ExposureApi<AssetList>, presenter: ListViewController) {
        apiRequest
            .request()
            .validate()
            .response{ [weak presenter] in
                if let value = $0.value?.items {
                    presenter?.content = value
                }
                
                if let error = $0.error {
                    presenter?.content = [ListItem(title: "\(error.code)" + error.message, type: "ERROR")]
                }
                presenter?.tableView.reloadData()
        }
    }
    
    func createEpgRequest(channel: Asset, presenter: ListViewController, environment: Environment, sessionToken: SessionToken) {
        let epgViewController = UIStoryboard(name: AppDelegate.mainStoryboard, bundle: nil).instantiateViewController(withIdentifier: "List") as! ListViewController
        epgViewController.navigationItem.title = channel.title
        
        epgViewController.onDidSelect = { [weak self] in
            if let program = $0 as? Program {
                self?.play(program: program, presenter: epgViewController, environment: environment, sessionToken: sessionToken)
            }
            else if let noEpg = $0 as? ListItem, noEpg.type == "NO_EPG_TV_CHANNEL" {
                self?.play(channel: channel, presenter: epgViewController, environment: environment, sessionToken: sessionToken)
            }
        }
        
        let now = Date().millisecondsSince1970
        let yesterday = Date().subtract(days: 1)?.millisecondsSince1970 ?? now
        let query = "from=\(yesterday)&to=\(now)"
        ExposureApi<ChannelEpg>(environment: environment, endpoint: "epg/\(channel.assetId)", query: query, method: .get, sessionToken: sessionToken)
            .request()
            .validate()
            .response{ [weak epgViewController] in
                if let value = $0.value?.programs {
                    epgViewController?.content = value.isEmpty ? [ListItem(title: "No Epg. Play Live Channel", type: "NO_EPG_TV_CHANNEL")] : value
                }
                
                if let error = $0.error {
                    epgViewController?.content = [ListItem(title: "\(error.code)" + error.message, type: "ERROR")]
                }
                epgViewController?.tableView.reloadData()
            }
        presenter.navigationController?.pushViewController(epgViewController, animated: true)
    }
    
    func play(program: Program, presenter: ListViewController, environment: Environment, sessionToken: SessionToken) {
        let playerViewController = PlayerViewController(nibName: AppDelegate.playerViewController, bundle: nil)
        playerViewController.navigationItem.title = program.title
        playerViewController.player = Player(environment: environment, sessionToken: sessionToken)
        
        let playable = StreamrootPlayable(programId: program.programId, channelId: program.channelId, dnaDelegate: playerViewController)
        playerViewController.playable = playable.latency(30)
        presenter.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    func play(channel: Asset, presenter: ListViewController, environment: Environment, sessionToken: SessionToken) {
        let playerViewController = PlayerViewController(nibName: AppDelegate.playerViewController, bundle: nil)
        playerViewController.navigationItem.title = channel.title
        playerViewController.player = Player(environment: environment, sessionToken: sessionToken)
        
        let playable = StreamrootPlayable(channelId: channel.assetId, dnaDelegate: playerViewController)
        playerViewController.playable = playable.latency(30)
        presenter.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    func play(asset: Asset, presenter: ListViewController, environment: Environment, sessionToken: SessionToken) {
        let playerViewController = PlayerViewController(nibName: AppDelegate.playerViewController, bundle: nil)
        playerViewController.navigationItem.title = asset.title
        playerViewController.player = Player(environment: environment, sessionToken: sessionToken)
        
        let playable = StreamrootPlayable(assetId: asset.assetId, dnaDelegate: playerViewController)
        playerViewController.playable = playable.latency(30)
        presenter.navigationController?.pushViewController(playerViewController, animated: true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

