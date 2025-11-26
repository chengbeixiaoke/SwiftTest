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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let objURL = Bundle.main.url(forResource: "wd_1", withExtension: "obj")
        let hdrURL = Bundle.main.url(forResource: "wd_1", withExtension: "hdr")
        let modelView = S3DModelView2(frame: CGRectMake(0, 0, WidthScreen * 2, WidthScreen * 2),
                                     objURL: objURL,
                                     hdrURL: hdrURL)
        modelView.backgroundColor = .C_White
        view.addSubview(modelView)
        modelView.center = CGPoint(x: WidthScreen / 2.0, y: HeightScreen / 2.0)
    }
}
