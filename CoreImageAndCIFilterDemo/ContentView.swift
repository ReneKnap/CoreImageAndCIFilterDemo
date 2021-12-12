//
//  ContentView.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 10.12.21.
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
    @Published var currentImage: UIImage
    var context: CIContext!
    
    override init() {
        filters = CIFilter
            .filterNames(inCategory: kCICategoryBuiltIn)
            .compactMap(CIFilter.init)
            .map(Filter.init)
        
        currentFilter = filters.first!
        
        selectedImage = UIImage(named: "apple")
        currentImage = selectedImage!
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
        let tmpFilter = currentFilter.ciFilter
        let beginImage = CIImage(image: selectedImage!)
        
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



struct FilterSettings: View {
    @ObservedObject
    var filter: Filter
    
    var body: some View {
        VStack {
            Headline("\(filter.displayName)")
            
            ScrollView {
                VStack {
                    ForEach(filter.sliders) { slider in
                        SliderV(slider: slider)
                    }
                }.padding(10)
            }
        }
        .maxFrame()
    }
}


struct ImageNavigation: View {
    @ObservedObject
    var model: Model
    
    var body: some View {
        HStack(alignment: .center, spacing: 44) {
            Group{
                Button("Load Image") {
                    withAnimation {
                        model.isShowPicker.toggle()
                    }
                }
                Button("Save Image") {
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image: model.currentImage)
                }
                Button("Detect Face") {
                    print("Detect Face")
                }
            }
            .frame(width: 120, height: 44, alignment: .center)
            .background(Color(level: 5))
            .cornerRadius(12)
            .foregroundColor(.white)
        }
    }
}


struct SliderV: View {
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
            }.padding(.horizontal, 5)
            .padding(10)
            
            Slider(value: $slider.value, in: slider.min...slider.max)
                .padding(10)

        }
        .monospacedDigit()
        .background(Color(level: 2))
        .cornerRadius(6)
        
    }
    
}

struct Headline: View {
    let name: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 24, weight: .light, design: .rounded))
                .padding(.top, 10)
        }
    }
    
    init(_ name: String) {
        self.name = name
    }
}


struct FilterList: View {
    @ObservedObject var model: Model
    
    var body: some View {
        VStack(spacing: 5) {
            Headline("Filters")
            
            ScrollView {
                LazyVStack {
                    ForEach(model.filters) { filter in
                        Button {
                            model.select(filter: filter)
                        } label: {
                            Elememt(
                                filter,
                                isSelected: filter == model.currentFilter
                            )
                        }
                    }
                }.padding(10)
            }
        }
    }
}

extension FilterList {
    struct Elememt: View {
        @ObservedObject var filter: Filter
        let image: CGImage?
        let isSelected: Bool
        
        var body: some View {
            HStack {
                OptionalImage(image: image)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                
                Text(filter.displayName)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .lineLimit(1)
                
                Spacer()
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 10)
            .frame(height: 44)
            .background(isSelected ? Color.accentColor : Color(level: 3))
            .cornerRadius(6)
            
        }
        
        init(_ filter: Filter, image: CGImage? = nil, isSelected: Bool) {
            self.filter = filter
            self.image = image
            self.isSelected = isSelected
        }
    }
}

struct OptionalImage: View {
    let image: CGImage?
    
    var body: some View {
        if let image = image {
            Image(decorative: image, scale: 2);
        } else {
            Image(systemName: "photo")
        }
    }
}

struct FilterEditor: View {
    @StateObject var model = Model()
    
    var body: some View {
        VStack {
            ZStack {
//                Placeholder("Preview Image")
                Image(uiImage: model.currentImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
//                    .aspectRatio(1.0, contentMode: .fit)
            }
            .maxFrame()
            
            ImageNavigation(model: model)
            
            HStack {
                Group {
                    FilterList(model: model)
                        .frame(width: 250)
                    
                    FilterSettings(filter: model.currentFilter)
                        .frame(maxWidth: .infinity)
                }.background(Placeholder(""))
            }.frame(height: 350)
        }.sheet(isPresented: $model.isShowPicker) {
            ImagePicker(image2: $model.selectedImage)
        }
    }
}


struct ContentView: View {
    var body: some View {
        FilterEditor()
            .accentColor(.yellow)
            .statusBar(hidden: true)
    }
}



struct Placeholder: View {
    let name: String
    
    var body: some View {
        Color(level: 2)
            .cornerRadius(12)
            .overlay(Text(name))
    }
    
    init(_ name: String) {
        self.name = name
    }
}

struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    var presentationMode

    @Binding var image2: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        @Binding var presentationMode: PresentationMode
        @Binding var image2: UIImage?

        init(presentationMode: Binding<PresentationMode>, image2: Binding<UIImage?>) {
            _presentationMode = presentationMode
            _image2 = image2
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image2 = uiImage
            presentationMode.dismiss()

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image2: $image2)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
