import Foundation

public struct QuickAction: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let displayTitle: String
    public let displaySubtitle: String?
    public let layout: Layout?

    public init(
        id: String,
        displayTitle: String,
        displaySubtitle: String?,
        layout: Layout?
    ) {
        self.id = id
        self.displayTitle = displayTitle
        self.displaySubtitle = displaySubtitle
        self.layout = layout

    }

    public struct Layout: Codable, Equatable, Hashable {
        public var titleAndBulletPoint: TitleAndBulletPoints?
        public var emergency: Emergency?

        public init(
            titleAndBulletPoint: TitleAndBulletPoints?,
            emergency: Emergency?
        ) {
            self.titleAndBulletPoint = titleAndBulletPoint
            self.emergency = emergency
        }

        public struct TitleAndBulletPoints: Codable, Equatable, Hashable {
            public let color: String
            public var buttonTitle: String?
            public var title: String?
            public var bulletPoints: [BulletPoint]

            public init(
                color: String,
                buttonTitle: String? = nil,
                title: String? = nil,
                bulletPoints: [BulletPoint]
            ) {
                self.color = color
                self.buttonTitle = buttonTitle
                self.title = title
                self.bulletPoints = bulletPoints
            }

            public struct BulletPoint: Codable, Hashable, Equatable {
                public let title: String
                public let description: String

                public init(
                    title: String,
                    description: String
                ) {
                    self.title = title
                    self.description = description
                }
            }
        }

        public struct Emergency: Codable, Hashable, Equatable {
            public let title: String
            public let color: String
            public let emergencyNumber: String?

            public init(
                title: String,
                color: String,
                emergencyNumber: String? = nil
            ) {
                self.title = title
                self.color = color
                self.emergencyNumber = emergencyNumber
            }
        }
    }
}

extension QuickAction {
    var isFirstVet: Bool {
        id == "30" || id == "31" || id == "32"
    }

    public var isSickAborad: Bool {
        self.layout?.emergency?.emergencyNumber != nil
    }
}

extension Sequence where Iterator.Element == QuickAction {
    var vetQuickAction: QuickAction? {
        return self.first(where: { $0.isFirstVet })
    }

}
