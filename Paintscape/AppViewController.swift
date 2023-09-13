//
//  AppViewController.swift
//  Paintscape
//
//  Created by AC on 8/17/23.
//

import UIKit
import SwiftUI

class AppViewController: UIViewController, UIColorPickerViewControllerDelegate, CanvasViewDelegate, MenuViewControllerDelegate {
    
    
    let moveIcon = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right") ?? UIImage()
    let brushOnIcon = UIImage(systemName: "paintbrush.pointed.fill") ?? UIImage()
    let brushOffIcon = UIImage(systemName: "paintbrush.pointed") ?? UIImage()
    let swapColorIcon = UIImage(systemName: "arrow.triangle.2.circlepath") ?? UIImage()
    let squareIcon = UIImage(named: "square_tip") ?? UIImage()
    let circleIcon = UIImage(named: "circle_tip") ?? UIImage()
    let toolsIcon = UIImage(systemName: "pencil.and.ruler") ?? UIImage()
    let replaceOnIcon = UIImage(systemName: "square.fill.on.square.fill") ?? UIImage()
    let replaceOffIcon = UIImage(systemName: "square.fill.on.square") ?? UIImage()
    let eyedropperOnIcon = UIImage(systemName: "eyedropper.full") ?? UIImage()
    let eyedropperOffIcon = UIImage(systemName: "eyedropper") ?? UIImage()
    let fillOnIcon = UIImage(systemName: "paintbrush.fill") ?? UIImage()
    let fillOffIcon = UIImage(systemName: "paintbrush") ?? UIImage()
    let undoIcon = UIImage(systemName: "arrow.uturn.backward") ?? UIImage()
    let redoIcon = UIImage(systemName: "arrow.uturn.forward") ?? UIImage()
    let menuIcon = UIImage(systemName: "line.3.horizontal") ?? UIImage()
    var toolIcon = UIImage(systemName: "paintbrush.pointed.fill") ?? UIImage()
    
    let accentColor = UIColor.orange
    
