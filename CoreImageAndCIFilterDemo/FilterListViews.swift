//
//  FilterList.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI

struct FilterList: View {
    @ObservedObject var model: Model
    
    var body: some View {
        VStack(spacing: 5) {
            Headline("Filters")
            
            ScrollView {
                LazyVStack {
                    ForEach(model.filters) { filter in
                        Button {
                            model.select(filter: filter)
                        } label: {
                            Elememt(
                                filter,
                                isSelected: filter == model.currentFilter
                            )
                        }
                    }
                }.padding(10)
            }
        }
    }
}

extension FilterList {
    struct Elememt: View {
        @ObservedObject var filter: Filter
        let image: CGImage?
        let isSelected: Bool
        
        var body: some View {
            HStack {
                OptionalImage(image: image)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                
                Text(filter.displayName)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .lineLimit(1)
                
                Spacer()
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 10)
            .frame(height: 44)
            .background(isSelected ? Color.accentColor : Color(level: 3))
            .cornerRadius(6)
            
        }
        
        init(_ filter: Filter, image: CGImage? = nil, isSelected: Bool) {
            self.filter = filter
            self.image = image
            self.isSelected = isSelected
        }
    }
}
