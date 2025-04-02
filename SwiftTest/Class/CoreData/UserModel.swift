//
//  UserModel.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/13.
//

import UIKit
import CoreStore

class DogModel {
    var id: String = ""
    var name: String = ""
    var color: String = ""
    
    init(id: String, name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    static func copyV1(_ c: EntityDogModelV1) -> DogModel {
        let model = DogModel.init(id: "", name: "", color: "")
        model.name = c.name
        model.color = c.color
        return model
    }
    
    static func copyV2(_ c: EntityDogModelV2) -> DogModel {
        let model = DogModel.init(id: "", name: "", color: "")
        model.name = c.name
        model.color = c.color
        return model
    }
    
    static func copyV3(_ c: EntityDogModelV3) -> DogModel {
        let model = DogModel.init(id: "", name: "", color: "")
        model.name = c.name
        model.color = c.color
        return model
    }
}

extension DogModel: Hashable {
    static func == (lhs: DogModel, rhs: DogModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)       
        hasher.combine(color)
    }
}


class UserModel {
    var createTime: Int64 = 0
    var id: String = ""
    var name: String = ""
    var sex: Int16 = 0
    var dog: DogModel?
    var car: String = ""
    var color: String = ""
    var height: Float = 0.0
    
    static func copy(_ c: EntityUserModelV1) -> UserModel {
        let model = UserModel.init()
        model.createTime = c.createTime
        model.id = c.id
        model.name = c.name
        model.sex = c.sex
        
        if let dog = c.dog {
            model.dog = DogModel.copyV1(dog)
        }
        return model
    }
    
    static func copyV2(_ c: EntityUserModelV2) -> UserModel {
        let model = UserModel.init()
        model.createTime = c.createTime
        model.id = c.id
        model.name = c.name
        model.sex = c.sex
        model.car = c.car
        
        if let dog = c.dog {
            model.dog = DogModel.copyV2(dog)
        }
        return model
    }
    
    static func copyV3(_ c: EntityUserModelV3) -> UserModel {
        let model = UserModel.init()
        model.createTime = c.createTime
        model.id = c.id
        model.name = c.name
        model.sex = c.sex
        model.car = c.car
        model.color = c.color
        model.height = c.height
        
        if let dog = c.dog {
            model.dog = DogModel.copyV3(dog)
        }
        return model
    }
}


extension UserModel: Hashable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(createTime)
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(sex)
        hasher.combine(dog)
        hasher.combine(car)
        hasher.combine(color)
        hasher.combine(height)
    }
}
