import Foundation
import ImageIO
import Testing
import UIKit
import UniformTypeIdentifiers

@testable import hCore

/// Pure value tests (no DI, no globals), so the suite stays top level and runs in parallel.
@MainActor
final class ImageMetadataTests {
    private static let dateTimeOriginal = "2024:05:17 13:37:00"
    private static let latitude = 59.3293
    private static let latitudeRef = "N"
    private static let make = "Hedvig"

    @Test
    func jpegPreservingMetadataTranscodesHeicKeepingMetadataSuccess() throws {
        let heic = try #require(Self.makeImageData(type: .heic, properties: Self.cameraProperties(orientation: 6)))
        #expect(Self.typeIdentifier(of: heic) == UTType.heic.identifier)

        let jpeg = try #require(heic.jpegPreservingMetadata())

        #expect(Self.typeIdentifier(of: jpeg) == UTType.jpeg.identifier)
        let properties = try #require(Self.properties(of: jpeg))
        Self.expectCameraMetadata(in: properties, orientation: 6)
    }

    @Test
    func jpegPreservingMetadataTranscodesPngKeepingMetadataSuccess() throws {
        let png = try #require(Self.makeImageData(type: .png, properties: Self.cameraProperties(orientation: 3)))
        #expect(Self.typeIdentifier(of: png) == UTType.png.identifier)

        let jpeg = try #require(png.jpegPreservingMetadata())

        #expect(Self.typeIdentifier(of: jpeg) == UTType.jpeg.identifier)
        let properties = try #require(Self.properties(of: jpeg))
        #expect(properties[kCGImagePropertyOrientation as String] as? Int == 3)
        let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        #expect(exif?[kCGImagePropertyExifDateTimeOriginal as String] as? String == Self.dateTimeOriginal)
    }

    @Test
    func jpegPreservingMetadataReturnsJpegUnchangedSuccess() throws {
        let jpeg = try #require(Self.makeImageData(type: .jpeg, properties: Self.cameraProperties(orientation: 6)))

        let result = try #require(jpeg.jpegPreservingMetadata(compressionQuality: 0.1))

        #expect(result == jpeg, "JPEG input must be returned byte-identical, not re-encoded")
    }

    @Test
    func jpegPreservingMetadataNonImageDataFailure() {
        #expect(Data("not an image".utf8).jpegPreservingMetadata() == nil)
        #expect(Data().jpegPreservingMetadata() == nil)
    }

    @Test
    func jpegDataWithMetadataEmbedsMetadataSuccess() throws {
        let cgImage = try #require(Self.makeCGImage())
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        // Metadata says "up"; the UIImage's orientation (.right == 6) must win.
        let metadata = Self.cameraProperties(orientation: 1)

        let jpeg = try #require(image.jpegData(compressionQuality: 0.9, metadata: metadata))

        #expect(Self.typeIdentifier(of: jpeg) == UTType.jpeg.identifier)
        let properties = try #require(Self.properties(of: jpeg))
        Self.expectCameraMetadata(in: properties, orientation: 6)
    }

    @Test
    func jpegDataWithMetadataDerivesOrientationWithoutTiffSuccess() throws {
        let cgImage = try #require(Self.makeCGImage())
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .leftMirrored)
        var metadata = Self.cameraProperties(orientation: 1)
        metadata.removeValue(forKey: kCGImagePropertyTIFFDictionary as String)

        let jpeg = try #require(image.jpegData(compressionQuality: 0.9, metadata: metadata))

        let properties = try #require(Self.properties(of: jpeg))
        #expect(
            properties[kCGImagePropertyOrientation as String] as? UInt32
                == CGImagePropertyOrientation.leftMirrored.rawValue
        )
        let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        #expect(exif?[kCGImagePropertyExifDateTimeOriginal as String] as? String == Self.dateTimeOriginal)
    }

    @Test
    func jpegDataWithNilMetadataFallsBackToPlainJpegSuccess() throws {
        let cgImage = try #require(Self.makeCGImage())
        let image = UIImage(cgImage: cgImage)

        let jpeg = try #require(image.jpegData(compressionQuality: 0.9, metadata: nil))

        #expect(Self.typeIdentifier(of: jpeg) == UTType.jpeg.identifier)
        let properties = try #require(Self.properties(of: jpeg))
        #expect(properties[kCGImagePropertyGPSDictionary as String] == nil)
        let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        #expect(exif?[kCGImagePropertyExifDateTimeOriginal as String] == nil)
    }

    // MARK: - Fixtures

    private static func cameraProperties(orientation: Int) -> [String: Any] {
        [
            kCGImagePropertyOrientation as String: orientation,
            kCGImagePropertyExifDictionary as String: [
                kCGImagePropertyExifDateTimeOriginal as String: dateTimeOriginal
            ],
            kCGImagePropertyGPSDictionary as String: [
                kCGImagePropertyGPSLatitude as String: latitude,
                kCGImagePropertyGPSLatitudeRef as String: latitudeRef,
            ],
            kCGImagePropertyTIFFDictionary as String: [
                kCGImagePropertyTIFFMake as String: make,
                kCGImagePropertyTIFFOrientation as String: orientation,
            ],
        ]
    }

    private static func expectCameraMetadata(in properties: [String: Any], orientation: Int) {
        #expect(properties[kCGImagePropertyOrientation as String] as? Int == orientation)

        let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        #expect(exif?[kCGImagePropertyExifDateTimeOriginal as String] as? String == dateTimeOriginal)

        let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any]
        let gpsLatitude = gps?[kCGImagePropertyGPSLatitude as String] as? Double
        #expect(gpsLatitude.map { abs($0 - latitude) < 0.0001 } == true)
        #expect(gps?[kCGImagePropertyGPSLatitudeRef as String] as? String == latitudeRef)

        let tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
        #expect(tiff?[kCGImagePropertyTIFFMake as String] as? String == make)
        #expect(tiff?[kCGImagePropertyTIFFOrientation as String] as? Int == orientation)
    }

    private static func makeCGImage(width: Int = 32, height: Int = 16) -> CGImage? {
        guard
            let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )
        else { return nil }
        context.setFillColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setFillColor(red: 1, green: 0.5, blue: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width / 2, height: height / 2))
        return context.makeImage()
    }

    private static func makeImageData(type: UTType, properties: [String: Any]) -> Data? {
        guard let cgImage = makeCGImage() else { return nil }
        let output = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(output, type.identifier as CFString, 1, nil)
        else { return nil }
        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }

    private static func typeIdentifier(of data: Data) -> String? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceGetType(source) as String?
    }

    private static func properties(of data: Data) -> [String: Any]? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
    }
}
