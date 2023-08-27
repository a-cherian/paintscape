//
//  UIImageViewExtension.swift
//  Paintscape
//
//  Created by AC on 8/15/23.
//

import UIKit
import SwiftUI

extension UIImageView {
    // enable preview for UIKit
    // source: https://dev.to/gualtierofr/preview-uikit-views-in-xcode-3543
    @available(iOS 13, *)
    private struct Preview: UIViewRepresentable {

        typealias UIViewType = UIImageView
        let view: UIImageView
        
        func updateUIView(_ uiView: UIImageView, context: Context) {
            
        }
        
        func makeUIView(context: Context) -> UIImageView {
            return view
        }
    }
    
    @available(iOS 13, *)
    func showUIPreview() -> some View {
        // inject self (the current UIView) for the preview
        Preview(view: self)
    }
}
