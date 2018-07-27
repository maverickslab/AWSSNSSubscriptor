//
//  AWSSNSSubscriptorConfiguration.swift
//  AWSSNSSubscriptor
//
//  Created by Mavericks's iOS Dev on 7/26/18.
//  Copyright © 2018 Mavericks. All rights reserved.
//

import Foundation
import AWSSNS

//Configuration class
public class AWSSNSSubscriptorConfiguration{

    //AWS's secret key (IAM)
    public var secretKey: String = ""
    
    //AWS's access key (IAM)
    public var accessKey: String = ""
    
    //App key (your app name) e.g 'Kidsbook'
    public var appKey: String = ""
    
    //AWS's region type
    public var region: AWSRegionType = .USEast1
    
    //AWS's platform endpoint
    public var awsPlatformEndpoint: String = ""
    
    public init(secret: String, access: String){
        //init
        self.secretKey = secret
        self.accessKey = access
    }
}
