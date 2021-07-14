//
//  JourneyPresentation.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-07-14.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Flow
import UIKit

extension Presentation {
    public func withDismissButton<FutureValue>() -> some JourneyPresentation where P.Matter: UIViewController, P.Result: Future<FutureValue> {
        withDismissButton { _ in
            ContinueJourney()
        }
    }
    
    public func withDismissButton<FutureValue, InnerJourneyPresentation: JourneyPresentation>(
        @JourneyBuilder _ nextJourney: @escaping (_ value: FutureValue) -> InnerJourneyPresentation
    ) -> some JourneyPresentation where P.Matter: UIViewController, P.Result: Future<FutureValue> {
        let closeButton = CloseButton()
        let closeButtonItem = UIBarButtonItem(viewable: closeButton)
        
        return addConfiguration { viewController, bag in
            // move over any barButtonItems to the other side
            if viewController.navigationItem.rightBarButtonItems != nil {
                viewController.navigationItem.leftBarButtonItems =
                    viewController.navigationItem.rightBarButtonItems
            }

            viewController.navigationItem.rightBarButtonItem = closeButtonItem
        }.map { result in
            FiniteSignal<(FutureValue?, Void?)> { callback in
                let bag = DisposeBag()
                
                bag += closeButton.onTapSignal.onValue { _ in
                    callback(.value((nil, ())))
                }
                
                bag += result.onResult { result in
                    switch result {
                    case let .success(value):
                        callback(.value((value, nil)))
                    case let .failure(error):
                        callback(.end(error))
                    }
                }
                
                return bag
            }
        }.journey { value in
            if value.1 != nil {
                DismissJourney()
            } else {
                nextJourney(value.0!)
            }
        }
    }
    
    public func withDismissButton<SignalValue>() -> some JourneyPresentation where P.Matter: UIViewController, P.Result: FiniteSignal<SignalValue> {
        withDismissButton { _ in
            ContinueJourney()
        }
    }
    
    public func withDismissButton<SignalValue, InnerJourneyPresentation: JourneyPresentation>(
        @JourneyBuilder _ nextJourney: @escaping (_ value: SignalValue) -> InnerJourneyPresentation
    ) -> some JourneyPresentation where P.Matter: UIViewController, P.Result: FiniteSignal<SignalValue> {
        let closeButton = CloseButton()
        let closeButtonItem = UIBarButtonItem(viewable: closeButton)
        
        return addConfiguration { viewController, bag in
            // move over any barButtonItems to the other side
            if viewController.navigationItem.rightBarButtonItems != nil {
                viewController.navigationItem.leftBarButtonItems =
                    viewController.navigationItem.rightBarButtonItems
            }

            viewController.navigationItem.rightBarButtonItem = closeButtonItem
        }.map { result in
            FiniteSignal<(SignalValue?, Void?)> { callback in
                let bag = DisposeBag()
                
                bag += closeButton.onTapSignal.onValue { _ in
                    callback(.value((nil, ())))
                }
                
                bag += result.onEvent { event in
                    switch event {
                    case let .value(value):
                        callback(.value((value, nil)))
                    case let .end(error):
                        callback(.end(error))
                    }
                }
                
                return bag
            }
        }.journey { value in
            if value.1 != nil {
                DismissJourney()
            } else {
                nextJourney(value.0!)
            }
        }
    }
}
