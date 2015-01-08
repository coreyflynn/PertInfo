//
//  PertInfoDetailViewController.swift
//  PertInfo
//
//  Created by Corey Flynn on 1/6/15.
//  Copyright (c) 2015 Corey Flynn. All rights reserved.
//

import UIKit
import Alamofire

class PertInfoDetailViewController: UIViewController {
    @IBAction func backButtonCLick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBOutlet var pertIName: UILabel!
    @IBOutlet var pertType: UILabel!
    @IBOutlet var pertSummary: UITextView!
    @IBOutlet var numSig: UILabel!
    
    var searchString:String?
    var key:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let APIPlistPath = NSBundle.mainBundle().pathForResource("API", ofType: "plist"){
            let APIConfig = NSDictionary(contentsOfFile: APIPlistPath)
            self.key = APIConfig!["BaristaUserKey"] as NSString
            self.getPertInfo(self.searchString!)
        }

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: API query
    func mapPertInfo(dict:NSDictionary) -> PertInfo{
        var ps: AnyObject? = dict["pert_summary"]
        if ps? == nil {
            ps = ""
        }
        return PertInfo(
            pertIName: dict["pert_iname"] as String,
            pertType: dict["pert_type"] as String,
            pertSummary: ps as? String,
            numSig: dict["num_sig"] as Int
        )
    }
    
    func getPertInfo(searchString: NSString){
        Alamofire.request(.GET, "https://api.clue.io/a2/pertinfo", parameters: ["q":"{\"pert_type\":{\"$in\":[\"trt_cp\",\"trt_sh\",\"trt_sh.cgs\",\"trt_oe\"]},\"pert_iname\":{\"$regex\":\"" + searchString + "\",\"$options\":\"i\"}}", "f":"{\"pert_iname\":1,\"pert_type\":1,\"pert_summary\":1,\"\":1,\"num_sig\":1}", "l":"1", "user_key":self.key])
            .responseJSON { (_, _, JSON, _) in
                let pertInfos = (JSON! as [NSDictionary]).map {
                    self.mapPertInfo($0)
                }
                self.pertIName.text = pertInfos[0].pertIName
                self.pertType.text = pertInfos[0].pertType
                self.pertSummary.text = pertInfos[0].pertSummary
                self.numSig.text = String(pertInfos[0].numSig!)
        }
    }

}
