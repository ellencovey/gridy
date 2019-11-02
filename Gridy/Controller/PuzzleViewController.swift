//
//  PuzzleViewController.swift
//  Gridy
//
//  Created by Ellen Covey on 23/07/2019.
//  Copyright © 2019 Ellen Covey. All rights reserved.
//

import UIKit

class PuzzleViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate,
    UIDropInteractionDelegate {
    
    var collectionViewIndexPath: IndexPath?
    var moves = 0
    
    // arrays of tiles from split image
    var originalTiles = [UIImage]() // image split into pieces, will reorder
    var originalTilesBeforeShuffle = [UIImage]() // keep correct order for comparison
    var targetTiles = [UIImage]() // holds placeholders in drop spaces
    
    @IBOutlet weak var hintImage: UIImageView!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var movesCount: UILabel!
    @IBOutlet weak var tileCollectionView: UICollectionView!
    @IBOutlet weak var targetCollectionView: UICollectionView!
    @IBAction func showHint(_ sender: Any) {
        // shows hint for 2 seconds and updates move count
        hintImage.image = editedImage
        hintView.isHidden = false
        perform(#selector(hideHintView), with: nil, afterDelay: 2)
        moves += 1
        movesCount.text = String(moves)
    }
    
    public var editedImage: UIImage? // for screenshot from last view (screenshot in A)
    let gridSize = 4
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting collection view delegates & data sources
        tileCollectionView.dataSource = self
        targetCollectionView.dataSource = self
        tileCollectionView.dragDelegate = self
        tileCollectionView.dropDelegate = self
        targetCollectionView.dragDelegate = self
        targetCollectionView.dropDelegate = self
        
        // not allowing collection views to scroll
        tileCollectionView.isScrollEnabled = false
        targetCollectionView.isScrollEnabled = false
        
        // fill tile arrays
        if let editedImage = editedImage {
            let tiles = editedImage.slice(into: 4)
            originalTilesBeforeShuffle = tiles
            originalTiles.removeAll()
            originalTiles = tiles
            originalTiles.shuffle()
            tileCollectionView.reloadData()
            
            for _ in 1...16 {
                targetTiles.append(UIImage(named: "placeholder")!)
            }
            
            targetCollectionView.reloadData()
        }
        
        // enabling drag on collection views
        tileCollectionView.dragInteractionEnabled = true
        targetCollectionView.dragInteractionEnabled = true
        
    }
    
    // configuring collection view numbers
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tileCollectionView {
            return originalTiles.count
        } else {
            return targetTiles.count
        }
    }
    
    // configuring collection views' content
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        if collectionView == tileCollectionView {
            let width = (tileCollectionView.frame.size.width - 40) / 6
            let layout = tileCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: width)
            cell.tileImageView.image = originalTiles[indexPath.row]
        } else {
            let width = (targetCollectionView.frame.size.width - 6) / 4
            let layout = targetCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: width)
            cell.tileImageView.image = targetTiles[indexPath.row]
        }
        
        return cell
    }
    
    // configuring drag
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        collectionViewIndexPath = indexPath
        
        let item = collectionView == tileCollectionView ? originalTiles[indexPath.row] : targetTiles[indexPath.row]
        
        let itemProvider = NSItemProvider(object: item as UIImage)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    // configuring drop
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let dip: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            dip = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            dip = IndexPath(row: row, section: section)
        }
        
        if collectionView === targetCollectionView {
            print("destinationIndexPath: \(dip)")
            moveItems(coordinator: coordinator, destinationIndexPath: dip, collectionView: collectionView)
        } else if collectionView === tileCollectionView {
            return
        }
    }
    
    // moving tiles between collection views adn updating contents
    private func moveItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        
        collectionView.performBatchUpdates({
            let dragItem = items.first!.dragItem.localObject as! UIImage
            if dragItem === originalTilesBeforeShuffle[destinationIndexPath.item] {
                self.targetTiles.insert(items.first!.dragItem.localObject as! UIImage, at: destinationIndexPath.row)
                targetCollectionView.insertItems(at: [destinationIndexPath])
                
                if let selected = collectionViewIndexPath {
                    originalTiles.remove(at: selected.row)
                    if let temp = UIImage(named: "placeholder") {
                        let blank = temp
                        originalTiles.insert(blank, at: selected.row)
                    }
                    tileCollectionView.reloadData()
                    
                }
                
            }
        })
        
        collectionView.performBatchUpdates({
            if items.first!.dragItem.localObject as! UIImage === originalTilesBeforeShuffle[destinationIndexPath.item] {
                targetTiles.remove(at: destinationIndexPath.row + 1)
                let nextIndexPath = NSIndexPath(row: destinationIndexPath.row + 1, section: 0)
                targetCollectionView.deleteItems(at: [nextIndexPath] as [IndexPath])
                targetCollectionView.reloadData()
            }
        })
        
        coordinator.drop(items.first!.dragItem, toItemAt: destinationIndexPath)
        
        // adding to move count and updating label
        moves += 1
        movesCount.text = String(moves)
        
        // testing for win after each move
        if originalTiles.allSatisfy({$0 == UIImage(named: "placeholder")}) {
            print("You win!")
            performSegue(withIdentifier: "PuzzletoWinSegue", sender: nil)
        }

    }
    
    @objc func hideHintView() {
        hintView.isHidden = true
    }
    
    // sends final image to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PuzzletoWinSegue"
        {
            if let destinationVC = segue.destination as? WinViewController {
                destinationVC.fullImage = editedImage
                destinationVC.finalMoves = moves
            }
        }
    }
    
    // refreshes collection view layouts after rotating
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tileCollectionView.reloadData()
        targetCollectionView.reloadData()
    }
    
}
