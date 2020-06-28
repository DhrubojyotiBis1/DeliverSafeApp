//
//  Networking.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 21/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import Alamofire
import SwiftyJSON

class Network {
    public func getResponse(from url: String, having param: [String: String], method: HTTPMethod, completion: @escaping (JSON?)->()){
        let urlWithParameter = self.formCompleteUrl(url, having: param)
        AF.request(urlWithParameter, method: method).responseJSON { (response) in
            if response.error == nil {
                if let value  = response.value {
                    completion(JSON(value))
                }
            } else {
                print(response.error?.localizedDescription)
                completion(nil)
            }
        }
        
    }
}

private extension Network {
    func formCompleteUrl(_ url:String,having param: [String: String]) -> String {
        var urlWithParameter = "?"
        var index = param.count
        for (key, value) in param {
            index -= 1
            urlWithParameter += "\(key)=\(value)&"
        }
        urlWithParameter.removeLast()
        urlWithParameter = url + urlWithParameter
        return urlWithParameter
    }
}
