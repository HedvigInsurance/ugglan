//
//  AttachFilePane.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-30.
//

import Flow
import Foundation
import UIKit
import Form
import Photos
import Apollo

struct AttachFilePane {
    let isOpenSignal: ReadWriteSignal<Bool>
    let currentMessageSignal: ReadSignal<Message?>
    let client: ApolloClient
    
    init(
        isOpenSignal: ReadWriteSignal<Bool>,
        currentMessageSignal: ReadSignal<Message?>,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.isOpenSignal = isOpenSignal
        self.currentMessageSignal = currentMessageSignal
        self.client = client
    }
}

struct AttachFileAsset: Reusable {
    let asset: PHAsset
    let type: AssetType
    let uploadFileDelegate = Delegate<Data, Signal<Bool>>()
    
    enum AssetType {
        case image, video
    }
    
    init(
        asset: PHAsset,
        type: AssetType
    ) {
        self.asset = asset
        self.type = type
    }
    
    static func makeAndConfigure() -> (make: UIView, configure: (AttachFileAsset) -> Disposable) {
        let view = UIControl()
        view.backgroundColor = .transparent
        
        return (view, { `self` in
            let bag = DisposeBag()
            let sendOverlayBag = bag.innerBag()
            
            bag += view.signal(for: .touchUpInside).onValue { _ in
                if !sendOverlayBag.isEmpty {
                    sendOverlayBag.dispose()
                    return
                }
                
                let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                effectView.layer.cornerRadius = 5
                effectView.clipsToBounds = true
                effectView.alpha = 0
                view.addSubview(effectView)
                
                let hideOverlayControl = UIControl()
                effectView.contentView.addSubview(hideOverlayControl)
                
                sendOverlayBag += hideOverlayControl.signal(for: .touchUpInside).onValue { _ in
                    sendOverlayBag.dispose()
                }
                
                hideOverlayControl.snp.makeConstraints { make in
                    make.width.height.centerX.centerY.equalToSuperview()
                }
                
                let button = Button(title: String(key: .CHAT_UPLOAD_PRESEND), type: .standard(backgroundColor: .turquoise, textColor: .white))
                let loadableButton = LoadableButton(button: button, initialLoadingState: false)
                
                sendOverlayBag += loadableButton.onTapSignal.onValue { _ in
                    loadableButton.isLoadingSignal.value = true
                    
                    PHImageManager.default().requestImageData(for: self.asset, options: nil) { (data, _, _, _) in
                        guard let data = data else { return }
                        bag += self.uploadFileDelegate.call(data)?.onValue({ result in
                            loadableButton.isLoadingSignal.value = false
                            sendOverlayBag.dispose()
                        })
                    }
                }
                
                bag += hideOverlayControl.add(loadableButton) { buttonView in
                    buttonView.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                    }
                    
                    buttonView.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)
                    
                    sendOverlayBag += Signal(after: 0).animated(style: .mediumBounce()) { _ in
                        buttonView.transform = CGAffineTransform.identity
                    }
                    
                    sendOverlayBag += {
                        bag += Signal(after: 0).animated(style: .mediumBounce()) { _ in
                            buttonView.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)
                        }
                    }
                }
                
                effectView.snp.makeConstraints { make in
                    make.width.height.centerX.centerY.equalToSuperview()
                }
                
                sendOverlayBag += Signal(after: 0).animated(style: .easeOut(duration: 0.25)) { _ in
                    effectView.alpha = 1
                }
                
                sendOverlayBag += {
                    bag += Signal(after: 0).animated(style: .easeOut(duration: 0.25)) { _ in
                        effectView.alpha = 0
                    }.onValue { _ in
                        effectView.removeFromSuperview()
                    }
                }
            }
            
            PHImageManager.default().requestImage(for: self.asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil) { (image, _) in
                guard let image = image else {
                    return
                }
                
                let imageView = UIImageView()
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 5
                imageView.contentMode = .scaleAspectFill
                imageView.alpha = 0
                imageView.image = image
                view.addSubview(imageView)
                
                bag += {
                    imageView.removeFromSuperview()
                }
                
                imageView.snp.makeConstraints { make in
                    make.width.height.equalToSuperview()
                }
                
                bag += Signal(after: 0).animated(style: .easeOut(duration: 0.25)) { _ in
                    imageView.alpha = 1
                }
            }
            
            return bag
        })
    }
}

typealias AttachFilePaneData = Either<AttachFileAsset, ImageLibraryButton>

extension AttachFilePane: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.insetsLayoutMarginsFromSafeArea = true

        bag += isOpenSignal.atOnce().map { !$0 }.animated(style: SpringAnimationStyle.lightBounce(), animations: { isHidden in
            view.animationSafeIsHidden = isHidden
            view.layoutSuperviewsIfNeeded()
        })

        view.backgroundColor = .purple
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        
        let collectionKit = CollectionKit<EmptySection, AttachFilePaneData>(table: Table.init(rows: []), layout: layout)
        bag.hold(collectionKit)
        
        bag += collectionKit.delegate.sizeForItemAt.set { index -> CGSize in
            let item = collectionKit.table[index]
            
            if item.left != nil {
                let height = collectionKit.view.frame.height
                return CGSize(width: height, height: height)
            }
            
            let height = collectionKit.view.frame.height
            return CGSize(width: height / 2 - 10, height: height / 2 - 10)
        }
        
        bag += collectionKit.dataSource.supplementaryElement(for: UICollectionView.elementKindSectionHeader).set { index -> UICollectionReusableView in
            guard let indexPath = IndexPath(index, in: collectionKit.table) else {
                return UICollectionReusableView()
            }
            let view = collectionKit.view.dequeueSupplementaryView(forItem: ImageLibraryButton(), kind: UICollectionView.elementKindSectionHeader, at: indexPath)
            return view
        }
                
        collectionKit.view.backgroundColor = .transparent
                
        view.addArrangedSubview(collectionKit.view)
        
        collectionKit.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints({ make in
                make.width.equalToSuperview()
                make.height.equalTo(300)
            })
        }
        
        bag += collectionKit.onValueDisposePrevious { table in
            return DisposeBag(table.compactMap { $0.left }.map { asset -> Disposable in
                asset.uploadFileDelegate.set { data -> Signal<Bool> in
                    let file = GraphQLFile(
                        fieldName: "file",
                        originalName: "image.jpg",
                        mimeType: "image/jpeg",
                        data: data
                    )
                    
                    return Signal<Bool> { callbacker in
                        self.client.upload(
                            operation: UploadFileMutation(file: "image"),
                            files: [file],
                            queue: DispatchQueue.global(qos: .background)
                        ).onValue { result in
                            guard let key = result.data?.uploadFile.key else {
                                return
                            }
                            guard let globalID = self.currentMessageSignal.value?.globalId else {
                                return
                            }
                            
                            bag += self.client.perform(
                                mutation: SendChatFileResponseMutation(globalID: globalID, key: key, mimeType: "image/jpeg")
                            ).disposable
                            
                            callbacker(true)
                            self.isOpenSignal.value = false
                        }.disposable
                    }
                }
            })
        }
        
        bag += isOpenSignal.atOnce().filter { $0 }.onValue { _ in
            PHPhotoLibrary.requestAuthorization { authorization in
                var finalArray: [AttachFilePaneData] = [
                    
                ]
                
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                
                assets.enumerateObjects { (asset, count, _) in
                    finalArray.append(.make(AttachFileAsset(asset: asset, type: .image)))
                }
                
                DispatchQueue.main.async {
                    collectionKit.table = Table(rows: finalArray)
                }
            }
        }

        return (view, bag)
    }
}
