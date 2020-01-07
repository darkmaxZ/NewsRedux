//
//  ViewController.swift
//  ReduxApp
//
//  Created by Ziurin, Maksim on 2019/12/24.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter

class MainTabBarController: UITabBarController, Routable, StoreSubscriber {
    private let newsViewController = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
    
    static let identifier = "TabBar"
    
    private var savedRoutes: [String: Route] = [:]
       
    // MARK: NSObject(UINibLoadingAdditions)
       
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self // need to intercept user taps and redirect to the router
           
        mainStore.subscribe(self) {
            $0.select { $0.navigationState.route }
        }
           
        // save default routes per tab (NOTE: includes root identifier for each tab)
        savedRoutes[NewsViewController.identifier] = [NewsViewController.identifier]
    }
    
    // MARK: StoreSubscriber
    
    func newState(state: Route) {
        print("# newState route: \(state)")
        saveRelativeRoute()
    }
    
    // MARK: Routable
    
    func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
        
        print("MainTabBarController Routable push \(routeElementIdentifier)")
        setUpTabs()
        
        if routeElementIdentifier == MainTabBarController.identifier {
            // dsletten: we are the initial route, set up from AppDelegate, so we can ignore this request
            completionHandler()
        }
        
        if routeElementIdentifier == NewsViewController.identifier {
            selectedViewController = newsViewController
            completionHandler()
            return newsViewController
        }
        
        return self
    }
    
    func popRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) {
        print("MainTabBarController Routable pop \(routeElementIdentifier) (always null action)")
        completionHandler()
    }
    
    private func saveRelativeRoute() {
        var currentRelativeRoute = mainStore.state.navigationState.route
        while currentRelativeRoute.count > 0 {
            let id = currentRelativeRoute.removeFirst()
            if (id == MainTabBarController.identifier) {
                break
            }
        }
        if !currentRelativeRoute.isEmpty {
            print("Save relative route: \(currentRelativeRoute)")
            savedRoutes[currentRelativeRoute.first!] = currentRelativeRoute
        }
    }
    
    func changeRouteSegment(_ from: RouteElementIdentifier, to: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
        
        print("MainTabBarController Routable change \(to)")
        
        if to == NewsViewController.identifier {
            selectedViewController = newsViewController
            completionHandler()
            return newsViewController
        }
        
        return self
    }
    
    // MARK: Private
    
    private func setUpTabs() {
        if (viewControllers?.count ?? 0) == 0 {
            viewControllers = [newsViewController]
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // tab 1
        if viewController is NewsViewController {
            let route: Route = [MainTabBarController.identifier]
                + savedRoutes[NewsViewController.identifier]!
            mainStore.dispatch(SetRouteAction(route))
        }

        // don't let iOS change the selected tab by itself!! We must let our router do it for us lol!  ^__^ <- Dan
        return false
    }
}


