//
//  String+Extensions.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import Foundation
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

extension UIImage {
    convenience init(fromColor color: UIColor){
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        let renderer = UIGraphicsImageRenderer(bounds: rect)

        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fill(rect)
        }
        self.init(cgImage: img.cgImage!)
    }
}

