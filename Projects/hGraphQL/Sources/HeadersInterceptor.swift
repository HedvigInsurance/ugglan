import Apollo
import Foundation

class HeadersInterceptor: ApolloInterceptor {
	let token: String
	let acceptLanguageHeader: String
	let userAgent: String

	init(
		token: String,
		acceptLanguageHeader: String,
		userAgent: String
	) {
		self.token = token
		self.acceptLanguageHeader = acceptLanguageHeader
		self.userAgent = userAgent
	}

	func interceptAsync<Operation: GraphQLOperation>(
		chain: RequestChain,
		request: HTTPRequest<Operation>,
		response: HTTPResponse<Operation>?,
		completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
	) {
		let httpAdditionalHeaders = [
			"Authorization": token, "Accept-Language": acceptLanguageHeader, "User-Agent": userAgent,
		]

		httpAdditionalHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

		chain.proceedAsync(request: request, response: response, completion: completion)
	}
}
