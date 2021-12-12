//
//  HelperViews.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI

struct Headline: View {
    let name: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 24, weight: .light, design: .rounded))
                .padding(.top, 10)
        }
    }
    
    init(_ name: String) {
        self.name = name
    }
}


struct OptionalImage: View {
    let image: CGImage?
    
    var body: some View {
        if let image = image {
            Image(decorative: image, scale: 2);
        } else {
            Image(systemName: "photo")
        }
    }
}


struct Placeholder: View {
    let name: String
    
    var body: some View {
        Color(level: 2)
            .cornerRadius(12)
            .overlay(Text(name))
    }
    
    init(_ name: String) {
        self.name = name
    }
}
