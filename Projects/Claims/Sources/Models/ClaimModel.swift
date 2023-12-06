import Foundation
import hCore
import hGraphQL

public struct ClaimModel: Codable, Equatable, Identifiable, Hashable {

    public init(
        id: String,
        status: ClaimStatus,
        outcome: ClaimOutcome,
        submittedAt: String?,
        closedAt: String?,
        signedAudioURL: String?,
        type: String,
        memberFreeText: String?,
        payoutAmount: MonetaryAmount?,
        files: [File]
    ) {
        self.id = id
        self.status = status
        self.outcome = outcome
        self.submittedAt = submittedAt
        self.closedAt = closedAt
        self.signedAudioURL = signedAudioURL
        self.type = type
        self.subtitle = ""
        self.memberFreeText = memberFreeText
        self.payoutAmount = payoutAmount
        self.files = files
    }

    public var title: String {
        L10n.Claim.Casetype.insuranceCase
    }
    public let subtitle: String
    public let id: String
    public let status: ClaimStatus
    public let outcome: ClaimOutcome
    public let submittedAt: String?
    public let closedAt: String?
    public let signedAudioURL: String?
    public let memberFreeText: String?
    public let payoutAmount: MonetaryAmount?
    public let type: String
    public let files: [File]

    public var statusParagraph: String {
        switch self.status {
        case .submitted:
            return L10n.ClaimStatus.Submitted.supportText
        case .beingHandled:
            return L10n.ClaimStatus.BeingHandled.supportText
        case .closed:
            switch outcome {
            case .paid:
                return L10n.ClaimStatus.Paid.supportText
            case .notCompensated:
                return L10n.ClaimStatus.NotCompensated.supportText
            case .notCovered:
                return L10n.ClaimStatus.NotCovered.supportText
            case .none:
                return ""
            }
        case .reopened:
            return L10n.ClaimStatus.BeingHandledReopened.supportText
        default:
            return ""
        }
    }

    public var showUploadedFiles: Bool {
        return self.signedAudioURL != nil || !files.isEmpty || canAddFiles
    }

    public var canAddFiles: Bool {
        return self.status != .closed
    }

    public enum ClaimStatus: String, Codable, CaseIterable {
        case none
        case submitted
        case beingHandled
        case closed
        case reopened

        public init?(
            rawValue: RawValue
        ) {
            switch rawValue {
            case "CREATED": self = .submitted
            case "IN_PROGRESS": self = .beingHandled
            case "CLOSED": self = .closed
            case "REOPENED": self = .reopened
            default: self = .none
            }
        }

        var title: String {
            switch self {
            case .submitted:
                return L10n.Claim.StatusBar.submitted
            case .beingHandled:
                return L10n.Claim.StatusBar.beingHandled
            case .closed:
                return L10n.Claim.StatusBar.closed
            case .none:
                return ""
            case .reopened:
                return L10n.Home.ClaimCard.Pill.reopened
            }
        }
    }

    public enum ClaimOutcome: String, Codable, CaseIterable {
        case paid
        case notCompensated
        case notCovered
        case none

        public init?(
            rawValue: RawValue
        ) {
            switch rawValue {
            case "PAID": self = .paid
            case "NOT_COMPENSATED": self = .notCompensated
            case "NOT_COVERED": self = .notCovered
            default: self = .none
            }
        }

        var text: String {
            switch self {
            case .paid:
                return L10n.Claim.Decision.paid
            case .notCompensated:
                return L10n.Claim.Decision.notCompensated
            case .notCovered:
                return L10n.Claim.Decision.notCovered
            case .none:
                return L10n.Home.ClaimCard.Pill.claim
            }
        }
    }
}

public struct File: Codable, Equatable, Identifiable, Hashable {
    public let id: String
    let size: Double
    let mimeType: MimeType
    let name: String
    let source: FileSource
}

public enum FileSource: Codable, Equatable, Hashable {
    case data(data: Data)
    case url(url: URL)
}

enum MimeType: Codable, Equatable, Hashable {
    case PDF
    case DOCX
    case PPTX
    case XLSX
    case TXT
    case JPEG
    case JPG
    case PNG
    case GIF
    case BMP
    case SVG
    case MP3
    case WAV
    case FLAC
    case MP4
    case AVI
    case MKV
    case HTML
    case CSS
    case CSV
    case JSON
    case other(type: String)

    var isImage: Bool {
        switch self {
        case .JPEG:
            return true
        case .JPG:
            return true
        case .PNG:
            return true
        case .GIF:
            return true
        case .BMP:
            return true
        case .SVG:
            return true
        default:
            return false
        }
    }

    static func findBy(mimeType: String) -> MimeType {
        switch mimeType {
        case MimeType.PDF.mime: return MimeType.PDF
        case MimeType.DOCX.mime: return MimeType.DOCX
        case MimeType.PPTX.mime: return MimeType.PPTX
        case MimeType.XLSX.mime: return MimeType.XLSX
        case MimeType.TXT.mime: return MimeType.TXT
        case MimeType.JPEG.mime: return MimeType.JPEG
        case MimeType.JPG.mime: return MimeType.JPG
        case MimeType.PNG.mime: return MimeType.PNG
        case MimeType.GIF.mime: return MimeType.GIF
        case MimeType.BMP.mime: return MimeType.BMP
        case MimeType.SVG.mime: return MimeType.SVG
        case MimeType.MP3.mime: return MimeType.MP3
        case MimeType.WAV.mime: return MimeType.WAV
        case MimeType.FLAC.mime: return MimeType.FLAC
        case MimeType.MP4.mime: return MimeType.MP4
        case MimeType.AVI.mime: return MimeType.AVI
        case MimeType.MKV.mime: return MimeType.MKV
        case MimeType.HTML.mime: return MimeType.HTML
        case MimeType.CSS.mime: return MimeType.CSS
        case MimeType.CSV.mime: return MimeType.CSV
        case MimeType.JSON.mime: return MimeType.JSON
        default:
            return MimeType.other(type: mimeType)

        }
    }

    var mime: String {
        switch self {
        case .PDF: return "application/pdf"
        case .DOCX: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .PPTX: return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .XLSX: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .TXT: return "text/plain"
        case .JPEG: return "image/jpeg"
        case .JPG: return "image/jpeg"
        case .PNG: return "image/png"
        case .GIF: return "image/gif"
        case .BMP: return "image/bmp"
        case .SVG: return "image/svg+xml"
        case .MP3: return "audio/mpeg"
        case .WAV: return "audio/wav"
        case .FLAC: return "audio/flac"
        case .MP4: return "video/mp4"
        case .AVI: return "video/x-msvideo"
        case .MKV: return "video/x-matroska"
        case .HTML: return "text/html"
        case .CSS: return "text/css"
        case .CSV: return "text/csv"
        case .JSON: return "application/json"
        case .other(let type): return type
        }
    }
}
