//
//  FilterSettings.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI

extension FilterEditor {
    class ViewModel: BaseModel, ObservableObject {
        let model = Model()
        @Published var currentFilter: Filter! = nil
        @Published var filteredImage: UIImage? = nil
        
        @Published var selectedImage: UIImage? = nil
        
        @Published var isShowPicker: Bool = false
        @Published var showImageSavedAlert = false
        
        override init() {
            super.init()
            
            model.$currentFilter
//                .assign(to: \.currentFilter, on: self)
                .sink { [weak self] in
                    self?.currentFilter = $0
                }
                .store(in: &subs)
            
            model.$filteredImage
//                .assign(to: \.filteredImage, on: self)
                .sink { [weak self] in
                    self?.filteredImage = $0
                }
                .store(in: &subs)
            
            $selectedImage
                .sink { [weak self] image in
                    self?.model.selectedImage = image
                }
                .store(in: &subs)
        }
    }
}

struct FilterEditor: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: vm.filteredImage ?? UIImage(fromColor: .gray))
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(defaultCornerRasius)
            }
            .maxFrame()
            
            ImageFileNavigation()
            
            HStack {
                Group {
                    FilterList(model: vm.model)
                        .frame(width: 250)
                    
                    FilterSettings(filter: vm.currentFilter)
                        .frame(maxWidth: .infinity)
                }.background(Placeholder(""))
            }.frame(height: 350)
        }.sheet(isPresented: $vm.isShowPicker) {
            ImagePicker(image2: $vm.selectedImage)
        }.environmentObject(vm)
    }
}

struct FilterSettings: View {
    @ObservedObject
    var filter: Filter
    
    var body: some View {
        VStack {
            Headline("\(filter.displayName)")
            
            ScrollView {
                VStack {
                    ForEach(filter.sliders) { slider in
                        FilterParamerterSlider(slider: slider)
                    }
                }.padding(defaultPadding)
            }
        }
        .maxFrame()
    }
}


struct FilterParamerterSlider: View {
    @ObservedObject
    var slider: Filter.Slider
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Text("\(slider.min, specifier: "%.2f")")
                    
                    Spacer()
                    
                    Text("\(slider.max, specifier: "%.2f")")
                }
                
                HStack {
                    Text(slider.name.removeFirst(5).camelCaseToWords() + ": ")
                        + Text("\(slider.value, specifier: "%.2f")")
                }
            }.padding(.horizontal, defaultPadding/2)
            .padding(defaultPadding)
            
            Slider(value: $slider.value, in: slider.min...slider.max)
                .padding(defaultPadding)

        }
        .monospacedDigit()
        .background(Color(level: 2))
        .cornerRadius(defaultCornerRasius)
    }
}
