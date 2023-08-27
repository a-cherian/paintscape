//
//  AppView.swift
//  Paintscape
//
//  Created by AC on 8/15/23.
//

import SwiftUI
import Sliders

struct AppView: View {
    @State var movementEnabled = false
    @State var eyedropper = false
    @State var primary: Color = .black
    @State var secondary: Color = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
    @State var tool: String = ""
    @State var tipSize: Double = 2
    @State var tipType: TipType = .square
    @State var undo = false
    @State var redo = false
    @State var width = 200
    @State var height = 300
    var previewSlider = true
    
    init(previewSlider: Bool) {
        self.previewSlider = previewSlider
    }
    
    var body: some View {
        ZStack {
            VStack {
                CanvasViewControllerR(w: $width, h: $height, mO: $movementEnabled, e: $eyedropper, tS: $tipSize, tT: $tipType, p: $primary, s: $secondary, t: $tool, u: $undo, r: $redo)
            }
            HStack {
                // left
                VStack {
                    // left top
                    VStack(alignment:.leading) {
                        Button(action: { movementEnabled = !movementEnabled }) {
                            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right").frame(width: 50, height: 50)
                        }
                        .background(movementEnabled ? Color.orange.opacity(0.9) : Color.orange.opacity(0.5))
                        .accentColor(Color.white)
                        .cornerRadius(25)
                        .controlSize(.large)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    // left center
                    VStack {
                        
                    }
                    
                    // left bottom
                    VStack {
                        TextField("Height", value: $height, formatter: NumberFormatter())
                            .frame(width: 50, height: 20)
                        TextField("Width", value: $width, formatter: NumberFormatter())
                            .frame(width: 50, height: 20)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                // right
                VStack {
                    // right top
                    VStack {
                        ZStack {
                            Button(action: {
                                let temp = secondary
                                secondary = primary
                                primary = temp
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .accentColor(Color.white)
                            .cornerRadius(25)
                            .controlSize(.large)
                            .frame(width: 60, height: 60, alignment: .bottomLeading)
                            
                            ColorPicker("", selection: $secondary)
                                .frame(width: 50, height: 50, alignment: .bottomTrailing)
                                .labelsHidden()
                            
                            ColorPicker("", selection: $primary)
                                .frame(width: 50, height: 50, alignment: .topLeading)
                                .labelsHidden()
                        }
                        
                        Button(action: {
                            if tipType == .square {
                                tipType = .circle
                            }
                            else {
                                tipType = .square
                            }
                        }) {
                            Image(tipType == .circle ? "circle_tip" : "square_tip")
                                .interpolation(.none)
                                .resizable()
                                .padding(10)
                                .frame(width: 50, height: 50)
                        }
                        .background(Color.orange.opacity(0.5))
                        .accentColor(Color.white)
                        .cornerRadius(25)
                        .controlSize(.large)
                        ToolButton(name: "replace", iconOn: "square.filled.on.square", iconOff: "square.fill.on.square.fill")
                        ToolButton(name: "eyedropper", iconOn: "eyedropper.full", iconOff: "eyedropper")
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    // right center
                    VStack {
                        if(previewSlider) { Slider(value: $tipSize, in: 1...30) }
                        else {
                            let tS = Int(tipSize)
                            // https://github.com/spacenation/swiftui-sliders
                            ValueSlider(value: $tipSize, in: 1 ... 30, step: 1)
                                .valueSliderStyle(VerticalValueSliderStyle(
                                    track: VerticalTrack(view: Color.orange)
                                        .frame(width: 5)
                                        .background(Color.orange.opacity(0.5))
                                        .cornerRadius(10),
                                    thumb: Text("\(tS)")
                                        .foregroundColor(Color.black)
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .padding()
                                        .background(
                                            Circle()
                                                .stroke(Color.orange, lineWidth: 4)
                                                .background(Circle().foregroundColor(Color.white))
                                                .padding(6)),
                                    thumbSize: CGSize(width: 25, height: 25)))
                                .frame(width: 50, height: 200, alignment: .bottom)
                        }
                    }
                    
                    // right bottom
                    VStack {
                        Button(action: { undo = true }) {
                            Image(systemName: "arrow.uturn.backward").frame(width: 50, height: 50)
                        }
                        .background(Color.orange.opacity(0.5))
                        .accentColor(Color.white)
                        .cornerRadius(25)
                        .controlSize(.large)
                        
                        Button(action: { redo = true }) {
                            Image(systemName: "arrow.uturn.forward").frame(width: 50, height: 50)
                        }
                        .background(Color.orange.opacity(0.5))
                        .accentColor(Color.white)
                        .cornerRadius(25)
                        .controlSize(.large)
                        
                        Button(action: { redo = true }) {
                            Image(systemName: "line.3.horizontal").frame(width: 50, height: 50)
                        }
                        .background(Color.orange.opacity(0.5))
                        .accentColor(Color.white)
                        .cornerRadius(25)
                        .controlSize(.large)
                    }
                    .frame(maxHeight: .infinity)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .padding()
    }
    
    func ToolButton(name: String, iconOn: String, iconOff: String) -> some View {
        let toolOn = tool == name
        return Button(action: {
            if toolOn { tool = "" }
            else { tool = name }
        }) {
            Image(systemName: toolOn ? iconOn : iconOff).frame(width: 50, height: 50)
        }
        .background(toolOn ? Color.blue : Color.orange.opacity(0.5))
        .accentColor(Color.white)
        .cornerRadius(25)
        .controlSize(.large)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(previewSlider: true)
    }
}
