//
//  RemoteVectorIcon.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Disk
import Flow
import Foundation
import UIKit

struct RemoteVectorIcon {
    let pdfUrlStringSignal = ReadWriteSignal<String?>(nil)
    let environment: ApolloEnvironmentConfig

    init(
        _ pdfUrlString: String? = nil,
        environment: ApolloEnvironmentConfig = ApolloContainer.shared.environment
    ) {
        self.pdfUrlStringSignal.value = pdfUrlString
        self.environment = environment
    }
}

extension RemoteVectorIcon: Viewable {
    func materialize(events _: ViewableEvents) -> (UIImageView, Disposable) {
        let bag = DisposeBag()
        let imageView = UIImageView()

        let pdfDocumentSignal = ReadWriteSignal<CGPDFDocument?>(nil)

        func renderPdfDocument(pdfDocument: CGPDFDocument) {
            let imageViewSize = imageView.frame.size

            if let image = imageView.image {
                if image.size == imageViewSize {
                    return
                }
            }

            let page = pdfDocument.page(at: 1)!
            let rect = page.getBoxRect(CGPDFBox.mediaBox)

            func render(_ context: CGContext) {
                context.setFillColor(gray: 1, alpha: 0)
                context.fill(CGRect(
                    x: rect.origin.x,
                    y: rect.origin.y,
                    width: imageViewSize.width,
                    height: imageViewSize.height
                ))
                context.translateBy(x: 0, y: imageViewSize.height)
                context.scaleBy(
                    x: imageViewSize.width / rect.width, y:
                    -(imageViewSize.height / rect.height)
                )

                context.drawPDFPage(page)
            }

            if #available(iOS 10.0, *) {
                let renderer = UIGraphicsImageRenderer(size: imageViewSize)

                let image = renderer.image(actions: { context in
                    render(context.cgContext)
                })

                imageView.image = image
            } else {
                UIGraphicsBeginImageContext(imageViewSize)

                guard let context = UIGraphicsGetCurrentContext() else { return }

                render(context)

                let image = UIGraphicsGetImageFromCurrentImageContext()

                UIGraphicsEndImageContext()

                imageView.image = image
            }
        }

        bag += imageView.didLayoutSignal
            .withLatestFrom(pdfDocumentSignal.atOnce().plain().compactMap { $0 })
            .onValue { _, pdfDocument in
                renderPdfDocument(pdfDocument: pdfDocument)
            }

        bag += pdfDocumentSignal.compactMap { $0 }.onValue { pdfDocument in
            renderPdfDocument(pdfDocument: pdfDocument)
        }

        bag += pdfUrlStringSignal.atOnce().compactMap { $0 }.map { pdfUrlString -> CFData? in
            guard let url = URL(string: "\(self.environment.assetsEndpointURL.absoluteString)\(pdfUrlString)") else {
                return nil
            }
            
            if let data = try? Disk.retrieve(url.absoluteString, from: .caches, as: Data.self) {
                return data as CFData
            }

            let data = try? Data(contentsOf: url)

            if let data = data {
                defer {
                    try? Disk.save(data, to: .caches, as: url.absoluteString)
                }

                return data as CFData
            }

            return nil
        }.map { data in
            guard let data = data else { return nil }
            guard let provider = CGDataProvider(data: data) else { return nil }
            return CGPDFDocument(provider)
        }.compactMap { $0 }.bindTo(pdfDocumentSignal)

        return (imageView, bag)
    }
}
