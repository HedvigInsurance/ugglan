import SwiftUI
import Testing

@testable import Ugglan

/// The logged-out screen keeps its cards and buttons below the logo, drawn over the middle of the screen, unless they
/// need the whole height.
@MainActor
struct NotLoggedInLayoutTests {
    @Test
    func theBottomHalfLeavesRoomAboveTheButtonsAndIsNeverNegative() {
        #expect(NotLoggedInView.bottomHalfHeight(of: 800) == 384)
        #expect(NotLoggedInView.bottomHalfHeight(of: 20) == 0)
    }

    @Test
    func contentUpToTheBottomHalfFitsAndTallerContentDoesNot() {
        #expect(NotLoggedInView.fitsTheBottomHalf(contentHeight: 0, screenHeight: 800))
        #expect(NotLoggedInView.fitsTheBottomHalf(contentHeight: 384, screenHeight: 800))
        #expect(NotLoggedInView.fitsTheBottomHalf(contentHeight: 384.5, screenHeight: 800))
        #expect(!NotLoggedInView.fitsTheBottomHalf(contentHeight: 386, screenHeight: 800))
    }

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
