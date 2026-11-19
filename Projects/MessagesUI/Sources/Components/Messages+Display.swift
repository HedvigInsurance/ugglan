import Foundation
import MessagesCore
import hCore

extension InboxFilter {
    var title: String {
        switch self {
        case .all: L10n.MessagesInbox.filterAll
        case .channel(.email): L10n.MessagesInbox.filterEmails
        case .channel(.sms): L10n.MessagesInbox.filterSms
        case .channel(.kivra): L10n.MessagesInbox.filterKivra
        }
    }
}

@MainActor
extension InboxDateRange {
    /// e.g. "3 Nov – 12 Nov", "3 Nov" for a single day, "From 3 Nov" or "Until 12 Nov".
    var label: String {
        switch (from, to) {
        case let (from?, to?) where Calendar.current.isDate(from, inSameDayAs: to):
            from.displayDateDDMMMFormat
        case let (from?, to?):
            L10n.MessagesInbox.dateRangeLabel(from.displayDateDDMMMFormat, to.displayDateDDMMMFormat)
        case let (from?, nil):
            L10n.MessagesInbox.dateFromLabel(from.displayDateDDMMMFormat)
        case let (nil, to?):
            L10n.MessagesInbox.dateToLabel(to.displayDateDDMMMFormat)
        case (nil, nil):
            L10n.MessagesInbox.dateFilter
        }
    }
}

extension MessageChannel {
    /// Title of the opened message screen.
    var detailTitle: String {
        switch self {
        case .email: L10n.MessagesInbox.detailTitleEmail
        case .sms: L10n.MessagesInbox.detailTitleSms
        case .kivra: L10n.MessagesInbox.detailTitleKivra
        }
    }
}

@MainActor
extension InboxMessage {
    /// Trailing label of a read row: the time today, "Yesterday", otherwise e.g. "3 Nov".
    var listDateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(receivedAt) {
            return Self.timeFormatter.string(from: receivedAt)
        } else if calendar.isDateInYesterday(receivedAt) {
            return L10n.generalYesterday
        }
        return receivedAt.displayDateDDMMMFormat
    }

    /// e.g. "12 November at 09:14".
    var receivedAtLabel: String {
        L10n.MessagesInbox.receivedAt(
            Self.dayMonthFormatter.string(from: receivedAt),
            Self.timeFormatter.string(from: receivedAt)
        )
    }

    private static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Localization.Locale.currentLocale.value.foundation
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    private static var dayMonthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Localization.Locale.currentLocale.value.foundation
        formatter.dateFormat = "d MMMM"
        return formatter
    }
}
