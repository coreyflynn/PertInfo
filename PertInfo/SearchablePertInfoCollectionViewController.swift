//
//  SearchablePertInfoCollectionViewController.swift
//  PertInfo
//
//  Created by Corey Flynn on 1/3/15.
//  Copyright (c) 2015 Corey Flynn. All rights reserved.
//

import UIKit
import Alamofire

class SearchablePertInfoCollectionViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var containerView: UIView!
    
    var data:[PertInfo] = []
    var responseData:[PertInfo] = []
    var lastIndexPathRow:Int = 0
    var searchHidden:Bool = false
    var isFiltering:Bool = true
    var numberOfPendingFilters:Int = 0
    
    var key:String = ""
    var skip:Int = 0
    var limit:Int = 50
    var count:Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        
        self.collectionView.dataSource = self
        self.collectionView.keyboardDismissMode = .OnDrag
        
        if let APIPlistPath = NSBundle.mainBundle().pathForResource("API", ofType: "plist"){
            let APIConfig = NSDictionary(contentsOfFile: APIPlistPath)
            self.key = APIConfig!["BaristaUserKey"] as NSString
            self.getPertInfo("")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        var detailViewController = (segue.destinationViewController as PertInfoDetailViewController)
        
        let cell = sender as PertInfoCell
        
        // Pass the selected object to the new view controller.
        detailViewController.searchString = cell.pertIName.text
    }

    
    // MARK: - UICollectionViewDataSource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PertInfoCell", forIndexPath: indexPath) as UICollectionViewCell
        
        // Configure the cell
        if let gridCell = cell as? PertInfoCell {
            gridCell.pertIName.text = self.data[indexPath.row].pertIName
            gridCell.pertType.text = self.data[indexPath.row].pertType
        }
        
        // figure out which way we are scroll content
        if !self.isFiltering{
            if self.lastIndexPathRow < indexPath.row && !self.searchHidden && !self.isFiltering && self.searchBar.text == ""{
                println("hide")
                UIView.animateWithDuration(0.5, animations: {
                    self.containerView.frame.origin = CGPointMake(0, -65)
                })
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.searchHidden = true
                })

            }
            
            if self.lastIndexPathRow - indexPath.row > 5 && self.searchHidden && !self.isFiltering{
                println("show")
                UIView.animateWithDuration(0.5, animations: {
                    self.containerView.frame.origin = CGPointMake(0, 0)
                })
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.searchHidden = false
                })
            }
            
            if self.data.count - indexPath.row < 10 && indexPath.row != self.count{
                println("grabbing more data")
                self.skip += self.limit
                self.getPertInfo(self.searchBar.text)
            }
        }
        self.lastIndexPathRow = indexPath.row
        
        return cell
        
    }
    
    // MARK: UICollectionView layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(5.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(5.0)
    }
    
    // MARK: SearchBar delegate methods
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        println(self.searchBar.text)
//    }
//    
//    func searchBarTextDidStartEditing(searchBar: UISearchBar) {
//        println(self.searchBar.text)
//    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.skip = 0
        self.data = []
        self.getCount(searchBar.text)
        self.getPertInfo(searchBar.text)
        
    }
    
    // MARK: API query
    func getPertInfo(searchString: NSString){
        self.numberOfPendingFilters += 1
        self.isFiltering = true
        Alamofire.request(.GET, "https://api.clue.io/a2/pertinfo", parameters: ["q":"{\"pert_type\":{\"$in\":[\"trt_cp\",\"trt_sh\",\"trt_sh.cgs\",\"trt_oe\"]},\"pert_iname\":{\"$regex\":\"" + searchString + "\",\"$options\":\"i\"}}", "f":"{\"pert_iname\":1,\"pert_type\":1}", "l":String(self.limit), "sk":String(self.skip), "user_key":self.key])
            .responseJSON { (_, _, JSON, _) in
                var map = NSDictionary()
                var pertInfos = (JSON! as [NSDictionary]).map {
                    PertInfo(pertIName: $0["pert_iname"] as String, pertType: $0["pert_type"] as String)
                }
                pertInfos = self.data + pertInfos
                self.data = []
                for pertInfo in pertInfos{
                    if map[pertInfo.pertIName!] == nil{
                        self.data.append(pertInfo)
                    }
                }
                
                self.collectionView.reloadData()
                self.numberOfPendingFilters -= 1
                if self.numberOfPendingFilters == 0{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                        self.isFiltering = false
                    })
                }
        }
    }
    
    func getCount(searchString: NSString){
        Alamofire.request(.GET, "https://api.clue.io/a2/pertinfo", parameters: ["q":"{\"pert_type\":{\"$in\":[\"trt_cp\",\"trt_sh\",\"trt_sh.cgs\",\"trt_oe\"]},\"pert_iname\":{\"$regex\":\"" + searchString + "\",\"$options\":\"i\"}}","c":"1","user_key":"fe1efb2b01fa76d71182bdb78e66d588"])
            .responseJSON { (_, _, JSON, _) in
                let countDict = JSON! as NSDictionary
                self.count = countDict["count"]! as Int
                println(self.count)
        }
    }
    

}
