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
    static let identifier = "TabBar"
    
    private let topHeadlinesNavigationController = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "TopHeadlinesNavigationController") as! TopHeadlinesNavigationController
    private let newsSearchNavigationController = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "NewsSearchNavigationController") as! NewsSearchNavigationController
    private var savedRoutes: [String: Route] = [:]
       
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
           
        mainStore.subscribe(self) {
            $0.select { $0.multiNavigationState.currentState.route }
        }
           
        savedRoutes[TopHeadlinesNavigationController.identifier] = [TopHeadlinesNavigationController.identifier, TopHeadlinesViewController.identifier]
        savedRoutes[NewsSearchNavigationController.identifier] = [NewsSearchNavigationController.identifier, NewsSearchViewController.identifier]
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
            completionHandler()
        }
        
        if routeElementIdentifier == TopHeadlinesNavigationController.identifier {
            selectedViewController = topHeadlinesNavigationController
            completionHandler()
            return topHeadlinesNavigationController
        }
        if routeElementIdentifier == NewsSearchNavigationController.identifier {
            selectedViewController = newsSearchNavigationController
            completionHandler()
            return newsSearchNavigationController
        }
        
        return self
    }
    
    func popRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) {
        print("MainTabBarController Routable pop \(routeElementIdentifier) (always null action)")
        completionHandler()
    }
    
    private func saveRelativeRoute() {
        var currentRelativeRoute = mainStore.state.multiNavigationState.currentState.route
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
        
        if to == TopHeadlinesNavigationController.identifier {
            selectedViewController = topHeadlinesNavigationController
            completionHandler()
            return topHeadlinesNavigationController
        }
        if to == NewsSearchNavigationController.identifier {
            selectedViewController = newsSearchNavigationController
            completionHandler()
            return newsSearchNavigationController
        }
        
        return self
    }
    
    private func setUpTabs() {
        if (viewControllers?.count ?? 0) == 0 {
            viewControllers = [topHeadlinesNavigationController, newsSearchNavigationController]
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is TopHeadlinesNavigationController {
            let route: Route = [MainTabBarController.identifier]
                + savedRoutes[TopHeadlinesNavigationController.identifier]!
            mainStore.dispatch(SwitchRouteStackAction(routeStackName: TopHeadlinesNavigationController.identifier, route: route))
        }
        if viewController is NewsSearchNavigationController {
            let route: Route = [MainTabBarController.identifier]
                + savedRoutes[NewsSearchNavigationController.identifier]!
            mainStore.dispatch(SwitchRouteStackAction(routeStackName: NewsSearchNavigationController.identifier, route: route))
        }

        return false
    }
}


