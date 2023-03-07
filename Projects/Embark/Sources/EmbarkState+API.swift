import Apollo
import Flow
import Foundation
import hGraphQL

extension ResultMap {

    private func getArrayValue(_ path: String) -> Any? {
        if let (pathWithoutIndex, index) = path.getArrayPathAndIndex() {

            let resultMap = self[pathWithoutIndex] as? [Any]

            if let intIndex = Int(index), resultMap?.indices.contains(intIndex) ?? false {
                return resultMap?[intIndex]
            }
        }

        return nil
    }

    func deepFind(_ path: String) -> Any? {
        let splittedPath = path.split(separator: ".")

        if splittedPath.count > 1 {
            if let firstPath = splittedPath.first,
                let range = Range(
                    NSRange(
                        location: firstPath.startIndex.utf16Offset(in: path),
                        length: firstPath.endIndex.utf16Offset(in: path)
                    ),
                    in: path
                )
            {
                let nextPath = String(path.replacingCharacters(in: range, with: "").dropFirst())

                if let arrayValue = getArrayValue(String(firstPath)) {
                    return (arrayValue as? ResultMap)?.deepFind(nextPath)
                }

                let resultMap = self[String(firstPath)] as? ResultMap
                return resultMap?
                    .deepFind(nextPath)
            }

            return nil
        }

        return getArrayValue(path) ?? self[path] ?? nil
    }

    func getValues(at path: String) -> Either<[String], String>? {
        guard let value = deepFind(path) else {
            return nil
        }

        if let values = value as? [String] {
            return .make(values)
        } else if let values = value as? [Int] {
            return .make(values.map { String($0) })
        } else if let values = value as? [Float] {
            return .make(values.map { String($0) })
        } else if let values = value as? [Bool] {
            return .make(values.map { String($0) })
        } else if let value = value as? String {
            return .make(value)
        } else if let value = value as? Int {
            return .make(String(value))
        } else if let value = value as? Float {
            return .make(String(value))
        } else if let value = value as? Bool {
            return .make(String(value))
        }

        return nil
    }
}

extension String {
    fileprivate func getArrayPathAndIndex() -> (String, String)? {
        let arrayRegex = "\\[[0-9]+\\]$"

        if range(of: ".*\(arrayRegex)", options: .regularExpression) != nil,
            let rangeOfIndex = range(of: arrayRegex, options: .regularExpression)
        {
            let index = String(self[rangeOfIndex].dropFirst().dropLast())

            let pathWithoutIndex = String(self.replacingCharacters(in: rangeOfIndex, with: ""))

            return (pathWithoutIndex, index)
        }

        return nil
    }

    fileprivate func isIndex() -> Bool {
        if let index = Int(self), index > -1 {
            return true
        } else {
            return false
        }
    }
}

extension GraphQLMap {

    private enum PathType {
        case normal(path: String)
        case array(index: Int, path: String)
        case last(path: String)
    }

    private func castedPath(_ path: String) -> [PathType] {
        let paths = path.components(separatedBy: ".")
        var newArray = [PathType]()
        paths.enumerated()
            .forEach { pathIndex, path in
                if let (path, index) = path.getArrayPathAndIndex(), let intValue = Int(index) {
                    newArray.append(.array(index: intValue, path: path))
                } else if pathIndex == (paths.count - 1) {
                    newArray.append(.last(path: path))
                } else {
                    newArray.append(.normal(path: path))
                }
            }
        return newArray
    }

    func lodash_set(path: String, value: JSONEncodable) -> GraphQLMap {
        var castPath = castedPath(path)
        var accumulatedMap = GraphQLMap()
        let returnMap = setMap(originalMap: self, accumulatedMap: &accumulatedMap, paths: &castPath, value: value)

        return returnMap.merging(self, uniquingKeysWith: { lhs, _ in lhs })
    }

    private func setMap(
        originalMap: GraphQLMap?,
        accumulatedMap: inout GraphQLMap,
        paths: inout [PathType],
        value: JSONEncodable
    ) -> GraphQLMap {
        let path = paths.removeFirst()

        switch path {
        case .normal(let path):
            if var hasValue = originalMap?[path] as? GraphQLMap {
                accumulatedMap[path] = setMap(
                    originalMap: hasValue,
                    accumulatedMap: &hasValue,
                    paths: &paths,
                    value: value
                )
            } else {
                var newMap = GraphQLMap()
                accumulatedMap[path] = setMap(originalMap: nil, accumulatedMap: &newMap, paths: &paths, value: value)
            }
        case .array(let index, let path):
            if var hasValue = originalMap?[path] as? [GraphQLMap] {
                if (hasValue.count - 1) >= index {
                    hasValue[index] = setMap(
                        originalMap: hasValue[index],
                        accumulatedMap: &hasValue[index],
                        paths: &paths,
                        value: value
                    )
                    accumulatedMap[path] = hasValue
                } else {
                    var newMap = GraphQLMap()
                    hasValue.append(setMap(originalMap: nil, accumulatedMap: &newMap, paths: &paths, value: value))
                    accumulatedMap[path] = hasValue
                }
            } else {
                var newValue = GraphQLMap()
                let newArray = [setMap(originalMap: nil, accumulatedMap: &newValue, paths: &paths, value: value)]
                accumulatedMap[path] = newArray
            }
        case .last(let path):
            accumulatedMap[path] = value
            return accumulatedMap
        }

        return accumulatedMap
    }

