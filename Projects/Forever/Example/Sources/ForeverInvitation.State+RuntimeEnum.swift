import ExampleUtil
import Forever
import Foundation

extension ForeverInvitation.State: RuntimeEnum {
  public static func fromName(_ name: String) -> ForeverInvitation.State {
    switch name {
    case "active": return .active
    case "terminated": return .terminated
    case "pending": return .pending
    default: fatalError("Unhandled case in ForeverInvitation.State")
    }
  }
}
