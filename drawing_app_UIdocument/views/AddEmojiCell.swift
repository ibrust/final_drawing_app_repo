//
//  Add_Emoji_Cell.swift
//  drawing_app_revised
//
//  Created by Field Employee on 11/29/20.
//

import UIKit

class Add_Emoji_Cell: UICollectionViewCell {

    var emoji_controller_reference: Emoji_Controller? = nil
    
    @IBAction func add_button_handler(_ sender: UIButton) {
        
        self.emoji_controller_reference?.add_emoji()
        
    }

}
