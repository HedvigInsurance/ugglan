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
    func deepFind(_ path: String) -> String {
        let splittedPath = path.split(separator: ".")

        _ = splittedPath.reduce(self) { resultMap, subPath in
            resultMap[String(subPath)] as? [String: Any?] ?? [:]
        }

        return ""
    }
}

struct RAWGraphQLData: GraphQLSelectionSet {
    static var selections: [GraphQLSelection] = []
    var resultMap: ResultMap

    func insertInto(store: EmbarkStore, basedOn query: ApiFragment.AsEmbarkApiGraphQlQuery) {
        query.data.queryResults.forEach { queryResult in
            let value = resultMap.deepFind(queryResult.key)
            store.setValue(key: queryResult.as, value: value)
        }
    }

    func insertInto(store: EmbarkStore, basedOn mutation: ApiFragment.AsEmbarkApiGraphQlMutation) {
        mutation.data.mutationResults.compactMap { $0 }.forEach { mutationResult in
            let value = resultMap.deepFind(mutationResult.key)
            store.setValue(key: mutationResult.as, value: value)
        }
    }

    init(unsafeResultMap: ResultMap) {
        resultMap = unsafeResultMap
    }
}

class RAWGraphqlQuery: GraphQLQuery {
    var operationDefinition: String
    var operationName: String

    typealias Data = RAWGraphQLData

    var variables: GraphQLMap

    init(_ query: String, variables: GraphQLMap) {
        self.variables = variables
        operationDefinition = query
        operationName = "EmbarkAPI"
    }
}

class RAWGraphqlMutation: GraphQLMutation {
    var operationDefinition: String
    var operationName: String

    typealias Data = RAWGraphQLData

    var variables: GraphQLMap

    init(_ query: String, variables: GraphQLMap) {
        self.variables = variables
        operationDefinition = query
        operationName = "EmbarkAPI"
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

extension EmbarkState {
    func handleApi(apiFragment: ApiFragment) -> Future<EmbarkLinkFragment?> {
        self.handleApiRequest(apiFragment: apiFragment).map { result in
            if let queryApi = apiFragment.asEmbarkApiGraphQlQuery {
                if result != nil {
                    return queryApi.data.next?.fragments.embarkLinkFragment
                }
            } else if let mutationApi = apiFragment.asEmbarkApiGraphQlMutation {
                if result != nil {
                    return mutationApi.data.next?.fragments.embarkLinkFragment
                } else {
                    return mutationApi.data.
                }
            }
        }
    }
    
    private func handleApiRequest(apiFragment: ApiFragment) -> Future<RAWGraphQLData?> {
        if let queryApi = apiFragment.asEmbarkApiGraphQlQuery {
            return self.client.fetch(
                query: RAWGraphqlQuery(
                    queryApi.data.query,
                    variables: queryApi.data.graphQLVariables(store: self.store)
                )
            ).map { result in
                result.data
            }.onValue { result in
                guard let result = result else {
                    return
                }

                result.insertInto(store: self.store, basedOn: queryApi)
            }
        } else if let mutationApi = apiFragment.asEmbarkApiGraphQlMutation {
            return self.client.perform(
                mutation: RAWGraphqlMutation(
                    mutationApi.data.mutation,
                    variables: mutationApi.data.graphQLVariables(store: self.store)
                )
            ).map { result in
                result.data
            }.onValue { result in
                guard let result = result else {
                    return
                }

                result.insertInto(store: self.store, basedOn: mutationApi)
            }
        }
        
        return Future(immediate: { nil })
    }
    
    var apiResponseSignal: ReadSignal<RAWGraphQLData?> {
        currentPassageSignal.compactMap { $0 }.mapLatestToFuture { passage -> Future<RAWGraphQLData?> in
            guard let apiFragment = passage.api?.fragments.apiFragment else {
                return Future(immediate: { nil })
            }
            
            return self.handleApiRequest(apiFragment: apiFragment)
        }.providedSignal.plain().readable(initial: nil)
    }
}
