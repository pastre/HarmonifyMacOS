//
//  ViewController.swift
//  HarmonifyMacOS
//
//  Created by Bruno Pastre on 24/06/19.
//  Copyright © 2019 Bruno Pastre. All rights reserved.
//

import Cocoa
import Sparkle

let HARMONIFY_BASE_KEY = "io.github.pastre.harmonify"
let HARMONIFY_UBIQUITOUS_CLOUD_NAME = NSNotification.Name.init("io.github.pastre.harmonify")
let HARMONIFY_ICLOUD_KEY = "io.github.pastre.harmonify.palettes"
let HARMONIFY_EXTENSION_BROADCAST_KEY = "io.github.pastre.harmonify.extension.palettes"
let kCLOSE_POPOVER_NOTIFICATION  = NSNotification.Name( "\(HARMONIFY_BASE_KEY).closepopover")


let kEXTENSION_BASE_KEY = "\(HARMONIFY_BASE_KEY).extension"
let kEXTENSION_CLEAR_LIST  = NSNotification.Name.init("\(kEXTENSION_BASE_KEY).clear")
let kEXTENSION_PALETTE_ADDED = NSNotification.Name.init("\(kEXTENSION_BASE_KEY).newPalette")
let kEXTENSION_PALETTES = NSNotification.Name.init("\(kEXTENSION_BASE_KEY).palettes")

let CURRENT_VERSION = "1.0.0"

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, SUUpdaterDelegate {
    
//    SUUpdater.shared()?
    
    let PALETTE_CELL_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "paletteCell")
    
    @IBOutlet weak var updateWarningButton: NSButton!
    @IBOutlet weak var palettesCollectionView: NSCollectionView!
    
    var updateTimer: Timer!
    var palettes: [Palette]!
    
    func updater(_ updater: SUUpdater, didFinishLoading appcast: SUAppcast) {
        print("Carregou o appcast!!!", appcast)
    }
    
    override func viewDidLoad() {
        
        SUUpdater.shared()?.automaticallyChecksForUpdates = true
        SUUpdater.shared()!.checkForUpdates(self)
        SUUpdater.shared()?.delegate = self
        super.viewDidLoad()
        // COMECA A OUVIR DO ICLOUD PARA BUSCAR DADOS
        NotificationCenter.default.addObserver(self, selector: #selector(self.onICloudUpdate(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        self.setupCollectinView()
        self.updatePalettesFromiCloud()
        self.setupUpdater()
    }
    
    override func viewWillDisappear() {
        self.updateTimer.invalidate()
    }

    func setupUpdater(){
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            
            let url = URL(string: "https://pastre.github.io/harmonify/version.html")!
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                guard let str = String(data: data, encoding: .utf8) else { return }
                if str != CURRENT_VERSION{
                    DispatchQueue.main.async {
                        
                        self.onUpdateNeeded()
                    }
                }
                print(Date(), " - Checked for update", str)
            }
            
            task.resume()
            
        }
        
    }
    
    func onUpdateNeeded(){
        self.updateWarningButton.isEnabled = true
        self.updateWarningButton.isHidden = false
    }
    
    
    func setupCollectinView(){
        let item =  NSNib(nibNamed: "PaletteCollectionViewItem", bundle: nil)
        self.palettesCollectionView.register(item, forItemWithIdentifier: PALETTE_CELL_IDENTIFIER)
        self.palettesCollectionView.delegate = self
        self.palettesCollectionView.dataSource = self
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func updatePalettes(){
        let palettes = NSUbiquitousKeyValueStore.default.data(forKey: "palettes")
        
        DistributedNotificationCenter.default.post(name: kEXTENSION_CLEAR_LIST, object: nil, userInfo: nil)
        DistributedNotificationCenter.default.post(name: kEXTENSION_PALETTES, object: nil, userInfo: ["palettes": palettes])
        
    }
    
    func updatePalettesFromiCloud(){
        guard let data = NSUbiquitousKeyValueStore.default.object(forKey: "palettes") as? Data else {
            self.palettes = [Palette]()
            return
            
        }
        let b64 = Data(base64Encoded: data)!
        let json = String(data: b64, encoding: .utf8)!
        do {
            var palettes = try JSONDecoder().decode([Palette].self, from: b64)
            if self.palettes == nil{
               self.palettes = [Palette]()
            }
            self.palettes.removeAll()
            palettes.sort { (p1, p2) -> Bool in
                return p1.createdAt >= p2.createdAt
            }
            
            
            //self.palettesCollectionView.deleteItems(at: palettesCollectionView.indexPathsForVisibleItems())
            for p in palettes{
                self.palettes.append(p)
                
            }
//            self.palettes = palettes
            
            print("Sorted", self.palettes.map({ (p:  Palette) -> String in
                return "\(p.name)"
            }))
//            self.palettesCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            self.palettes = palettes
            self.palettesCollectionView.reloadData()
        } catch let error {
            print("Erro no json!", error)
        }
        
        print("Updated data from iCloud")
    }
    
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.palettes.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell  = collectionView.makeItem(withIdentifier: PALETTE_CELL_IDENTIFIER, for: indexPath)  as! PaletteCollectionViewItem
        cell.palette = self.palettes[indexPath.item]
        cell.setupPalette()
        return cell
    }
    
    
    @objc func onICloudUpdate(_ sender: Any){
        print("Recebi um novo update de dados do icloud", sender)
        self.updatePalettesFromiCloud()
    }
    
    @IBAction func onHelp(_ sender: Any) {
        let button = sender as! NSButton
        let helpPopover = NSPopover()
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let colorDetailViewController = storyboard.instantiateController(withIdentifier: "HelpViewController") as? NSViewController  else { fatalError("Erro ao carregar as paletas") }
        
        helpPopover.contentViewController = colorDetailViewController
        helpPopover.behavior = .transient
        helpPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }
    
    @IBAction func onClose(_ sender: Any) {
        NotificationCenter.default.post(name: kCLOSE_POPOVER_NOTIFICATION, object: self)
    }
    
}

