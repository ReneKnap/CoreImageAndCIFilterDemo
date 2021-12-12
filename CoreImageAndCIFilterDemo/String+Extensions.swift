//
//  String+Extensions.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import UIKit

extension String {
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + " " + String($1))
            }
            else {
                return $0 + String($1)
            }
        }
    }
    
    func removeFirst(_ count: Int) -> String {
        if self.count > count {
            return String(self.dropFirst(count))
        }
        return self
    }
}
