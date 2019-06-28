//
//  AppDelegate.swift
//  HarmonifyMacOS
//
//  Created by Bruno Pastre on 24/06/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var popoverView = NSPopover()
    var isPopoverOpened: Bool!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.isPopoverOpened = false
//        statusItem.button?.title = "Harmonify"
        statusItem.button?.image = NSImage(named: "statusBarIcon")
//        NSButton(
        statusItem.button?.target = self
        statusItem.button?.action = #selector(self.onStatusItemPressed)
//        statusItem.behavior = .removalAllowed
        NotificationCenter.default.addObserver(self, selector: #selector(self.onStatusItemPressed), name: kCLOSE_POPOVER_NOTIFICATION, object: nil)
        
        print("BROW CARREGOU")
    }
    
    @objc func onStatusItemPressed(){
        if self.isPopoverOpened{
            self.closePopover()
        }else{
            self.openPopover()
        }
        self.isPopoverOpened = !self.isPopoverOpened
    }
    
    func closePopover(){
        self.popoverView.performClose(self)
    }
    
    func openPopover(){
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let palettesCollectionViewController = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController  else { fatalError("Erro ao carregar as paletas") }
        
        guard let button = self.statusItem.button else { fatalError("Brow  sem botao") }
        
        
        popoverView.contentViewController = palettesCollectionViewController
        popoverView.behavior = .applicationDefined
        popoverView.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        
        print("DEU BOMMMM")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    


}

