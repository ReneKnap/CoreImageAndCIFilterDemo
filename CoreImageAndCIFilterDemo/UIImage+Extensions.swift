//
//  UIImage+Extension.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import UIKit

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
