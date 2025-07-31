import SwiftUI
import hCore
//
//  SubmitClaimErrorWrapper.swift
//  Claims
//
//  Created by Sladan Nimcevic on 2024-11-19.
//  Copyright © 2024 Hedvig. All rights reserved.
//
import hCoreUI

private struct ClaimErrorTrackerModifier: ViewModifier {
    @Binding var processingState: ProcessingState
    @EnvironmentObject var router: Router
    func body(content: Content) -> some View {
        content.trackErrorState(for: $processingState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            processingState = .success
                        }),
                    dismissButton: .init(
                        buttonTitle: L10n.openChat,
                        buttonAction: {
                            router.dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                            }
                        }
                    )
                )
            )
    }
}

private struct ClaimErrorTrackerModifierForString: ViewModifier {
    @Binding var error: String?
    @State private var processingState = ProcessingState.success
    @EnvironmentObject var router: Router
    func body(content: Content) -> some View {
        content.claimErrorTrackerForState($processingState)
            .onAppear {
                processingState = {
                    if let error {
                        return .error(errorMessage: error)
                    }
                    return .success
                }()
            }
            .onChange(of: error) { _ in
                processingState = {
                    if let error {
                        return .error(errorMessage: error)
                    }
                    return .success
                }()
            }
    }
}

extension View {
    func claimErrorTrackerForState(_ state: Binding<ProcessingState>) -> some View {
        modifier(ClaimErrorTrackerModifier(processingState: state))
    }

    func claimErrorTracker(for error: Binding<String?>) -> some View {
        modifier(ClaimErrorTrackerModifierForString(error: error))
    }
}
