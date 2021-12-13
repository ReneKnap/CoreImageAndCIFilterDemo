//
//  FaceMarker.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 13.12.21.
//

import Foundation
import CoreImage
import UIKit

struct FaceFeature: Identifiable {
    let id = UUID().uuidString
    let face: CGRect
    let eyes: [CGRect]
}
