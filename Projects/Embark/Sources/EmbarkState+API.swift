//
//  EmbarkState+API.swift
//  Embark
//
//  Created by sam on 25.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation

extension ResultMap {
    func deepFind(_ path: String) -> String? {
        let splittedPath = path.split(separator: ".")
                
        if splittedPath.count > 1 {
            if let firstPath = splittedPath.first, let range = Range.init(NSRange(location: firstPath.startIndex.utf16Offset(in: path), length: firstPath.endIndex.utf16Offset(in: path)), in: path) {
                let resultMap = self[String(firstPath)] as? ResultMap
                return resultMap?.deepFind(String(path.replacingCharacters(in: range, with: "").dropFirst()))
            }
            
            return nil
        }

        return self[path] as? String
    }
}

extension ApiSingleVariableFragment {
    func graphQLMap(store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        switch self.as {
        case .int:
            map[key] = Int(store.getValue(key: from) ?? "")
        case .string:
            map[key] = store.getValue(key: from)
        case .boolean:
            map[key] = store.getValue(key: from) == "true"
        case .__unknown:
            break
        }

        return map
    }
}

extension ApiGeneratedVariableFragment {
    func graphQLMap(store _: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        switch type {
        case .uuid:
            map[key] = UUID().uuidString
        case .__unknown:
            break
        }

        return map
    }
}

extension ApiMultiActionVariableFragment {
    func graphQLMap(store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        variables.forEach { variable in
            if let apiSingleVariableFragment = variable.fragments.apiSingleVariableFragment {
                map = map.merging(
                    apiSingleVariableFragment.graphQLMap(store: store),
                    uniquingKeysWith: { lhs, _ in lhs }
                )
            } else if let apiGeneratedVariableFragment = variable.fragments.apiGeneratedVariableFragment {
                map = map.merging(
                    apiGeneratedVariableFragment.graphQLMap(store: store),
                    uniquingKeysWith: { lhs, _ in lhs }
                )
            } else if let multiActionVariable = variable.asEmbarkApiGraphQlMultiActionVariable {
                if let apiSingleVariableFragment = multiActionVariable.fragments.apiSingleVariableFragment {
                    map = map.merging(
                        apiSingleVariableFragment.graphQLMap(store: store),
                        uniquingKeysWith: { lhs, _ in lhs }
                    )
                } else if let apiGeneratedVariableFragment =
                    multiActionVariable.fragments.apiGeneratedVariableFragment {
                    map = map.merging(
                        apiGeneratedVariableFragment.graphQLMap(store: store),
                        uniquingKeysWith: { lhs, _ in lhs }
                    )
                }
            }
        }

        return map
    }
}

extension ApiVariablesFragment {
    func graphQLMap(store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        if let apiSingleVariableFragment = fragments.apiSingleVariableFragment {
            map = map.merging(
                apiSingleVariableFragment.graphQLMap(store: store),
                uniquingKeysWith: { lhs, _ in lhs }
            )
        } else if let apiGeneratedVariableFragment = fragments.apiGeneratedVariableFragment {
            map = map.merging(
                apiGeneratedVariableFragment.graphQLMap(store: store),
                uniquingKeysWith: { lhs, _ in lhs }
            )
        } else if let apiMultiActionVariableFragment = fragments.apiMultiActionVariableFragment {
            map = map.merging(
                apiMultiActionVariableFragment.graphQLMap(store: store),
                uniquingKeysWith: { lhs, _ in lhs }
            )
        }

        return map
    }
}

extension ApiFragment.AsEmbarkApiGraphQlQuery.Datum {
    func graphQLVariables(store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        variables.forEach { variable in
            map = map.merging(
                variable.fragments.apiVariablesFragment.graphQLMap(store: store),
                uniquingKeysWith: { lhs, _ in lhs }
            )
        }

        return map
    }
}

extension ApiFragment.AsEmbarkApiGraphQlMutation.Datum {
    func graphQLVariables(store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        variables.forEach { variable in
            map = map.merging(
                variable.fragments.apiVariablesFragment.graphQLMap(store: store),
                uniquingKeysWith: { lhs, _ in lhs }
            )
        }

        return map
    }
}

extension ResultMap {
    func insertInto(store: EmbarkStore, basedOn query: ApiFragment.AsEmbarkApiGraphQlQuery) {
        query.data.queryResults.forEach { queryResult in
            let value = deepFind(queryResult.key)
            store.setValue(key: queryResult.as, value: value)
        }
    }

