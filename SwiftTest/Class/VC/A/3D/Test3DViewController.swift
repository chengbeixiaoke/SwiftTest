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
        
        modelView?.loadHDREnvironment()
        modelView?.loadOBJModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        let objURL = Bundle.main.url(forResource: "wd_1", withExtension: "obj")
        let hdrURL = Bundle.main.url(forResource: "wd_1", withExtension: "hdr")
        let modelView = S3DModelView(frame: CGRectMake(0, 0, WidthScreen, WidthScreen),
                                     objURL: objURL,
                                     hdrURL: hdrURL)
        view.addSubview(modelView)
        modelView.backgroundColor = .C_White
        modelView.center = CGPoint(x: WidthScreen / 2.0, y: HeightScreen / 2.0)
        modelView.onModelLoadComplete = { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.view.backgroundColor = .C_White
        }
        self.modelView = modelView
    }
}
