//
//  FontLoader.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-05-15.
//

import Foundation
import UIKit

class FontLoader {
    static func loadFonts(fontNames: [String]) -> Void {
        let fileManager = FileManager.default
        let bundleURL = Bundle(for: FontLoader.self).bundleURL
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            for url in contents {
                if (fontNames.contains(url.deletingPathExtension().lastPathComponent)) {
                    guard let fontData = NSData(contentsOf: url) else {
                        continue
                    }
                    let provider = CGDataProvider(data: fontData)
                    let font = CGFont(provider!)!
                    CTFontManagerRegisterGraphicsFont(font, nil)
                }
            }
        } catch {
            print("Error loading fonts: \(error)")
        }
    }
}
