//
//  AlgoliaService.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import InstantSearchClient

class AlgoliaService {
    
    static let shared = AlgoliaService()
    
    let client = Client(appID: ALGOLIA_APP_ID, apiKey: ALGOLOA_ADMIN_KEY)
    let index = Client(appID:ALGOLIA_APP_ID, apiKey: ALGOLOA_ADMIN_KEY).index(withName: "AppStore_Item_Name")
    
    private init() {}
}
