import Flow
import Form
import Foundation
import PDFKit
import UIKit
import hCore

public struct PDFViewer {
  public let url = ReadWriteSignal<URL?>(nil)
  public let data: ReadSignal<Data?>

  private let dataReadWriteSignal: ReadWriteSignal<Data?>

  public init() {
    dataReadWriteSignal = ReadWriteSignal(nil)
    data = dataReadWriteSignal.readOnly()
  }
}

extension PDFViewer: Viewable {
  public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
    let dataFetchSignal = url.atOnce()
      .map(on: .background) { pdfUrl -> Data? in
        guard let pdfUrl = pdfUrl, let pdfData = try? Data(contentsOf: pdfUrl) else {
          return nil
        }
        return pdfData
      }

    let bag = DisposeBag()

    bag += dataFetchSignal.bindTo(dataReadWriteSignal)

    let pdfView = PDFView()
    pdfView.backgroundColor = .brand(.primaryBackground())
    pdfView.maxScaleFactor = 3
    pdfView.autoScales = true

    // for some reason layouting works with this...
    bag += pdfView.didLayoutSignal.onValue { _ in }

    bag += dataFetchSignal.onValue { pdfData in guard let pdfData = pdfData else { return }
      pdfView.document = PDFDocument(data: pdfData)
    }

    let loadingView = UIView()
    loadingView.alpha = 1
    loadingView.backgroundColor = .brand(.primaryBackground())
    pdfView.addSubview(loadingView)

    loadingView.snp.makeConstraints { make in make.width.equalToSuperview()
      make.height.equalToSuperview()
      make.center.equalToSuperview()
    }

    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.startAnimating()
    activityIndicator.tintColor = .brand(.primaryTintColor)

    loadingView.addSubview(activityIndicator)

    activityIndicator.snp.makeConstraints { make in make.center.equalToSuperview() }

    bag += dataFetchSignal.delay(by: 1)
      .animated(style: AnimationStyle.easeOut(duration: 0.5)) { _ in loadingView.alpha = 0 }
      .onValue { _ in loadingView.removeFromSuperview() }

    return (pdfView, bag)
  }
}
