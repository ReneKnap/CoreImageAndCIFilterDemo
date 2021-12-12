//
//  FilterModel.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI
import Combine

class BaseModel {
    var subs = Set<AnyCancellable>()
}

class Model: BaseModel, ObservableObject {
//    @Published var isShowPicker: Bool = false
//    @Published var showImageSavedAlert = false
    @Published var currentFilter: Filter
    @Published var filteredImage: UIImage?
    let filters: [Filter]
    @Published var selectedImage: UIImage?
    
    //Initialize the context to be reused
    private let context = CIContext()
    
    override init() {
        //MARK: - Get built-in Filters
        filters = CIFilter
        //String Array of biuld-in filters
            .filterNames(inCategory: kCICategoryBuiltIn)
            .compactMap(CIFilter.init)
            .map(Filter.init)
        
        currentFilter = filters.first!
        
        super.init()
        
        doApply
            .combineLatest($selectedImage.compactMap{$0})
            .sink(receiveValue: apply(filter:image:))
            .store(in: &subs)
        
        $currentFilter
            .map(\.ciFilter)
            .sink(receiveValue: doApply.send)
            .store(in: &subs)
        
        for filter in filters {
            filter.didChange
                .sink(receiveValue: doApply.send)
                .store(in: &subs)
        }
    }
    
    //MARK: - Appy Filte
    private let doApply = PassthroughSubject<CIFilter, Never>()
    private func apply(filter: CIFilter, image: UIImage) {
        // Create a CIImage to apply the CIFilter
        let beginImage = CIImage(image: image)
        
        // Pass the image to the filter
        currentFilter.ciFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        // Calculate in the context the transformed image with the filter settings
        guard let outputImage = currentFilter.ciFilter.outputImage else { return }
        if let cgImage = context.createCGImage(outputImage,
                                               from: outputImage.extent) {
            filteredImage = UIImage(cgImage: cgImage)
        }
    }
    
    func select(filter: Filter) {
        currentFilter = filter
    }
}

class Filter: BaseModel, ObservableObject, Identifiable, Equatable {
    let ciFilter: CIFilter
    let didChange = PassthroughSubject<CIFilter, Never>()
    
    var id: String { name }
    var name: String {
        "\(ciFilter.name)"
    }
    var displayName: String {
        "\(ciFilter.attributes["CIAttributeFilterDisplayName"]!)"
    }
    
    var sliders: [Slider]
    
    init(from ciFilter: CIFilter) {
        self.ciFilter = ciFilter
        sliders = []
        
        super.init()
        
        //MARK: - Slider for
        // Set a slider for each numeric filter parameter
        for attribute in ciFilter.attributes{
            if attribute.key.hasPrefix("input") &&
                ((attribute.value as! Dictionary<String,Any>)["CIAttributeClass"] as! String) == "NSNumber"
            {
                sliders.append(
                    Slider(
                        name: attribute.key,
                        value: ciFilter.value(forKey: attribute.key) as? CGFloat ?? CGFloat(0.0),
                        min: (attribute.value as! Dictionary<String,Any>)["CIAttributeSliderMin"] as? CGFloat ?? CGFloat(0.0),
                        max: (attribute.value as! Dictionary<String,Any>)["CIAttributeSliderMax"] as? CGFloat ?? CGFloat(1.0)
                    )
                )
            }
        }
        makeSub()
    }
    
    private func makeSub() {
        subs.removeAll()
        
        for slider in sliders {
            slider.$value
                .debounce(for: .seconds(0.01), scheduler: DispatchQueue.main)
                .sink {
                    self.adjustFilter(value: $0)
                }.store(in: &subs)
        }
    }
    
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.name == rhs.name
    }
    
    func adjustFilter(value: CGFloat) {
        ciFilter.setValuesForKeys(sliders.reduce(
            into: [String: CGFloat](), {
            $0[$1.name] = value
        }))
        
        didChange.send(ciFilter)
    }
    
    class Slider: ObservableObject, Identifiable {
        var id: String { name }
        var name: String
        @Published var value: CGFloat
        var min: CGFloat
        var max: CGFloat
        
        init(name: String, value: CGFloat, min: CGFloat, max: CGFloat) {
            self.name = name
            self.value = value
            self.min = min
            self.max = max
        }
    }
}
