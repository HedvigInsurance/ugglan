import Foundation

public func takeRight<T>(lhs _: T, rhs: T) -> T { rhs }

public func takeLeft<T>(lhs: T, rhs _: T) -> T { lhs }
