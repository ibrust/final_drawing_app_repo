//
//  Document.swift
//  drawing_app_UIdocument
//
//  Created by Field Employee on 12/10/20.
//

import UIKit

class Document: UIDocument {
    
    var current_file: File_Model?
    
    override func contents(forType typeName: String) throws -> Any {
        return current_file?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            current_file = File_Model(json: json)
        }
    }
}

