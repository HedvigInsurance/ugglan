import Foundation
import SwiftUI
import hCore

struct LoadingViewWithContent: ViewModifier {
    @Binding var isLoading: Bool
    @Binding var error: String?
    var showLoading: Bool = true

    func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            if isLoading && showLoading {
                loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else if let error = error {
                GenericErrorView(
                    description: error,
                    formPosition: .center
                )
                .hStateViewButtonConfig(.init())
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else {
                content.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

struct LoadingViewWithContentForProcessingState: ViewModifier {
    @Binding var state: ProcessingState

    public func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            switch state {
            case .loading:
                loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            case .success:
                content.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            case .error(let errorMessage):
                GenericErrorView(
                    description: errorMessage,
                    formPosition: nil
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

struct LoadingViewWithButtonLoadingForProcessingState: ViewModifier {
    @Binding var state: ProcessingState
    public func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            switch state {
            case .success, .loading:
                content.transition(.opacity.animation(.easeInOut(duration: 0.2))).hButtonIsLoading(state == .loading)
            case .error(let errorMessage):
                GenericErrorView(
                    description: errorMessage,
                    formPosition: nil
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

extension View {
    public func loading(_ isLoading: Binding<Bool>, _ error: Binding<String?>) -> some View {
        modifier(LoadingViewWithContent(isLoading: isLoading, error: error))
    }

    public func loading(_ state: Binding<ProcessingState>) -> some View {
        modifier(LoadingViewWithContentForProcessingState(state: state))
    }

    public func loadingWithButtonLoading(_ state: Binding<ProcessingState>) -> some View {
        modifier(LoadingViewWithButtonLoadingForProcessingState(state: state))
    }
}
