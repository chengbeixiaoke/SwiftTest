//
//  Test3DViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/12.
//

import UIKit
import SceneKit
import SceneKit.ModelIO

class Test3DViewController: BaseViewController {
    
    var modelView: S3DModelView?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load3DModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .C_White
    }
    
    func load3DModel() {
        let objURL = Bundle.main.url(forResource: "wd_1", withExtension: "obj")
        let hdrURL = Bundle.main.url(forResource: "wd_1", withExtension: "hdr")
        let modelView = S3DModelView(frame: CGRectMake(0, 0, WidthScreen * 2, WidthScreen * 2),
                                     objURL: objURL,
                                     hdrURL: hdrURL)
        view.addSubview(modelView)
        modelView.backgroundColor = .C_White
        modelView.center = CGPoint(x: WidthScreen / 2.0, y: HeightScreen / 2.0)
        self.modelView = modelView
    }
}
