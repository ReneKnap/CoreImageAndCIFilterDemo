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
    @Published var currentFilter: Filter
    @Published var isShowPicker: Bool = false
    var filters = [Filter]()
    var selectedImage: UIImage?
    @Published var currentImage: UIImage?
    var context: CIContext!
    @Published var showImageSavedAlert = false
    
    override init() {
        filters = CIFilter
            .filterNames(inCategory: kCICategoryBuiltIn)
            .compactMap(CIFilter.init)
            .map(Filter.init)
        
        currentFilter = filters.first!
        
        context = CIContext()
        
        super.init()
        
        for filter in filters {
            filter.didChange
                .sink { filter in
                    self.apply(filter: filter)
                }.store(in: &subs)
        }
    }
    
    func apply(filter: CIFilter) {
        guard let image = selectedImage else {
            return
        }
        let beginImage = CIImage(image: image)
        let tmpFilter = currentFilter.ciFilter
        
        tmpFilter.setValue(beginImage, forKey: kCIInputImageKey)
        guard let outputImage = tmpFilter.outputImage else { return }

        if let cgImage = context.createCGImage(outputImage,
                                               from: outputImage.extent) {
            currentImage = UIImage(cgImage: cgImage)
        }
    }
    
    func select(filter: Filter) {
        currentFilter = filter
    }
}

class Filter: BaseModel, ObservableObject, Identifiable, Equatable {
    let ciFilter: CIFilter
    
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
    
    let didChange = PassthroughSubject<CIFilter, Never>()
    
    private func makeSub() {
        subs.removeAll()
        
        for slider in sliders {
            slider.$value.sink { _ in
                self.rander()
            }.store(in: &subs)
        }
    }
    
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.name == rhs.name
    }
    
    
    func rander() {
        ciFilter.setValuesForKeys(sliders.reduce(
            into: [String: CGFloat](), {
            $0[$1.name] = $1.value
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
