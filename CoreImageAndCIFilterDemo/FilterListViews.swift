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
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section(header: Headline("ToDo").maxFrame().background(Color(level: 2))){
                        ForEach(model.filters, id: \.self) { filter in
                            Elememt(
                                filterName: filter,
                                isSelected: filter == model.currentFilter.name
                            ) {
                                model.selectFilter(name: filter)
                            }
                        }
                    }
                    Section(header: Headline("Face Detection").maxFrame().background(Color(level: 2))){
                        Elememt(
                            filterName: "Face Detection",
                            isSelected: "Face Detection" == model.currentFilter.name
                        ) {
                            model.selectFilter(name: "Face Detection")
                        }
                    }
                }.padding(defaultPadding)
            }
        }
    }
}

extension FilterList {
    struct Elememt: View {
        let filterName: String
        let image: CGImage?
        let isSelected: Bool
        
        let onPress: ()->()
        
        var body: some View {
            Button {
                onPress()
            } label: {
                HStack {
                    OptionalImage(image: image)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                    
                    Text(filterName)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(1)
                    
                    Spacer()
                }
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, defaultPadding)
                .frame(height: minimumTappableLenght)
                .background(isSelected ? Color.accentColor : Color(level: 3))
                .cornerRadius(defaultCornerRasius)
            }
        }
        
        
        
        init(filterName: String, image: CGImage? = nil, isSelected: Bool, onPress: @escaping ()->()) {
            self.filterName = filterName
            self.image = image
            self.isSelected = isSelected
            self.onPress = onPress
        }
    }
}
