//
//  MenuViewController.swift
//  Paintscape
//
//  Created by AC on 8/22/23.
//

import UIKit
import SwiftUI

protocol MenuViewControllerDelegate: AnyObject {
    func didExportOccur()
    func didCreateOccur(height: Int, width: Int)
    func didLoadOccur()
}

class MenuViewController: UIViewController {
    weak var delegate: MenuViewControllerDelegate?
    let MAX_DIMENSION = 2048
    
    lazy var exportButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, title: "Export as PNG")
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return button
    }()
    
    lazy var createButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, title: "Create Canvas")
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    lazy var loadButton: UIButton = {
        let button = UIButton()
        setStaticButtonStyle(button: button, title: "Load Image")
        button.addTarget(self, action: #selector(didTapLoadButton), for: .touchUpInside)
        return button
    }()
    
    lazy var listStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.backgroundColor = UIColor.orange
        stack.addArrangedSubview(exportButton)
        stack.addArrangedSubview(createButton)
        stack.addArrangedSubview(loadButton)
//        stack.isLayoutMarginsRelativeArrangement = true
//        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return stack
    }()
    
    
    
    
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listStack)
        setButtonConstraints()
        setStackConstraints()
    }
    
    func setStackConstraints() {
        listStack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        listStack.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        listStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        listStack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        listStack.isLayoutMarginsRelativeArrangement = true
        listStack.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    func setButtonConstraints() {
        setStaticButtonConstraints(button: exportButton)
        setStaticButtonConstraints(button: createButton)
        setStaticButtonConstraints(button: loadButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setStaticButtonStyle(button: UIButton, title: String) {
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.white
        button.setTitle(title, for: .normal)
    }
    
    func setStaticButtonConstraints(button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
    }
    
    @objc private func didTapSaveButton() {
        delegate?.didExportOccur()
    }
    
    @objc private func didTapCreateButton() {
        let alert = UIAlertController(title: "Canvas Dimensions", message: "Enter a height and width", preferredStyle: .alert)

        // Add a textField to your controller, with a placeholder value & secure entry enabled
        alert.addTextField { textField in
            textField.placeholder = "Height"
            textField.textAlignment = .center
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Width"
            textField.textAlignment = .center
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancelled")
        }

        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            var height = alert.textFields?[0].text ?? "200"
            var width = alert.textFields?[1].text ?? "200"
            print("Height value: \(height)")
            print("Width value: \(width)")
            if Int(height) ?? 2048 > 2048 { height = String(self.MAX_DIMENSION) }
            if Int(width) ?? 2048 > 2048 { width = String(self.MAX_DIMENSION) }
            self.delegate?.didCreateOccur(height: Int(height) ?? 200, width: Int(width) ?? 200)
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: false, completion: nil)
        
    }
    
    @objc private func didTapLoadButton() {
        delegate?.didLoadOccur()
    }
}

struct MenuViewController_Preview: PreviewProvider {
    static var previews: some View {
        MenuViewController().showPreview()
    }
}
