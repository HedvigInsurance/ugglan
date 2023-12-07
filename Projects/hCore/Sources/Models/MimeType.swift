import Foundation

public enum MimeType: Codable, Equatable, Hashable {
    case PDF
    case DOCX
    case PPTX
    case XLSX
    case TXT
    case JPEG
    case JPG
    case PNG
    case HEIC
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
    case M4A
    case other(type: String)

    public var isImage: Bool {
        switch self {
        case .JPEG:
            return true
        case .JPG:
            return true
        case .PNG:
            return true
        case .HEIC:
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

    public static func findBy(mimeType: String) -> MimeType {
        switch mimeType {
        case MimeType.PDF.mime: return MimeType.PDF
        case MimeType.DOCX.mime: return MimeType.DOCX
        case MimeType.PPTX.mime: return MimeType.PPTX
        case MimeType.XLSX.mime: return MimeType.XLSX
        case MimeType.TXT.mime: return MimeType.TXT
        case MimeType.JPEG.mime: return MimeType.JPEG
        case MimeType.JPG.mime: return MimeType.JPG
        case MimeType.PNG.mime: return MimeType.PNG
        case MimeType.HEIC.mime: return MimeType.HEIC
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
        case MimeType.M4A.mime: return MimeType.M4A
        default:
            return MimeType.other(type: mimeType)

        }
    }

    public var mime: String {
        switch self {
        case .PDF: return "application/pdf"
        case .DOCX: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .PPTX: return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .XLSX: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .TXT: return "text/plain"
        case .JPEG: return "image/jpeg"
        case .JPG: return "image/jpeg"
        case .PNG: return "image/png"
        case .HEIC: return "image/heic"
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
        case .M4A: return "audio/x-m4a"
        case .other(let type): return type
        }
    }
}
