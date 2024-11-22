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
                    description: error
                )
                .hErrorViewButtonConfig(.init())
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
    var showLoading: Bool

    public func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            switch state {
            case .loading:
                if showLoading {
                    loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            case .success:
                content.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            case .error(let errorMessage):
                GenericErrorView(
                    description: errorMessage
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

struct LoadingViewForButtonForProcessingState: ViewModifier {
    @Binding var state: ProcessingState
    public func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            switch state {
            case .success, .loading:
                content.transition(.opacity.animation(.easeInOut(duration: 0.2))).hButtonIsLoading(state == .loading)
            case .error(let errorMessage):
                GenericErrorView(
                    description: errorMessage
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

    public func loading(_ state: Binding<ProcessingState>, showLoading: Bool? = true) -> some View {
        modifier(LoadingViewWithContentForProcessingState(state: state, showLoading: showLoading ?? true))
    }

    public func loadingButtonWithErrorHandling(_ state: Binding<ProcessingState>) -> some View {
        modifier(LoadingViewForButtonForProcessingState(state: state))
    }
}
