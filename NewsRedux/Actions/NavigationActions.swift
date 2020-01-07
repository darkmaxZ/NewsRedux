//
//  NavigationActions.swift
//  NewsRedux
//
//  Created by Ziurin, Maksim on 2019/12/26.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import ReSwiftThunk

struct SwitchRouteStackAction: Action {
    let routeStackName: String
    let route: Route
}

func multiNavigationReducer(_ action: Action, state: MultiNavigationState?) -> MultiNavigationState {
    var value: MultiNavigationState = state ?? MultiNavigationState(routeMap: [:], currentState: NavigationState())
    switch action {
    case let results as SwitchRouteStackAction:
        if let routeStack = value.routeMap[results.routeStackName] {
           value.currentState.route = routeStack
        } else {
            value.routeMap[results.routeStackName] = results.route
            value.currentState.route = results.route
        }
        value.currentState = NavigationReducer.handleAction(SetRouteAction(results.route), state: state?.currentState)
    case is SetRouteAction:
        value.currentState = NavigationReducer.handleAction(action, state: state?.currentState)
    case is SetRouteSpecificData:
        value.currentState = NavigationReducer.handleAction(action, state: state?.currentState)
    default:
        break
    }
    return value
}

class NavigationActions {
    static func executeSetupNavigation() -> Thunk<AppState> {
        return Thunk<AppState> { dispatch, getState in
            if getState()?.multiNavigationState.currentState.route == [] {
                dispatch(SetRouteAction([MainTabBarController.identifier, TopHeadlinesNavigationController.identifier, TopHeadlinesViewController.identifier]))
            }
        }
    }
}
