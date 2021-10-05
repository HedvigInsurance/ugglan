import Apollo
import Disk
import Flow
import Foundation
import UIKit
import hCore
import hGraphQL
import SwiftUI

public struct RemoteVectorIcon {
    let iconSignal = ReadWriteSignal<IconEnvelope?>(nil)
    let finishedLoadingSignal: Signal<Void>
    let finishedLoadingCallback = Callbacker<Void>()
    let threaded: Bool

    public init(
        _ icon: GraphQL.IconFragment? = nil,
        threaded: Bool? = false
    ) {
        let hIcon = IconEnvelope(fragment: icon)
        iconSignal.value = hIcon
        finishedLoadingSignal = finishedLoadingCallback.providedSignal
        self.threaded = threaded ?? false
    }

    public init(
        _ icon: IconEnvelope?,
        threaded: Bool? = false
    ) {
        iconSignal.value = icon
        finishedLoadingSignal = finishedLoadingCallback.providedSignal
        self.threaded = threaded ?? false
    }
}

extension RemoteVectorIcon: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIImageView, Disposable) {
        let bag = DisposeBag()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0

        let pdfDocumentSignal = ReadWriteSignal<CGPDFDocument?>(nil)

        func renderPdfDocument(pdfDocument: CGPDFDocument) {
            let imageViewSize = imageView.frame.size

            if let image = imageView.image { if image.size == imageViewSize { return } }

            let page = pdfDocument.page(at: 1)!
            let rect = page.getBoxRect(CGPDFBox.mediaBox)

            let imageSize = CGSize(
                width: imageViewSize.width,
                height: imageViewSize.width * (rect.height / rect.width)
            )

            imageView.frame.size = imageSize

            func render(_ context: CGContext) {
                context.setFillColor(gray: 1, alpha: 0)
                context.fill(
                    CGRect(
                        x: rect.origin.x,
                        y: rect.origin.y,
                        width: imageSize.width,
                        height: imageSize.height
                    )
                )
                context.translateBy(x: 0, y: imageSize.height)
                context.scaleBy(x: imageSize.width / rect.width, y: -(imageSize.height / rect.height))
                context.drawPDFPage(page)
            }

            let renderer = UIGraphicsImageRenderer(size: imageSize)
            let image = renderer.image(actions: { context in render(context.cgContext) })

            DispatchQueue.main.async {
                imageView.image = image

                UIView.animate(withDuration: 0.25) { imageView.alpha = 1 }
            }

            finishedLoadingCallback.callAll()
        }

        bag += imageView.didLayoutSignal.map { imageView.bounds.size }
            .filter { $0.width != 0 && $0.height != 0 }.distinct()
            .withLatestFrom(pdfDocumentSignal.atOnce().plain().compactMap { $0 })
            .onValue { _, pdfDocument in renderPdfDocument(pdfDocument: pdfDocument) }

        bag += pdfDocumentSignal.compactMap { $0 }
            .onValue { pdfDocument in renderPdfDocument(pdfDocument: pdfDocument) }

        bag += combineLatest(iconSignal.atOnce(), imageView.traitCollectionSignal.atOnce())
            .compactMap { icon, traitCollection -> String? in
                if traitCollection.userInterfaceStyle == .dark {
                    return icon?.dark
                }

                return icon?.light
            }
            .map(on: .background) { pdfUrlString -> CFData? in
                var pdfURL: URL? {
                    if let url = URL(
                        string: pdfUrlString
                    ), url.host != nil {
                        return url
                    }

                    return URL(
                        string:
                            "\(Environment.current.assetsEndpointURL.absoluteString)\(pdfUrlString)"
                    )
                }

                guard let url = pdfURL else { return nil }

                if let data = try? Disk.retrieve(url.absoluteString, from: .caches, as: Data.self) {
                    DispatchQueue.main.async { imageView.alpha = 1 }
                    return data as CFData
                }

                let data = try? Data(contentsOf: url)

                if let data = data {
                    try? Disk.save(data, to: .caches, as: url.absoluteString)

                    return data as CFData
                }

                return nil
            }
            .map(on: threaded ? .background : .main) { data in guard let data = data else { return nil }
                guard let provider = CGDataProvider(data: data) else { return nil }
                return CGPDFDocument(provider)
            }
            .compactMap { $0 }.bindTo(pdfDocumentSignal)

        return (imageView, bag)
    }
}

public struct RemoteVectorIconView: UIViewRepresentable {
    var icon: IconEnvelope
    let backgroundFetch: Bool
    
    public init(icon: IconEnvelope, backgroundFetch: Bool) {
        self.icon = icon
        self.backgroundFetch = backgroundFetch
    }
    
    public class Coordinator {
        let remoteVectorIcon: RemoteVectorIcon
        let bag = DisposeBag()
        
        init(icon: IconEnvelope?, threaded: Bool) {
            remoteVectorIcon = RemoteVectorIcon(icon, threaded: threaded)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(icon: icon, threaded: backgroundFetch)
    }
    
    public func makeUIView(context: Context) -> some UIView {
        let (view, disposable) = context.coordinator.remoteVectorIcon.materialize(events: .init(wasAddedCallbacker: .init()))
        context.coordinator.bag += disposable
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.remoteVectorIcon.iconSignal.value = icon
    }
}

extension RemoteVectorIcon {
    public func alignedTo(
        _: UIStackView.Alignment,
        configure: @escaping (_ matter: Self.Matter) -> Void = { _ in }
    ) -> ContainerStackViewable<
        ContainerStackViewable<RemoteVectorIcon, UIImageView, UIStackView>, UIStackView, UIStackView
    > {
        wrappedIn(
            {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .leading
                stackView.distribution = .equalSpacing
                return stackView
            }(),
            configure: { iconView in configure(iconView) }
        )
        .wrappedIn(
            {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.distribution = .equalSpacing
                stackView.alignment = .leading
                return stackView
            }()
        )
    }
}
