import Flow
import Foundation

public typealias ThreeEither<A, B, C> = Either<A, Either<B, C>>
public typealias FourEither<A, B, C, D> = Either<Either<A, B>, Either<C, D>>

extension Either {
    public static func make(_ value: Left) -> Self { .left(value) }

    public static func make(_ value: Right) -> Self { .right(value) }

    public static func make<A, B>(_ value: A) -> Self where Left == Either<A, B> { .make(.make(value)) }

    public static func make<A, B>(_ value: B) -> Self where Left == Either<A, B> { .make(.make(value)) }

    public static func make<A, B>(_ value: A) -> Self where Right == Either<A, B> { .make(.make(value)) }

    public static func make<A, B>(_ value: B) -> Self where Right == Either<A, B> { .make(.make(value)) }
}
