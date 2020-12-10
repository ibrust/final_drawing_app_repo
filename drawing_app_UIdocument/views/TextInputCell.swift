//
//  TextInputCell.swift
//  drawing_app_revised
//
//  Created by Field Employee on 11/29/20.
//

import UIKit

class Text_Input_Cell: UICollectionViewCell, UITextFieldDelegate{

    @IBOutlet weak var text_input_outlet: UITextField! {
        didSet {
            text_input_outlet.delegate = self
        }
    }
    
    // instead of delegation or direct assignment... you can use a closure 
    var resignation_handler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignation_handler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        text_input_outlet.resignFirstResponder()
        return true
    }
    
}
