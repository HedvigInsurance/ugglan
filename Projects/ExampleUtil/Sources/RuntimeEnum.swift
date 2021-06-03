import Foundation

public protocol RuntimeEnum { static func fromName(_ name: String) -> Self }
