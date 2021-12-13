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
    let filterLibrary = filterLibraryPreset
    
    let chain = FilterChain()
    @Published var filteredImage: UIImage?
    @Published var selectedImage: UIImage?
    @Published var isChainActive = false
    
    
    
    override init() {
        super.init()
        
        selectFilter(name: filterLibrary.first!)
        
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
        chain.didChange
            .combineLatest(
                $selectedImage
                    .compactMap { $0 }
            ).map { (filter, image) in
                
                
                filter.set(image: image)
            }
            .sink(receiveValue: apply)
            .store(in: &subs)
        
        chain.didChange.send(chain)
    }
    
    
//    private func onSetupChange(filter: Filter) {
//        filterSubs.removeAll()
//        filter.didChange
//            .sink(receiveValue: apply(filter:))
//            .store(in: &filterSubs)
//
//        apply(filter: filter)
//    }
    
    //MARK: - Appy Filte
    private func apply() {
        
        filteredImage = chain.apply()
    }
    
    func selectFilter(name: String) {
        guard
            let ciFilter = CIFilter(name: name)
        else { return }
        
        let filter = FilterBuildIn(ciFilter)
        
        if isChainActive {
            chain.add(filter: filter)
        } else {
            chain.reset()
            chain.add(filter: filter)
            //TODO convert to one
        }

    }
    
    func mockFaceFeatures(uiSize: CGSize) -> [FaceFeature]? {
        return [
            FaceFeature(
                face: CGRect(x: 0, y: 0, width: 200, height: 400),
                eyes: [
                    CGRect(x: 0, y: 0, width: 20, height: 20),
                    CGRect(x: 200, y: 150, width: 10, height: 10)
                ]
            )
        ]
    }
    
    func faceFeatures(uiSize: CGSize) -> [FaceFeature] {
        guard let image = selectedImage else { return [] }
        
        let context = CIContext()
        var outputFeatures = [FaceFeature]()
        let ciImage = CIImage(image: image)!
        let scaleFactor = 1 / image.size.width * uiSize.width
        
        let param: [String:Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        if let faceDetector: CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: param) {
            let detectResult = faceDetector.features(in: ciImage) as! [CIFaceFeature]
            
            for feature in detectResult {
                
                var eyes = [CGRect]()
                eyes += feature.hasLeftEyePosition
                    ? [CGRect(origin: feature.leftEyePosition.scale(factor: scaleFactor),
                            size: feature.bounds.size.scale(factor: 0.125))]
                    : []
                
                eyes += feature.hasRightEyePosition
                    ? [CGRect(origin: feature.rightEyePosition.scale(factor: scaleFactor),
                       size: feature.bounds.size.scale(factor: 0.125))]
                    : []
                
                
                outputFeatures.append(
                    FaceFeature(
                        face: feature.bounds,
                        eyes: eyes
                    )
                )
            }
        }
        return outputFeatures
    }
}

fileprivate let filterLibraryPreset = [
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

extension CGSize {
    func scale(factor: CGFloat) -> CGSize {
        CGSize(width: self.width * factor, height: self.height * factor)
    }
    
    var ratio: CGFloat {
        width / height
    }
}

extension CGPoint {
    func scale(factor: CGFloat) -> CGPoint {
        CGPoint(x: self.x * factor, y: self.y * factor)
    }
}
