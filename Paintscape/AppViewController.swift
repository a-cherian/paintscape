//
//  AppViewController.swift
//  Paintscape
//
//  Created by AC on 8/17/23.
//

import UIKit
import SwiftUI

class AppViewController: UIViewController, UIColorPickerViewControllerDelegate, CanvasViewDelegate {
    
    let moveIcon = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right") ?? UIImage()
    let swapColorIcon = UIImage(systemName: "arrow.triangle.2.circlepath") ?? UIImage()
    let squareIcon = UIImage(named: "square_tip") ?? UIImage()
    let circleIcon = UIImage(named: "circle_tip") ?? UIImage()
    let replaceOnIcon = UIImage(systemName: "square.filled.on.square") ?? UIImage()
    let replaceOffIcon = UIImage(systemName: "square.fill.on.square.fill") ?? UIImage()
    let eyedropperOnIcon = UIImage(systemName: "eyedropper.full") ?? UIImage()
    let eyedropperOffIcon = UIImage(systemName: "eyedropper") ?? UIImage()
    let undoIcon = UIImage(systemName: "arrow.uturn.backward") ?? UIImage()
    let redoIcon = UIImage(systemName: "arrow.uturn.forward") ?? UIImage()
    let menuIcon = UIImage(systemName: "line.3.horizontal") ?? UIImage()
    
    var movementEnabled = false {
        didSet {
            canvasView.movementEnabled = movementEnabled
            if movementEnabled { addMoveGestures() }
            else { removeMoveGestures() }
            setStaticButtonStyle(button: moveButton, condition: movementEnabled, iconOn: moveIcon, toggleBg: true)
        }
    }
    var tipType: TipType = .square {
        didSet {
            setStaticButtonStyle(button: tipButton, condition: tipType == .square, iconOn: squareIcon, iconOff: circleIcon)
            updateStroke()
        }
    }
    var tool: String = "" {
        didSet {
            setStaticButtonStyle(button: replaceButton, condition: tool == "replace", iconOn: replaceOnIcon, iconOff: replaceOffIcon, toggleBg: true)
            setStaticButtonStyle(button: eyedropperButton, condition: tool == "eyedropper", iconOn: eyedropperOnIcon, iconOff: eyedropperOffIcon, toggleBg: true)
            updateStroke()
            if(tool == "eyedropper") { addEyedropper() }
            else { removeEyedropper() }
        }
    }
    var tipSize: Int = 2 {
        didSet {
            updateStroke()
        }
    }
    var primary = UIColor.black {
        didSet {
            primaryPicker.backgroundColor = primary
            updateStroke()
        }
    }
    var secondary = UIColor.white {
        didSet {
            secondaryPicker.backgroundColor = secondary
            updateStroke()
        }
    }
    
    var canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var canvasHeight = CGFloat(200)
    var canvasWidth = CGFloat(200)
    var maxScale = CGFloat(4)
    var minScale = CGFloat(0.1)
    var initialCenter = CGPoint(x: 0, y: 0)
    
    var selectedPrimaryPicker = false
    
    var pinch = UIPinchGestureRecognizer()
    var pan = UIPanGestureRecognizer()
    var dropperPan = UIPanGestureRecognizer()
    
    var magnifyingGlass = MagnifyingGlassView(offset: CGPoint.zero,
                                              radius: 50.0,
                                              scale: 2.0,
                                              borderColor: UIColor.lightGray,
                                              borderWidth: 3.0,
                                              showsCrosshair: true,
                                              crosshairColor: UIColor.lightGray,
                                              crosshairWidth: 0.5)
    
    
    
    
    
    
    
