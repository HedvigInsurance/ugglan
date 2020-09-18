import Flow
import Form
import Foundation
import hCore

struct ContactDetailsSection {
    let state: MyInfoState
}

extension ContactDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.myInfoContactDetailsTitle,
            footer: nil
        )

        let phoneNumberRow = PhoneNumberRow(
            state: state
        )
        bag += section.append(phoneNumberRow)

        let emailRow = EmailRow(
            state: state
        )
        bag += section.append(emailRow)

        return (section, bag)
    }
}
