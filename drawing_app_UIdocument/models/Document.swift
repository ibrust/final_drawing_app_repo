//
//  Document.swift
//  drawing_app_UIdocument
//
//  Created by Field Employee on 12/10/20.
//

import UIKit

class Document: UIDocument {
    
    var current_file: File_Model?
    var thumbnail: UIImage? = nil 
    
    override func contents(forType typeName: String) throws -> Any {
        return current_file?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            current_file = File_Model(json: json)
        }
    }
    
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
    
}

