//
//  PertInfo.swift
//  PertInfo
//
//  Created by Corey Flynn on 1/3/15.
//  Copyright (c) 2015 Corey Flynn. All rights reserved.
//

import UIKit

class PertInfo {
    var pertIName:String?
    var pertID:String?
    var pertType:String?
    var pertSummary:String?
    var numSig:Int?
    
    init(pertIName: String = "", pertID: String = "", pertType: String = "", pertSummary: String? = nil, numSig: Int = 0){
        self.pertIName = pertIName
        self.pertID = pertID
        if pertSummary? == nil {
            self.pertSummary = ""
        }else{
            self.pertSummary = pertSummary!
        }
        self.numSig = numSig
        
        switch pertType{
            case "trt_cp":
                self.pertType = "Compound"
            case "trt_sh":
                self.pertType = "Knockdown"
            case "trt_sh.cgs":
                self.pertType = "Knockdown"
            case "trt_oe":
                self.pertType = "Over Expression"
            default:
                self.pertType = pertType
        }
    }
}