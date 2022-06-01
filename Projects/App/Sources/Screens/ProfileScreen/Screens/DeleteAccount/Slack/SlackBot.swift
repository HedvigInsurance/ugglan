import Foundation
import hGraphQL

class SlackBot {
    
    enum SlackError: Error {
        case invalidRequestBody(description: String)
        case requestError(description: String)
        case invalidStatusCode
        case emptyDataReceived
        case badResponse
    }
    
    private let token: String = ""
    private let channelID: String = "C03HLK3PB7V"
    private let url: URL = URL(string: "https://slack.com/api/chat.postMessage")!
    
    func postSlackMessage(
        memberDetails: MemberDetails,
        completion: @escaping (Result<Bool, SlackError>) -> Void
    ) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let requestBody = generatePostMessageBody(memberDetails: memberDetails)
        
        do {
            request.httpBody =  try JSONEncoder().encode(requestBody)
        } catch let error {
            completion(.failure(.invalidRequestBody(description: error.localizedDescription)))
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
    
    private func generatePostMessageBody(memberDetails: MemberDetails) -> SlackMessageFormat {
        var hopeURL: String
        switch Environment.current {
        case .staging, .custom:
            hopeURL = "https://hedvig-hope-staging.herokuapp.com/members/\(memberDetails.id)"
        case .production:
            // TODO: Change URL to production URL
            hopeURL = "https://hedvig-hope-staging.herokuapp.com/members/\(memberDetails.id)"
        }
        
        let text = ":rotating_light:*A new request from <\(hopeURL)|\(memberDetails.displayName)> to have their account deleted*\nContact details:\n:e-mail: \(memberDetails.email ?? "N/A")\n:phone: \(memberDetails.phone ?? "N/A")"
        
        let block = SlackMessageFormat.Block(
            type: "section",
            text: SlackMessageFormat.Block.Text(
                type: "mrkdwn",
                text: text
            )
        )
        
        return SlackMessageFormat(channel: self.channelID, blocks: [block])
    }
}

struct SlackMessageFormat: Codable {
    var channel: String
    var blocks: [Self.Block]
    
    struct Block: Codable {
        var type: String
        var text: Self.Text
        
        struct Text: Codable {
            var type: String
            var text: String
        }
    }
}
