//
//  DrawBarController.swift
//  drawing_app
//
//  Created by Field Employee on 10/31/20.
//

import UIKit

class Draw_Controller: UIViewController {

    var canvas_controller_reference: Canvas_Controller? = nil
    var main_controller_reference: Main_Controller? = nil
    
    @IBOutlet weak var segmented_control_outlet: UISegmentedControl!
    
    @IBAction func clear_button_pressed(_ sender: UIButton) {
        self.canvas_controller_reference?.clear_paths()
        self.canvas_controller_reference?.reset_background_image()
    }
    
    @IBAction func width_slider_changed(_ sender: UISlider) {
        self.canvas_controller_reference?.stroke_options.width = CGFloat(sender.value)
    }
    
    @IBAction func segmented_control_pressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.change_mode(.move)
        case 1:
            self.change_mode(.pencil)
        case 2:
            self.change_mode(.eraser)
        case 3:
            self.change_mode(.line)
        case 4:
            self.change_mode(.polyline)
        case 5:
            self.change_mode(.fill)
        default:
            return
        }
    }
    
    private func change_mode(_ new_mode: Drawing_Modes){
        self.canvas_controller_reference?.drawing_mode = new_mode
        self.main_controller_reference?.old_drawing_mode = new_mode
    }
    
}
