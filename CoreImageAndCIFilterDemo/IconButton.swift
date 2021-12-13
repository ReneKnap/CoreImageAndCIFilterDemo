//
//  IconButton.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 13.12.21.
//

import SwiftUI

struct IconButton: View {
    let systemName: String
    let yOffset: Double
    let backgroundColor: Color
    let onPress: ()->()
    
    var body: some View {
        Button {
            onPress()
        } label: {
            Image(systemName: systemName)
                .offset(y: yOffset)
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .cornerRadius(defaultCornerRadius)
                .contentShape(Rectangle())
        }
    }
    
    init(
        systemName: String,
        yOffset: Double = 0,
        backgroundColor: Color = Color(level: 3),
        onPress: @escaping ()->()
    ) {
        self.systemName = systemName
        self.yOffset = yOffset
        self.backgroundColor = backgroundColor
        self.onPress = onPress
    }
}
