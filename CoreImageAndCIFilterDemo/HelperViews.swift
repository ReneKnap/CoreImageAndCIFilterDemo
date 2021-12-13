//
//  HelperViews.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI

let defaultCornerRadius = CGFloat(12)
let defaultPadding = CGFloat(10)
let minimumTappableLenght = CGFloat(44)

struct Headline: View {
    let name: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .padding(.top, defaultPadding)
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
            .cornerRadius(defaultCornerRadius)
            .overlay(Text(name))
    }
    
    init(_ name: String) {
        self.name = name
    }
}
