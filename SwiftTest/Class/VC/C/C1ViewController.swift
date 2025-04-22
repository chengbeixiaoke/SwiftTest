//
//  C1ViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/26.
//

import UIKit
import Combine
import CoreStore
import SnapKit

class C1ViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    var idNumber = 0
    var dataList: [UserModel] = []
    
    let maxSize = 50
    let minSize = 20
    
    /// 做加载刷新的属性
    var currentUserId: String? = nil
    var contentOffsetY: CGFloat = 0
    var isLoading: Bool = false
    var scrollDirection: Scroll = .none
    var enableReceiveNewData: Bool  = true
    var scrollToUserStartAnimationBlock: (()->())?
    
    var monitor: ListMonitor<EntityUserModel>?
    
    lazy var flowLayout: CustomFlowLayout = {
        return CustomFlowLayout()
    }()
    
    lazy var tableView: C1TableView = {
        let tableView = C1TableView(frame: .zero, style: .plain)
        tableView.contentInset = UIEdgeInsets(top: 90, left: 0, bottom: 70, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.scrollIndicatorInsets = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        
        /// 需要设置预估高度为0，不然页面滑动时，会导致cell跳跃，页面闪动
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderHeight = CGFLOAT_MIN
        tableView.sectionFooterHeight = CGFLOAT_MIN
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.register(CCell.self,
                           forCellReuseIdentifier: "CCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("新增", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(addUser), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        initializeCoreData()
        if let currentUserId {
            enableReceiveNewData = false
            loadMoreMessage_positioning(size: maxSize, userId: currentUserId)
        }
        else {
            loadMoreMessage_down(size: minSize, firstLoad: true)
        }
    }
    
    func initializeCoreData() {
        let indexStr = try? CoreDataManager.shared.coreDataStack.queryValue(From<EntityUserModel>()
            .select(String.self, [SelectTerm<EntityUserModel>(stringLiteral: "id")])
            .orderBy(.descending(\.$createTime))
            .tweak({
                $0.fetchLimit = 1
                $0.fetchOffset = 0
            }))
        
        if let indexStr = indexStr, let index = Int(indexStr)  {
            idNumber = index
        }
        
        initializeMonitor()
    }
    
    @objc func addUser() {
        self.corestoreTest()
    }
    
    deinit {
        print("[Test] C1ViewController deinit")
    }
}

extension C1ViewController: UITableViewDelegate, UITableViewDataSource {
    enum Scroll {
        case none
        case up
        case down
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataList[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CCell", for: indexPath) as! CCell
        cell.updateContent(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.frame.maxY < HeightScreen / 2.0 && scrollDirection == .down {
            scrollDirection = .none
            loadMoreMessage_down(size: maxSize)
        }
        
        if (tableView.contentSize.height - cell.frame.minY) < HeightScreen/2.0 && scrollDirection == .up {
            scrollDirection = .none
            loadMoreMessage_up(size: maxSize)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataList[indexPath.section]
        if var id = Int(item.id) {
            id = id - 200
            if id < 1 { id = 1 }
            scrollToUser(String(id))
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        print("[test] \(contentOffsetY), \(scrollView.frame.height), \(scrollView.contentInset), \(scrollView.contentSize.height)")
        if scrollView.isDragging {
            if contentOffsetY > self.contentOffsetY {
                scrollDirection = .up
            } else if contentOffsetY < self.contentOffsetY {
                scrollDirection = .down
            }
        }
        self.contentOffsetY = contentOffsetY
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollToUserStartAnimationBlock?()
    }
}

extension C1ViewController {
    enum FindLoadMessageOffset {
        case up
        case down
        case positioning
    }
    
    func findIndex(_ userId: String?) -> (Int, Int?) {
        let allUserIds = try? CoreDataManager.shared.coreDataStack.queryAttributes(
            From<EntityUserModel>(),
            Select("id"),
            OrderBy<EntityUserModel>(.descending(\.$createTime))
        )
        
        /// 没有数据，就走正常加载逻辑
        guard let allUserIds = allUserIds else {
            return (0, 0)
        }
        
        /// 定位消息，找到offset
        var offset: Int? = nil
        for (i, item) in allUserIds.enumerated() {
            if let id = item["id"] as? String {
                if id == userId {
                    offset = i
                    break
                }
            }
        }
        return (allUserIds.count, offset)
    }
    
    func findOffsetAndSize(_ userId: String?, size: Int, _ type: FindLoadMessageOffset) -> (Int, Int) {
        let (total, offset) = findIndex(userId)
        
        switch type {
        case .down:
            if var offset {
                offset = offset + 1
                if offset >= total {
                    return (offset, 0)
                }
                return (offset, min(size, total - offset))
            }
            return (0, min(size, total))
            
        case .up:
            if var offset {
                offset = offset - size
                if offset <= 0 {
                    return (0, size + offset)
                }
                return (offset, min(size, total - offset))
            }
            return (max(total - size, 0), min(size, total))
            
        case .positioning:
            if var offset {
                offset = offset - size / 2
                if offset <= 0 { offset = 0 }
                return (offset, min(size, total - offset))
            }
            return (0, min(size, total))
        }
    }
    
    func loadMoreMessage_down(size: Int, firstLoad: Bool = false) {
        if isLoading { return }
        isLoading = true
        if firstLoad { dataList.removeAll() }
        
        let (offset, size) = findOffsetAndSize(dataList.first?.id, size: size, .down)
        print("[Test] 向下滑动，Offset:\(offset), size:\(size)")
        if size == 0 {
            isLoading = false
            return
        }
        
        var tmp_dataSource: [UserModel] = []
        CoreDataManager.shared.coreDataStack.perform { transaction in
            let results = try transaction.fetchAll(From<EntityUserModelV3>()
                .orderBy(.descending(\.$createTime))
                .tweak({
                    $0.fetchLimit = size
                    $0.fetchOffset = offset
                }))
            for message in results {
                let model = UserModel.copyV3(message)
                tmp_dataSource.append(model)
            }
            tmp_dataSource = tmp_dataSource.reversed()
        } completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            if firstLoad {
                weakSelf.dataList.append(contentsOf: tmp_dataSource)
                weakSelf.tableView.reloadData()
                weakSelf.tableView.scrollToLastItem(animated: false) {
                    weakSelf.isLoading = false
                }
            }
            else {
                /// 加载更多时，采用插入的逻辑，实现无感刷新
                var indexs: [Int] = []
                for i in 0..<tmp_dataSource.count {
                    indexs.append(i)
                }
                print(tmp_dataSource.map {$0.id})
                weakSelf.dataList.insert(contentsOf: tmp_dataSource, at: 0)
                weakSelf.tableView.insertSectionAndKeepOffset(IndexSet(indexs)) { contentOffset in
                    weakSelf.contentOffsetY = contentOffset.y
                    weakSelf.isLoading = false
                }
            }
        }
    }
    
    /// (0.0, 69930.0, 414.0, 70.0)
    func loadMoreMessage_up(size loadSize: Int, firstLoad: Bool = false) {
        if isLoading { return }
        isLoading = true
        if firstLoad { dataList.removeAll() }
        
        let (offset, size) = findOffsetAndSize(dataList.last?.id, size: loadSize, .up)
        print("[Test] 向上滑动，Offset:\(offset), size:\(size)")
        if size == 0 {
            isLoading = false
            return
        }
        
        var tmp_dataSource: [UserModel] = []
        CoreDataManager.shared.coreDataStack.perform { transaction in
            let results = try transaction.fetchAll(From<EntityUserModelV3>()
                .orderBy(.descending(\.$createTime))
                .tweak({
                    $0.fetchLimit = size
                    $0.fetchOffset = offset
                }))
            for message in results {
                let model = UserModel.copyV3(message)
                tmp_dataSource.append(model)
            }
            tmp_dataSource = tmp_dataSource.reversed()
        } completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            if firstLoad {
                weakSelf.dataList.append(contentsOf: tmp_dataSource)
                weakSelf.tableView.reloadData()
            }
            else {
                /// 加载更多时，采用插入的逻辑，实现无感刷新
                var indexs: [Int] = []
                let count = weakSelf.dataList.count
                for i in 0..<tmp_dataSource.count {
                    indexs.append(i + count)
                }
                print(tmp_dataSource.map {$0.id})
                weakSelf.dataList.append(contentsOf: tmp_dataSource)
                weakSelf.tableView.performBatchUpdates({ [weak self] in
                    guard let weakSelf = self else { return }
                    weakSelf.tableView.insertSections(IndexSet(indexs), with: .none)
                    weakSelf.enableReceiveNewData = size < loadSize
                })
            }
            weakSelf.isLoading = false
        }
    }
    
    func loadMoreMessage_positioning(size loadSize: Int, userId: String) {
        if isLoading { return }
        isLoading = true
        
        let (offset, size) = findOffsetAndSize(userId, size: loadSize, .positioning)
        print("[Test] 定位Cell，Offset:\(offset), size:\(size)")
        if size == 0 {
            isLoading = false
            return
        }
        
        var tmp_dataSource: [UserModel] = []
        CoreDataManager.shared.coreDataStack.perform { transaction in
            let results = try transaction.fetchAll(From<EntityUserModelV3>()
                .orderBy(.descending(\.$createTime))
                .tweak({
                    $0.fetchLimit = size
                    $0.fetchOffset = offset
                }))
            for message in results {
                let model = UserModel.copyV3(message)
                tmp_dataSource.append(model)
            }
            tmp_dataSource = tmp_dataSource.reversed()
        } completion: { [weak self] result in
            guard let weakSelf = self else { return }
            print(tmp_dataSource.map {$0.id})
            weakSelf.dataList.append(contentsOf: tmp_dataSource)
            weakSelf.tableView.reloadData()
            weakSelf.isLoading = false
            weakSelf.enableReceiveNewData = size < loadSize
            weakSelf.scrollToCurrentUser(userId,
                                         at: .middle,
                                         animated: false)
        }
    }
    
    func scrollToUser(_ userId: String) {
        if isLoading { return }
        isLoading = true
        enableReceiveNewData = false
        
        if let _ = dataList.map({ $0.id }).firstIndex(of: userId) {
            scrollToCurrentUser(userId,
                                at: .middle,
                                animated: true)
            isLoading = false
            return
        }
        
        guard let firstId = dataList.first?.id else {
            isLoading = false
            return
        }
        let (total, current) = findIndex(firstId)
        let (_, location) = findIndex(userId)
        guard total > 0, let current, let location else {
            isLoading = false
            print("[Test] 无法定位Cell，userId:\(userId), first:\(firstId)")
            return
        }
        
        let offset = current
        let size = location - current + min(10, total - location)

        print("[Test] 定位Cell，userId:\(userId), Offset:\(offset), size:\(size)")
        if size == 0 {
            isLoading = false
            return
        }
        
        var tmp_dataSource: [UserModel] = []
        CoreDataManager.shared.coreDataStack.perform { transaction in
            let results = try transaction.fetchAll(From<EntityUserModelV3>()
                .orderBy(.descending(\.$createTime))
                .tweak({
                    $0.fetchLimit = size
                    $0.fetchOffset = offset
                }))
            for message in results {
                let model = UserModel.copyV3(message)
                tmp_dataSource.append(model)
            }
            tmp_dataSource = tmp_dataSource.reversed()
        } completion: { [weak self] result in
            guard let weakSelf = self else { return }
            print(tmp_dataSource.map {$0.id})
            
            /// 加载更多时，采用插入的逻辑，实现无感刷新
            var indexs: [Int] = []
            for i in 0..<tmp_dataSource.count {
                indexs.append(i)
            }
            weakSelf.dataList.insert(contentsOf: tmp_dataSource, at: 0)
            weakSelf.tableView.insertSectionAndKeepOffset(IndexSet(indexs)) { contentOffset in
                weakSelf.contentOffsetY = contentOffset.y
                weakSelf.isLoading = false
                weakSelf.scrollToCurrentUser(userId,
                                             at: .middle,
                                             animated: true)
            }
        }
    }
    
    func scrollToCurrentUser(_ userId: String,
                             at scrollPosition: UITableView.ScrollPosition,
                             animated: Bool) {
        var index: Int? = nil
        for (i, m2) in self.dataList.enumerated() {
            if userId == m2.id {
                index = i
                break
            }
        }
        guard let index = index else { return }
        let indexPath = IndexPath(row: 0, section: index)
        if animated {
            scrollToUserStartAnimationBlock = { [weak self] in
                guard let weakSelf = self else { return }
                
                defer {
                    weakSelf.scrollToUserStartAnimationBlock = nil
                }
                
                weakSelf.scrollToCellAnimation(indexPath)
            }
            tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
        }
        else {
            tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: false)
            scrollToCellAnimation(indexPath)
        }
    }
    
    func scrollToCellAnimation(_ indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? CCell {
            UIView.animateKeyframes(withDuration: 2, delay: 0.0) {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                    cell.contentView.backgroundColor = .red
                }
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                    cell.contentView.backgroundColor = .white
                }
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                    cell.contentView.backgroundColor = .red
                }
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                    cell.contentView.backgroundColor = .white
                }
            }
        }
    }
}

