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

struct AppState: StateType {
    let topHeadlinesState: TopHeadlinesState
    let newsSearchState: NewsSearchState
    let multiNavigationState: MultiNavigationState
}

// MARK: App State Reducer

fileprivate func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(
        topHeadlinesState: topHeadlinesReducer(action, state: state?.topHeadlinesState),
        newsSearchState: newsSearchReducer(action, state: state?.newsSearchState),
        multiNavigationState: multiNavigationReducer(action, state: state?.multiNavigationState)
    )
}

// MARK: Global App Store

let mainStore = Store<AppState>(
    reducer: appReducer,
    state: nil,
    middleware: [createThunkMiddleware()]
)

var router: Router<AppState>!

class AppStateCommon {
    static func setUpRouting(_ vc: Routable) {
        router = Router<AppState>(store: mainStore, rootRoutable: vc) { state in
            state.select { $0.multiNavigationState.currentState }
        }
        mainStore.dispatch(NavigationActions.executeSetupNavigation())
    }
}
