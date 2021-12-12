//
//  FilterSettings.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 12.12.21.
//

import SwiftUI

struct FilterEditor: View {
    @StateObject var model = Model()
    
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: model.currentImage ?? UIImage(fromColor: UIColor(.gray)))
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
            }
            .maxFrame()
            
            ImageFileNavigation(model: model)
            
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
                }.padding(10)
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
