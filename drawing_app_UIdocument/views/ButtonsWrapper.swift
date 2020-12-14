//
//  ButtonsWrapper.swift
//  drawing_app_UIdocument
//
//  Created by Field Employee on 12/12/20.
//

import UIKit

class Buttons_Wrapper: UIView {

    var canvas_controller_reference: Canvas_Controller? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        canvas_controller_reference?.draw_and_remove_emojis()
    }

}
