//
//  ModelRealm.swift
//  Test
//
//  Created by mac on 13.04.2020.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import RealmSwift

class ModelRealm: Object {
    @objc dynamic var searchName = ""
    @objc dynamic var image = Data()
    @objc dynamic var created = Date()
}
