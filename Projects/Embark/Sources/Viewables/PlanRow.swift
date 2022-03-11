import Flow
import Form
import Foundation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct PlanRow: Equatable, Hashable {
    static func == (lhs: PlanRow, rhs: PlanRow) -> Bool { lhs.hashValue == rhs.hashValue }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(discount)
        hasher.combine(message)
    }

    let title: String
    let discount: String?
    let message: String
    let gradientType: GradientView.Preset?
    let isSelected: ReadWriteSignal<Bool>
}

struct PlanRowContent: View {
    let selected: Bool
    let row: PlanRow

    @ViewBuilder var discountBackground: some View {
        if !selected {
            hColorScheme(
                light: hGrayscaleColor.five,
                dark: hGrayscaleColor.one
            )
        } else {
            hBackgroundColor.primary
        }
    }

    @hColorBuilder var discountForegroundColor: some hColor {
        if !selected {
            hLabelColor.primary.inverted
        } else {
            hLabelColor.primary
        }
    }

    var paddingTop: CGFloat {
        if row.discount != nil {
            return 16
        }

        return 24
    }

    var body: some View {
        VStack {
            if let discount = row.discount {
                VStack {
                    discount.hText(.caption1)
                }
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(discountBackground)
                .foregroundColor(discountForegroundColor)
                .invertColorScheme
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    row.title.hText(.title2)
                        .foregroundColor(hLabelColor.primary)
                    Spacer()
                    BulletView(isSelected: selected).frame(width: 24, height: 24)
                }
                row.message.hText(.body)
                    .foregroundColor(hLabelColor.secondary)
                    .padding(.trailing, 24)
            }
            .padding([.leading, .trailing], 16)
            .padding(.top, paddingTop)
            .padding(.bottom, 24)
        }
    }
}

extension PlanRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (PlanRow) -> Disposable) {
        let view = UIStackView()
        view.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        view.insetsLayoutMarginsFromSafeArea = true

        let contentView = UIControl()
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = .defaultCornerRadius
        contentView.layer.borderWidth = .hairlineWidth

        view.addArrangedSubview(contentView)

        let hostingView = HostingView(rootView: AnyView(EmptyView()))
        hostingView.isUserInteractionEnabled = false
        contentView.addSubview(hostingView)

        hostingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return (
            view,
            { `self` in
                let bag = DisposeBag()

                bag += contentView.applyBorderColor { _ in .brand(.primaryBorderColor) }

                bag += contentView.signal(for: .touchUpInside).map { true }.bindTo(self.isSelected)

                bag += self.isSelected.atOnce()
                    .onValue({ selected in
                        hostingView.swiftUIRootView = AnyView(
                            PlanRowContent(selected: self.isSelected.value, row: self)
                        )
                    })

                if let gradientType = self.gradientType {
                    let gradientView = GradientView(
                        gradientOption: .init(preset: gradientType),
                        shouldShowGradientSignal: self.isSelected
                    )

                    bag += contentView.add(gradientView) { view in contentView.sendSubviewToBack(view)
                        view.snp.makeConstraints { make in
                            make.top.bottom.trailing.leading.equalToSuperview()
                        }
                    }
                }

                return bag
            }
        )
    }
}
