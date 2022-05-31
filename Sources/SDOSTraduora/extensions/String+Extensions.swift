//
//  File.swift
//  
//
//  Created by Oleg Tverdyy on 27/5/21.
//

import Foundation

extension String {

    func replaceRegexString() -> String {
        var result = self
        do {
            let regex = try NSRegularExpression(pattern: "\\{\\{(?:\\$\\d+;)string\\}\\}", options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "%@")
        } catch { }
        return result
    }
    
    func replaceRegexNumber() -> String {
        var result = self
        do {
            let regex = try NSRegularExpression(pattern: "\\{\\{(?:\\$\\d+;)number\\}\\}", options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "%ld")
        } catch { }
        return result
    }
    
    func replaceRegexDecimal() -> String {
        var result = self
        do {
            let regex = try NSRegularExpression(pattern: "\\{\\{(?:\\$\\d+;)decimal(?:;(\\d+))?\\}\\}", options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            regex.matches(in: result, options: [], range: range).reversed().forEach { match in
                var floatPoint = ""
                if match.numberOfRanges >= 1 {
                    let substringRange = match.range(at: 0)
                    var replaceText: String = "%f"
                    if match.numberOfRanges >= 2 {
                        let range = match.range(at: 1)
                        if let substring = result.substring(with: range) {
                            floatPoint = substring
                        }
                        
                        if floatPoint.isEmpty {
                            replaceText = "%f"
                        } else {
                            replaceText = "%.\(floatPoint)f"
                        }
                    }
                    if let range = Range(substringRange, in: result) {
                        result = result.replacingCharacters(in: range, with: replaceText)
                    }
                }
            }
        } catch { }
        return result
    }
    
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }
}
