//
//  NewsSearchNavigationController.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/25.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import Kingfisher

class NewsSearchNavigationController: UINavigationController, UINavigationControllerDelegate, Routable {
    static let identifier = "NewsSearchTabRoot"

    private var topRouteId: RouteElementIdentifier?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self // need to intercept user taps and redirect to the router
    }
    
    private func didPopViewController(_ viewController: UIViewController) {
        print("NON-ROUTING GO BACK!")
        
        var route = mainStore.state.multiNavigationState.currentState.route
        if route.count > 1 {
            _ = route.popLast()
            mainStore.dispatch(SetRouteAction(route, animated: false))
        }
    }
    
    // MARK: Routable
    
    var skipRoutingDuringMultiRouteSynchronization = false
    
    func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) -> Routable {
        print("NewsSearchNavigationController Routable push \(routeElementIdentifier)")

        // convention: route element name + "ViewController" matches storyboard identifier
        if routeElementIdentifier == NewsArticleDetailsViewController.identifier {
            let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: routeElementIdentifier + "ViewController") as! NewsArticleDetailsViewController
            vc.article = mainStore.state.multiNavigationState.currentState.getRouteSpecificState(mainStore.state.multiNavigationState.currentState.route)!
            pushViewController(vc, animated: animated)
            topRouteId = routeElementIdentifier
        } else if viewControllers.count < 1 {
            let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: routeElementIdentifier + "ViewController")
            setViewControllers([vc], animated: animated)
            topRouteId = routeElementIdentifier
        }
        completionHandler()
        
        return self
    }
    
    func popRouteSegment(_ routeElementIdentifier: RouteElementIdentifier, animated: Bool, completionHandler: @escaping RoutingCompletionHandler) {
        print("NewsSearchNavigationController Routable pop \(routeElementIdentifier)")
        
        if (routeElementIdentifier != NewsSearchViewController.identifier  && viewControllers.count > 1) {
            popViewController(animated: animated)
        }
        
        completionHandler()
    }
    
    // MARK: UINavigationControllerDelegate
    
    private var previousViewControllers: [UIViewController]?
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("NewsSearchNavigationController didShow VC")
            
        // detect Go Back action here:
        if let previousViewControllers = previousViewControllers {
            if previousViewControllers.count == viewControllers.count + 1 {
                didPopViewController(previousViewControllers.last!)
            }
        }
        previousViewControllers = viewControllers
    }
}
