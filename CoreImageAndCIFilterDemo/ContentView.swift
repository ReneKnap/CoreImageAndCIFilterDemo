//
//  ContentView.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 10.12.21.
//

import SwiftUI

struct ContentView: View {
    @State private var value1: Double = 0
    @State private var value2: Double = 0
    @State private var value3: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
            VStack {
                Image("apple")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding()
                    .frame(width: geo.size.width * 1.0, height: (geo.size.height-400) * 1.0)
                    .background(.black)
 
                HStack {
                    Spacer()
                    Spacer()
                    Button("Set Filter"){
                        print("Set Filter")
                    }
                        .padding()
                        .background(Color(UIColor.darkGray))
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                    Spacer()
                    Button("Load Image"){
                        print("Load Image")
                    }
                        .padding()
                        .background(Color(UIColor.darkGray))
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                    Spacer()
                    Button("Save Image"){
                        print("Save Image")
                    }
                        .padding()
                        .background(Color(UIColor.darkGray))
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                    Spacer()
                    Spacer()
                }
                .padding()
                Spacer()
            }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Filter: Name").font(.headline).padding()
                    Text("Value 1: \(value1, specifier: "%.1f")").font(.footnote)
                    Slider(value: $value1, in: 0...100)
                    Text("Value 2: \(value2, specifier: "%.1f")").font(.footnote)
                    Slider(value: $value2, in: 0...100)
                    Text("Value 3: \(value3, specifier: "%.1f")").font(.footnote)
                    Slider(value: $value3, in: 0...100)
                    Spacer()
                }
                    .padding()
                    .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: .infinity, alignment: .center)
                    .background(Color(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
