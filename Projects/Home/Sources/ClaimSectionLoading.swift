import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL
import Presentation
import Foundation
import Flow

struct ClaimSectionLoading: View {
    
    @State
    var shouldPoll = false
    
    @ViewBuilder
    func claimsSection(_ claims: [Claim]) -> some View {
        if claims.isEmpty {
            EmptyView()
        } else {
            ClaimSection(claims: claims)
        }
    }
    
    var body: some View {
        Poller(HomeStore.self,
               getter: { $0.claims ?? [] },
               fetchAction: .fetchClaims,
               shouldPoll: $shouldPoll)
        { claims in
           claimsSection(claims)
        }
    }
}

struct Poller<S: Store, Value: Equatable, Content: View>: View {
    typealias Getter = (_ state: S.State) -> Value

    let pollTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    @State
    var value: Value
    
    @Binding
    var shouldPoll: Bool
    
    var getter: Getter
    var fetchAction: S.Action
    
    var store: S

    var content: (_ value: Value) -> Content

    public init(
        _ storeType: S.Type,
        getter: @escaping Getter,
        fetchAction: S.Action,
        shouldPoll: Binding<Bool>,
        @ViewBuilder _ content: @escaping (_ value: Value) -> Content
    ) {
        self.getter = getter
        self.fetchAction = fetchAction
        self.content = content

        let store: S = globalPresentableStoreContainer.get()
        self.store = store
        
        self._shouldPoll = shouldPoll
        
        self._value = State(initialValue: getter(store.stateSignal.value))
    }
    
    private var claimsDidChange: ReadSignalPublisher<S.State> {
        store.stateSignal.distinct { lhs, rhs in
            self.getter(lhs) == self.getter(rhs)
        }.publisher
    }
    
    public var body: some View {
        content(
            value
        ).onReceive(pollTimer) { _ in
            store.send(fetchAction)
        }.onReceive(claimsDidChange) { _ in
            pollTimer.upstream.connect().cancel()
            self.value = getter(store.stateSignal.value)
        }
    }
}
