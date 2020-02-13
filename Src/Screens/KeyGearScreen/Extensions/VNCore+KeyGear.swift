//
//  VNCore+KeyGear.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-06.
//

import Foundation
import CoreML
import Vision
import Disk
import Flow
import Apollo

extension AddKeyGearItem {
    private enum Category: String {
        case smartWatch = "SmartWatches",
        watch = "Watches",
        appliance = "Applicances",
        camera = "Camera",
        jewelry = "Jewelry",
        phone = "Phones",
        bicycle = "Bicycle",
        computer = "Computer"
    }
    
    func classifyImage(_ image: UIImage) -> Future<KeyGearItemCategory?> {
        return Future { completion in
            let bag = DisposeBag()
            
            bag += VNCoreMLModel.keyGearClassifier.onValue { model in
                let delegate = Delegate<Either<VNRequest, Error>, Void>()
                let request = VNCoreMLRequest(model: model, delegate: delegate)
                
                bag += delegate.set({ result in
                    let classifications = result.left?.results as! [VNClassificationObservation]
                    if let classification = classifications.first {
                        if classification.confidence > 0.9 {
                            guard let category = Category(rawValue: classification.identifier) else {
                                completion(.success(nil))
                                return
                            }
                            
                            switch category {
                            case .smartWatch:
                                completion(.success(KeyGearItemCategory.jewelry))
                            case .watch:
                                completion(.success(KeyGearItemCategory.jewelry))
                            case .appliance:
                                completion(.success(nil))
                            case .camera:
                                completion(.success(nil))
                            case .phone:
                                completion(.success(KeyGearItemCategory.phone))
                            case .bicycle:
                                completion(.success(nil))
                            case .computer:
                                completion(.success(KeyGearItemCategory.computer))
                            case .jewelry:
                                completion(.success(KeyGearItemCategory.jewelry))
                            }
                        } else {
                            completion(.success(nil))
                        }
                    }
                })
                
                request.imageCropAndScaleOption = .centerCrop
                
                func process(request: VNCoreMLRequest, image: UIImage) {
                    guard let ciImage = CIImage(image: image) else {
                        return
                    }
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
                        try? handler.perform([request])
                    }
                }
                                   
                process(request: request, image: image)
            }
        
            return bag
        }
    }
}

extension VNCoreMLModel {
    enum KeyGearClassifierError: Error {
        case compileModel, convertModel, downloadModel, createVNModel
    }
    
    static var keyGearClassifier: Future<VNCoreMLModel> {
        let client: ApolloClient = Dependencies.shared.resolve()
        let bag = DisposeBag()
        
        return Future { completion in
            func downloadModel(_ url: URL) {
                let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
                    guard let location = location else {
                        completion(.failure(KeyGearClassifierError.downloadModel))
                        return
                    }
                    guard let compiledUrl = try? MLModel.compileModel(at: location) else {
                        completion(.failure(KeyGearClassifierError.compileModel))
                        return
                    }
                     

                    guard let model = try? MLModel(contentsOf: compiledUrl) else {
                        completion(.failure(KeyGearClassifierError.convertModel))
                        return
                    }
                    
                                      
                    guard let vnModel = try? VNCoreMLModel(for: model) else {
                        completion(.failure(KeyGearClassifierError.createVNModel))
                        return
                    }
                     
                    completion(.success(vnModel))
                }
                
                task.resume()
            }
            
            bag += client.fetch(query: KeyGearClassifierQuery()).map { result in result.data?.coreMlModels.first??.file?.url }.valueSignal.compactMap { url in URL(string: url) }.onValue { url in
                downloadModel(url)
            }
            
            
            return bag
        }
    }
}

extension VNCoreMLRequest {
    convenience init(model: VNCoreMLModel, delegate: Delegate<Either<VNRequest, Error>, Void>) {
        self.init(model: model) { (request, error) in
            guard let error = error else {
                delegate.call(.left(request))
                return
            }
            
            delegate.call(.right(error))
        }
    }
}