    var toolsExpanded = true {
        didSet {
            if toolsExpanded { addButtonsToStack(stack: toolsStack, buttons: toolButtons) }
            else { removeButtonsFromStack(stack: toolsStack, buttons: toolButtons) }
        }
    }
    var movementEnabled = false {
        didSet {
            canvasView.movementEnabled = movementEnabled
            if movementEnabled { addMoveGestures() }
            else { removeMoveGestures() }
        }
    }
    var tipType: TipType = .square {
        didSet {
            setStaticButtonStyle(button: tipButton, condition: tipType == .square, iconOn: squareIcon, iconOff: circleIcon)
            updateStroke()
        }
    }
    var tool: String = "brush" {
        didSet {
            setStaticButtonStyle(button: brushButton, condition: tool == "brush", iconOn: brushOnIcon, iconOff: brushOffIcon, toggleBg: true)
            setStaticButtonStyle(button: replaceButton, condition: tool == "replace", iconOn: replaceOnIcon, iconOff: replaceOffIcon, toggleBg: true)
            setStaticButtonStyle(button: eyedropperButton, condition: tool == "eyedropper", iconOn: eyedropperOnIcon, iconOff: eyedropperOffIcon, toggleBg: true)
            setStaticButtonStyle(button: fillButton, condition: tool == "fill", iconOn: fillOnIcon, iconOff: fillOffIcon, toggleBg: true)
            updateStroke()
            removeEyedropper()
            rightTopStack.removeArrangedSubview(tipButton)
            tipButton.removeFromSuperview()
            if tool == "eyedropper" { addEyedropper() }
            if tool == "brush" || tool == "replace" {
                rightTopStack.addArrangedSubview(tipButton)
            }
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
    
    
    

    
    lazy var toolsButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, iconOn: toolsIcon)
        
        button.addTarget(self, action: #selector(didTapToolsButton), for: .touchUpInside)
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    lazy var brushButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        setStaticButtonStyle(button: button, condition: tool == "brush", iconOn: brushOnIcon, iconOff: brushOffIcon, toggleBg: true)
        
        button.addTarget(self, action: #selector(didTapToolButton(_:)), for: .touchUpInside)
        
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
    
    lazy var fillButton: UIButton = {
        let button = UIButton()
        button.tag = 3
        setStaticButtonStyle(button: button, condition: tool == "fill", iconOn: fillOnIcon, iconOff: fillOffIcon, toggleBg: true)
        
        button.addTarget(self, action: #selector(didTapToolButton(_:)), for: .touchUpInside)
        
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
        
        picker.heightAnchor.constraint(equalToConstant: 25).isActive = true
        picker.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return picker
    }()
    
    lazy var primaryPicker: UIButton = {
        let picker = UIButton()
        picker.backgroundColor = primary
        picker.layer.borderColor = UIColor.white.cgColor
        picker.layer.borderWidth = 2
        
        picker.addTarget(self, action: #selector(didTapPrimaryPicker), for: .touchUpInside)
        
        picker.heightAnchor.constraint(equalToConstant: 25).isActive = true
        picker.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return picker
    }()
    
    lazy var swapColorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.layer.magnificationFilter = .nearest
        
        var config = UIButton.Configuration.filled()
        config.image = swapColorIcon
        config.imagePadding = 5
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.configuration = config
        
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        button.layer.cornerRadius = 25 / 2.0
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(didTapSwapColorButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var tipButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, condition: tipType == .square, iconOn: squareIcon, iconOff: circleIcon)
        
        button.addTarget(self, action: #selector(didTapTipButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var sizeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.maximumValue = 30
        slider.tintColor = accentColor
        
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
        return stack
    }()
    
    lazy var colorView: UIView = {
        let cView = UIView()
        cView.translatesAutoresizingMaskIntoConstraints = false
        cView.addSubview(swapColorButton)
        cView.addSubview(colorPicker)
        cView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        cView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        colorPicker.trailingAnchor.constraint(equalTo: cView.trailingAnchor).isActive = true
        swapColorButton.leadingAnchor.constraint(equalTo: cView.leadingAnchor).isActive = true
        swapColorButton.centerYAnchor.constraint(equalTo: cView.centerYAnchor).isActive = true
        return cView
    }()
    
    lazy var toolsStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.addArrangedSubview(toolsButton)
        addButtonsToStack(stack: stack, buttons: toolButtons)
        return stack
    }()
    
    lazy var rightTopStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.addArrangedSubview(toolsStack)
        stack.addArrangedSubview(tipButton)
        return stack
    }()
    
    lazy var rightCenterStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    
    lazy var rightBottomStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
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
        stack.addArrangedSubview(colorView)
        return stack
    }()
    
    lazy var leftCenterStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
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
    
    lazy var centerStack: ContainerStackView = {
        let stack = ContainerStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 100
//        stack.addArrangedSubview(sizeSlider)
        stack.heightAnchor.constraint(equalToConstant: self.view.bounds.height).isActive = true
        stack.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        return stack
    }()
    
    var toolButtons: [UIButton] = []
    
    
    
    
    
    
    
    init(height: CGFloat = CGFloat(200), width: CGFloat = CGFloat(200)) {
        super.init(nibName: nil, bundle: nil)
        self.canvasHeight = height
        self.canvasWidth = width
        toolButtons = [brushButton, replaceButton, eyedropperButton, fillButton]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCanvas(height: canvasHeight, width: canvasWidth)
        view.addSubview(rightStack)
        view.addSubview(sizeSlider)
        view.addSubview(leftStack)
        leftStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sizeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sizeSlider.topAnchor.constraint(equalTo: view.topAnchor, constant: 45).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasView.center = view.center
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
    
    private func removeButtonsFromStack(stack: UIStackView, buttons: [UIButton]) {
        buttons.forEach {button in
            stack.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
    }
    
    private func addButtonsToStack(stack: UIStackView, buttons: [UIButton]) {
        buttons.forEach {button in
            stack.addArrangedSubview(button)
        }
    }
    
    func updateStroke() {
        guard let primRGBA = primary.rgba else { return }
        guard let secRGBA = secondary.rgba else { return }
        let primary = RGBA32(r: primRGBA.r, g: primRGBA.g, b: primRGBA.b, a: primRGBA.a, nType: CGFloat.self)
        let secondary = RGBA32(r: secRGBA.r, g: secRGBA.g, b: secRGBA.b, a: secRGBA.a, nType: CGFloat.self)
        canvasView.stroke = Stroke(tool: tool, tip: Tip(type: tipType, r: Int(self.tipSize)), primary: primary, secondary: secondary)
    }
    
    func createCanvas(height: CGFloat, width: CGFloat) {
        canvasView.removeFromSuperview()
        canvasHeight = height
        canvasWidth = width
        canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
        canvasView.delegate = self
        view.backgroundColor = UIColor.black
        view.insertSubview(canvasView, at: 0)
        
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
    
    func setStaticButtonStyle(button: UIButton, condition: Bool = true, iconOn: UIImage, iconOff: UIImage? = nil, toggleBg: Bool = false) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.layer.magnificationFilter = .nearest
        
        var config = UIButton.Configuration.filled()
        if condition || iconOff == nil {
            config.image = iconOn
        } else {
            config.image = iconOff
        }
        config.imagePadding = 15
        config.baseForegroundColor = .white
        if toggleBg { config.baseBackgroundColor = condition ? accentColor.withAlphaComponent(0.9) : accentColor.withAlphaComponent(0.5) }
        else { config.baseBackgroundColor = accentColor.withAlphaComponent(0.5) }
        button.configuration = config
        
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 50 / 2.0
        button.clipsToBounds = true
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
    
    
    
    
    

    
    @objc private func didTapSwapColorButton() {
        let temp = primary
        primary = secondary
        secondary = temp
    }
    
    @objc private func didTapTipButton() {
        if tipType == .square { tipType = .circle }
        else { tipType = .square }
    }
    
    @objc private func didTapToolsButton() {
        toolsExpanded = !toolsExpanded
    }
    
    @objc private func didTapToolButton(_ sender: UIButton) {
        var toolName = ""
        if sender.tag == 0  { toolName = "brush" }
        if sender.tag == 1  { toolName = "replace" }
        if sender.tag == 2  { toolName = "eyedropper" }
        if sender.tag == 3  { toolName = "fill" }
        
        if tool == toolName {
            movementEnabled = true
            tool = ""
        }
        else {
            movementEnabled = false
            tool = toolName
        }
    }
    
    @objc private func didTapUndoButton() {
        canvasView.undo()
    }
    
    @objc private func didTapRedoButton() {
        canvasView.redo()
    }
    
    @objc private func didTapMenuButton() {
        let menuViewController = MenuViewController()
        menuViewController.modalPresentationStyle = .formSheet
        menuViewController.delegate = self
        present(menuViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapPrimaryPicker() {
        let colorPickerVC = UIColorPickerViewController()
        selectedPrimaryPicker = true
        colorPickerVC.selectedColor = primary
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    @objc private func didTapSecondaryPicker() {
        let colorPickerVC = UIColorPickerViewController()
        selectedPrimaryPicker = false
        colorPickerVC.selectedColor = secondary
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
    }
    
    @objc private func didSizeChange(_ sender: UISlider) {
        tipSize = Int(sender.value)
        sender.value = Float(tipSize)
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
    
    
    
    
    
    
    
    
    func didExportOccur() {
        guard let imageToSave = canvasView.imageView.image else { return }
        guard let pngData =  imageToSave.pngData() else { return }
        guard let imgPng = UIImage(data: pngData) else { return }
        
        UIImageWriteToSavedPhotosAlbum(imgPng, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func didCreateOccur(height: Int, width: Int) {
        createCanvas(height: CGFloat(height), width: CGFloat(width))
        dismiss(animated: true, completion: nil)
    }
    
    func didLoadOccur() {
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            let alert = UIAlertController(title: "Unable to export image", message: "Make sure Paintscape has photo gallery access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            dismiss(animated: true){ () -> Void in
                self.present(alert, animated: true, completion: nil)
            }
            print(error.localizedDescription)

        } else {
            let alert = UIAlertController(title: "Export Image", message: "Image successfully saved to photo gallery!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            dismiss(animated: true){ () -> Void in
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

struct AppViewController_Preview: PreviewProvider {
    static var previews: some View {
        AppViewController().showPreview()
    }
}
