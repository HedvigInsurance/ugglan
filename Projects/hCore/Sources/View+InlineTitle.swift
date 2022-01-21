import Presentation

extension JourneyPresentation {
    public func inlineTitle() -> some JourneyPresentation {
        return self.addConfiguration { presenter in
            presenter.viewController.navigationItem.largeTitleDisplayMode = .never
        }
    }
}
