//
//  PertInfoCollectionViewController.swift
//  PertInfo
//
//  Created by Corey Flynn on 1/3/15.
//  Copyright (c) 2015 Corey Flynn. All rights reserved.
//

import UIKit
import Alamofire

let reuseIdentifier = "PertInfoCell"

class PertInfoCollectionViewController: UICollectionViewController, UISearchBarDelegate {

    var data:[PertInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Alamofire.request(.GET, "https://api.clue.io/a2/pertinfo", parameters: ["q":"{\"pert_type\":{\"$in\":[\"trt_cp\",\"trt_sh\",\"trt_sh.cgs\",\"trt_oe\"]}}", "f":"{\"pert_iname\":1,\"pert_type\":1}", "l":"0", "user_key":"fe1efb2b01fa76d71182bdb78e66d588"])
            .responseJSON { (_, _, JSON, _) in
                let pertInfos = (JSON! as [NSDictionary]).map {
                    PertInfo(pertIName: $0["pert_iname"] as String, pertType: $0["pert_type"] as String)
                }
                self.data = pertInfos
                self.collectionView?.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.data.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    
        // Configure the cell
        if let gridCell = cell as? PertInfoCell {
            gridCell.pertIName.text = self.data[indexPath.row].pertIName
            gridCell.pertType.text = self.data[indexPath.row].pertType
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
