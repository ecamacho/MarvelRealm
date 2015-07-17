//
//  Character.swift
//  MarvelRealm
//
//  Created by Erick Camacho on 7/12/15.
//  Copyright (c) 2015 ecamacho. All rights reserved.
//

import RealmSwift

class Character: Object {

  dynamic var id: Int = 0
  dynamic var name: String = ""
  dynamic var desc: String = ""
  dynamic var thumbnailUrl: String = ""
  
  
  override static func primaryKey() -> String? {
    return "id"
  }
  
  override static func indexedProperties() -> [String] {
    return ["name"]
  }
  
  class func fromDictionary(dic: NSDictionary) {
    let c = Character()
    if let id = dic["id"] as? Int {
      c.id = id
    }
    if let name = dic["name"] as? String {
      c.name = name
    }
    
    if let desc = dic["description"] as? String {
      c.desc = desc
    }
    if let thumbDic = dic["thumbnail"] as? NSDictionary {
      let path = thumbDic["path"] as! String
      let ext = thumbDic["extension"] as! String
      c.thumbnailUrl = "\(path).\(ext)"
    }
    let realm = Realm()
    realm.write { () -> Void in
      realm.add(c, update: true)
    }
//    println("\(realm.path)")

  }
  
  class func all() -> Results<Character>{
    let realm = Realm()
    return realm.objects(Character.self)
  }
  
  
  class func fromServer(responseBlock: (() -> Void)) {
    let ts = "\(NSDate().timeIntervalSince1970)"
    
    let url = "http://gateway.marvel.com:80/v1/public/characters?orderBy=name&limit=100&ts=\(ts)&apikey=\(API.publicKey())&hash=\(authHash(ts))"

    let session = NSURLSession.sharedSession()
    let request = NSURLRequest(URL: NSURL(string: url)!)
    let task = session.dataTaskWithRequest(request,
      completionHandler: { (responseData: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
        let data = NSJSONSerialization.JSONObjectWithData(responseData,
          options: NSJSONReadingOptions(0),
          error: nil) as! NSDictionary
        if let r = data["data"] as? NSDictionary {
          if let characters = r["results"] as? NSArray {
            for character in characters {
              if let dic = character as? NSDictionary {
                self.fromDictionary(dic)
                
              }
            }
            responseBlock()
          }
          
        }        
        return
    })
    task.resume()
  }
  
  
  class func authHash(ts: String) -> String {
    
    return "\(ts)\(API.privateKey())\(API.publicKey())".md5
  }
}
