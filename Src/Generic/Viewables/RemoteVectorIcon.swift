//
//  RemoteVectorIcon.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Apollo
import Disk
import Flow
import Foundation
import UIKit

struct RemoteVectorIcon {
    let iconSignal = ReadWriteSignal<IconFragment?>(nil)
    let finishedLoadingSignal: Signal<Void>
    let finishedLoadingCallback = Callbacker<Void>()
    @Inject var environment: ApolloEnvironmentConfig
    let threaded: Bool

    init(
        _ icon: IconFragment? = nil,
        threaded: Bool? = false
    ) {
        iconSignal.value = icon
        finishedLoadingSignal = finishedLoadingCallback.signal()
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
            let image = renderer.image(actions: { context in
                render(context.cgContext)
            })
            
            DispatchQueue.main.async {
                imageView.image = image
            }
            
            finishedLoadingCallback.callAll()
        }

        bag += imageView.didLayoutSignal.map { return imageView.bounds.size }.filter { $0.width != 0 && $0.height != 0 }.distinct()
            .withLatestFrom(pdfDocumentSignal.atOnce().plain().compactMap { $0 })
            .onValue { _, pdfDocument in
                renderPdfDocument(pdfDocument: pdfDocument)
            }

        bag += pdfDocumentSignal.compactMap { $0 }.onValue { pdfDocument in
            renderPdfDocument(pdfDocument: pdfDocument)
        }

        bag += combineLatest(
            iconSignal.atOnce(),
            imageView.traitCollectionSignal.atOnce()
        ).compactMap { iconFragment, traitCollection -> String? in
            if traitCollection.userInterfaceStyle == .dark {
                return iconFragment?.variants.dark.pdfUrl
            }

            return iconFragment?.variants.light.pdfUrl
        }.map(on: .background) { pdfUrlString -> CFData? in
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
        }.map(on: threaded ? .background : .main) { data in
            guard let data = data else { return nil }
            guard let provider = CGDataProvider(data: data) else { return nil }
            return CGPDFDocument(provider)
        }.compactMap { $0 }.bindTo(pdfDocumentSignal)

        return (imageView, bag)
    }
}
