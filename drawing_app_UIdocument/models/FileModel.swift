//
//  FileFormat.swift
//  drawing_app_revised
//
//  Created by Field Employee on 12/9/20.
//

import UIKit

struct File_Model : Codable {
    var base_image: String?
    var canvas_image: String?
    var converted_emojis_array: [Converted_Emoji_Label] = []
    
    init(base_image: UIImage, canvas_image: UIImage){
        self.base_image = base_image.pngData()?.base64EncodedString()
        self.canvas_image = canvas_image.pngData()?.base64EncodedString()
    }
    
    struct Converted_Emoji_Label : Codable {
        var x: Int
        var y: Int
        var text: String
        var font_size: Int
        
        init?(_ label: UILabel) {
            if let attributed_text = label.attributedText {
                x = Int(label.center.x)
                y = Int(label.center.y)
                text = attributed_text.string
                font_size = Int(attributed_text.font?.pointSize ?? 30)
            } else {
                return nil
            }
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let decoded_file_obj = try? JSONDecoder().decode(File_Model.self, from: json) {
            self = decoded_file_obj
        } else {
            return nil
        }
    }
    
    func get_base_image() -> UIImage? {
        guard let base_image_string = self.base_image else {return nil}
        guard let base_image_data = Data(base64Encoded: base_image_string) else {return nil}
        return UIImage(data: base_image_data)
    }
    
    func get_canvas_image() -> UIImage? {
        guard let canvas_image_string = self.canvas_image else {return nil}
        guard let canvas_image_data = Data(base64Encoded: canvas_image_string) else {return nil}
        return UIImage(data: canvas_image_data)
    }
    
    mutating func set_base_image(_ input_image: UIImage){
        self.base_image = input_image.pngData()?.base64EncodedString()
    }
    
    mutating func set_canvas_image(_ input_image: UIImage){
        self.canvas_image = input_image.pngData()?.base64EncodedString()
    }
    
    
}

