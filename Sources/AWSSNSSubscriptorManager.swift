//
//  AWSSNSSubscriptorManager.swift
//  AWSSNSSubscriptor
//
//  Created by Mavericks's iOS Dev on 7/26/18.
//  Copyright © 2018 Mavericks. All rights reserved.
//

import Foundation
import AWSSNS

public class AWSSNSSubscriptorManager{
    
    //AWS's configuration
    public var configuration: AWSSNSSubscriptorConfiguration? = nil
    
    //Singleton
    public class var shared: AWSSNSSubscriptorManager{
        struct Static {
            static let instance = AWSSNSSubscriptorManager()
        }
        return Static.instance
    }
    
    
    //AWS's sns client
    public func sns()->AWSSNS{
        if(self.configuration == nil){
            fatalError("Configuration not been initialized")
        }
        
        //init credentials provider
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: self.configuration!.accessKey, secretKey: self.configuration!.secretKey)
        
        //aws service configuration
        let configuration = AWSServiceConfiguration(region: self.configuration!.region, credentialsProvider: credentialsProvider)
        
        //register sns service
        AWSSNS.register(with: configuration!, forKey: self.configuration!.appKey)
        
        //return sns client
        let sns = AWSSNS(forKey: self.configuration!.appKey)
        
        return sns
    }
    
    //Create AWS's Platform Endpoint
    public func createPlatformEndpoint(deviceTokenString: String){
        
        if(self.configuration == nil){
            fatalError("Configuration not been initialized")
        }
        
        //init sns client
        let sns = self.sns()

        //init request
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = deviceTokenString // device token
        request?.platformApplicationArn = self.configuration!.awsPlatformEndpoint //platform endpoint
        
        //create endpoint
        sns.createPlatformEndpoint(request!) { (response, eror) in
            
            let defaults = UserDefaults.standard
            defaults.set(response?.endpointArn, forKey: "endpointArn")
            defaults.synchronize()
            
            if(eror != nil){
                print(eror!)
            }
        }
    }
    
    //AWS Suscribe to topic
    //Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
    //Topic name: Name of topic (e.g userID)
    public func subscribeToTopic(topicArn: String, topicName: String){
        
        if(self.configuration == nil){
            fatalError("Configuration not been initialized")
        }
        
        //init sns
        let sns = self.sns()
        
        //create topic input with name
        let createTopicInput = AWSSNSCreateTopicInput()
        
        createTopicInput?.name = topicName
        
        sns.createTopic(createTopicInput!)
        
        //aws's subscription input
        let input = AWSSNSSubscribeInput()
        input?.topicArn = topicArn
        
        let defaults = UserDefaults.standard
        
        //endpoint arn
        if let endpointArn : String =  defaults.object(forKey: "endpointArn") as? String{
            input?.endpoint = endpointArn
            input?.protocols = "application"
            
            //subscribe
            sns.subscribe(input!) { (response, error) in
                if(error != nil){
                    print(error!)
                }
            }
        }
    }
    
    // AWS Unsubscribe topic
    // Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
    public func unsubscribeDeviceFromTopic(topicArn: String){
        
        //find subscription by topic
        self.findSubscriptionARNByTopic(topicArn: topicArn, success: {
            subscription in
            
            //init sns
            let sns = self.sns()
            
            //unsubscribe input
            let unsubscribeInput = AWSSNSUnsubscribeInput()
            unsubscribeInput?.subscriptionArn = subscription
            
            //unsubscribe that input
            sns.unsubscribe(unsubscribeInput!, completionHandler: {
                print($0 as Any)
            })
            
        }, failure: {
            print($0 as Any)
        })
    }
    
    // Find Subscription ARN By Topic
    // Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
    public func findSubscriptionARNByTopic(topicArn: String, success: @escaping (_ subscription: String)->Void, failure: @escaping (_ error: Error)->Void) {
        
        //list subscription with topic
        let listSubscriptionRequest: AWSSNSListSubscriptionsByTopicInput = AWSSNSListSubscriptionsByTopicInput()
        listSubscriptionRequest.topicArn = topicArn
        
        //init sns
        let sns = self.sns()
        
        //list of subscriptions
        sns.listSubscriptions(byTopic: listSubscriptionRequest, completionHandler: {
            subscriptions, error in
            
            guard error == nil else{
                failure(error!)
                return
            }
            
            //each subscription in topic I will compare if that subscription is on arn's endpoint
            for subscription in subscriptions!.subscriptions!{
                
                //arn
                if let arn = UserDefaults.standard.object(forKey: "endpointArn") as? String{
                    //compare with endpoint
                    if(subscription.endpoint == arn){
                        success(subscription.subscriptionArn!)
                    }
                }
                
            }
        })
        
    }
    
}
