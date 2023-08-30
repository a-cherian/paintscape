//
//  MenuView.swift
//  Paintscape
//
//  Created by AC on 8/22/23.
//

import SwiftUI

struct MenuView: View {
    @State var height = 200
    @State var width = 300
    
    var body: some View {
        VStack {
            TextField("Height", value: $height, formatter: NumberFormatter())
            TextField("Width", value: $width, formatter: NumberFormatter())
            
            List {
                TextField("Height", value: $height, formatter: NumberFormatter())
                TextField("Width", value: $width, formatter: NumberFormatter())
            }
        }
        .padding()
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
