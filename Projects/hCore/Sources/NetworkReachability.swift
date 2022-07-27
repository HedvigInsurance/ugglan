import Foundation
import Reachability
import Flow

/**
 Wrapper class around Reachability
 */
public class NetworkReachability: NSObject {
    public static let sharedInstance = NetworkReachability()
    private var reachability : Reachability!
    
    public var whenReachable: ((Reachability) -> Void)?
    public var whenUnreachable: ((Reachability) -> Void)?
    
    public var reachableSignal: ReadSignal<Bool>?
    
    public func observeReachability() {
        self.reachability = try! Reachability()
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(self.reachabilityChanged),
            name: NSNotification.Name.reachabilityChanged,
            object: self.reachability
        )
        
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular, .wifi:
            if let callback = whenReachable {
                callback(reachability)
            }
            reachableSignal = ReadSignal<Bool>(true)
        case .none, .unavailable:
            if let callback = whenUnreachable {
                callback(reachability)
            }
            reachableSignal = ReadSignal<Bool>(false)
        }
    }
}
