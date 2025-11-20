//
//  T3D3ViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/11/12.
//

import UIKit
import SceneKit
import SceneKit.ModelIO

class T3D3ViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let objURL = Bundle.main.url(forResource: "wd_obj", withExtension: "obj")
        let hdrURL = Bundle.main.url(forResource: "wd_obj", withExtension: "hdr")
        let modelView = S3DModelView(frame: CGRectMake(0, 300, WidthScreen * 2, WidthScreen / UIScale(260) * UIScale(179) * 2),
                                objURL: objURL,
                                hdrURL: hdrURL)
        modelView.backgroundColor = .C_White
        view.addSubview(modelView)
        modelView.center = CGPoint(x: WidthScreen / 2.0, y: 300 + 179 / 2.0)
    }
}
