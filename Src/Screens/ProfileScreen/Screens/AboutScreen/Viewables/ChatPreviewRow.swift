//
//  ChatPreviewRow.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-13.
//

import Flow
import Form
import Foundation
import Presentation

struct ChatPreviewRow {
    let remoteConfig: RemoteConfigContainer
    
    init(remoteConfig: RemoteConfigContainer = RemoteConfigContainer.shared) {
        self.remoteConfig = remoteConfig
    }
}

extension ChatPreviewRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        
        let row = RowView()
        row.append(UILabel(value: "Chat preview enabled", style: .rowTitle))
        
        let switchButton = UISwitch()
        
        bag += self.remoteConfig.chatPreviewEnabledSignal.bidirectionallyBindTo(switchButton)
        
        row.append(switchButton)
        
        return (row, bag)
    }
}
