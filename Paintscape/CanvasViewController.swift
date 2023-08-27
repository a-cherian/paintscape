//
//  CanvasViewController.swift
//  Paintscape
//
//  Created by AC on 8/17/23.
//

import UIKit
import SwiftUI

class CanvasViewController: UIViewController {
    var movementEnabled = false {
        didSet {
            canvasView.movementEnabled = movementEnabled
            if movementEnabled {
                addGestures()
            }
            else {
                removeGestures()
            }
        }
    }
    var canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var canvasHeight = CGFloat(200)
    var canvasWidth = CGFloat(200)
    var maxScale = CGFloat(4)
    var minScale = CGFloat(0.1)
    var initialCenter = CGPoint(x: 0, y: 0)
    
    var pinch = UIPinchGestureRecognizer()
    var pan = UIPanGestureRecognizer()
    
    init(height: CGFloat = CGFloat(200), width: CGFloat = CGFloat(200)) {
        super.init(nibName: nil, bundle: nil)
        self.canvasHeight = height
        self.canvasWidth = width
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createCanvas()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasView.center = view.center
    }
    
    private func addGestures() {
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(pan)
    }
    
    private func removeGestures() {
        view.removeGestureRecognizer(pinch)
        view.removeGestureRecognizer(pan)
    }
    
    func createCanvas() {
        canvasView.removeFromSuperview()
        canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
        view.addSubview(canvasView)
        
        let initXScale = view.bounds.width / canvasWidth * 0.75
        let initYScale = view.bounds.height / canvasHeight * 0.75
        let initScale = min(initXScale, initYScale)
        maxScale = max(view.bounds.width / maxScale, view.bounds.height / maxScale)
        minScale = min(view.bounds.width / canvasWidth * minScale, view.bounds.height / canvasHeight * minScale)
        canvasView.transform = CGAffineTransformScale(canvasView.transform, initScale, initScale);
        canvasView.center = view.center
        initialCenter = view.center
        
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        
        addGestures()
    }

    @objc private func didPinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            
            let transform = CGAffineTransformScale(canvasView.transform, gesture.scale, gesture.scale);
            if transform.a > minScale && transform.a < maxScale {
                canvasView.transform = CGAffineTransformScale(canvasView.transform, gesture.scale, gesture.scale);
                gesture.scale = 1
            }
        }
    }
    
    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            let translation = gesture.translation(in: canvasView)
            
            canvasView.transform = CGAffineTransformTranslate(canvasView.transform, translation.x, translation.y)
            gesture.setTranslation(CGPoint.zero, in: canvasView)
        }
    }
}

struct CanvasViewController_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        CanvasViewController().showPreview()
    }
}

