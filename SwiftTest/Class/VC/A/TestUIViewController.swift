//
//  TestUIViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/4/11.
//

import UIKit

class TestUIViewController: UIViewController, UITextFieldDelegate {
    let textField = UITextField(frame: CGRectMake(50, 100, 300, 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        
        textField.placeholder = "输入"
        view.addSubview(textField)
        textField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("输入开始")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("输入结束")
    }
}




