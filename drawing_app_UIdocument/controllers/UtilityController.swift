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
    
    @IBAction func save_button_handler(_ sender: UIButton) {
        let file_name = "Untitled"
        if let json = canvas_controller_reference?.current_file.json {
            
            // save the file to the sandbox
            if let url = try? FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent(file_name + ".json") {
                do {
                    try json.write(to: url)
                } catch let error {
                    print("failed to save: ", error)
                }
            }
            
        }
    }
    
    @IBAction func open_button_handler(_ sender: UIButton) {
        //let decoded_json = try? JSONDecoder().decode(File_Model.self, from: json)
    }
    
    @IBAction func new_file_button_handler(_ sender: UIButton) {
    
    }
    
    @IBAction func coloring_book_button_handler(_ sender: UIButton) {
    
    }
    
    func load_last_document() {
        
        if let url = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("Untitled.json") {
            if let json_data = try? Data(contentsOf: url) {
                guard let last_file = File_Model(json: json_data) else { return }
                canvas_controller_reference?.current_file = last_file
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
