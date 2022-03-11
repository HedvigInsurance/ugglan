import Apollo
import Flow
import Foundation
import SwiftUI
import hCore

public typealias GraphQLMockHandlers = [AnyHashable: Any]

public protocol GraphQLMock {
    var handlers: GraphQLMockHandlers { get }
}

public protocol GraphQLMockOperation: GraphQLMock {
    associatedtype Operation: GraphQLOperation
    associatedtype Handler
    var operationType: Operation.Type { get }
    var duration: TimeInterval { get }
    var handler: Handler { get }
}

public struct QueryMock<Operation: GraphQLOperation>: GraphQLMockOperation {
    public var handlers: GraphQLMockHandlers = [:]

    public init(
        _ operationType: Operation.Type,
        duration: TimeInterval = 0.25,
        handler: @escaping (Operation) throws -> Operation.Data
    ) {
        self.operationType = operationType
        self.duration = duration
        self.handler = handler
        self.handlers[ObjectIdentifier(operationType)] = self
    }

    public var operationType: Operation.Type
    public var duration: TimeInterval
    public var handler: (Operation) throws -> Operation.Data
}

public struct MutationMock<Operation: GraphQLOperation>: GraphQLMockOperation {
    public var handlers: GraphQLMockHandlers = [:]

    public init(
        _ operationType: Operation.Type,
        duration: TimeInterval = 0.25,
        handler: @escaping (Operation) throws -> Operation.Data
    ) {
        self.operationType = operationType
        self.duration = duration
        self.handler = handler
        self.handlers[ObjectIdentifier(operationType)] = self
    }

    public var operationType: Operation.Type
    public var duration: TimeInterval
    public var handler: (Operation) throws -> Operation.Data
}

public struct SubscriptionMock<Operation: GraphQLOperation>: GraphQLMockOperation {
    public var handlers: GraphQLMockHandlers = [:]

    public init(
        _ operationType: Operation.Type,
        duration: TimeInterval = 0.25,
        handler: @escaping (Operation) throws -> CoreSignal<Plain, Operation.Data>
    ) {
        self.operationType = operationType
        self.duration = duration
        self.handler = handler
        self.handlers[ObjectIdentifier(operationType)] = self
    }

    public init(
        _ operationType: Operation.Type,
        duration: TimeInterval = 0.25,
        @TimelineBuilder<Operation.Data> timeline: @escaping (Operation) throws -> Timeline<Operation.Data>
    ) {
        self.operationType = operationType
        self.duration = duration
        self.handler = { operation in
            try timeline(operation).providedSignal
        }
        self.handlers[ObjectIdentifier(operationType)] = self
    }

    public var operationType: Operation.Type
    public var duration: TimeInterval
    public var handler: (Operation) throws -> CoreSignal<Plain, Operation.Data>
}

public struct CombinedMock<T>: GraphQLMock {
    public var handlers: GraphQLMockHandlers = [:]

    public var value: T

    public init(
        _ value: T
    ) {
        self.value = value
    }
}

extension Dictionary {
    static func + (_ lhs: [Key: Value], _ rhs: [Key: Value]) -> [Key: Value] {
        var copy = lhs
        copy.merge(rhs, uniquingKeysWith: takeLeft)
        return copy
    }
}

