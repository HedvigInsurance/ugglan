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
    let finishedLoadingSignal: Signal<Void>
    let finishedLoadingCallback = Callbacker<Void>()
    let environment: ApolloEnvironmentConfig
    let threaded: Bool

    init(
        _ pdfUrlString: String? = nil,
        environment: ApolloEnvironmentConfig = ApolloContainer.shared.environment,
        threaded: Bool? = false
    ) {
        pdfUrlStringSignal.value = pdfUrlString
        self.finishedLoadingSignal = finishedLoadingCallback.signal()
        self.environment = environment
        self.threaded = threaded ?? false
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
            
            let imageSize = CGSize(
                width: imageViewSize.width,
                height: imageViewSize.width * (rect.height / rect.width)
            )
            
            imageView.frame.size = imageSize
            
            func render(_ context: CGContext) {
                context.setFillColor(gray: 1, alpha: 0)
                context.fill(CGRect(
                    x: rect.origin.x,
                    y: rect.origin.y,
                    width: imageSize.width,
                    height: imageSize.height
                ))
                context.translateBy(x: 0, y: imageSize.height)
                context.scaleBy(
                    x: imageSize.width / rect.width,
                    y: -(imageSize.height / rect.height)
                )
                
                context.drawPDFPage(page)
            }

            let renderer = UIGraphicsImageRenderer(size: imageSize)
            
            var image = UIImage()
            
            if (self.threaded) {
                DispatchQueue.global(qos: .background).async {
                    image = renderer.image(actions: { context in
                        render(context.cgContext)
                    })
                    DispatchQueue.main.async {
                        imageView.image = image
                        self.finishedLoadingCallback.callAll()
                    }
                }
            } else {
                image = renderer.image(actions: { context in
                    render(context.cgContext)
                })
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

        bag += pdfUrlStringSignal.atOnce().compactMap { $0 }.map(on: .background) { pdfUrlString -> CFData? in
            guard let url = URL(string: "\(self.environment.assetsEndpointURL.absoluteString)\(pdfUrlString)") else {
                return nil
            }

            if let data = try? Disk.retrieve(url.absoluteString, from: .caches, as: Data.self) {
                return data as CFData
            }

            let data = try? Data(contentsOf: url)

            if let data = data {
                try? Disk.save(data, to: .caches, as: url.absoluteString)
                
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