extension C1ViewController {
    func corestoreTest() {
        if CurrentEntityUserModelVersion == CoreDataManagerVersion.v1.rawValue {
            insertUserV1()
        }
        
        if CurrentEntityUserModelVersion == CoreDataManagerVersion.v2.rawValue {
            insertUserV2()
        }
        
        if CurrentEntityUserModelVersion == CoreDataManagerVersion.v3.rawValue {
            insertUserV3()
        }
    }
    
    func insertUserV1() {
        self.idNumber += 1
        var userModel: UserModel?
        CoreDataManager.shared.coreDataStack.perform { [weak self] transaction in
            guard let weakSelf = self else { return }
            
            let model = UserModel()
            model.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model.id = "\(weakSelf.idNumber)"
            model.name = "王小1"
            model.sex = 1
            model.dog = DogModel(id: model.id, name: "狗狗", color: "yellow")
            let _ = try transaction.importUniqueObject(Into<EntityUserModelV1>(),
                                                       source: model)
            
            let model2 = UserModel()
            model2.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model2.id = "\(weakSelf.idNumber)"
            model2.name = "王小1测试"
            model2.sex = 0
            let user = try transaction.importUniqueObject(Into<EntityUserModelV1>(),
                                                          source: model2)
            user?.dog?.name = "狗狗更新名字"
            
            userModel = model2
        } completion:{ [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success():
                print("insert success")
                if let userModel {
                    weakSelf.dataList.insert(userModel, at: 0)
                    weakSelf.tableView.reloadData()
                }
                
            case .failure(let error):
                print("insert error: \(error.localizedDescription)")
            }
        }
    }
    
