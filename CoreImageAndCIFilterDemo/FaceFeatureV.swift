//
//  FaceFeatureV.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 13.12.21.
//

import SwiftUI

struct FaceFeatureV: View {
    let features: [FaceFeature]

    var body: some View {
        ZStack {
            ForEach(features) { feature in
                FaceV(bounds: feature.face)
                
                ForEach(0..<feature.eyes.count) { index in
                    EyeV(bounds: feature.eyes[index])
                }
            }
        }
    }
}


struct FaceV: View {
    let bounds: CGRect
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(Color.blue, lineWidth: 5)
            .frame(width: bounds.width, height: bounds.height)
            .position(x: bounds.minX + (bounds.width / 2), y: bounds.minY + (-bounds.height / 2))
    }
}

struct EyeV: View {
    let bounds: CGRect
    
    var body: some View {
        Circle()
            .stroke(Color.green, lineWidth: 5)
            .frame(width: bounds.width, height: bounds.height)
            .position(x: bounds.minX, y: bounds.minY)
    }
}

