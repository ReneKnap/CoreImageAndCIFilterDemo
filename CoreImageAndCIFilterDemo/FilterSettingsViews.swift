//
//  FilterSettings.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI

extension FilterEditor {
    class ViewModel: ModelBase, ObservableObject {
        private let model = Model()
        var filterLibrary: [String] { model.filterLibrary }
        var chain: FilterChain { model.chain }
        
        @Published var currentFilter: Filter! = nil
        @Published var filteredImage: UIImage? = nil
        
        @Published var selectedImage: UIImage? = nil
        
        @Published var isShowPicker: Bool = false
        @Published var showImageSavedAlert = false
        @Published var isFaceDetectionOn = true
        @Published var isChainingOn = false
        
        func faceFeatures(uiSize: CGSize) -> [FaceFeature]? {
            model.faceFeatures(uiSize: uiSize)
//            model.mockFaceFeatures(uiSize: uiSize)
        }
        
        override init() {
            super.init()
            
            currentFilter = model.chain.activeFilters.first!
            
            model.$filteredImage
                .sink { [weak self] in
                    self?.filteredImage = $0
                }.store(in: &subs)
            
            $selectedImage
                .sink { [weak self] image in
                    self?.model.selectedImage = image
                }.store(in: &subs)
            
            $isChainingOn
                .sink(receiveValue: onChainActiveChange)
                .store(in: &subs)
        }
        
        func save() {
            let imageSaver = ImageSaver()
            guard let targetImage = filteredImage else {
                return
            }
            imageSaver.writeToPhotoAlbum(image: targetImage)
            showImageSavedAlert = true
        }
        
//        func addToChain(filter: String) {
//            if let ciFilter = CIFilter(name: filter) {
//                let filter = FilterBuildIn(ciFilter)
//                chain.add(filter: filter)
//                currentFilter = filter
//            }
//        }
        
        func onFilterSelect(filter: String) {
            model.selectFilter(name: filter)
            currentFilter = chain.activeFilters.last!
        }
        
        private func onChainActiveChange(isActive: Bool) {
            model.isChainActive = isActive
            
            if
                isActive
            {
                if let filter = chain.activeFilters.first {
                    currentFilter = filter
                } else if let filter = currentFilter as? FilterBuildIn {
                    chain.add(filter: filter)
                }
            }
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
                    .aspectRatio(vm.selectedImage?.size.ratio, contentMode: .fit)
                    .cornerRadius(defaultCornerRadius)
                    .overlay( features )
            }
            .maxFrame()
            
            ImageFileNavigation()
            
            HStack {
                Group {
                    FilterList()
                        .frame(width: 250)
                    
                    FilterSettings(filter: vm.currentFilter)
                        .frame(maxWidth: .infinity)
                }.background(Placeholder(""))
            }.frame(height: 350)
        }.sheet(isPresented: $vm.isShowPicker) {
            ImagePicker(image2: $vm.selectedImage)
        }.environmentObject(vm)
    }
    
    var features: some View {
        GeometryReader { geo in
            Group {
                if vm.isFaceDetectionOn, let features = vm.faceFeatures(uiSize: geo.size) {
                    FaceFeatureV(features: features)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

struct FilterSettings: View {
    @EnvironmentObject
    var vm: FilterEditor.ViewModel
    let filter: Filter
    
    var body: some View {
        VStack {
            ZStack {
                Group {
                    if vm.isChainingOn {
                        FilterChainV(chainFilter: vm.chain)
                            .padding(5)
                    } else {
                        Headline("\(filter.name)")
                    }
                }
                
//                HStack {
//                    Spacer()
//
//                    IconButton(systemName: "link.badge.plus", backgroundColor: .clear) {
//                        vm.currentChain?.addFilter(name: filter.name)
//                    }.padding(.horizontal, 10)
//                }
            }.frame(maxWidth: .infinity).frame(height: 54)
            
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
        .cornerRadius(defaultCornerRadius)
    }
}
