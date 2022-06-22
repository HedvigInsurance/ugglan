#!/usr/bin/env swift

import Foundation
import FoundationNetworking

struct RunnerReponse: Codable {
    let runners: [Runner]

    struct Runner: Codable {
      let name: String
      let status: String
    }
}

let dispatchGroup = DispatchGroup()

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    dispatchGroup.enter()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    dispatchGroup.leave()
    
    return output
}

func handleServerStatus(_ response: RunnerReponse) {
  response.runners.forEach { runner in
    if (runner.status == "online") {
      guard let runnerPassword = ProcessInfo.processInfo.environment["RUNNER_\(runner.name)_PASSWORD"] else {
        return
      }
      guard let runnerIP = ProcessInfo.processInfo.environment["RUNNER_\(runner.name)_IP"] else {
        return
      }

      let isUp = shell("nc -z \(runnerIP) 22").contains("succeeded")

      if isUp {
        let _ = shell("echo \(runnerPassword) | ssh -tt administrator@\(runnerIP) sudo shutdown -r now")
        print("Restarted \(runner.name)")
      } else {
        print("Didn't restart \(runner.name) as SSH wasn't online")
      }
    }
  }

  dispatchGroup.leave()
}

func getServerStatus() {
    var request = URLRequest(url: URL(string: "https://api.github.com/repos/HedvigInsurance/Ugglan/actions/runners")!)
    request.allHTTPHeaderFields = [
      "Authorization": "token \(ProcessInfo.processInfo.environment["RUNNER_GITHUB_TOKEN"]!)",
      "Accept": "application/vnd.github.v3+json"
    ]
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else { exit(1) }
        guard let response = try? JSONDecoder().decode(RunnerReponse.self, from: data) else { exit(1) }

        handleServerStatus(response)
    }
    task.resume()
}

dispatchGroup.enter()
getServerStatus()
dispatchGroup.wait()