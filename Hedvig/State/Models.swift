//
//  Models.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation

struct Todo: Equatable {
    let id: String
    var text: String
    var completed: Bool
    var archived: Bool
    
    init(text: String, completed: Bool = false) {
        self.id = String.random(length: 16)
        self.text = text
        self.completed = completed
        self.archived = false
    }
    
    static func == (l: Todo, r: Todo) -> Bool {
        return l.id == r.id && l.text == r.text
    }
}
