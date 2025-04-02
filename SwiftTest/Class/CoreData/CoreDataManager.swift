//
//  CoreDataManager.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/8.
//

import UIKit
import CoreStore
import Combine

let VEntityUserModelV1 = "EntityUserModelV1"
let VEntityUserModelV2 = "EntityUserModelV2"
let VEntityUserModelV3 = "EntityUserModelV3"

let CurrentEntityUserModelVersion = VEntityUserModelV3
typealias EntityUserModel = EntityUserModelV3

enum CoreDataManagerVersion: RawRepresentable, CaseIterable, Hashable, CustomStringConvertible {
    typealias RawValue = ModelVersion
    
    case v1
    case v2
    case v3
    
    var version: ModelVersion {
        return self.rawValue
    }
    
    var rawValue: ModelVersion {
        switch self {
        case .v1:
            return VEntityUserModelV1
        case .v2:
            return VEntityUserModelV2
        case .v3:
            return VEntityUserModelV3
        }
    }
    
    init(rawValue: ModelVersion) {
        switch rawValue {
        case VEntityUserModelV1:
            self = .v1
        case VEntityUserModelV2:
            self = .v2
        case VEntityUserModelV3:
            self = .v3
        default:
            self = .v3
        }
    }
    
    var description: String {
        switch self {
        case .v1:
            return "EntityUserModelV1"
        case .v2:
            return "EntityUserModelV2"
        case .v3:
            return "EntityUserModelV3"
        }
    }
}

class CoreDataManager: NSObject {
    private override init() {}
    
    static let shared: CoreDataManager = {
        let queue = DispatchQueue(label: "com.example.chat.im.singleton")
        var instance: CoreDataManager?
        queue.sync {
            if instance == nil {
                instance = CoreDataManager()
            }
            instance?.synchronizeCurrentVersion()
        }
        return instance!
    }()
    
    /// 数据库初始化完成
    public let initializeCoreData = PassthroughSubject<Bool, Never>()
    
    static let schemaHistory = {
        let v1Schema = CoreStoreSchema(modelVersion: VEntityUserModelV1,
                                       entities: [
                                        Entity<EntityUserModelV1>("EntityUserModelV1"),
                                        Entity<EntityDogModelV1>("EntityDogModelV1")
                                       ],
                                       versionLock: [
                                        "EntityDogModelV1": [0xe63d03befaaa2b49, 0x4fcddc2dd02f7d15, 0x718b8f1888ea5811, 0xfe29ee01f219f8d],
                                        "EntityUserModelV1": [0xd934f475c14a5e04, 0x499fb7089f35dded, 0x3e0c4a18e67de503, 0xf672502ca9103fb6]
                                       ])
        
        let v2Schema = CoreStoreSchema(modelVersion: VEntityUserModelV2,
                                       entities: [
                                        Entity<EntityUserModelV2>("EntityUserModelV2"),
                                        Entity<EntityDogModelV2>("EntityDogModelV2")
                                       ],
                                       versionLock: [
                                        "EntityDogModelV2": [0xe97ebb046ada8601, 0x23423d6be8991058, 0x1557fe9afd21814a, 0xc70f2bd4effea26e],
                                        "EntityUserModelV2": [0xf9b8e42638cb84ad, 0xa2f16058a438be82, 0x807a05d3885d3019, 0x4273a7766745810b]
                                       ])
        
        let v3Schema = CoreStoreSchema(modelVersion: VEntityUserModelV3,
                                       entities: [
                                        Entity<EntityUserModelV3>("EntityUserModelV3"),
                                        Entity<EntityDogModelV3>("EntityDogModelV3")
                                       ],
                                       versionLock: [
                                        "EntityDogModelV3": [0xda0b242f250bdb19, 0x3a4330e3e806c39c, 0x9b532614498db7c9, 0x4154418ffe64b5d3],
                                        "EntityUserModelV3": [0x7e4b87a2d1e7990e, 0xea3d56c10a5ee7f8, 0xc790f1f8e1a90811, 0xf1c0c6092a3d8875]
                                       ])
        return [v1Schema, v2Schema, v3Schema]
    }()
    
    var coreDataStack: DataStack!
    private func createDataStack(
        exactCurrentModelVersion: ModelVersion?,
        migrationChain: MigrationChain) -> DataStack
    {
        return DataStack(
            schemaHistory: SchemaHistory(
                allSchema: CoreDataManager.schemaHistory,
                migrationChain: migrationChain,
                exactCurrentModelVersion: exactCurrentModelVersion
            )
        )
    }
    
    private func accessSQLiteStore() -> SQLiteStore
    {
        let upgradeMappings: [SchemaMappingProvider] = [
            EntityUserModelV2.mappingFromV1,
            EntityUserModelV3.mappingFromV2
        ]
        let downgradeMappings: [SchemaMappingProvider] = [
            EntityUserModelV2.mappingFromV3,
            EntityUserModelV1.mappingFromV2
        ]
        return SQLiteStore(
            fileName: "CoreDataStackTestModel.sqlite",
            configuration: nil,
            migrationMappingProviders: upgradeMappings + downgradeMappings,
            localStorageOptions: []
        )
    }
    
    private func findLastVersion() -> ModelVersion? {
        let allVersions = CoreDataManagerVersion.allCases.map({ $0.version })
        let dataStack = self.createDataStack(exactCurrentModelVersion: nil, migrationChain: MigrationChain(allVersions))
        
        let migrations = try! dataStack.requiredMigrationsForStorage(
            self.accessSQLiteStore()
        )
        let lastVersion = migrations.first?.sourceVersion
        if lastVersion == CurrentEntityUserModelVersion {
            return nil
        }
        return lastVersion
    }
    
    var isBusy = false
    var progress: Progress?
    private func synchronizeCurrentVersion() {
        self.isBusy = true
        
        let lastVersion = self.findLastVersion()
        let migrationChain: MigrationChain
        
        switch (lastVersion, CurrentEntityUserModelVersion) {
        case (nil, let newVersion):
            migrationChain = [newVersion]
            
        case (let lastVersion?, let currentVersion):
            let upgradeMigrationChain = CoreDataManagerVersion.allCases.map({ $0.version })
            let lastVersionIndex = upgradeMigrationChain.firstIndex(of: lastVersion)!
            let currentVersionIndex = upgradeMigrationChain.firstIndex(of: currentVersion)!
            let isUpgrade = lastVersionIndex < currentVersionIndex
            migrationChain = MigrationChain(isUpgrade ? upgradeMigrationChain : upgradeMigrationChain.reversed())
        }
        
        self.coreDataStack = self.createDataStack(
            exactCurrentModelVersion: CurrentEntityUserModelVersion,
            migrationChain: migrationChain
        )
        
        let completion = { [weak self] () -> Void in
            guard let weakSelf = self else { return }
            weakSelf.isBusy = false
        }
        
        self.progress = self.coreDataStack.addStorage(self.accessSQLiteStore(), completion: { [weak self] result in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let xx):
                weakSelf.isBusy = false
                weakSelf.initializeCoreData.send(true)
                print("数据库加载完成：\(xx)")
            case .failure(let xx):
                print("数据库加载失败：\(xx)")
            }
            completion()
        })
        
        self.progress?.setProgressHandler({ progress in
            print("数据库迁移进度: \(progress.completedUnitCount)")
        })
    }
}


