import Foundation

public enum ActionTypeName: Codable {
	case textAction(hTextAction)
	case multiAction(hMultiAction)
	case numberAction(hNumberAction)
	case datePickerAction(hDatePickerAction)
	case selectAction(hSelectAction)
	case textActionSet([hTextAction])
	case numberActionSet([hNumberAction])
    case insuranceAction(EmbarkInsuranceData)
}

public struct hNumberAction: Codable {
	public let key: String?
	public let placeholder: String
	public let label: String?
	public let maxValue: Int?
	public let minValue: Int?
	public let unit: String?
	public let link: hEmbarkLink?

	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkNumberAction.NumberActionDatum
	) {
		key = data.key
		label = data.label
		placeholder = data.placeholder
		maxValue = data.maxValue
		minValue = data.minValue
		unit = data.unit
		link = .init(name: data.link.name, label: data.link.label)
	}

	init?(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkNumberActionSet.Datum
			.NumberAction.Datum?
	) {
		guard let data = data else { return nil }
		key = data.key
		label = data.label
		placeholder = data.placeholder
		maxValue = data.maxValue
		minValue = data.minValue
		unit = data.unit
		link = nil
	}

	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum
			.Component.AsEmbarkMultiActionNumberAction.NumberActionDatum
	) {
		key = data.key
		label = data.label
		placeholder = data.placeholder
		maxValue = nil
		minValue = nil
		unit = data.unit
		link = nil
	}
}

public struct hSelectAction: Codable {
	public let options: [hSelectOption]
	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction.SelectActionDatum
	) {
		options = data.options.map {
			.init(
				link: .init(name: $0.link.name, label: $0.link.label),
				keys: $0.keys,
				values: $0.values,
				api: .init(api: $0.api)
			)
		}
	}
}

public struct hEmbarkLink: Codable {
	public let name: String
	public let label: String
}

public struct hSelectOption: Codable {
	public let link: hEmbarkLink
	public let keys: [String]
	public let values: [String]
	public let api: hAPI?
}

public enum MultiActionComponent: Codable {
	case dropDownAction(hDropDownAction)
	case number(hNumberAction)
	case `switch`(hSwitchAction)
}

public struct hMultiAction: Codable {
	public let key: String?
	public let components: [MultiActionComponent]
	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum
	) {
		key = data.key
		components = data.components.compactMap { action -> MultiActionComponent? in
			if let dropDown = action.asEmbarkDropdownAction {
				return MultiActionComponent.dropDownAction(.init(data: dropDown.dropDownActionData))
			} else if let number = action.asEmbarkMultiActionNumberAction {
				return MultiActionComponent.number(.init(data: number.numberActionData))
			} else if let switchAction = action.asEmbarkSwitchAction {
				return MultiActionComponent.switch(.init(data: switchAction.switchActionData))
			} else {
				return nil
			}
		}
	}
}

public struct hDatePickerAction: Codable {
	public var key: String?
	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkDatePickerAction
	) {
		key = data.storeKey
	}
}

public struct hSwitchAction: Codable {
	public let key: String
	public let label: String?
	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum
			.Component.AsEmbarkSwitchAction.SwitchActionDatum
	) {
		key = data.key
		label = data.label
	}
}

public struct hDropDownAction: Codable {
	public let key: String
	public let label: String?
	public let options: [DropDownOption]
	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum
			.Component.AsEmbarkDropdownAction.DropDownActionDatum
	) {
		key = data.key
		label = data.label
		options = data.options.map { .init(text: $0.text, value: $0.value) }
	}

	public struct DropDownOption: Codable {
		public let text: String
		public let value: String
	}
}

public struct hTextAction: Codable {
	public let key: String?
	public let mask: String?
	public let placeholder: String?
	public let title: String?
	public let api: hAPI?
	init(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction.TextActionDatum
	) {
		key = data.key
		mask = data.mask
		placeholder = data.placeholder
		api = .init(api: data.api)
		title = nil
	}

	init?(
		data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextActionSet.TextActionSetDatum
			.TextAction.Datum?
	) {
		guard let data = data else { return nil }
		key = data.key
		mask = data.mask
		placeholder = data.placeholder
		title = data.title
		api = nil
	}
}

public struct hEmbarkAction: Codable {
	var typename: ActionTypeName
	init?(
		action: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action?
	) {
		if let action = action?.asEmbarkMultiAction {
			typename = .multiAction(hMultiAction(data: action.multiActionData))
		} else if let action = action?.asEmbarkTextAction {
			typename = .textAction(hTextAction(data: action.textActionData))
		} else if let action = action?.asEmbarkNumberAction {
			typename = .numberAction(.init(data: action.numberActionData))
		} else if let action = action?.asEmbarkDatePickerAction {
			typename = .datePickerAction(.init(data: action))
		} else if let action = action?.asEmbarkSelectAction {
			typename = .selectAction(.init(data: action.selectActionData))
		} else if let numberActions = action?.asEmbarkNumberActionSet?.data?.numberActions {
			typename = .numberActionSet(numberActions.compactMap { action in .init(data: action.data) })
		} else if let textActions = action?.asEmbarkTextActionSet?.textActionSetData?.textActions {
			typename = .textActionSet(textActions.compactMap { action in .init(data: action.data) })
        } else if let action = action?.asEmbarkExternalInsuranceProviderAction {
            typename = .insuranceAction(.init(actionData: action.externalInsuranceProviderData))
        } else if let action  = action?.asEmbarkPreviousInsuranceProviderAction {
            typename = .insuranceAction(.init(actionData: action.previousInsuranceProviderData))
        } else { return nil }
	}
}

