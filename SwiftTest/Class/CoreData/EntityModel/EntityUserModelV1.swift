//
//  EntityUserModelV1.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/21.
//

import UIKit
import CoreStore

class EntityDogModelV1: CoreStoreObject, ImportableUniqueObject {
    
    @Field.Stored("id")
    var id: String = ""
    
    @Field.Stored("name")
    var name: String = ""
    
    @Field.Stored("color")
    var color: String = ""
    
    @Field.Relationship("user", inverse: \.$dog)
    var user: EntityUserModelV1?
    
    typealias UniqueIDType = String
    static let uniqueIDKeyPath: String = String(keyPath: \EntityUserModelV1.$id)
    var uniqueIDValue: UniqueIDType {
        get {
            return self.id
        }
        set {
            self.id = newValue
        }
    }
    
    typealias ImportSource = DogModel
    func didInsert(from source: DogModel, in transaction: CoreStore.BaseDataTransaction) throws {
        self.name = source.name
        self.color = source.color
    }

    

    static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UniqueIDType? {
        return source.id
    }

    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        self.id = source.id
        self.name = source.name
        self.color = source.color
    }
}

class EntityUserModelV1: CoreStoreObject, ImportableUniqueObject {
    @Field.Stored("createTime")
    var createTime: Int64 = 0
    
    @Field.Stored("id")
    var id: String = ""
    
    @Field.Stored("name")
    var name: String = ""
    
    @Field.Stored("sex")
    var sex: Int16 = 0
    
    @Field.Relationship("dog")
    var dog: EntityDogModelV1?
    
    // MARK: ImportableObject
    typealias ImportSource = UserModel
    func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        try self.update(from: source, in: transaction)
    }
    
    // MARK: ImportableUniqueObject
    typealias UniqueIDType = String
    static let uniqueIDKeyPath: String = String(keyPath: \EntityUserModelV1.$id)

    var uniqueIDValue: UniqueIDType {
        get {
            return self.id
        }
        set {
            self.id = newValue
        }
    }

    static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> UniqueIDType? {
        return source.id
    }

    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        self.createTime = source.createTime
        self.id = source.id
        self.name = source.name
        self.sex = source.sex
        
        
        if let dog = source.dog {
            self.dog = try transaction.importObject(Into<EntityDogModelV1>(),
                                                    source: dog)
            self.dog?.user = self
        }
    }
    
    static var mappingFromV2: CustomSchemaMappingProvider {
        return CustomSchemaMappingProvider(
            from: "EntityUserModelV2",
            to: "EntityUserModelV1",
            entityMappings: [
                .transformEntity(
                    sourceEntity: "EntityUserModelV2",
                    destinationEntity: "EntityUserModelV1",
                    transformer: { (source, createDestination) in
                        let destination = createDestination()
                        destination["createTime"] = source["createTime"]
                        destination["id"] = source["id"]
                        destination["name"] = source["name"]
                        destination["sex"] = source["sex"]
                        print("数据迁移：\(source["id"] ?? "")，\(source["name"] ?? "")，\(source["sex"] ?? -1)")
                    }
                ),
                .transformEntity(
                    sourceEntity: "EntityDogModelV2",
                    destinationEntity: "EntityDogModelV1",
                    transformer: { (source, createDestination) in
                        let destination = createDestination()
                        destination["id"] = source["id"]
                        destination["name"] = source["name"]
                        destination["color"] = source["color"]
                        print("数据迁移：\(source["id"] ?? "")，\(source["name"] ?? "")")
                    }
                )
            ]
        )
    }
}
