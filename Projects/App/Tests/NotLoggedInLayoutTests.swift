import SwiftUI
import Testing

@testable import Ugglan

@MainActor
struct NotLoggedInLayoutTests {
    @Test
    func portraitAtANormalTextSizeNeedsTheWholeHeightOnlyWhenTheContentDoesNotFit() {
        #expect(
            !NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .regular,
                dynamicTypeSize: .large,
                contentFitsTheBottomHalf: true
            )
        )
        #expect(
            NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .regular,
                dynamicTypeSize: .large,
                contentFitsTheBottomHalf: false
            )
        )
    }

    @Test
    func landscapeAndAccessibilitySizesNeedTheWholeHeightEvenWhenTheContentFits() {
        #expect(
            NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .compact,
                dynamicTypeSize: .large,
                contentFitsTheBottomHalf: true
            )
        )
        #expect(
            NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .regular,
                dynamicTypeSize: .accessibility1,
                contentFitsTheBottomHalf: true
            )
        )
    }
}
