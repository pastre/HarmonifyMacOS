//
//  PaletteCollectionViewItem.swift
//  HarmonifyMacOS
//
//  Created by Bruno Pastre on 25/06/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Cocoa

func loadColor(named: String) -> NSColor{
    return NSColor(named: NSColor.Name(named))!
}

class PaletteCollectionViewItem: NSCollectionViewItem, BallViewDelegate {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var nameLabely: NSTextFieldCell!
    @IBOutlet var rootView: NSView!
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var boxView: NSBox!
    var palette: Palette!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _  = self.view
        let _  = self.rootView
    }
    override func viewDidAppear() {
        super.viewDidAppear()
//        self.setupPalette()
        
    }
    

    
    func setupPalette(){
        let cardBg = loadColor(named: "paletteCellBackgroundColor")
        let textColor = loadColor(named: "paletteNameTextColor")
        
        self.nameLabel.textColor = textColor
        self.boxView.fillColor = cardBg
        
        self.nameLabel.stringValue = palette.name
        while self.stackView.arrangedSubviews.count != 0{
            stackView.arrangedSubviews.first!.removeFromSuperview()
        }
        for c in self.palette.colors{
            let asBall = c.asCircularView()
            let tap =  NSClickGestureRecognizer(target: asBall, action: #selector(asBall.onTap))
            asBall.addGestureRecognizer(tap)
            asBall.delegate = self
            self.stackView.addArrangedSubview(asBall)
        }
    }
    
    func onTapped(view: BallView) {
        let copyPopover = NSPopover()
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let colorDetailViewController = storyboard.instantiateController(withIdentifier: "ColorDetailViewController") as? ColorDetailViewController else { fatalError("Erro ao carregar as paletas") }
        colorDetailViewController.color = view.hsv
        copyPopover.contentViewController = colorDetailViewController
        copyPopover.behavior = .transient
        copyPopover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxY)
        
    }
    
    
    
}
 
