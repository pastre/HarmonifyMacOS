//
//  HelpPanelViewController.swift
//  Easy Color Picker
//
//  Created by Bruno Pastre on 02/07/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Cocoa
import Sparkle

class HelpPanelViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func onCheckForUpdate(_ sender: Any) {
        
        SUUpdater.shared()!.checkForUpdates(self)
    }
    
}
