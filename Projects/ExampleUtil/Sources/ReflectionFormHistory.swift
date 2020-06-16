//
//  ReflectionFormHistory.swift
//  ForeverExample
//
//  Created by sam on 15.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import Presentation
import UIKit
import hCore
import Form

public struct ReflectionFormHistory<T: Codable> {
    let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    func storeItems(_ values: [ReflectionFormHistoryRow<T>]) {
        UserDefaults.standard.set(try? JSONEncoder().encode(values), forKey: self.title)
    }
    
    func getItems() -> [ReflectionFormHistoryRow<T>] {
       guard let prevValueJSON = UserDefaults.standard.value(forKey: self.title) as? Data, let decodedValue = try? JSONDecoder().decode([ReflectionFormHistoryRow<T>].self, from: prevValueJSON) else {
        return []
       }
        
        return decodedValue
    }
    
    func updateItem(_ value: ReflectionFormHistoryRow<T>) {
        var items = getItems()
        
        guard let index = items.firstIndex(of: value) else {
            return
        }
        
        items.remove(at: index)
        items.insert(value, at: index)
        
        storeItems(items)
    }
    
    func removeItem(_ value: ReflectionFormHistoryRow<T>) {
        var items = getItems()
        
        guard let index = items.firstIndex(of: value) else {
            return
        }
        
        items.remove(at: index)

        storeItems(items)
    }
    
    func appendItem(_ value: T) {
        var items = getItems()
        items.append(ReflectionFormHistoryRow<T>.init(name: nil, creation: Date(), value: value))
        storeItems(items)
    }
}

struct ReflectionFormHistoryRow<T: Codable>: Reusable, Hashable, Codable {
    static func == (lhs: ReflectionFormHistoryRow<T>, rhs: ReflectionFormHistoryRow<T>) -> Bool {
        lhs.creation == rhs.creation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(creation)
        hasher.combine(name)
    }
    
    var name: String?
    let creation: Date
    var value: T
    
    static func makeAndConfigure() -> (make: RowView, configure: (ReflectionFormHistoryRow) -> Disposable) {
        let row = RowView(title: "")
        
        return (row, { `self` in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            row.title = self.name ?? dateFormatter.string(from: self.creation)
            return NilDisposer()
        })
    }
}

extension ReflectionFormHistory: Presentable {
    public func materialize() -> (UIViewController, Signal<T>) {
        let viewController = UIViewController()
        viewController.title = "History"
        let bag = DisposeBag()
        
        let addItem = UIBarButtonItem(system: .add)
        viewController.navigationItem.rightBarButtonItem = addItem
        
        let tableKit = TableKit<EmptySection, ReflectionFormHistoryRow<T>>(holdIn: bag)
        
        bag += viewController.install(tableKit)
        
        func fetch() {
            tableKit.set(Table(rows: getItems()))
        }
        
        fetch()
        
        bag += tableKit.delegate.installAction(title: "Delete", style: .destructive, backgroundColor: nil, isVisibleAt: { index -> Bool in
            true
        }).onValue { index in
            let item = tableKit.table[index]
            self.removeItem(item)
            fetch()
        }
        
        bag += tableKit.delegate.installAction(title: "Rename", style: .normal, backgroundColor: nil, isVisibleAt: { index -> Bool in
            true
        }).onValue({ index in
            var item = tableKit.table[index]

            viewController.present(Alert<Void>(
                title: "Name",
                message: "",
                tintColor: nil,
                fields: [.init(initial: item.name ?? "", style: .default)],
                actions: [.init(title: "Change", action: { values in
                item.name = values.first
                
                self.updateItem(item)
                
                fetch()
                return ()
            })]))
        })
        
        bag += tableKit.delegate.installAction(title: "Edit", style: .normal, backgroundColor: nil, isVisibleAt: { index -> Bool in
            true
        }).onValue { index in
            var item = tableKit.table[index]
            
            viewController.present(
                ReflectionForm<T>(editInstance: item.value, title: self.title),
                style: .modal,
                options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            ).onValue { value in
                item.value = value
                self.updateItem(item)
                fetch()
            }
        }
        
        return (viewController, Signal<T> { callback in
            bag += addItem.onValue {
                viewController.present(
                    ReflectionForm<T>(editInstance: nil, title: self.title),
                    style: .modal,
                    options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
                ).onValue { value in
                    fetch()
                    callback(value)
                }
            }
            
            bag += tableKit.delegate.didSelectRow.onValue { row in
                callback(row.value)
            }
            
            return bag
        })
    }
}
