//
//  CMConstants.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.d.
//


extension CMClient {
    
    //-Constants
    struct Constants {
        
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "1a9dd8f528bb7e17deb54780ded8bc06"
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        
    }
    
    //-Parameter Keys
    struct MethodArguments {
        
        static let method = "method"
        static let api_key = "api_key"
        static let text = "text"
        static let safe_search = "safe_search"
        static let extras = "extras"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
    }
    
}

