//
//  ColorDetailViewController.swift
//  HarmonifyMacOS
//
//  Created by Bruno Pastre on 27/06/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Cocoa

class ColorDetailViewController: NSViewController {

    @IBOutlet weak var colorCodeLabel: NSTextField!
    var color: HSV!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        self.colorCodeLabel.stringValue = "#\( self.color.getDescriptiveHex())"
    }
    
    func animatePopover(with message: String){
        self.colorCodeLabel.stringValue = message
    }
    
    @IBAction func onCopy(_ sender: Any) {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        if NSPasteboard.general.setString(self.color.getDescriptiveHex(), forType: .string){
            print("Deu bom no clipboard")
            self.animatePopover(with: "Copied!")
        }else{
            self.animatePopover(with: "Error copying")
        }
    }
}