    func arrayOfKeyValues() -> [GraphQLMap] {
        let array =
            self
            .sorted(by: { $0.0 < $1.0 })
            .map { (key, value) -> GraphQLMap in
                var map = GraphQLMap()
                map[key] = value
                return map
            }
        return array
    }

    private func buildMap(_ key: String, _ value: Any?) -> ResultMap {
        var newDictionary = ResultMap()
        if let path = key.getArrayPathAndIndex(), let index = Int(path.1) {
            var array = [Any?]()
            for _ in 0...index {
                array.append(nil)
            }
            array[index] = value
            newDictionary = [path.0: array]
        } else {
            newDictionary = [key: value]
        }
        return newDictionary
    }
}

extension GraphQL.ApiSingleVariableFragment {
    func graphQLMap(currentMap: GraphQLMap, store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        switch self.as {
        case .int:
            map = currentMap.lodash_set(path: key, value: Int(store.getValue(key: from, includeQueue: true) ?? ""))
        case .string: map = currentMap.lodash_set(path: key, value: store.getValue(key: from, includeQueue: true))
        case .boolean:
            map = currentMap.lodash_set(path: key, value: (store.getValue(key: from, includeQueue: true) == "true"))
        case .file: map = currentMap.lodash_set(path: key, value: store.getValue(key: from, includeQueue: true))
        case .__unknown: break
        }

        return map
    }
}

extension GraphQL.ApiGeneratedVariableFragment {
    func graphQLMap(currentMap: GraphQLMap, store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        switch type {

        case .uuid:
            let uuid = UUID().uuidString
            map = currentMap.lodash_set(path: key, value: uuid)
            store.setValue(key: storeAs, value: uuid)
        case .__unknown: break
        }

        return map
    }
}

extension GraphQL.ApiMultiActionVariableFragment {
    func graphQLMapArray(store: EmbarkStore) -> [ResultMap] {
        var items: [ResultMap] = []

        func appendOrMerge(map: ResultMap, offset: Int) {
            if items.indices.contains(offset) {
                items[offset] = items[offset]
                    .merging(
                        map,
                        uniquingKeysWith: { lhs, _ in lhs }
                    )
            } else {
                items.insert(map, at: offset)
            }
        }

        let multiActionItems = store.getMultiActionItems(actionKey: from)
        let groupedMultiActionItems = Dictionary(grouping: multiActionItems, by: { $0.index }).values

        variables.forEach { variable in
            if let apiSingleVariableFragment = variable.fragments.apiSingleVariableFragment {
                groupedMultiActionItems.enumerated()
                    .forEach { offset, _ in
                        var nestedApiSingleVariableFragment = GraphQL.ApiSingleVariableFragment(
                            unsafeResultMap: apiSingleVariableFragment.resultMap
                        )
                        nestedApiSingleVariableFragment.from =
                            "\(from)[\(offset)]\(apiSingleVariableFragment.key)"
                        appendOrMerge(
                            map: nestedApiSingleVariableFragment.graphQLMap(currentMap: GraphQLMap(), store: store),
                            offset: offset
                        )
                    }
            } else if let apiConstantVariableFragment = variable.fragments.apiConstantVariableFragment {
                groupedMultiActionItems.enumerated()
                    .forEach { offset, _ in
                        var nestedApiSingleVariableFragment = GraphQL.ApiSingleVariableFragment(
                            unsafeResultMap: apiConstantVariableFragment.resultMap
                        )
                        nestedApiSingleVariableFragment.from =
                            "\(from)[\(offset)]\(apiConstantVariableFragment.key)"
                        appendOrMerge(
                            map: nestedApiSingleVariableFragment.graphQLMap(currentMap: GraphQLMap(), store: store),
                            offset: offset
                        )
                    }
            } else if let apiGeneratedVariableFragment = variable.fragments.apiGeneratedVariableFragment {
                groupedMultiActionItems.enumerated()
                    .forEach { offset, _ in
                        appendOrMerge(
                            map: apiGeneratedVariableFragment.graphQLMap(currentMap: GraphQLMap(), store: store),
                            offset: offset
                        )
                    }
            } else if let _ = variable.asEmbarkApiGraphQlMultiActionVariable {
                fatalError("Unsupported for now")
            }
        }

        return items
    }
}

