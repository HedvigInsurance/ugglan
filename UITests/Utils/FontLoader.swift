//
//  FontLoader.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-05-15.
//

import Foundation
import UIKit

struct FontLoader {    
    static func loadFonts() {
        let fileManager = FileManager.default
        let bundleURL = Bundle(for: AppDelegate.self).bundleURL
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            for url in contents {
                guard let fontData = NSData(contentsOf: url) else {
                    continue
                }
                guard let provider = CGDataProvider(data: fontData) else {
                    continue
                }
                guard let font = CGFont(provider) else {
                    continue
                }
                CTFontManagerRegisterGraphicsFont(font, nil)
            }
        } catch {
            print("Error loading fonts: \(error)")
        }
    }
}
