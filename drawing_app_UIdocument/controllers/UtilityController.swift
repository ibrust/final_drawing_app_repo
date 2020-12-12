//
//  UtilityController.swift
//  drawing_app
//
//  Created by Field Employee on 11/5/20.
//

import UIKit
import MobileCoreServices

class Utility_Controller: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var main_controller_reference: Main_Controller? = nil
    var canvas_controller_reference: Canvas_Controller? = nil 
    
    var document: Document?
    
    @IBOutlet weak var camera_outlet: UIButton! {
        didSet {
            camera_outlet.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    @IBAction func save_button_handler(_ sender: UIButton? = nil) {
        document?.current_file = canvas_controller_reference?.current_file
        if document?.current_file != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func open_button_handler(_ sender: UIButton) {
        save_button_handler()
        document?.thumbnail = canvas_controller_reference?.merge_imageview_and_canvas()
        main_controller_reference?.dismiss(animated: true)
        document?.close()
    }
    
    @IBAction func coloring_book_button_handler(_ sender: UIButton) {
        
    }
    
    @IBAction func camera_button_handler(_ sender: UIButton) {
        let camera_picker = UIImagePickerController()
        camera_picker.sourceType = .camera
        camera_picker.mediaTypes = [kUTTypeImage as String]
        camera_picker.allowsEditing = true
        camera_picker.delegate = self
        present(camera_picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.presentingViewController?.dismiss(animated: true)
        
        if let image = ((info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage) {
            canvas_controller_reference?.background_image = image
        }
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
