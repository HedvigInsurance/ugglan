//
//  hSection.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-08-02.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

@resultBuilder
public struct RowViewBuilder {
    public static func buildBlock<V: View>(_ view: V) -> some View {
        return view
    }
    
    public static func buildOptional<V: View>(_ view: V?) -> some View {
        TupleView(view)
    }
    
    public static func buildBlock<A: View, B: View>(
        _ viewA: A,
        _ viewB: B
    ) -> some View {
        return TupleView((viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .bottom)))
    }
}

struct hSectionContainer<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder _ builder: @escaping () -> Content) {
        self.content = builder()
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                content
            }
            .background(Color(UIColor(base: .brand(.secondaryBackground()), elevated: .brand(.primaryBackground()))))
            .cornerRadius(.defaultCornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }.padding(14)
    }
}

public struct hSection<Content: View>: View {
    var content: Content
    
    public init(@RowViewBuilder _ builder: @escaping () -> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        hSectionContainer {
            content
        }
    }
}

public struct hSectionList<Content: View, Element>: View {
    struct IdentifiableContent: Identifiable {
        var id: Int
        var position: hRowPosition
        var content: Content
    }
    
    var content: [IdentifiableContent]
    
    public init(_ list: [Element], @ViewBuilder _ builder: @escaping (_ element: Element) -> Content) where Element: Identifiable {
        let count = list.count
        let unique = count == 1
        let lastOffset = count - 1
        
        self.content = list.enumerated().map { offset, element in
            var position: hRowPosition {
                if unique {
                    return .unique
                }
                
                switch offset {
                case lastOffset:
                    return .bottom
                case 0:
                    return .top
                default:
                    return .middle
                }
            }
            
            return IdentifiableContent(id: element.id.hashValue, position: position, content: builder(element))
        }
    }
    
    public init<Hash: Hashable>(_ list: [Element], id: KeyPath<Element, Hash>, @RowViewBuilder _ builder: @escaping (_ element: Element) -> Content) {
        let count = list.count
        let unique = count == 1
        let lastOffset = count - 1
        
        self.content = list.enumerated().map { offset, element in
            var position: hRowPosition {
                if unique {
                    return .unique
                }
                
                switch offset {
                case lastOffset:
                    return .bottom
                case 0:
                    return .top
                default:
                    return .middle
                }
            }
            
            return IdentifiableContent(id: element[keyPath: id].hashValue, position: position, content: builder(element))
        }
    }
    
    public var body: some View {
        hSectionContainer {
            ForEach(content) { element in
                VStack(spacing: 0) {
                    element.content
                }.environment(\.hRowPosition, element.position)
            }
        }
    }
}
