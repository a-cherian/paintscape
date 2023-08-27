//
//  DrawViewControllerR.swift
//  Paintscape
//
//  Created by AC on 8/17/23.
//

import SwiftUI

struct CanvasViewControllerR: UIViewControllerRepresentable {
    @Binding var movementEnabled: Bool
    @Binding var tipSize: Double
    @Binding var tipType: TipType
    @Binding var primary: Color
    @Binding var secondary: Color
    @Binding var tool: String
    @Binding var undo: Bool
    @Binding var redo: Bool
    @Binding var width: Int
    @Binding var height: Int
    
    init(w: Binding<Int>, h: Binding<Int>, mO: Binding<Bool>, tS: Binding<Double>, tT: Binding<TipType>, p: Binding<Color>, s: Binding<Color>, t: Binding<String>, u: Binding<Bool>, r: Binding<Bool>) {
        self._width = w
        self._height = h
        self._movementEnabled = mO
        self._tipSize = tS
        self._tipType = tT
        self._primary = p
        self._secondary = s
        self._tool = t
        self._undo = u
        self._redo = r
    }
    
    func makeUIViewController(context: Context) -> CanvasViewController {
        let controller = CanvasViewController(height: CGFloat(height), width: CGFloat(width))
        controller.canvasView.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CanvasViewController, context: Context) {
        syncData(controller: uiViewController, context: context)
        
        if(undo) {
            uiViewController.canvasView.undo()
            DispatchQueue.main.async { undo = false }
        }
        if(redo) {
            uiViewController.canvasView.redo()
            DispatchQueue.main.async { redo = false }
        }
        if(height != Int((uiViewController.canvasView.imageView.image?.size.height)!) || width != Int((uiViewController.canvasView.imageView.image?.size.width)!)) {
            uiViewController.canvasWidth = CGFloat(width)
            uiViewController.canvasHeight = CGFloat(height)
            uiViewController.createCanvas()
            syncData(controller: uiViewController, context: context)
        }
    }
    
    func syncData(controller: CanvasViewController, context: Context) {
        guard let primRGBA = primary.rgba else { return }
        guard let secRGBA = secondary.rgba else { return }
        let primary = RGBA32(r: primRGBA.r, g: primRGBA.g, b: primRGBA.b, a: primRGBA.a, nType: CGFloat.self)
        let secondary = RGBA32(r: secRGBA.r, g: secRGBA.g, b: secRGBA.b, a: secRGBA.a, nType: CGFloat.self)
        
        controller.canvasView.delegate = context.coordinator
        controller.movementEnabled = self.movementEnabled
        controller.canvasView.movementEnabled = self.movementEnabled
        controller.eyedropper = tool == "eyedropper"
        controller.eyedropper = tool == "eyedropper"
        controller.canvasView.stroke = Stroke(tool: tool, tip: Tip(type: tipType, r: Int(self.tipSize)), primary: primary, secondary: secondary)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    typealias UIViewControllerType = CanvasViewController
    
    class Coordinator: NSObject, CanvasViewDelegate {
        var parent: CanvasViewControllerR

        init(_ parent: CanvasViewControllerR) {
            self.parent = parent
        }
        
        func didColorChange(_ color: RGBA32) {
            parent.primary = Color(r: color.redComponent, g: color.greenComponent, b: color.blueComponent)
        }
    }
}
