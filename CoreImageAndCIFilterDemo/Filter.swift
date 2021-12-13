//
//  Filter.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import Foundation
import CoreImage
import Combine
import UIKit

class Filter: ModelBase, Identifiable {
    var id: String = UUID().uuidString
    var name: String { "Base" }
    
    var sliders = [Slider]()
    var didChange = PassthroughSubject<Filter, Never>()
    
    override init() {
        super.init()
        
        makeSubs()
    }
    
    func makeSubs() {
        subs.removeAll()
        
        for slider in sliders {
            slider.$value
                .debounce(for: .seconds(0.01), scheduler: DispatchQueue.main)
                .sink {
                    self.adjustFilter(value: $0, sliderName: slider.name)
                }.store(in: &subs)
        }
        didChange.send(self)
    }
    
    func adjustFilter(value: CGFloat, sliderName: String) {
        didChange.send(self)
    }
    
    func apply() -> UIImage? {
        fatalError("Not Implemented")
    }
    
    func set(image: UIImage) {
        fatalError("Not Implemented")
    }
}

extension Filter {
    class Slider: ObservableObject, Identifiable {
        var name: String
        var id: String { name }
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

//extension Filter: Identifiable {
//    var id: String = UUID().uuidString
//}

extension Filter: Equatable {
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}



final class FilterBuildIn: Filter {
    let context = CIContext()
    let ciFilter: CIFilter
    
    override var name: String { ciFilter.name }
    
    init(_ ciFilter: CIFilter) {
        self.ciFilter = ciFilter
        
        super.init()
        
        sliders = sliders(ciFilter)
        makeSubs()
    }
    
    private func sliders(_ ciFilter: CIFilter) -> [Slider]{
        var sliders = [Slider]()
        
        for attribute in ciFilter.attributes{
            if
                attribute.key.hasPrefix("input"),
                ((attribute.value as! Dictionary<String,Any>)["CIAttributeClass"] as! String) == "NSNumber"
//                let hasMin = ((attribute.value as! Dictionary<String,Any>)["CIAttributeSliderMin"] as? String),
//                !hasMin.isEmpty

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
        
        return sliders
    }
    
    override func adjustFilter(value: CGFloat, sliderName: String) {
        ciFilter.setValue(value, forKey: sliderName)
        
        super.adjustFilter(value: value, sliderName: sliderName)
    }

    override func apply() -> UIImage? {
        if
            let outputImage = ciFilter.outputImage,
            let cgImage = context.createCGImage(outputImage,
                                               from: outputImage.extent)
        {
            return UIImage(cgImage: cgImage)
        }

        return nil
    }
    
    override func set(image: UIImage) {
        ciFilter.setValue(CIImage(image: image)!, forKey: kCIInputImageKey)
    }
}


//final class FilterFaceDetection: Filter {
//    override var name: String { "Face Detection" }
//
//    override init() {
//        super.init()
//    }
//
//    override func apply() -> UIImage? {
//        UIImage(fromColor: .blue)
//    }
//
//    override func set(image: UIImage) {
//
//    }
//}

final class FilterChain: Filter, ObservableObject {
    private var filterSubs = Set<AnyCancellable>()
    override var name: String { "Chain" }
    let context = CIContext()
    @Published var activeFilters: [FilterBuildIn] = []
    var originalImage: CIImage? = nil
    
    override init() {
        super.init()
    }
    
    private func updateSubs() {
        filterSubs.removeAll()
        
        for filter in activeFilters {
            filter.didChange
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    self.didChange.send(self)
                }.store(in: &filterSubs)
        }
        didChange.send(self)
    }
    
    func add(filter: FilterBuildIn) {
        activeFilters += [filter]
        
        updateSubs()
    }
    
    override func apply() -> UIImage? {
        var image = originalImage
        
        for filter in activeFilters {
            filter.ciFilter.setValue(image, forKey: kCIInputImageKey)
            image = filter.ciFilter.outputImage
        }
        
        
        if
            let outputImage = image,
            let cgImage = context.createCGImage(outputImage,
                                               from: outputImage.extent)
        {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
    
    override func set(image: UIImage) {
        originalImage = CIImage(image: image)
    }
    
    func reset() {
        activeFilters.removeAll()
        updateSubs()
    }
}




//class Filter: BaseModel, ObservableObject, Identifiable, Equatable {
//    let ciFilter: CIFilter
//    let didChange = PassthroughSubject<Filter, Never>()
//
//    //Initialize the context to be reused
//    private let context = CIContext()
//
//    var displayName: String {
//        "\(ciFilter.attributes["CIAttributeFilterDisplayName"]!)"
//    }
//
//    var sliders: [Slider]
//
//    init(from ciFilter: CIFilter) {
//        self.ciFilter = ciFilter
//        sliders = []
//
//        super.init()
//
//        //MARK: - Slider for
//        // Set a slider for each numeric filter parameter
//        for attribute in ciFilter.attributes{
//            if
//                attribute.key.hasPrefix("input"),
//                ((attribute.value as! Dictionary<String,Any>)["CIAttributeClass"] as! String) == "NSNumber"
////                let hasMin = ((attribute.value as! Dictionary<String,Any>)["CIAttributeSliderMin"] as? String),
////                !hasMin.isEmpty
//
//            {
//                sliders.append(
//                    Slider(
//                        name: attribute.key,
//                        value: ciFilter.value(forKey: attribute.key) as? CGFloat ?? CGFloat(0.0),
//                        min: (attribute.value as! Dictionary<String,Any>)["CIAttributeSliderMin"] as? CGFloat ?? CGFloat(0.0),
//                        max: (attribute.value as! Dictionary<String,Any>)["CIAttributeSliderMax"] as? CGFloat ?? CGFloat(1.0)
//                    )
//                )
//            }
//        }
//        makeSub()
//        didChange.send(self)
//    }
//
//    private func makeSub() {
//        subs.removeAll()
//
//        for slider in sliders {
//            slider.$value
//                .debounce(for: .seconds(0.01), scheduler: DispatchQueue.main)
//                .sink {
//                    self.adjustFilter(value: $0, sliderName: slider.name)
//                }.store(in: &subs)
//        }
//    }
//
//    static func == (lhs: Filter, rhs: Filter) -> Bool {
//        lhs.name == rhs.name
//    }
//
//    func adjustFilter(value: CGFloat, sliderName: String) {
//        print(sliderName, value)
//        ciFilter.setValue(value, forKey: sliderName)
//        didChange.send(self)
//    }
//
//    func apply() -> UIImage? {
//        if
//            let outputImage = ciFilter.outputImage,
//            let cgImage = context.createCGImage(outputImage,
//                                               from: outputImage.extent)
//        {
//            return UIImage(cgImage: cgImage)
//        }
//
//        return nil
//    }
//
//}
