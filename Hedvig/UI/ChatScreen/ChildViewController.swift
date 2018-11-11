//
//  ChildViewController.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Tempura

struct ChildViewModel: ViewModelWithState {
    var numberOfTodosContent: String
    init?(state: AppState) {
        self.numberOfTodosContent = "There are \(state.items.count) items pending"
    }
}

class ChildView: UIView, ViewControllerModellableView {
    var label = UILabel()
    
    func setup() {
        self.addSubview(self.label)
    }
    
    func style() {
        self.backgroundColor = UIColor(red: 78.0 / 255.0, green: 205.0 / 255.0, blue: 196.0 / 255.0, alpha: 1.0)
        self.label.textColor = .black
        self.label.font = UIFont.systemFont(ofSize: 20)
        self.label.textAlignment = .center
    }
    
    func update(oldModel: ChildViewModel?) {
        self.label.text = self.model?.numberOfTodosContent ?? ""
    }
    
    override func layoutSubviews() {
        self.label.sizeToFit()
        self.label.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
}

class ChildViewController: ViewController<ChildView> {
    
}
