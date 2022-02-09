import Combine
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct SingleStartDateSection {
    @State var isExpanded: Bool
    @State var datePickerDate: Date
    @Binding var date: Date?

    let title: String?
    let switchingActivated: Bool

    init(
        date: Binding<Date?>,
        title: String?,
        switchingActivated: Bool,
        initiallyCollapsed: Bool
    ) {
        self._date = date
        self.title = title
        self.switchingActivated = switchingActivated
        self._datePickerDate = State(initialValue: date.wrappedValue ?? Date())
        self._isExpanded = State(initialValue: !initiallyCollapsed)
    }
    
    var calendar: Calendar {
        Calendar(identifier: .gregorian)
    }
    
    var minimumDate: Date? {
        calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
    }
    
    var maximumDate: Date? {
        calendar.date(byAdding: .year, value: 1, to: Date())
    }

    @ViewBuilder var footer: some View {
        if switchingActivated {
            hText(L10n.offerSwitcherExplanationFooter)
                .foregroundColor(hLabelColor.secondary)
        }
    }

    @ViewBuilder private var header: some View {
        if let title = title {
            hText(title, style: .headline)
                .foregroundColor(hLabelColor.secondary)
        }
    }
}

extension SingleStartDateSection: View {
    var body: some View {
        hSection(header: header, footer: footer) {
            hRow {
                HStack {
                    hCoreUIAssets.calendar.view
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 21, height: 21)
                        .padding(.trailing, 5)
                    hText(L10n.offerStartDate, style: .body)
                }
            }
            .withCustomAccessory {
                Spacer()
                hText(date?.localDateStringWithToday ?? "")
                    .foregroundColor(hLabelColor.link)
            }
            .onTap(if: date != nil) {
                withAnimation(.interpolatingSpring(stiffness: 250, damping: 100)) {
                    isExpanded.toggle()
                }
            }

            StartDateCollapser(expanded: self.isExpanded) {
                hRow {
                    DatePicker(
                        date: $datePickerDate,
                        minimumDate: minimumDate,
                        maximumDate: maximumDate,
                        calendar: calendar,
                        datePickerMode: .date
                    )
                }
                .noSpacing()
                .padding(.bottom, 2)
            }
            .onReceive(Just(datePickerDate)) { _ in
                if isExpanded {
                    date = datePickerDate
                }
            }

            if switchingActivated {
                hRow {
                    HStack {
                        hCoreUIAssets.circularClock.view
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 21, height: 21)
                            .padding(.trailing, 5)
                        hText(L10n.offerSwitcherNoDate, style: .body)
                    }
                }
                .withCustomAccessory {
                    Spacer()
                    Switch(
                        on: .init(
                            get: {
                                date == nil
                            },
                            set: { on in
                                if on {
                                    withAnimation(.interpolatingSpring(stiffness: 250, damping: 100)) {
                                        isExpanded = false
                                        date = nil
                                    }
                                } else {
                                    withAnimation(.interpolatingSpring(stiffness: 250, damping: 100)) {
                                        isExpanded = true
                                        date = Date()
                                    }
                                }
                            }
                        )
                    )
                }
            }
        }
        .onAppear {
            // if date is before today, reset date
            if let date = date, let minimumDate = minimumDate, date < minimumDate {
                self.date = Date()
                self.datePickerDate = Date()
            } else if !switchingActivated && date == nil {
                self.date = Date()
            } else {
                self.date = self.date
            }
        }
    }
}
