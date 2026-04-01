//
//  SharedTemporaryImageStorage.swift
//  BitmapKeyboardCanvas
//
//  Created by Romas on 01/04/2026.
//

import Foundation

class SharedTemporaryImageStorage {
    
    static var shared: SharedTemporaryImageStorage = {
        let instance = SharedTemporaryImageStorage()
        return instance
    }()
    
    private init() {}
    
    private let suite = UserDefaults(suiteName: "group.com.romas.bitmapkeyboard")!
    private var currentKeyIndex = 0
    
    func append(imagePngData: Data) -> String {
        let key = "imagePngDataKey\(currentKeyIndex)"
        currentKeyIndex += 1
        suite.set(imagePngData, forKey: key)
        return key
    }

    func getImagePngData(forKey key: String) -> Data? {
        guard let pngData = suite.data(forKey: key) else {
            return nil
        }
        
        suite.set(nil, forKey: key)
        
        return pngData
    }
}
