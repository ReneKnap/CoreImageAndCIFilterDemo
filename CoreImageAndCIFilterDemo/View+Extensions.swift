//
//  View+Extensions.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//
import Foundation
import SwiftUI

extension View {
    func maxFrame() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
