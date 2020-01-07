//
//  AppStateCommon.swift
//  ReduxApp
//
//  Created by Ziurin, Maksim on 2019/12/24.
//  Copyright © 2019 Ziurin, Maksim. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import ReSwiftThunk

// MARK: Global App State Data Type

struct AppState: StateType {
    let newsState: NewsState
    let navigationState: NavigationState
}

// MARK: App State Reducer

fileprivate func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(
        newsState: newsReducer(action, state: state?.newsState),
        navigationState: NavigationReducer.handleAction(action, state: state?.navigationState)
    )
}

// MARK: Global App Store

let mainStore = Store<AppState>(
    reducer: appReducer,
    state: nil,
    middleware: [createThunkMiddleware()]
)

var router: Router<AppState>!

// MARK: AppStateCommon

class AppStateCommon {
    static func setUpRouting(_ vc: Routable) {
        // set up routing
        router = Router<AppState>(store: mainStore, rootRoutable: vc) { state in
            state.select { $0.navigationState }
        }
        
        mainStore.dispatch { state, store in
            if state.navigationState.route == [] {
                return SetRouteAction([MainTabBarController.identifier, NewsViewController.identifier])
            } else {
                return nil
            }
        }
    }
}
