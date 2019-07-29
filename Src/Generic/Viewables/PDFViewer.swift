//
//  PDFViewer.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-20.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import PDFKit
import UIKit

struct PDFViewer {
    let url = ReadWriteSignal<URL?>(nil)
    let data: ReadSignal<Data?>

    private let dataReadWriteSignal: ReadWriteSignal<Data?>

    init() {
        dataReadWriteSignal = ReadWriteSignal(nil)
        data = dataReadWriteSignal.readOnly()
    }
}

extension PDFViewer: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let dataFetchSignal = url.atOnce().map(on: .background) { pdfUrl -> Data? in
            guard let pdfUrl = pdfUrl, let pdfData = try? Data(contentsOf: pdfUrl) else { return nil }
            return pdfData
        }

        let bag = DisposeBag()

        bag += dataFetchSignal.bindTo(dataReadWriteSignal)

        let pdfView = PDFView()
        pdfView.backgroundColor = .offWhite
        pdfView.maxScaleFactor = 3
        pdfView.autoScales = true

        // for some reason layouting works with this...
        bag += pdfView.didLayoutSignal.onValue { _ in
        }

        bag += dataFetchSignal.onValue { pdfData in
            guard let pdfData = pdfData else { return }
            pdfView.document = PDFDocument(data: pdfData)
        }

        let loadingView = UIView()
        loadingView.alpha = 1
        loadingView.backgroundColor = .offWhite
        pdfView.addSubview(loadingView)

        loadingView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.style = .gray

        loadingView.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        bag += dataFetchSignal.delay(by: 1).animated(
            style: AnimationStyle.easeOut(duration: 0.5)
        ) { _ in
            loadingView.alpha = 0
        }.onValue { _ in
            loadingView.removeFromSuperview()
        }

        return (pdfView, bag)
    }
}
