//
//  ImageUtils.swift
//  BitmapKeyboardCanvas
//
//  Created by Romas on 01/04/2026.
//

import Foundation

struct ImageUtils {
    static let deleteToken = "[delete]"
    
    static func embedImageInTags(_ imageName: String) -> String {
        return "[img]\(imageName)[/img]";
    }
    
    static func parseTaggedImages(_ taggedText: String) -> [String]
    {
        // Pattern
        let pattern = #"\[img\](.*?)\[/img\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("invalid regex")
            return [];
        }
        
        let matches = regex.matches(in: taggedText, range: NSRange(taggedText.startIndex..., in: taggedText))
        
        return matches.compactMap { match -> String? in
            if let range = Range(match.range(at: 1), in: taggedText) {
                return String(taggedText[range])
            }
            return nil
        }
    }
}
