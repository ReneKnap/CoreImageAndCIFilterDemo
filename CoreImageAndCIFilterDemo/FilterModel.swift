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

    private func apply() {
        
        filteredImage = chain.apply()
    }
    
    //MARK: - Select a Filter
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
    
    
    //MARK: - Detect face features
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
                    ? [CGRect(origin: feature.leftEyePosition.swapY(image.size.height).scale(factor: scaleFactor),
                            size: feature.bounds.size.scale(factor: 0.125))]
                    : []
                
                eyes += feature.hasRightEyePosition
                    ? [CGRect(origin: feature.rightEyePosition.swapY(image.size.height).scale(factor: scaleFactor),
                       size: feature.bounds.size.scale(factor: 0.125))]
                    : []
                
                
                outputFeatures.append(
                    FaceFeature(
                        face: feature.bounds.swapY(image.size.height).scale(factor: scaleFactor),
                        eyes: eyes
                    )
                )
            }
        }
        return outputFeatures
    }
}

//MARK: - Filter Library Preset
fileprivate let filterLibraryPreset = [
    "CISepiaTone",
    "CIBoxBlur",
    "CIDiscBlur",
    "CIGaussianBlur",
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

extension CGPoint {
    func swapY(_ originImageHeight: CGFloat) -> CGPoint {
        CGPoint(x: self.x, y: originImageHeight - self.y)
    }
}

extension CGRect {
    func scale(factor: CGFloat) -> CGRect {
        CGRect(x: self.origin.x * factor, y: self.origin.y * factor,
               width: self.size.width * factor, height: self.size.height * factor)
    }
}

extension CGRect {
    func swapY(_ originImageHeight: CGFloat) -> CGRect {
        CGRect(x: self.origin.x, y: originImageHeight - self.origin.y,
               width: self.size.width, height: self.size.height)
    }
}
