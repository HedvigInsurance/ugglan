import Foundation

class SlackBot {
    
    enum SlackError: Error {
        case invalidBody(description: String)
        case requestError(description: String)
        case invalidStatusCode
        case emptyDataReceived
        case badResponse
    }
    
    private let token: String = ""
    private let channelID: String = "C03HLK3PB7V"
    private let url: URL = URL(string: "https://slack.com/api/chat.postMessage")!
    
    func postMemberDetails(
        memberID: String,
        completion: @escaping (Result<Bool, SlackError>) -> Void
    ) {
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
            completion(.failure(.invalidBody(description: error.localizedDescription)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestError(description: error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                completion(.failure(.invalidStatusCode))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(.emptyDataReceived))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(
                    with: responseData,
                    options: .mutableContainers
                ) as? [String: Any], let status = json["ok"] as? Bool {
                    completion(.success(status))
                } else {
                    completion(.failure(.badResponse))
                }
            } catch let error {
                completion(.failure(.requestError(description: error.localizedDescription)))
            }
        }
        
        task.resume()
    }
}
