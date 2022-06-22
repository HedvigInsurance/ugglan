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

func restartServer(_ runnerIP: String, _ runnerName: String) {
    var request = URLRequest(url: URL(string: "http://\(runnerIP):9000/hooks/restart?name=\(runnerName)")!)
    request.allHTTPHeaderFields = [:]
    request.httpMethod = "POST"

    dispatchGroup.enter()

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        dispatchGroup.leave()
    }
    task.resume()
}

func handleServerStatus(_ response: RunnerReponse) {
    response.runners.forEach { runner in
        if runner.status != "online" {
            guard let runnerIP = ProcessInfo.processInfo.environment["RUNNER_\(runner.name)_IP"] else {
                return
            }

            restartServer(runnerIP, runner.name)
            print("Sent restart command")
        }
    }

    dispatchGroup.leave()
}

func getServerStatus() {
    var request = URLRequest(url: URL(string: "https://api.github.com/repos/HedvigInsurance/Ugglan/actions/runners")!)
    request.allHTTPHeaderFields = [
        "Authorization": "token \(ProcessInfo.processInfo.environment["RUNNER_GITHUB_TOKEN"]!)",
        "Accept": "application/vnd.github.v3+json",
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