    func insertUserV2() {
        self.idNumber += 1
        var userModel: UserModel?
        CoreDataManager.shared.coreDataStack.perform { [weak self] transaction in
            guard let weakSelf = self else { return }
            
            let model = UserModel()
            model.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model.id = "\(weakSelf.idNumber)"
            model.name = "王小2"
            model.sex = 1
            model.car = "测试哈"
            model.dog = DogModel(id: model.id, name: "狗狗V2", color: "green")
            let _ = try transaction.importUniqueObject(Into<EntityUserModelV2>(),
                                                       source: model)
            
            let model2 = UserModel()
            model2.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model2.id = "\(weakSelf.idNumber)"
            model2.name = "王小2测试"
            model2.sex = 0
            model.car = "测试哈111"
            model.dog = DogModel(id: model2.id, name: "狗狗V2更新", color: "green")
            _ = try transaction.importUniqueObject(Into<EntityUserModelV2>(),
                                                   source: model2)
            
            userModel = model2
        } completion:{ [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success():
                print("insert success")
                if let userModel {
                    weakSelf.dataList.insert(userModel, at: 0)
                    weakSelf.tableView.reloadData()
                }
                
            case .failure(let error):
                print("insert error: \(error.localizedDescription)")
            }
        }
    }
    
    func insertUserV3() {
        self.idNumber += 1
        var userModel: UserModel?
        CoreDataManager.shared.coreDataStack.perform { [weak self] transaction in
            guard let weakSelf = self else { return }
            
            let model = UserModel()
            model.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model.id = "\(weakSelf.idNumber)"
            model.name = "王小3"
            model.sex = 1
            model.car = "测试哈"
            model.color = "yellow"
            model.height = 178.01
            model.dog = DogModel(id: model.id, name: "狗狗V3", color: "green")
            let _ = try transaction.importUniqueObject(Into<EntityUserModelV3>(),
                                                       source: model)
            
            let model2 = UserModel()
            model2.createTime = Int64(Date().timeIntervalSince1970 * 1000)
            model2.id = "\(weakSelf.idNumber)"
            model2.name = "王小3测试"
            model2.sex = 0
            model.car = "测试哈111"
            model.color = "yellow"
            model.height = 178.01
            let user = try transaction.importUniqueObject(Into<EntityUserModelV3>(),
                                                          source: model2)
            user?.dog?.color = "blue"
            
            userModel = model2
        } completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success():
                print("insert success")
                if let userModel, weakSelf.enableReceiveNewData {
                    weakSelf.dataList.append(userModel)
                    weakSelf.tableView.performBatchUpdates {
                        weakSelf.tableView.insertSections(IndexSet([weakSelf.dataList.count-1]), with: .bottom)
                    } completion: { _ in
                        weakSelf.tableView.scrollToLastItem(at: .bottom, animated: true) {}
                    }
                    print(userModel.id)
                }
                
            case .failure(let error):
                print("insert error: \(error.localizedDescription)")
            }
        }
    }
}


