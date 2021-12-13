//
//  FilterList.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI

struct FilterList: View {
    @EnvironmentObject
    var vm: FilterEditor.ViewModel
    
    var body: some View {
        VStack(spacing: 5) {
            Headline("Filters")
            
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    ForEach(vm.filterLibrary, id: \.self) { filter in
                            Elememt(
                                filterName: filter,
                                isSelected: vm.isChainingOn
                                    ? false
                                    : filter == vm.currentFilter.name
                            ) {
                                vm.onFilterSelect(filter: filter)
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
                .cornerRadius(defaultCornerRadius)
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