    func insertInto(store: EmbarkStore, basedOn mutation: ApiFragment.AsEmbarkApiGraphQlMutation) {
        mutation.data.mutationResults.compactMap { $0 }.forEach { mutationResult in
            let value = deepFind(mutationResult.key)
            store.setValue(key: mutationResult.as, value: value)
        }
    }
}

extension EmbarkState {    
    func handleApi(apiFragment: ApiFragment) -> Future<EmbarkLinkFragment?> {
        self.handleApiRequest(apiFragment: apiFragment).mapResult { result in
            switch result {
            case .success:
                if let queryApi = apiFragment.asEmbarkApiGraphQlQuery {
                    return queryApi.data.next?.fragments.embarkLinkFragment
                } else if let mutationApi = apiFragment.asEmbarkApiGraphQlMutation {
                    return mutationApi.data.next?.fragments.embarkLinkFragment
                }
            case let .failure(error):
                if let queryApi = apiFragment.asEmbarkApiGraphQlQuery {
                    return queryApi.data.queryErrors.first { queryError -> Bool in
                        guard let contains = queryError.contains else {
                            return false
                        }
                        return error.localizedDescription.contains(contains)
                    }?.next.fragments.embarkLinkFragment
                } else if let mutationApi = apiFragment.asEmbarkApiGraphQlMutation {
                    return mutationApi.data.mutationErrors.first { mutationError -> Bool in
                        guard let contains = mutationError.contains else {
                            return false
                        }
                        return error.localizedDescription.contains(contains)
                    }?.next.fragments.embarkLinkFragment
                }
            }
            
            return nil
        }
    }
    
    private func handleApiRequest(apiFragment: ApiFragment) -> Future<ResultMap?> {
        func performHTTPCall(_ query: String, variables: ResultMap) -> Future<ResultMap?> {
            var urlRequest = URLRequest(url: URL(string: "https://graphql.dev.hedvigit.com/graphql")!)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: ["query": query, "variables": variables], options: [])
                        
            return Future { completion in
                self.urlSessionClient.sendRequest(urlRequest) { result in
                    switch result {
                    case .failure(_):
                        break
                    case let .success((data, response)):
                        if response.statusCode == 200 {
                            if let result = try? JSONSerialization.jsonObject(with: data, options: []) as? ResultMap {
                                if let errors = result["errors"] as? [ResultMap] {
                                    if let error = errors.first, let message = error["message"] as? String {
                                        completion(.failure(ApiError.failed(reason: message)))
                                    } else {
                                        completion(.failure(ApiError.unknown))
                                    }
                                } else if let data = result["data"] as? ResultMap {
                                    completion(.success(data))
                                } else {
                                    completion(.failure(ApiError.unknown))
                                }
                            } else {
                                completion(.failure(ApiError.unknown))
                            }
                        } else {
                            completion(.failure(ApiError.failed(reason: String(data: data, encoding: .utf8)!)))
                        }
                    }
                }
                
                return NilDisposer()
            }
        }
        
        if let queryApi = apiFragment.asEmbarkApiGraphQlQuery {
            return performHTTPCall(queryApi.data.query, variables: queryApi.data.graphQLVariables(store: self.store)).onValue { resultMap in
                guard let resultMap = resultMap else {
                    return
                }
                
                resultMap.insertInto(store: self.store, basedOn: queryApi)
            }
        } else if let mutationApi = apiFragment.asEmbarkApiGraphQlMutation {
            return performHTTPCall(mutationApi.data.mutation, variables: mutationApi.data.graphQLVariables(store: self.store)).onValue { resultMap in
                guard let resultMap = resultMap else {
                    return
                }
                
                resultMap.insertInto(store: self.store, basedOn: mutationApi)
            }
        }
        
        return Future(immediate: { nil })
    }
    
    enum ApiError: Error {
        case noApi, failed(reason: String), unknown
        
        var localizedDescription: String {
            switch self {
            case .noApi:
                return "No API for this passage"
            case let .failed(reason):
                return "Failed with \(reason)"
            case .unknown:
                return "Unknown"
            }
        }
    }
    
    var apiResponseSignal: ReadSignal<ResultMap?> {
        currentPassageSignal.compactMap { $0 }.mapLatestToFuture { passage -> Future<ResultMap?> in
            guard let apiFragment = passage.api?.fragments.apiFragment else {
                return Future(error: ApiError.noApi)
            }
            
            return self.handleApiRequest(apiFragment: apiFragment)
        }.providedSignal.plain().readable(initial: nil)
    }
}