extension C1ViewController: ListObjectObserver {
    typealias ListEntityType = EntityUserModel
    
    /// 初始化 NSFetchedResultsController
    func initializeMonitor() {
        let dataStack = CoreDataManager.shared.coreDataStack
        let monitor = dataStack!.monitorList(From<ListEntityType>()
            .orderBy(.descending(\.$createTime))
        )
        monitor.addObserver(self)
        self.monitor = monitor
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<ListEntityType>) {

    }
    
    func listMonitorDidRefetch(_ monitor: CoreStore.ListMonitor<ListEntityType>) {

    }
    
    func listMonitorWillChange(_ monitor: ListMonitor<ListEntityType>) {
//        tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: CoreStore.ListMonitor<ListEntityType>) {
//        tableView.endUpdates()
    }
    
    func listMonitor(_ monitor: ListMonitor<ListEntityType>,
                     didInsertObject object: ListEntityType,
                     toIndexPath indexPath: IndexPath) {
        print("Insert: \(indexPath)")
    }
    
    func listMonitor(_ monitor: ListMonitor<ListEntityType>,
                     didUpdateObject object: ListEntityType,
                     atIndexPath indexPath: IndexPath) {
        print("Update: \(indexPath)")
    }
    
    func listMonitor(_ monitor: ListMonitor<ListEntityType>,
                     didDeleteObject object: ListEntityType,
                     fromIndexPath indexPath: IndexPath) {
        
        print("Delete: \(indexPath)")
    }
    
    func listMonitor(_ monitor: ListMonitor<ListEntityType>,
                     didMoveObject object: ListEntityType,
                     fromIndexPath: IndexPath,
                     toIndexPath: IndexPath) {
        print("Move: \(fromIndexPath), \(toIndexPath)")
    }
}
