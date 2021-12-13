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
//        .background(Color.red.opacity(0.3))
//        .cornerRadius(20)
    }
}


struct FaceV: View {
    let bounds: CGRect
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(Color.blue)
            .frame(width: bounds.width, height: bounds.height)
//            .position(x: bounds.minX + (bounds.width / 2), y: bounds.minY + (bounds.height / 2))
            .position(x: bounds.minX, y: bounds.minY)
    }
}

struct EyeV: View {
    let bounds: CGRect
    
    var body: some View {
        Circle()
            .stroke(Color.green)
            .frame(width: bounds.width, height: bounds.height)
//            .position(x: bounds.minX + (bounds.width/2), y: bounds.minY + (bounds.height/2))
            .position(x: bounds.minX, y: bounds.minY)
    }
}

