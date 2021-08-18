import Foundation
import WebKit

public class TrustlyWKScriptOpenURLScheme: NSObject, WKScriptMessageHandler {
  public static let NAME = "trustlyOpenURLScheme"
  var webView: WKWebView

  public init(webView: WKWebView) { self.webView = webView }

  public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
    if let parsed = getParsedJSON(object: message.body as AnyObject),
      let callback: String = parsed.object(forKey: "callback") as? String,
      let urlscheme: String = parsed.object(forKey: "urlscheme") as? String,
      let appUrl: URL = NSURL(string: urlscheme) as URL?
    {
      let canOpenApplicationUrl = UIApplication.shared.canOpenURL(appUrl)
      if canOpenApplicationUrl {
        if #available(iOS 10.0, *) {
          UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
        } else {
          UIApplication.shared.openURL(NSURL(string: urlscheme)! as URL)
        }
      }
      let template = "%@(%@,\"%@\");"
      let js = String(format: template, callback, String(canOpenApplicationUrl), urlscheme)
      webView.evaluateJavaScript(js, completionHandler: nil)
    }
  }

  /**
     Helper function that will try to parse AnyObject to JSON and return as NSDictionary
     :param: AnyObject
     :returns: JSON object as NSDictionary if parsing is successful, otherwise nil
     */
  func getParsedJSON(object: AnyObject) -> NSDictionary? {
    do {
      let jsonString: String = object as! String
      let jsonData = jsonString.data(using: String.Encoding.utf8)!
      let parsed =
        try JSONSerialization.jsonObject(
          with: jsonData,
          options: JSONSerialization.ReadingOptions.allowFragments
        ) as! NSDictionary
      return parsed
    } catch let error as NSError { print("A JSON parsing error occurred:\n \(error)") }
    return nil
  }
}
