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
import Kingfisher

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

struct PDFProcessor: ImageProcessor {
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            let pdfData = data as CFData
            guard let provider:CGDataProvider = CGDataProvider(data: pdfData) else {return nil}
            guard let pdfDoc:CGPDFDocument = CGPDFDocument(provider) else {return nil}
            guard let pdfPage:CGPDFPage = pdfDoc.page(at: 1) else {return nil}
            var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
            pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
            UIGraphicsBeginImageContextWithOptions(pageRect.size, false, UIScreen.main.scale)
            guard let context:CGContext = UIGraphicsGetCurrentContext()  else {return nil}
            context.saveGState()
            context.translateBy(x: 0.0, y: pageRect.size.height)
            context.scaleBy(x: 1, y: -1)
            context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect:  pageRect, rotate: 0, preserveAspectRatio: true))
            context.drawPDFPage(pdfPage)
            context.restoreGState()
            let pdfImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return pdfImage
        }
    }
    
    let identifier = "com.hedvig.kingfisher.pdf"
}

extension RemoteVectorIcon: Viewable {
    func materialize(events _: ViewableEvents) -> (UIImageView, Disposable) {
        let bag = DisposeBag()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        let processor = PDFProcessor()

        bag += combineLatest(
            iconSignal.atOnce(),
            imageView.traitCollectionSignal.atOnce()
        ).compactMap { iconFragment, traitCollection -> String? in
            if traitCollection.userInterfaceStyle == .dark {
                return iconFragment?.variants.dark.pdfUrl
            }

            return iconFragment?.variants.light.pdfUrl
        }.onValue { pdfUrlString in
            guard let url = URL(string: "\(self.environment.assetsEndpointURL.absoluteString)\(pdfUrlString)") else {
                return
            }
                        
            imageView.kf.setImage(with: url, options: [.processor(processor), .transition(.fade(0.25))], completionHandler: { _ in
                self.finishedLoadingCallback.callAll()
            })
        }

        return (imageView, bag)
    }
}
