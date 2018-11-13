//
//  AppActions.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-13.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Katana

protocol AppAction: Action {
    func updatedState(currentState: inout AppState)
}

extension AppAction {
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? AppState else {
            fatalError()
        }
        updatedState(currentState: &state)
        return state
    }
}

extension AppAction {
    func updatedState(currentState _: inout AppState) {}
}
