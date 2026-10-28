import Foundation
import hCore
import hGraphQL

// These GraphQL-fragment conversions for hCore models live in App so that hCore doesn't depend on hGraphQL.

extension Perils {
    init(
        fragment: OctopusGraphQL.AddonVariantFragment.AddonPeril
    ) {
        var description = fragment.description ?? ""
        let coverageTexts = [fragment.coverageText].compactMap { $0 }
        if !coverageTexts.isEmpty {
            description += "\r\n"
        }
        for coverageText in [fragment.coverageText].compactMap({ $0 }) {
            description += "\r\n \(coverageText)"
        }
        self.init(
            id: fragment.title,
            title: fragment.title,
            description: description,
            color: fragment.colorCode,
            covered: [],
            isDisabled: false
        )
    }

    init(
        fragment: OctopusGraphQL.PerilFragment
    ) {
        self.init(
            id: fragment.id,
            title: fragment.title,
            description: fragment.description,
            color: fragment.colorCode,
            covered: fragment.covered,
            isDisabled: false
        )
    }
}

extension hPDFDocument {
    init(
        _ data: OctopusGraphQL.ProductVariantFragment.Document
    ) {
        self.init(
            displayName: data.displayName,
            url: data.url,
            type: data.type.asTypeOfDocument
        )
    }

    init(
        _ data: OctopusGraphQL.AddonVariantFragment.Document
    ) {
        self.init(
            displayName: data.displayName,
            url: data.url,
            type: data.type.asTypeOfDocument
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.InsuranceDocumentType> {
    var asTypeOfDocument: TypeOfDocument {
        switch self {
        case let .case(type):
            switch type {
            case .generalTerms:
                return .generalTerms
            case .preSaleInfo:
                return .preSaleInfo
            case .preSaleInfoEuStandard:
                return .preSaleInfoEuStandard
            case .privacyPolicy:
                return .privacyPolicy
            case .termsAndConditions:
                return .termsAndConditions
            case .scarTable:
                return .unknown
            case .termsChanges:
                return .unknown
            }
        case .unknown:
            return .unknown
        }
    }
}

extension MonetaryAmount {
    init(
        fragment: OctopusGraphQL.MoneyFragment
    ) {
        self.init(
            amount: String(fragment.amount),
            currency: fragment.currencyCode.rawValue
        )
    }

    init?(
        optionalFragment: OctopusGraphQL.MoneyFragment?
    ) {
        guard let optionalFragment else { return nil }
        self.init(fragment: optionalFragment)
    }
}

extension ProductVariant {
    init(
        data: OctopusGraphQL.ProductVariantFragment
    ) {
        self.init(
            termsVersion: data.termsVersion,
            typeOfContract: data.typeOfContract,
            perils: data.perils.map { .init(fragment: $0.fragments.perilFragment) },
            insurableLimits: data.insurableLimits.map { .init($0) },
            documents: data.documents.map { .init($0) },
            displayName: data.displayName,
            displayNameTier: data.displayNameTier,
            tierDescription: data.tierDescription
        )
    }

    init?(
        data: OctopusGraphQL.ProductVariantFragment?
    ) {
        guard let data else { return nil }
        self.init(data: data)
    }
}

extension Premium {
    init(
        fragment: OctopusGraphQL.ItemCostFragment
    ) {
        self.init(
            gross: .init(fragment: fragment.monthlyGross.fragments.moneyFragment),
            net: .init(fragment: fragment.monthlyNet.fragments.moneyFragment)
        )
    }
}

extension AddonVariant {
    init(
        fragment: OctopusGraphQL.AddonVariantFragment?
    ) {
        self.init(
            displayName: fragment?.displayName ?? "",
            documents: fragment?.documents.map { .init($0) } ?? [],
            perils: fragment?.addonPerils.map { .init(fragment: $0) } ?? [],
            product: fragment?.product ?? "",
            termsVersion: fragment?.termsVersion ?? ""
        )
    }
}

extension InsurableLimits {
    init(
        _ data: OctopusGraphQL.ProductVariantFragment.InsurableLimit
    ) {
        self.init(
            label: data.label,
            limit: data.limit,
            description: data.description
        )
    }
}

extension ItemCost {
    init(fragment: OctopusGraphQL.ItemCostFragment) {
        self.init(
            premium: .init(
                gross: .init(fragment: fragment.monthlyGross.fragments.moneyFragment),
                net: .init(fragment: fragment.monthlyNet.fragments.moneyFragment)
            ),
            discounts: fragment.discounts.map { .init(fragment: $0.fragments.itemDiscountFragment) }
        )
    }
}

extension ItemDiscount {
    init(fragment: OctopusGraphQL.ItemDiscountFragment) {
        self.init(
            campaignCode: fragment.campaignCode,
            displayName: fragment.displayName,
            displayValue: fragment.displayValue,
            explanation: fragment.explanation
        )
    }
}

@MainActor
extension hGraphQL.GraphQLError: @preconcurrency @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .graphQLError:
            return L10n.General.defaultError
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