@resultBuilder public struct GraphQLMockBuilder {
    public static func buildBlock<M1>(_ m1: M1) -> CombinedMock<(M1)>
    where M1: GraphQLMock {
        var combinedMock = CombinedMock((m1))
        combinedMock.handlers += m1.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2>(_ m1: M1, _ m2: M2) -> CombinedMock<(M1, M2)>
    where M1: GraphQLMock, M2: GraphQLMock {
        var combinedMock = CombinedMock((m1, m2))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3>(_ m1: M1, _ m2: M2, _ m3: M3) -> CombinedMock<(M1, M2, M3)>
    where M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock {
        var combinedMock = CombinedMock((m1, m2, m3))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3, M4>(
        _ m1: M1,
        _ m2: M2,
        _ m3: M3,
        _ m4: M4
    ) -> CombinedMock<(M1, M2, M3, M4)>
    where M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock, M4: GraphQLMock {
        var combinedMock = CombinedMock((m1, m2, m3, m4))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        combinedMock.handlers += m4.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3, M4, M5>(
        _ m1: M1,
        _ m2: M2,
        _ m3: M3,
        _ m4: M4,
        _ m5: M5
    ) -> CombinedMock<(M1, M2, M3, M4, M5)>
    where M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock, M4: GraphQLMock, M5: GraphQLMock {
        var combinedMock = CombinedMock((m1, m2, m3, m4, m5))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        combinedMock.handlers += m4.handlers
        combinedMock.handlers += m5.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3, M4, M5, M6>(
        _ m1: M1,
        _ m2: M2,
        _ m3: M3,
        _ m4: M4,
        _ m5: M5,
        _ m6: M6
    ) -> CombinedMock<(M1, M2, M3, M4, M5, M6)>
    where M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock, M4: GraphQLMock, M5: GraphQLMock, M6: GraphQLMock {
        var combinedMock = CombinedMock((m1, m2, m3, m4, m5, m6))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        combinedMock.handlers += m4.handlers
        combinedMock.handlers += m5.handlers
        combinedMock.handlers += m6.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3, M4, M5, M6, M7>(
        _ m1: M1,
        _ m2: M2,
        _ m3: M3,
        _ m4: M4,
        _ m5: M5,
        _ m6: M6,
        _ m7: M7
    ) -> CombinedMock<(M1, M2, M3, M4, M5, M6, M7)>
    where
        M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock, M4: GraphQLMock, M5: GraphQLMock, M6: GraphQLMock,
        M7: GraphQLMock
    {
        var combinedMock = CombinedMock((m1, m2, m3, m4, m5, m6, m7))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        combinedMock.handlers += m4.handlers
        combinedMock.handlers += m5.handlers
        combinedMock.handlers += m6.handlers
        combinedMock.handlers += m7.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3, M4, M5, M6, M7, M8>(
        _ m1: M1,
        _ m2: M2,
        _ m3: M3,
        _ m4: M4,
        _ m5: M5,
        _ m6: M6,
        _ m7: M7,
        _ m8: M8
    ) -> CombinedMock<(M1, M2, M3, M4, M5, M6, M7, M8)>
    where
        M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock, M4: GraphQLMock, M5: GraphQLMock, M6: GraphQLMock,
        M7: GraphQLMock, M8: GraphQLMock
    {
        var combinedMock = CombinedMock((m1, m2, m3, m4, m5, m6, m7, m8))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        combinedMock.handlers += m4.handlers
        combinedMock.handlers += m5.handlers
        combinedMock.handlers += m6.handlers
        combinedMock.handlers += m7.handlers
        combinedMock.handlers += m8.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3, M4, M5, M6, M7, M8, M9>(
        _ m1: M1,
        _ m2: M2,
        _ m3: M3,
        _ m4: M4,
        _ m5: M5,
        _ m6: M6,
        _ m7: M7,
        _ m8: M8,
        _ m9: M9
    ) -> CombinedMock<(M1, M2, M3, M4, M5, M6, M7, M8, M9)>
    where
        M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock, M4: GraphQLMock, M5: GraphQLMock, M6: GraphQLMock,
        M7: GraphQLMock, M8: GraphQLMock, M9: GraphQLMock
    {
        var combinedMock = CombinedMock((m1, m2, m3, m4, m5, m6, m7, m8, m9))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        combinedMock.handlers += m4.handlers
        combinedMock.handlers += m5.handlers
        combinedMock.handlers += m6.handlers
        combinedMock.handlers += m7.handlers
        combinedMock.handlers += m8.handlers
        combinedMock.handlers += m9.handlers
        return combinedMock
    }

    public static func buildBlock<M1, M2, M3, M4, M5, M6, M7, M8, M9, M10>(
        _ m1: M1,
        _ m2: M2,
        _ m3: M3,
        _ m4: M4,
        _ m5: M5,
        _ m6: M6,
        _ m7: M7,
        _ m8: M8,
        _ m9: M9,
        _ m10: M10
    ) -> CombinedMock<(M1, M2, M3, M4, M5, M6, M7, M8, M9, M10)>
    where
        M1: GraphQLMock, M2: GraphQLMock, M3: GraphQLMock, M4: GraphQLMock, M5: GraphQLMock, M6: GraphQLMock,
        M7: GraphQLMock, M8: GraphQLMock, M9: GraphQLMock, M10: GraphQLMock
    {
        var combinedMock = CombinedMock((m1, m2, m3, m4, m5, m6, m7, m8, m9, m10))
        combinedMock.handlers += m1.handlers
        combinedMock.handlers += m2.handlers
        combinedMock.handlers += m3.handlers
        combinedMock.handlers += m4.handlers
        combinedMock.handlers += m5.handlers
        combinedMock.handlers += m6.handlers
        combinedMock.handlers += m7.handlers
        combinedMock.handlers += m8.handlers
        combinedMock.handlers += m9.handlers
        combinedMock.handlers += m10.handlers
        return combinedMock
    }
}
