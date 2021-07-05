import Apollo
import Flow
import Foundation
import UIKit
import WebKit
import hCore
import hGraphQL

enum WebOnboardingScreen {
	case webOffer(ids: [String])
	case webOnboarding
}

struct WebOnboardingState {
	let screen: WebOnboardingScreen

	private var locale: String { Localization.Locale.currentLocale.webPath }

	private var path: String {
		switch screen {
		case .webOffer: return "/\(locale)/new-member/offer"
		case .webOnboarding: return "/\(locale)/new-member"
		}
	}

	private var host: String { Environment.current.webBaseURL.host ?? "" }

	private var token: String? {
		guard let token = ApolloClient.retreiveToken() else { return nil }

		return token.urlEncodedString
	}

	private let defaultQueryItem = URLQueryItem(name: "variation", value: "ios")

	private var queryItems: [URLQueryItem] {
		switch screen {
		case let .webOffer(ids):
			return [
				URLQueryItem(name: "quoteIds", value: "[" + ids.joined(separator: ",") + "]"),
				defaultQueryItem,
			]
		case .webOnboarding: return [defaultQueryItem]
		}
	}

	private var fragment: String { "#token=\(token ?? "")" }

	private var components: URLComponents {
		var components = URLComponents()
		components.scheme = "https"
		components.host = host
		components.path = path
		components.queryItems = queryItems
		return components
	}

	public var url: URL? {
		let url = components.url
		return URL(string: fragment, relativeTo: url)
	}
}
