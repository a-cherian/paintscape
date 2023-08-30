//
//  ViewController.swift
//  Paintscape
//
//  Created by AC on 8/16/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    var drawView: DrawViewOld!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        drawView = DrawViewOld(frameWidth: 500, frameHeight: 500)
        drawView.backgroundColor = .red
        self.view.addSubview(drawView)
        
        drawView.translatesAutoresizingMaskIntoConstraints = false
        drawView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        drawView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        drawView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        drawView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
    }
    
    func drawShape(_ sender: Any) {
        drawView.drawTool(selectedTool: .brush)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        ViewController().showPreview()
    }
}

