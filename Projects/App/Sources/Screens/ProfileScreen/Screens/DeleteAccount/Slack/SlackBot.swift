import Foundation

class SlackBot {
    private let token: String = "Bearer xoxb-189699051172-3592269948246-CAYwxaD47ic6f90OcPoIGSRR"
    
    private let channelID: String = "C03HLK3PB7V"
    private let url: URL = URL(string: "https://slack.com/api/chat.postMessage")!
    
    func postMemberDetails(memberID: String) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: String] = [
            "channel": channelID,
            "text": "The member \(memberID) has requested for deleting their account"
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                print("Invalid Response received from the server")
                return
            }
            
            
            guard let responseData = data else {
                print("nil Data received from the server")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    print(jsonResponse)
                    if let status = jsonResponse["ok"] as? Bool {
                        status == true ? print("Message delivered successfully") : print("Message not delivered")
                    }
                    // handle json response
                } else {
                    print("data maybe corrupted or in wrong format")
                    throw URLError(.badServerResponse)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
}
