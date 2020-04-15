//
//  Either+Make.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-02.
//

import Flow
import Foundation

typealias ThreeEither<A, B, C> = Either<A, Either<B, C>>
typealias FourEither<A, B, C, D> = Either<Either<A, B>, Either<C, D>>

extension Either {
    static func make(_ value: Left) -> Self {
        return .left(value)
    }

    static func make(_ value: Right) -> Self {
        return .right(value)
    }

    static func make<A, B>(_ value: A) -> Self where Left == Either<A, B> {
        return .make(.make(value))
    }

    static func make<A, B>(_ value: B) -> Self where Left == Either<A, B> {
        return .make(.make(value))
    }

    static func make<A, B>(_ value: A) -> Self where Right == Either<A, B> {
        return .make(.make(value))
    }

    static func make<A, B>(_ value: B) -> Self where Right == Either<A, B> {
        return .make(.make(value))
    }
}
