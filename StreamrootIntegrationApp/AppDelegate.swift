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

extension Asset: ListContent {
    var type: String {
        return self.type
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var mainList: ListViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let root = window?.rootViewController as? UINavigationController, let viewController = root.viewControllers.first as? ListViewController {
            mainList = viewController
            viewController.navigationItem.title = "Streamroot Integration"
            
            let conf = validateEnvironment()
            switch conf {
            case .valid(environment: let env, sessionToken: let token):
                viewController.onDidSelect = { [weak self] content in
                    self?.createRequest(listContent: content, environment: env, sessionToken: token)
                }
                
                viewController.content = [
                    ListItem(title: "Channels", type: "TV_CHANNEL"),
                    ListItem(title: "Movies", type: "MOVIE")
                ]
            default:
                
                viewController.content = [
                    ListItem(title: conf.errorMessage ?? "Unknown Error", type: "ERROR")
                ]
            }
            
        }
        
        return true
    }
    
    enum ConfigStatus: Error {
        case missingExposureEntry
        case missingBaseUrl
        case missingCustomer
        case missingBusinessUnit
        case missingSessionToken
        case valid(environment: Environment, sessionToken: SessionToken)
        
        var errorMessage: String? {
            switch self {
            case .missingExposureEntry: return "Exposure entry not found in Info.plist"
            case .missingBaseUrl: return "BaseUrl entry not found in Info.plist"
            case .missingCustomer: return "Customer entry not found in Info.plist"
            case .missingBusinessUnit: return "BusinessUnit entry not found in Info.plist"
            case .missingSessionToken: return "SessionToken entry not found in Info.plist"
            default: return nil
            }
        }
    }
    
    func validateEnvironment() -> ConfigStatus {
        guard let exposure = Bundle.main.object(forInfoDictionaryKey: "Exposure") as? [String: String] else {
            return .missingExposureEntry
        }
        
        guard let baseUrl = exposure["BaseUrl"] else { return .missingBaseUrl }
        guard let customer = exposure["Customer"] else { return .missingCustomer }
        guard let businessUnit = exposure["BusinessUnit"] else { return .missingBusinessUnit }
//        guard let sessionToken = exposure["SessionToken"] else { return .missingSessionToken }
        let env = Environment(baseUrl: baseUrl, customer: customer, businessUnit: businessUnit)
        let token = SessionToken(value: "sessionToken")
        return .valid(environment: env, sessionToken: token)
    }
    
    func createRequest(listContent: ListContent, environment: Environment, sessionToken: SessionToken) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "List") as! ListViewController
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
        mainList?.navigationController?.pushViewController(viewController, animated: true)
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
        let epgViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "List") as! ListViewController
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
        let playerViewController = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        playerViewController.navigationItem.title = program.title
        playerViewController.player = Player(environment: environment, sessionToken: sessionToken)
        
        let playable = StreamrootPlayable(programId: program.programId, channelId: program.channelId, dnaDelegate: playerViewController)
        presenter.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    func play(channel: Asset, presenter: ListViewController, environment: Environment, sessionToken: SessionToken) {
        print(#function)
        
    }
    
    func play(asset: Asset, presenter: ListViewController, environment: Environment, sessionToken: SessionToken) {
        print(#function)
        
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