public struct EmbarkInsuranceData: Codable {
    public let link: hEmbarkLink?
    public let providerType: ProviderType
    public let storeKey: String?
    public let providers: GraphQL.EmbarkPreviousInsuranceProviderActionDataProviders?
    
    public enum ProviderType: Codable {
        case external
        case previous
    }
    
    init(actionData: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkPreviousInsuranceProviderAction.PreviousInsuranceProviderDatum) {
        link = .init(name: actionData.next.name, label: actionData.next.label)
        providerType = .external
        storeKey = actionData.storeKey
        providers = actionData.providers
    }
    
    init(actionData: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkExternalInsuranceProviderAction.ExternalInsuranceProviderDatum) {
        link = .init(name: actionData.next.name, label: actionData.next.label)
        providerType = .previous
        storeKey = nil
        providers = nil
    }
}

extension GraphQL.EmbarkPreviousInsuranceProviderActionDataProviders: Codable {}

extension ActionTypeName {
	enum CodingKeys: CodingKey {
		case multiAction, numberAction, textAction, datePickerAction, selectAction, textActionSet,
			numberActionSet, insuranceAction
	}

	public init(
		from decoder: Decoder
	) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		guard let key = container.allKeys.first else {
			throw DecodingError.dataCorrupted(
				DecodingError.Context(
					codingPath: container.codingPath,
					debugDescription: "Unabled to decode enum."
				)
			)
		}

		switch key {
		case .multiAction:
			let data = try container.decode(hMultiAction.self, forKey: .multiAction)
			self = .multiAction(data)
		case .numberAction:
			let data = try container.decode(hNumberAction.self, forKey: .numberAction)
			self = .numberAction(data)
		case .textAction:
			let data = try container.decode(hTextAction.self, forKey: .textAction)
			self = .textAction(data)
		case .datePickerAction:
			let data = try container.decode(hDatePickerAction.self, forKey: .datePickerAction)
			self = .datePickerAction(data)
		case .selectAction:
			let data = try container.decode(hSelectAction.self, forKey: .selectAction)
			self = .selectAction(data)
		case .textActionSet:
			let data = try container.decode([hTextAction].self, forKey: .textActionSet)
			self = .textActionSet(data)
		case .numberActionSet:
			let data = try container.decode([hNumberAction].self, forKey: .numberActionSet)
			self = .numberActionSet(data)
        case .insuranceAction(let data):
            let data = try container.decode(EmbarkInsuranceData.self, forKey: .insuranceAction)
            self = .insuranceAction(data)
        }
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		switch self {
		case .multiAction(let data):
			try container.encode(data, forKey: .multiAction)
		case .textAction(let data):
			try container.encode(data, forKey: .textAction)
		case .numberAction(let data):
			try container.encode(data, forKey: .numberAction)
		case .datePickerAction(let data):
			try container.encode(data, forKey: .datePickerAction)
		case .selectAction(let data):
			try container.encode(data, forKey: .selectAction)
		case .textActionSet(let data):
			try container.encode(data, forKey: .textActionSet)
		case .numberActionSet(let data):
			try container.encode(data, forKey: .numberActionSet)
        case .insuranceAction(let data):
            try container.encode(data, forKey: .insuranceAction)
        }
	}
}

extension MultiActionComponent {
	enum CodingKeys: CodingKey {
		case numberAction, dropDownAction, switchAction
	}

	public init(
		from decoder: Decoder
	) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		guard let key = container.allKeys.first else {
			throw DecodingError.dataCorrupted(
				DecodingError.Context(
					codingPath: container.codingPath,
					debugDescription: "Unabled to decode enum."
				)
			)
		}

		switch key {
		case .numberAction:
			let data = try container.decode(hNumberAction.self, forKey: .numberAction)
			self = .number(data)
		case .switchAction:
			let data = try container.decode(hSwitchAction.self, forKey: .switchAction)
			self = .switch(data)
		case .dropDownAction:
			let data = try container.decode(hDropDownAction.self, forKey: .dropDownAction)
			self = .dropDownAction(data)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		switch self {
		case .dropDownAction(let data):
			try container.encode(data, forKey: .dropDownAction)
		case .number(let data):
			try container.encode(data, forKey: .numberAction)
		case .switch(let data):
			try container.encode(data, forKey: .switchAction)
		}
	}
}
