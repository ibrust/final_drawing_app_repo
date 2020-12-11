//
//  UtilityController.swift
//  drawing_app
//
//  Created by Field Employee on 11/5/20.
//

import UIKit

class Utility_Controller: UIViewController {

    var main_controller_reference: Main_Controller? = nil
    var canvas_controller_reference: Canvas_Controller? = nil 
    
    var document: Document?
    
    @IBAction func save_button_handler(_ sender: UIButton? = nil) {
        document?.current_file = canvas_controller_reference?.current_file
        if document?.current_file != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func open_button_handler(_ sender: UIButton) {
        save_button_handler()
        print("dismiss?", main_controller_reference)
        main_controller_reference?.dismiss(animated: true)
        print("dismiss?")
        document?.close()
    }
    
    @IBAction func new_file_button_handler(_ sender: UIButton) {
    
    }
    
    @IBAction func coloring_book_button_handler(_ sender: UIButton) {
    
    }
    
    func load_document() {
        document?.open { [weak self] success in
            if success {
                guard let current_file = self?.document?.current_file else {return}
                self?.canvas_controller_reference?.current_file = current_file
            }
        }
    }

}
