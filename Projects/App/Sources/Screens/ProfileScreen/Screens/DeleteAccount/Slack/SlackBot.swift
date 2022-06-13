import Foundation
import hGraphQL
import Apollo
import hCore
import Flow

class SlackBot {
    @Inject var client: ApolloClient
    
    enum SlackError: Error {
        case invalidRequestBody(description: String)
        case requestError(description: String)
        case invalidStatusCode
        case emptyDataReceived
        case badResponse
    }
    
    private let url: URL = URL(string: "https://slack.com/api/chat.postMessage")!
    
    func postSlackMessage(
        memberDetails: MemberDetails
    ) -> Future<Bool> {
        client.fetch(
            query: GraphQL.SlackDetailsQuery()
        )
        .compactMap { result in
            var request = URLRequest(url: self.url)
            
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer xoxb-" + result.slackDetails.token,
                "Content-Type": "application/json"
            ]
            
            let requestBody = self.generatePostMessageBody(memberDetails: memberDetails, channelID: result.slackDetails.channelId)
            
            do {
                request.httpBody =  try JSONEncoder().encode(requestBody)
            } catch let error {
                throw SlackError.requestError(description: error.localizedDescription)
            }
            
            return request
        }
        .flatMap {
            self.slackNetworkRequest(request: $0)
        }
    }
    
    private func slackNetworkRequest(request: URLRequest) -> Future<Bool> {
        return Future { completion in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(SlackError.requestError(description: error.localizedDescription)))
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode)
                else {
                    completion(.failure(SlackError.invalidStatusCode))
                    return
                }
                
                guard let responseData = data else {
                    completion(.failure(SlackError.emptyDataReceived))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(
                        with: responseData,
                        options: .mutableContainers
                    ) as? [String: Any], let status = json["ok"] as? Bool {
                        completion(.success(status))
                    } else {
                        completion(.failure(SlackError.badResponse))
                    }
                } catch let error {
                    completion(.failure(SlackError.requestError(description: error.localizedDescription)))
                }
            }
            
            task.resume()
            
            return Disposer { task.cancel() }
        }
    }
    
    private func generatePostMessageBody(memberDetails: MemberDetails, channelID: String) -> SlackMessageFormat {
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
            text: SlackMessageFormat.Block.Text(
                text: text
            )
        )
        
        return SlackMessageFormat(channel: channelID, blocks: [block])
    }
}

struct SlackMessageFormat: Codable {
    var channel: String
    var blocks: [Self.Block]
    
    struct Block: Codable {
        var type: String = "section"
        var text: Self.Text
        
        struct Text: Codable {
            var type: String = "mrkdwn"
            var text: String
        }
    }
}
