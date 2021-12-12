//
//  Color+Extensions.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//
import Foundation
import SwiftUI

extension Color {
    init(level: Int) {
        let value = 0.1 * Double(level)
        self.init(uiColor: UIColor.init(white: value, alpha: 1))
    }
}
