//
//  ContractRow.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-16.
//

import Flow
import Form
import Foundation

struct ContractRow: Hashable {
    static func == (lhs: ContractRow, rhs: ContractRow) -> Bool {
        lhs.displayName == rhs.displayName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }

    let contract: ContractsQuery.Data.Contract
    let displayName: String
    let state: State
    let type: ContractType

    enum State {
        case active
        case cancelled(from: Date)
        case coming
    }

    enum ContractType {
        case swedishApartment
        case swedishHouse
        case norwegianTravel
        case norwegianHome
    }

    func calculateHeight(for width: CGFloat) -> CGSize {
        let bag = DisposeBag()
        let form = FormView()

        let (contentBag, contents) = makeFormContent()
        bag += contentBag

        contents.forEach { content in
            switch content {
            case let .left(section):
                form.append(section)
            case let .right(viewOrSpacing):
                switch viewOrSpacing {
                case let .left(view):
                    form.append(view)
                case let .right(spacing):
                    bag += form.append(spacing)
                }
            }
        }

        let size = form.systemLayoutSizeFitting(CGSize(width: width, height: 0))

        bag.dispose()

        return size
    }
}

extension ContractRow: Reusable {
    func makeStateIndicator() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10

        let imageView = UIImageView()
        stackView.addArrangedSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
        }

        let label = UILabel(value: "", style: .bodySmallSmallLeft)
        stackView.addArrangedSubview(label)

        switch state {
        case .active:
            imageView.image = Asset.greenCircularCheckmark.image
            label.value = "Aktiv"
        case .cancelled:
            imageView.image = Asset.pinkCircularExclamationPoint.image
            label.value = "Uppsagd"
        case .coming:
            imageView.image = Asset.clock.image
            label.value = "Aktiveras snart"
        }

        return stackView
    }

    func makeInfoIcon() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.infoPurple.image

        imageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        return imageView
    }

    var daysUntilRenewal: Int? {
        let formatter = DateFormatter.iso8601
        guard let date = formatter.date(from: contract.upcomingRenewal?.renewalDate ?? "") else {
            return nil
        }

        let calendar = Calendar.current

        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: dateFrom, to: dateTo)

        return components.day
    }

    func makeRenewalRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = .sectionPlain
        let row = RowView()

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(value: String(key: .DASHBOARD_RENEWAL_PROMPTER_TITLE), style: .headlineSmallSmallLeft)
        )

        bag += textContainer.addArranged(
            MultilineLabel(
                value: String(key: .DASHBOARD_RENEWAL_PROMPTER_BODY(daysUntilRenewal: daysUntilRenewal ?? "")),
                style: .bodySmallSmallLeft
            )
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            guard let url = URL(string: self.contract.upcomingRenewal?.draftCertificateUrl) else {
                return
            }
            section.viewController?.present(
                InsuranceCertificate(url: url).withCloseButton,
                style: .modally()
            )
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeInfoRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = .sectionPlain
        let row = RowView()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.insuranceInfo.image
        row.append(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(value: "Min information", style: .headlineSmallSmallLeft)
        )
        textContainer.addArrangedSubview(
            UILabel(value: contract.currentAgreement.summary ?? "", style: .bodySmallSmallLeft)
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            section.viewController?.present(
                ContractDetail(contract: self.contract).withCloseButton,
                style: .modally()
            )
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeCoverageRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = .sectionPlain
        let row = RowView()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.coverage.image
        row.append(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(value: "Mitt skydd", style: .headlineSmallSmallLeft)
        )
        textContainer.addArrangedSubview(
            UILabel(value: "Tryck för att läsa", style: .bodySmallSmallLeft)
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            section.viewController?.present(ContractCoverage().withCloseButton, style: .modally())
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeDocumentsRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = .sectionPlain
        let row = RowView()

        let imageView = UIImageView()
        imageView.image = Asset.documents.image
        imageView.contentMode = .scaleAspectFit
        row.append(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(value: "Mina dokument", style: .headlineSmallSmallLeft)
        )
        textContainer.addArrangedSubview(
            UILabel(value: "Försäkringsbrev", style: .bodySmallSmallLeft)
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            section.viewController?.present(
                ContractDocuments(contract: self.contract).withCloseButton,
                style: .modally()
            )
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeFormContent() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()
        let header = UIStackView()
        header.axis = .vertical
        header.spacing = 10
        header.addArrangedSubview(UILabel(value: displayName, style: .headlineMediumMediumLeft))
        header.addArrangedSubview(makeStateIndicator())

        let (renewalRowBag, renewalRowContent) = makeRenewalRow()
        bag += renewalRowBag

        let (infoRowBag, infoRowContent) = makeInfoRow()
        bag += infoRowBag

        let (coverageRowBag, coverageRowContent) = makeCoverageRow()
        bag += coverageRowBag

        let (documentsRowBag, documentsRowContent) = makeDocumentsRow()
        bag += documentsRowBag

        return (
            bag,
            [
                [
                    .make(header),
                    .make(Spacing(height: 10)),
                ],
                contract.upcomingRenewal != nil ? renewalRowContent : nil,
                contract.upcomingRenewal != nil ? [.make(Spacing(height: 10))] : nil,
                infoRowContent,
                [.make(Spacing(height: 10))],
                coverageRowContent,
                [.make(Spacing(height: 10))],
                documentsRowContent,
            ].compactMap { $0 }.flatMap { $0 }
        )
    }

    static func makeAndConfigure() -> (make: UIView, configure: (ContractRow) -> Disposable) {
        let view = UIView()

        let form = FormView()
        view.addSubview(form)

        form.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        return (view, { `self` in
            let bag = DisposeBag()

            let (contentBag, contents) = self.makeFormContent()
            bag += contentBag

            contents.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                    bag += {
                        section.removeFromSuperview()
                    }
                case let .right(viewOrSpacing):
                    switch viewOrSpacing {
                    case let .left(view):
                        form.append(view)
                        bag += {
                            view.removeFromSuperview()
                        }
                    case let .right(spacing):
                        bag += form.append(spacing)
                    }
                }
            }

            return bag
        })
    }
}
