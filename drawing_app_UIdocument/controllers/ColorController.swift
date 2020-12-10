//
//  ColorController.swift
//  drawing_app
//
//  Created by Field Employee on 11/1/20.
//

import UIKit

class Color_Controller: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var canvas_controller_reference: Canvas_Controller? = nil

    private let reuseIdentifier = "color_cell"
    
    var previous_highlighted_cell: Color_Cell? = nil
    var current_highlighted_index: Int? = nil
    var array_of_colors: [UIColor] = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black, UIColor.white, UIColor.orange, UIColor.purple, UIColor.yellow, UIColor.magenta, UIColor.cyan, UIColor.darkGray, UIColor.lightGray, UIColor.brown]

    @IBOutlet weak var collection_view_outlet: UICollectionView!

    
    @IBAction func opacity_slider_changed(_ sender: UISlider) {
        canvas_controller_reference?.stroke_options.opacity = CGFloat(sender.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collection_view_outlet.dataSource = self
        self.collection_view_outlet.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array_of_colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? Color_Cell ?? Color_Cell()
        
        if let color_view = cell.color_view_outlet {
            color_view.backgroundColor = array_of_colors[indexPath.row]
        }
        
        if current_highlighted_index ?? -1 == indexPath.row {
            cell.border_outlet.backgroundColor = UIColor.yellow
        } else {
            cell.border_outlet.backgroundColor = UIColor.systemBlue
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        canvas_controller_reference?.stroke_options.color = array_of_colors[indexPath.row]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? Color_Cell else{return}
        cell.border_outlet.backgroundColor = UIColor.yellow
        cell.is_highlighted = true
        current_highlighted_index = indexPath.row
        if previous_highlighted_cell != nil {
            previous_highlighted_cell?.border_outlet.backgroundColor = UIColor.systemBlue
            previous_highlighted_cell?.is_highlighted = false
        }
        previous_highlighted_cell = cell
        collection_view_outlet.reloadData()
    }
    
    
    func RGB_to_UIColor(red: Int, green: Int, blue: Int) -> UIColor {
        let cg_red = CGFloat(Double(red) / 255.0)
        let cg_green = CGFloat(Double(green) / 255.0)
        let cg_blue = CGFloat(Double(blue) / 255.0)
        
        let new_color = UIColor(red: cg_red, green: cg_green, blue: cg_blue, alpha: 1.0)
        return new_color
    }
    
}
