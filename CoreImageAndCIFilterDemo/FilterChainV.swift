//
//  FilterChainV.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 13.12.21.
//

import SwiftUI

struct FilterChainV: View {
    @EnvironmentObject var vm: FilterEditor.ViewModel
    @ObservedObject var chainFilter: FilterChain
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(chainFilter.activeFilters) { filter in
                    Button {
                        vm.currentFilter = filter
                    } label: {
                        ChainFilterV(
                            filter,
                            isSelected: vm.currentFilter == filter
                        )
                    }
                }
            }.padding(5)
            .padding(.trailing, 44)
        }
        .maxFrame()
//        .frame(width: geo.size.width, height: geo.size.height)
        .background(Color(level: 1))
        .overlay(removeButton)
        .cornerRadius(7)
    }
    
    var removeButton: some View {
        HStack {
            Spacer()
            
            IconButton(systemName: "trash") {
                chainFilter.reset()
            }.background(Color(level: 1))
        }
    }
    
    struct ChainFilterV: View {
        let filter: Filter
        let isSelected: Bool
        
        var body: some View {
            Text(filter.name)
                .foregroundColor(isSelected ? Color.black : Color.white)
                .frame(width: 150).frame(maxHeight: .infinity)
                .background(isSelected ? Color.accentColor : Color(level: 3))
                .cornerRadius(6)
        }
        
        init(_ filter: Filter, isSelected: Bool = false) {
            self.filter = filter
            self.isSelected = isSelected
        }
    }
}
