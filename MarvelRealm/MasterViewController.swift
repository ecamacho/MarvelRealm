//
//  MasterViewController.swift
//  MarvelRealm
//
//  Created by Erick Camacho on 7/12/15.
//  Copyright (c) 2015 ecamacho. All rights reserved.
//

import UIKit

import Haneke

import RealmSwift

class MasterViewController: UICollectionViewController, UISearchBarDelegate {

  var characters: Results<Character>?
  

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Character.fromServer { () -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.characters = Character.all()
        self.collectionView?.reloadData()
      }
    }
  }

  

  // MARK: - Segues

//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == "showDetail" {
//        if let indexPath = self.tableView.indexPathForSelectedRow() {
//            let object = objects[indexPath.row] as! NSDate
//        (segue.destinationViewController as! DetailViewController).detailItem = object
//        }
//    }
//  }

  // MARK: - CollectionView
  

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
    if let c = characters {
      return c.count
    }
    return 0
  }
  
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MarvelCell", forIndexPath: indexPath) as! MarvelCell
    let character = self.characters![indexPath.row]
    if character.thumbnailUrl != "" {
      cell.imageView.hnk_setImageFromURL(NSURL(string: character.thumbnailUrl)!)
    }
    cell.nameLabel.text = character.name
    return cell
  }

  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "searchBar", forIndexPath: indexPath) as! UICollectionReusableView
  }

  // MARK: - SearchBar
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    let realm = Realm()
    self.characters = realm.objects(Character).filter("name CONTAINS '\(searchText)'")
    self.collectionView?.reloadData()
  }
  
  
  


}

