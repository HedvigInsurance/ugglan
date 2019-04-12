//
//  RemoteVectorIcon.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Foundation
import Flow
import UIKit

struct RemoteVectorIcon {
    let pdfUrl = ReadWriteSignal<URL?>(nil)
    
    init(_ pdfUrl: URL? = nil) {
        self.pdfUrl.value = pdfUrl
    }
}

extension RemoteVectorIcon: Viewable {
    func materialize(events: ViewableEvents) -> (UIImageView, Disposable) {
        let bag = DisposeBag()
        let imageView = UIImageView()
        
        let pdfDocumentSignal = ReadWriteSignal<CGPDFDocument?>(nil)
        
        bag += imageView.didLayoutSignal
            .withLatestFrom(pdfDocumentSignal.atOnce().plain().compactMap { $0 })
            .onValue { _, pdfDocument in
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
        
        bag += pdfUrl.atOnce().compactMap { $0 }.map { url in
            let data = try? Data(contentsOf: url)
            return CGPDFDocument(CGDataProvider(data: data! as CFData)!)!
        }.bindTo(pdfDocumentSignal)
        
        return (imageView, bag)
    }
}
