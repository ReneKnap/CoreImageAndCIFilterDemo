//
//  ContentView.swift
//  CoreImageAndCIFilterDemo
//
//  Created by Creatcher on 10.12.21.
//

import SwiftUI
import Combine


struct ContentView: View {
    var body: some View {
        FilterEditor()
            .accentColor(.yellow)
            .statusBar(hidden: true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