    lazy var moveButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, condition: movementEnabled, iconOn: moveIcon, toggleBg: true)
        
        button.addTarget(self, action: #selector(didTapMoveButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var undoButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, iconOn: undoIcon)
        
        button.addTarget(self, action: #selector(didTapUndoButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var redoButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, iconOn: redoIcon)
        
        button.addTarget(self, action: #selector(didTapRedoButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, iconOn: menuIcon)
        
        button.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var secondaryPicker: UIButton = {
        let picker = UIButton()
        picker.backgroundColor = secondary
        picker.layer.borderColor = UIColor.white.cgColor
        picker.layer.borderWidth = 2
        
        picker.addTarget(self, action: #selector(didTapSecondaryPicker), for: .touchUpInside)
        
        picker.heightAnchor.constraint(equalToConstant: 50).isActive = true
        picker.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return picker
    }()
    
    lazy var primaryPicker: UIButton = {
        let picker = UIButton()
        picker.backgroundColor = primary
        picker.layer.borderColor = UIColor.white.cgColor
        picker.layer.borderWidth = 2
        
        picker.addTarget(self, action: #selector(didTapPrimaryPicker), for: .touchUpInside)
        
        picker.heightAnchor.constraint(equalToConstant: 50).isActive = true
        picker.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return picker
    }()
    
    lazy var swapColorButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, iconOn: swapColorIcon)
        
        button.addTarget(self, action: #selector(didTapSwapColorButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var tipButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, condition: tipType == .square, iconOn: squareIcon, iconOff: circleIcon)
        
        button.addTarget(self, action: #selector(didTapTipButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var replaceButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        setStaticButtonStyle(button: button, condition: tool == "replace", iconOn: replaceOnIcon, iconOff: replaceOffIcon, toggleBg: true)
        
        button.addTarget(self, action: #selector(didTapToolButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var eyedropperButton: UIButton = {
        let button = UIButton()
        button.tag = 2
        setStaticButtonStyle(button: button, condition: tool == "eyedropper", iconOn: eyedropperOnIcon, iconOff: eyedropperOffIcon, toggleBg: true)
        
        button.addTarget(self, action: #selector(didTapToolButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var sizeSlider: UISlider = {
        // TO DO: make slider vertical
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 30
        
        slider.addTarget(self, action: #selector(didSizeChange), for: UIControl.Event.valueChanged)
        
        slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return slider
    }()
    
    lazy var colorPicker: ContainerStackView = {
        let stack = ContainerStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.addArrangedSubview(primaryPicker)
        stack.addArrangedSubview(secondaryPicker)
        stack.widthAnchor.constraint(equalToConstant: 50).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        stack.backgroundColor = .systemMint
        return stack
    }()
    
    lazy var rightTopStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.addArrangedSubview(moveButton)
        stack.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return stack
    }()
    
    lazy var rightCenterStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return stack
    }()
    
    lazy var rightBottomStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return stack
    }()
    
    lazy var rightStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = 100
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.addArrangedSubview(rightTopStack)
        stack.addArrangedSubview(rightCenterStack)
        stack.addArrangedSubview(rightBottomStack)
        stack.heightAnchor.constraint(equalToConstant: self.view.bounds.height).isActive = true
        stack.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        return stack
    }()
    
    lazy var leftTopStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.addArrangedSubview(colorPicker)
        stack.addArrangedSubview(swapColorButton)
        stack.addArrangedSubview(tipButton)
        stack.addArrangedSubview(replaceButton)
        stack.addArrangedSubview(eyedropperButton)
        return stack
    }()
    
    lazy var leftCenterStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.addArrangedSubview(sizeSlider)
        return stack
    }()
    
    lazy var leftBottomStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.addArrangedSubview(undoButton)
        stack.addArrangedSubview(redoButton)
        stack.addArrangedSubview(menuButton)
        return stack
    }()
    
    lazy var leftStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.distribution = .equalSpacing
        stack.spacing = 100
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.addArrangedSubview(leftTopStack)
        stack.addArrangedSubview(leftCenterStack)
        stack.addArrangedSubview(leftBottomStack)
        stack.heightAnchor.constraint(equalToConstant: self.view.bounds.height).isActive = true
        stack.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        return stack
    }()
    
    
    
    
    
    
    
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
        view.addSubview(rightStack)
        view.addSubview(leftStack)
        leftStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasView.center = view.center
        makeCircular(view: moveButton)
        makeCircular(view: swapColorButton)
        makeCircular(view: tipButton)
        makeCircular(view: replaceButton)
        makeCircular(view: eyedropperButton)
        makeCircular(view: undoButton)
        makeCircular(view: redoButton)
        makeCircular(view: menuButton)
    }
    
    private func addMoveGestures() {
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(pan)
    }
    
    private func removeMoveGestures() {
        view.removeGestureRecognizer(pinch)
        view.removeGestureRecognizer(pan)
    }
    
    private func addEyedropper() {
        view.addGestureRecognizer(dropperPan)
    }
    
    private func removeEyedropper() {
        view.removeGestureRecognizer(dropperPan)
    }
    
    func updateStroke() {
        guard let primRGBA = primary.rgba else { return }
        guard let secRGBA = secondary.rgba else { return }
        let primary = RGBA32(r: primRGBA.r, g: primRGBA.g, b: primRGBA.b, a: primRGBA.a, nType: CGFloat.self)
        let secondary = RGBA32(r: secRGBA.r, g: secRGBA.g, b: secRGBA.b, a: secRGBA.a, nType: CGFloat.self)
        canvasView.stroke = Stroke(tool: tool, tip: Tip(type: tipType, r: Int(self.tipSize)), primary: primary, secondary: secondary)
    }
    
    func createCanvas() {
        canvasView.removeFromSuperview()
        canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
        canvasView.delegate = self
        view.backgroundColor = UIColor.black
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
        dropperPan = UIPanGestureRecognizer(target: self, action: #selector(didEyedrop(_:)))
    }
    
    func makeCircular(view: UIView) {
        view.layer.cornerRadius = view.bounds.size.width / 2.0
        view.clipsToBounds = true
    }
    
    func setStaticButtonStyle(button: UIButton, condition: Bool = true, iconOn: UIImage, iconOff: UIImage? = nil, toggleBg: Bool = false) {
        if condition || iconOff == nil {
            button.setImage(iconOn, for: .normal)
        } else {
            button.setImage(iconOff, for: .normal)
        }
        if toggleBg { button.backgroundColor = condition ? UIColor.orange.withAlphaComponent(0.9) : UIColor.orange.withAlphaComponent(0.5) }
        else { button.backgroundColor = UIColor.orange.withAlphaComponent(0.5) }
        button.tintColor = UIColor.white
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.layer.magnificationFilter = .nearest
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
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
    
    @objc private func didEyedrop(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            magnifyingGlass.magnifiedView = canvasView
        }
        if gesture.state == .ended {
            magnifyingGlass.magnifiedView = nil
        }
        magnifyingGlass.magnify(at: gesture.location(in: canvasView))
        canvasView.eyedropper(location: gesture.location(in: canvasView))
    }
    
    
    
    
    
    
    
    @objc private func didTapMoveButton() {
        movementEnabled = !movementEnabled
        canvasView.movementEnabled = movementEnabled
    }
    
    @objc private func didTapSwapColorButton() {
        let temp = primary
        primary = secondary
        secondary = temp
    }
    
    @objc private func didTapTipButton() {
        if tipType == .square { tipType = .circle }
        else { tipType = .square }
    }
    
    @objc private func didTapToolButton(_ sender: UIButton) {
        var toolName = ""
        if sender.tag == 1  { toolName = "replace" }
        if sender.tag == 2  { toolName = "eyedropper" }
        
        if tool == toolName { tool = "" }
        else { tool = toolName }
    }
    
    @objc private func didTapUndoButton() {
        canvasView.undo()
    }
    
    @objc private func didTapRedoButton() {
        canvasView.redo()
    }
    
    @objc private func didTapMenuButton() {
        // TO DO: implement menu
    }
    
    @objc private func didTapPrimaryPicker() {
        let colorPickerVC = UIColorPickerViewController()
        selectedPrimaryPicker = true
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    @objc private func didTapSecondaryPicker() {
        let colorPickerVC = UIColorPickerViewController()
        selectedPrimaryPicker = false
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    @objc private func didSizeChange(_ sender: UISlider) {
        tipSize = Int(sender.value)
    }
    
    
    
    
    
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if(selectedPrimaryPicker) { primary = viewController.selectedColor }
        else { secondary = viewController.selectedColor }
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if(selectedPrimaryPicker) { primary = viewController.selectedColor }
        else { secondary = viewController.selectedColor }
    }
    
    func didColorChange(_ color: RGBA32) {
        primary = UIColor(red: CGFloat(color.redComponent) / 255, green: CGFloat(color.greenComponent) / 255, blue: CGFloat(color.blueComponent) / 255, alpha: 255)
    }
}

struct AppViewController_Preview: PreviewProvider {
    static var previews: some View {
        AppViewController().showPreview()
    }
}
