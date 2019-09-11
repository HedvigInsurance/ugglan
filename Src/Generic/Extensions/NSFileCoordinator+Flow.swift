//
//  NSFileCoordinator+Flow.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-09-11.
//

import Foundation
import Flow

extension NSFileCoordinator {
    enum CoordinatorError: Error {
        case failureConvertingToData
    }
    
    func coordinate(readingItemAt: URL, options: NSFileCoordinator.ReadingOptions) -> Future<Data> {
        Future { completion in
            let errorPointer = NSErrorPointer(nilLiteral: ())
            
            self.coordinate(readingItemAt: readingItemAt, options: options, error: errorPointer) { url in
                
                if let data = try? Data(contentsOf: url) {
                    completion(.success(data))
                } else {
                    completion(.failure(CoordinatorError.failureConvertingToData))
                }
            }
            
            if let error = errorPointer?.pointee {
                print(error)
            }
            
            return NilDisposer()
        }
    }
}
