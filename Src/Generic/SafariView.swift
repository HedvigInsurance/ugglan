//
//  SafariView.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Foundation
import SafariServices
import Presentation
import Flow

struct SafariView: Presentable {
    let url: URL
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let didFinishCallbacker: Callbacker<Void>
        
        init(didFinishCallbacker: Callbacker<Void>) {
            self.didFinishCallbacker = didFinishCallbacker
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            didFinishCallbacker.callAll()
        }
    }
    
    func materialize() -> (SFSafariViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = SFSafariViewController(url: url)
        viewController.preferredPresentationStyle = .modal
        
        let didFinishCallbacker = Callbacker<Void>()
        
        let coordinator = Coordinator(didFinishCallbacker: didFinishCallbacker)
        viewController.delegate = coordinator
        bag.hold(coordinator)
        
        return (viewController, Future { completion in
            bag += didFinishCallbacker.onValue { _ in
                completion(.success)
            }
            
            return bag
        })
    }
}
