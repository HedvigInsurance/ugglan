import Kingfisher
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    @State var claim: ClaimModel
    @PresentableStore var store: ClaimsStore
    @State var player: AudioPlayer?

    public init(
        claim: ClaimModel
    ) {
        self.claim = claim
        if let signedAudioURL = claim.signedAudioURL {
            _player = State(initialValue: AudioPlayer(url: URL(string: signedAudioURL)))
        }
    }
    
    private var statusParagraph: String {
        claim.statusParagraph
    }
    
    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                ClaimStatus(claim: claim, enableTap: false)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                hSection {
                    hRow {
                        hText(statusParagraph)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                    hRow {
                        ContactChatView(
                            store: self.store,
                            id: self.claim.id,
                            status: self.claim.status.rawValue
                        )
                        .padding(.bottom, 4)
                    }
                }
                
                if let inputText = claim.memberFreeText {
                    hSection {
                        hRow {
                            hText(inputText)
                        }
                    }
                    .withHeader {
                        hText(L10n.ClaimStatusDetail.submittedMessage)
                            .padding(.leading, 2)
                    }
                    .padding(.top, 16)
                }
                
                if claim.showUploadedFiles {
                    hSection {
                        if let player {
                            ClaimDetailFilesView(
                                audioPlayer: player
                            )
                            .onReceive(player.objectWillChange.filter({ $0.playbackState == .finished })) { player in }
                        }
                    }
                    .withHeader {
                        HStack {
                            hText(L10n.ClaimStatusDetail.uploadedFiles)
                                .padding(.leading, 2)
                            Spacer()
                            InfoViewHolder(
                                title: L10n.ClaimStatusDetail.uploadedFilesInfoTitle,
                                description: L10n.ClaimStatusDetail.uploadedFilesInfoDescription
                            )
                        }
                    }
                    .padding(.top, 16)
                    hSection {
                        FilesGridView(files: claim.files, options: [])
                    }
                    .sectionContainerStyle(.transparent)
                }
                
                if claim.canAddFiles {
                    hSection {
                        hButton.LargeButton(type: .primaryAlt) {
                            store.send(.navigation(action: .openFilesFor(claim: claim)))
                        } content: {
                            hText(L10n.ClaimStatusDetail.addMoreFiles)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

struct ClaimDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let claim = ClaimModel(
            id: "claimId",
            status: .beingHandled,
            outcome: .none,
            submittedAt: "2023-11-11",
            closedAt: nil,
            signedAudioURL: "https://filesamples.com/samples/audio/m4a/sample3.m4a",
            type: "associated type",
            memberFreeText: nil,
            payoutAmount: nil,
            files: []
        )
        return ClaimDetailView(claim: claim)
    }
}

