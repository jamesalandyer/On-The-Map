//
//  ParseConstants.swift
//  On The Map
//
//  Created by James Dyer on 6/5/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

extension ParseClient {
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes/StudentLocation"
    }
    
    struct Methods {
        static let Post = "POST"
        static let Put = "PUT"
    }
    
    struct Parse {
        static let Id = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let Key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Parameters {
        static let UniqueKey = ["where": "{\"uniqueKey\":\"\(DataService.sharedInstance.userId)\"}"]
        static let Recent100 = ["limit": 100, "order": "-updatedAt"]
    }
    
}
