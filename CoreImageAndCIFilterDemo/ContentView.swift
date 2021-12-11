//
//  ContentView.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 10.12.21.
//

//import SwiftUI
//
//struct ContentView: View {
//    @State private var value1: Double = 0
//    @State private var value2: Double = 0
//    @State private var value3: Double = 0
//
//    var body: some View {
//        GeometryReader { geo in
//            VStack(alignment: .leading, spacing: 0) {
//            VStack {
//                Image("apple")
//                    .resizable()
//                    .scaledToFit()
//                    .cornerRadius(10)
//                    .padding()
//                    .frame(width: geo.size.width * 1.0, height: (geo.size.height-400) * 1.0)
//                    .background(.black)
//
//                HStack {
//                    Spacer()
//                    Spacer()
//                    Button("Set Filter"){
//                        print("Set Filter")
//                    }
//                        .padding()
//                        .background(Color(UIColor.darkGray))
//                        .foregroundStyle(.black)
//                        .cornerRadius(10)
//                    Spacer()
//                    Button("Load Image"){
//                        print("Load Image")
//                    }
//                        .padding()
//                        .background(Color(UIColor.darkGray))
//                        .foregroundStyle(.black)
//                        .cornerRadius(10)
//                    Spacer()
//                    Button("Save Image"){
//                        print("Save Image")
//                    }
//                        .padding()
//                        .background(Color(UIColor.darkGray))
//                        .foregroundStyle(.black)
//                        .cornerRadius(10)
//                    Spacer()
//                    Spacer()
//                }
//                .padding()
//                Spacer()
//            }
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Filter: Name").font(.headline).padding()
//                    Text("Value 1: \(value1, specifier: "%.1f")").font(.footnote)
//                    Slider(value: $value1, in: 0...100)
//                    Text("Value 2: \(value2, specifier: "%.1f")").font(.footnote)
//                    Slider(value: $value2, in: 0...100)
//                    Text("Value 3: \(value3, specifier: "%.1f")").font(.footnote)
//                    Slider(value: $value3, in: 0...100)
//                    Spacer()
//                }
//                    .padding()
//                    .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: .infinity, alignment: .center)
//                    .background(Color(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)))
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


import SwiftUI
import Combine


class BaseModel {
    var subs = Set<AnyCancellable>()
}


class Model: BaseModel, ObservableObject {
    @Published var currentFilter: Filter
    var filters = [Filter]()
    
    override init() {
        filters = CIFilter
            .filterNames(inCategory: kCICategoryBuiltIn)
            .compactMap(CIFilter.init)
            .map(Filter.init)
//        filters = [Filter(from: CIFilter(name: "CISepiaTone")!)]
        
        currentFilter = filters.first!
        
        super.init()
        
        for filter in filters {
            filter.didChange
                .sink { filter in
                    self.apply(filter: filter)
                }.store(in: &subs)
        }
    }
    
    func apply(filter: CIFilter) {
        
    }
    
    func select(filter: Filter) {
        currentFilter = filter
    }
}

class Filter: BaseModel, ObservableObject, Identifiable, Equatable {
    private let ciFilter: CIFilter
    var id: String { name }
    var name: String {
        ciFilter.name
    }
    
    let sliders: [Slider]
    
    init(from ciFilter: CIFilter) {
        self.ciFilter = ciFilter
        let sliderName = "inputIntensity"
        
        sliders = [
//            Slider(
//                name: sliderName,
//                value: ciFilter.value(forKey: sliderName) as! CGFloat,
//                min: 0,
//                max: 1
//            ),
//            Slider(
//                name: sliderName,
//                value: ciFilter.value(forKey: sliderName) as! CGFloat,
//                min: 0,
//                max: 1
//            ),
//            Slider(
//                name: sliderName,
//                value: ciFilter.value(forKey: sliderName) as! CGFloat,
//                min: 0,
//                max: 1
//            )
        ]
        
        super.init()
        
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
            Headline("\(filter.name)")
            
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
    var body: some View {
        HStack(alignment: .center, spacing: 44) {
            Group{
                Button("Load Image") {
                    print("Load Image")
                }
                Button("Save Image") {
                    print("Save Image")
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
                    Text("0.0")
                    
                    Spacer()
                    
                    Text("1.0")
                }
                
                HStack {
                    Text(slider.name + ": ") + Text("\(round(100 * slider.value) / 100)")
                }
            }.padding(.horizontal, 5)
            .padding(10)
            
            Slider(value: $slider.value)
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
                
                Text(filter.name)
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
                Placeholder("Preview Image")
//                    .aspectRatio(1.0, contentMode: .fit)
            }.maxFrame()
            
            ImageNavigation()
            
            HStack {
                Group {
                    FilterList(model: model)
                        .frame(width: 250)
                    
                    FilterSettings(filter: model.currentFilter)
                        .frame(maxWidth: .infinity)
                }.background(Placeholder(""))
            }.frame(height: 350)
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

extension View {
    func maxFrame() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func maxWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    func maxHeight() -> some View {
        self.frame(maxHeight: .infinity)
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


fileprivate extension Color {
    init(level: Int) {
        let value = 0.1 * Double(level)
        self.init(uiColor: UIColor.init(white: value, alpha: 1))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
