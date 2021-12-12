//
//  FilterModel.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI
import Combine

class ModelBase {
    var subs = Set<AnyCancellable>()
}

class Model: ModelBase, ObservableObject {
    private var filterSubs = Set<AnyCancellable>()
    
    @Published var currentFilter: Filter! = nil
    @Published var filteredImage: UIImage?
    let filters: [String]
    @Published var selectedImage: UIImage?
    
    override init() {
        //MARK: - Get built-in Filters
//        filters = CIFilter
//        //String Array of biuld-in filters
//            .filterNames(inCategory: kCICategoryBuiltIn)
//
        filters = [
            "CIBoxBlur",
            "CIDiscBlur",
            "CIGaussianBlur",
            "CIMaskedVariableBlur",
            "CIBloom",
            "CIComicEffect",
            "CIEdges",
            "CIEdgeWork",
            "CIPixellate",
            "CIHexagonalPixellate"
        ]
        
        super.init()
        
        selectFilter(name: filters.first!)
        
//        $selectedImage
//            .compactMap { $0 }
//            // Create a CIImage to apply the CIFilter
//            .map { CIImage(image: $0) }
//            .sink { [weak self] in
//                guard let self = self else { return }
//                // Pass the image to the filter
//                self.currentFilter.ciFilter.setValue($0, forKey: kCIInputImageKey)
//                self.apply(filter: self.currentFilter.ciFilter)
//            }.store(in: &subs)
        
        
//        $currentFilter
//            .map(\.ciFilter)
//            .sink(receiveValue: doApply.send)
//            .store(in: &subs)
        
//        for filter in filters {
//            filter.didChange
//                .sink(receiveValue: doApply.send)
//                .store(in: &subs)
//        }
        $currentFilter
            .compactMap { $0 }
            .combineLatest(
                $selectedImage
                    .compactMap { $0 }
            ).map { (filter, image) in
                filter.set(image: image)
                return filter
            }
            .sink(receiveValue: onSetupChange(filter:))
            .store(in: &subs)
    }
    
    
    private func onSetupChange(filter: Filter) {
        filterSubs.removeAll()
        filter.didChange
            .sink(receiveValue: apply(filter:))
            .store(in: &filterSubs)
        
        apply(filter: filter)
    }
    
    //MARK: - Appy Filte
    private func apply(filter: Filter) {
        filteredImage = filter.apply()
    }
    
    func selectFilter(name: String) {
        if let ciFilter = CIFilter(name: name) {
            currentFilter = FilterBuildIn(ciFilter)
        } else {
            currentFilter = FilterFaceDetection()
        }
    }
}

