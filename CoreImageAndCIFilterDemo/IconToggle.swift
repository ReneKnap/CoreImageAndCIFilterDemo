//
//  IconToggle.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 13.12.21.
//

import SwiftUI

struct IconToggle: View {
    @Binding var isActive: Bool
    let systemName: String
    let yOffset: Double
    
    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            Image(systemName: systemName)
                .offset(y: yOffset)
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(isActive ? .black : .accentColor)
                .frame(width: 44, height: 44)
                .background(isActive ? Color.accentColor : Color.clear)
                .cornerRadius(defaultCornerRadius)
                .contentShape(Rectangle())
        }
    }
    
    init(isActive: Binding<Bool> , systemName: String, yOffset: Double = 0) {
        self._isActive = isActive
        self.systemName = systemName
        self.yOffset = yOffset
    }
}