extension GraphQL.ApiVariablesFragment {
    func graphQLMap(accumulatedMap: GraphQLMap, store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        if let apiSingleVariableFragment = fragments.apiSingleVariableFragment {
            map = apiSingleVariableFragment.graphQLMap(currentMap: accumulatedMap, store: store)
        } else if let apiGeneratedVariableFragment = fragments.apiGeneratedVariableFragment {
            map = apiGeneratedVariableFragment.graphQLMap(currentMap: accumulatedMap, store: store)
        } else if let apiMultiActionVariableFragment = fragments.apiMultiActionVariableFragment {
            let values = apiMultiActionVariableFragment.graphQLMapArray(
                store: store
            )
            map = accumulatedMap.lodash_set(
                path: apiMultiActionVariableFragment.key,
                value: values
            )
        } else if let apiConstantVariableFragment = fragments.apiConstantVariableFragment {
            let newMap = accumulatedMap.lodash_set(
                path: apiConstantVariableFragment.key,
                value: apiConstantVariableFragment.value
            )
            map = newMap
        }

        return map
    }
}

extension GraphQL.ApiFragment.AsEmbarkApiGraphQlQuery.Datum {
    func graphQLVariables(store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        let sortedVariables = variables.map { $0.fragments.apiVariablesFragment }.sorted(by: <)

        sortedVariables.forEach { variable in
            map = variable.graphQLMap(accumulatedMap: map, store: store)
        }

        return map
    }
}

extension GraphQL.ApiFragment.AsEmbarkApiGraphQlMutation.Datum {
    func graphQLVariables(store: EmbarkStore) -> GraphQLMap {
        var map = GraphQLMap()

        let sortedVariables = variables.map { $0.fragments.apiVariablesFragment }.sorted(by: <)

        sortedVariables.forEach { variable in
            map = variable.graphQLMap(accumulatedMap: map, store: store)
        }

        return map
    }
}

extension GraphQL.ApiVariablesFragment: Comparable {
    var key: String {
        return self.asEmbarkApiGraphQlConstantVariable?.key ?? self.asEmbarkApiGraphQlSingleVariable?.key
            ?? self.asEmbarkApiGraphQlGeneratedVariable?.key ?? self.asEmbarkApiGraphQlMultiActionVariable?.key ?? ""
    }

    public static func < (lhs: GraphQL.ApiVariablesFragment, rhs: GraphQL.ApiVariablesFragment) -> Bool {
        return lhs.key < rhs.key
    }

    public static func == (lhs: GraphQL.ApiVariablesFragment, rhs: GraphQL.ApiVariablesFragment) -> Bool {
        return lhs.key == rhs.key
    }
}

extension ResultMap {
    func insertInto(store: EmbarkStore, basedOn query: GraphQL.ApiFragment.AsEmbarkApiGraphQlQuery) {
        query.data.queryResults.forEach { queryResult in
            let values = getValues(at: queryResult.key)

            switch values {
            case let .left(array):
                array.enumerated()
                    .forEach { (offset, value) in
                        store.setValue(
                            key: "\(queryResult.as)[\(String(offset))]",
                            value: value
                        )
                    }
            case let .right(value):
                store.setValue(key: queryResult.as, value: value)
            case .none:
                break
            }
        }
    }

    func insertInto(store: EmbarkStore, basedOn mutation: GraphQL.ApiFragment.AsEmbarkApiGraphQlMutation) {
        mutation.data.mutationResults.compactMap { $0 }
            .forEach { mutationResult in
                let values = getValues(at: mutationResult.key)

                switch values {
                case let .left(array):
                    array.enumerated()
                        .forEach { (offset, value) in
                            store.setValue(
                                key: "\(mutationResult.as)[\(String(offset))]",
                                value: value
                            )
                        }
                case let .right(value):
                    store.setValue(key: mutationResult.as, value: value)
                case .none:
                    break
                }
            }
    }
}

extension GraphQLMap {
    func findFiles() -> (files: [GraphQLFile], result: GraphQLMap) {
        var files: [GraphQLFile] = []

        let mappedResult = map { item -> (key: String, value: JSONEncodable?) in
            if let stringValue = item.value as? String {
                if stringValue.contains("file://") {
                    files.append(
                        try! .init(fieldName: item.key, originalName: "file", fileURL: URL(string: stringValue)!)
                    )
                    return (item.key, nil)
                }
            }

            return item
        }

        let result = Dictionary(uniqueKeysWithValues: mappedResult)

        return (files: files, result: result)
    }
}

