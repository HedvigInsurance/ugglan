import Apollo
import DatadogInternal
import DatadogRUM
import UIKit

struct RUMViewsPredicate: UIKitRUMViewsPredicate {
    let filteredViewControllerClasses: [UIViewController.Type] = [
        UINavigationController.self,
        UITabBarController.self,
        UISplitViewController.self,
        PlaceholderViewController.self,
    ]

    func rumView(for viewController: UIViewController) -> RUMView? {
        guard
            !filteredViewControllerClasses.contains(where: { viewControllerClass in
                viewControllerClass == type(of: viewController)
            }), let name = viewController.debugPresentationTitle
        else {
            return nil
        }

        var view = RUMView(name: name)
        view.path = name
        return view
    }
}

struct RUMUserActionsPredicate: UIKitRUMActionsPredicate {
    func rumAction(targetView: UIView) -> RUMAction? {
        if let derivedFromL10N = targetView.accessibilityLabel?.derivedFromL10n {
            return .init(name: derivedFromL10N.key)
        }

        return nil
    }
}

class InterceptingURLSessionClient: URLSessionClient {
    override func sendRequest(
        _ request: URLRequest,
        rawTaskCompletionHandler: URLSessionClient.RawCompletion? = nil,
        completion: @escaping URLSessionClient.Completion
    ) -> URLSessionTask {
        guard let instrumentedRequest = URLSessionInterceptor.shared()?.intercept(request: request) else {
            return super
                .sendRequest(request, rawTaskCompletionHandler: rawTaskCompletionHandler, completion: completion)
        }

        let task = super
            .sendRequest(
                instrumentedRequest,
                rawTaskCompletionHandler: rawTaskCompletionHandler,
                completion: completion
            )
        URLSessionInterceptor.shared()?.intercept(task: task)

        return task
    }

    override func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {

        URLSessionInterceptor.shared()?.task(task, didFinishCollecting: metrics)
        super.urlSession(session, task: task, didFinishCollecting: metrics)
    }

    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        URLSessionInterceptor.shared()?.task(task, didCompleteWithError: error)
        super.urlSession(session, task: task, didCompleteWithError: error)
    }

    override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        URLSessionInterceptor.shared()?.task(dataTask, didReceive: data)
        super.urlSession(session, dataTask: dataTask, didReceive: data)
    }
}