extension EmbarkState {
    func handleApi(apiFragment: GraphQL.ApiFragment) -> Future<GraphQL.EmbarkLinkFragment?> {
        handleApiRequest(apiFragment: apiFragment)
            .mapResult { result in
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
                            guard let contains = queryError.contains else { return true }
                            return error.localizedDescription.contains(contains)
                        }?
                        .next.fragments.embarkLinkFragment
                    } else if let mutationApi = apiFragment.asEmbarkApiGraphQlMutation {
                        return mutationApi.data.mutationErrors.first { mutationError -> Bool in
                            guard let contains = mutationError.contains else { return true }
                            return error.localizedDescription.contains(contains)
                        }?
                        .next.fragments.embarkLinkFragment
                    }
                }

                return nil
            }
    }

    private func handleApiRequest(apiFragment: GraphQL.ApiFragment) -> Future<ResultMap?> {
        func performHTTPCall(_ query: String, variables: GraphQLMap) -> Future<ResultMap?> {
            var urlRequest = URLRequest(url: Environment.current.giraffeEndpointURL)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (files, variablesWithNilFiles) = variables.findFiles()

            if files.isEmpty {
                let JSONData = try! JSONSerialization.data(
                    withJSONObject: ["query": query, "variables": variables],
                    options: []
                )
                urlRequest.httpBody = JSONData
            } else {
                let JSONData = try! JSONSerialization.data(
                    withJSONObject: ["query": query, "variables": variablesWithNilFiles],
                    options: []
                )

                let formData = MultipartFormData()
                urlRequest.setValue(
                    "multipart/form-data; boundary=\(formData.boundary)",
                    forHTTPHeaderField: "Content-Type"
                )

                try? formData.appendPart(string: String(data: JSONData, encoding: .utf8)!, name: "operations")

                var map: [String: [String]] = [:]

                files.enumerated()
                    .forEach { item in
                        map[String(item.offset)] = ["variables.\(item.element.fieldName)"]
                    }

                let JSONMapData = try! JSONSerialization.data(
                    withJSONObject: map,
                    options: []
                )

                try? formData.appendPart(string: String(data: JSONMapData, encoding: .utf8)!, name: "map")

                files.enumerated()
                    .forEach { item in
                        let url = item.element.fileURL!
                        let file = try! GraphQLFile(
                            fieldName: "file",
                            originalName: String(item.offset),
                            fileURL: url
                        )

                        formData.appendPart(
                            inputStream: try! file.generateInputStream(),
                            contentLength: file.contentLength,
                            name: String(item.offset),
                            contentType: url.mimeType,
                            filename: file.originalName
                        )
                    }

                urlRequest.httpBody = try! formData.encode()
            }

            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders =
                ApolloClient.headers() as [AnyHashable: Any]

            let urlSessionClient = URLSessionClient(sessionConfiguration: configuration)

            return Future { completion in
                urlSessionClient.sendRequest(urlRequest) { result in
                    switch result {
                    case .failure: break
                    case let .success((data, response)):
                        if response.statusCode == 200 {
                            if let result = try? JSONSerialization.jsonObject(
                                with: data,
                                options: []
                            ) as? ResultMap {
                                if let errors = result["errors"] as? [ResultMap] {
                                    if let error = errors.first,
                                        let message = error["message"]
                                            as? String
                                    {
                                        completion(
                                            .failure(
                                                ApiError.failed(
                                                    reason: message
                                                )
                                            )
                                        )
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
                            if let reason = String(data: data, encoding: .utf8) {
                                completion(.failure(ApiError.failed(reason: reason)))
                            } else {
                                completion(.failure(ApiError.unknown))
                            }
                        }
                    }
                }

                return NilDisposer()
            }
        }

        if let queryApi = apiFragment.asEmbarkApiGraphQlQuery {
            return performHTTPCall(
                queryApi.data.query,
                variables: queryApi.data.graphQLVariables(store: store)
            )
            .onValue { resultMap in guard let resultMap = resultMap else { return }

                resultMap.insertInto(store: self.store, basedOn: queryApi)
            }
        } else if let mutationApi = apiFragment.asEmbarkApiGraphQlMutation {
            return performHTTPCall(
                mutationApi.data.mutation,
                variables: mutationApi.data.graphQLVariables(store: store)
            )
            .onValue { resultMap in
                guard let resultMap = resultMap else { return }
                resultMap.insertInto(store: self.store, basedOn: mutationApi)
            }
        }

        return Future(immediate: { nil })
    }

    enum ApiError: Error {
        case noApi
        case failed(reason: String)
        case unknown

        var localizedDescription: String {
            switch self {
            case .noApi: return "No API for this passage"
            case let .failed(reason): return "Failed with \(reason)"
            case .unknown: return "Unknown"
            }
        }
    }
}
