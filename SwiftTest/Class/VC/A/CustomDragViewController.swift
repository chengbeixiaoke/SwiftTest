//
//  CustomDragViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/4/10.
//

import UIKit
import SnapKit
import SwifterSwift

class CustomDragViewController: BaseViewController {
    private var dataSource = ["🍎 苹果", "🍌 香蕉", "🍊 橙子", "🍇 葡萄", "🫐蓝莓", "🥑牛油果", "🍐梨子", "🪷荷花", "✈️飞机", "🐘大象", "🦁狮子", "🦓斑马", "🐯老虎", "🐔鸡子"]
    
    private lazy var tableView = {
        let tableView = BaseTableView(frame: .zero, style: .plain)
        tableView.register(cellWithClass: WWManagementAccountListCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .automatic
        if #available(iOS 26.0, *) {
            tableView.topEdgeEffect.isHidden = false
            tableView.bottomEdgeEffect.isHidden = false
        }
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScale(110))
            make.edges.equalToSuperview()
        }
    }
}

extension CustomDragViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: WWManagementAccountListCell.self)
        cell.updateUI(dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScale(68)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
    }
}

// MARK: - UITableViewDragDelegate
extension CustomDragViewController: UITableViewDragDelegate {
    /// 提供拖拽的数据项
    /// - Parameters:
    ///   - tableView: 发起拖拽的 tableView
    ///   - session: 拖拽会话对象，包含拖拽的相关信息
    ///   - indexPath: 被拖拽的 cell 所在的索引位置
    /// - Returns: 拖拽数据项数组（支持同时拖拽多个 cell）
    /// - Note:
    ///   - 这是唯一必须实现的方法
    ///   - 如果返回 nil 或空数组，拖拽将不会开始
    ///   - 每个 UIDragItem 包含一个 NSItemProvider，用于提供数据
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        printLog("[Deag] 开始提供拖拽数据: \(indexPath)")
        let item = dataSource[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    
    /// 提供额外的拖拽数据（当拖拽过程中添加更多项目时调用）
    /// - Parameters:
    ///   - tableView: 发起拖拽的 tableView
    ///   - session: 拖拽会话对象
    ///   - indexPath: 新添加的 cell 索引位置
    ///   - point: 在 cell 中的触摸点坐标
    /// - Returns: 额外添加的拖拽数据项
    /// - Note:
    ///   - 例如：用户先拖拽一个 cell，然后在拖拽过程中点击另一个 cell
    ///   - 可以实现多选拖拽功能
    func tableView(_ tableView: UITableView, itemsForAddingTo session: any UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        printLog("[Deag] 开始提供额外拖拽数据: \(indexPath)")
        return []
    }
    
    /// 自定义拖拽时的预览参数
    /// - Parameter indexPath: 被拖拽的 cell 索引位置
    /// - Returns: 预览参数，控制预览视图的圆角和背景
    /// - Note:
    ///   - 只能自定义预览的**圆角路径**和**背景色**
    ///   - 不能自定义预览的阴影、边框、内容等
    ///   - 返回 nil 表示使用系统默认预览
    /// - Example:
    ///   ```swift
    ///   let parameters = UIDragPreviewParameters()
    ///   parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 12)
    ///   parameters.backgroundColor = .clear
    ///   return parameters
    ///   ```
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters?
    {
        printLog("[Deag] 长按即将开始拖拽: \(indexPath)")
        return nil
    }
    
    /// 拖拽会话即将开始时调用
    /// - Parameters:
    ///   - tableView: 发起拖拽的 tableView
    ///   - session: 拖拽会话对象
    /// - Note:
    ///   - 可以在这里做准备工作，例如高亮被拖拽的 cell
    ///   - 可以记录拖拽开始的状态
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: any UIDragSession) {
        printLog("[Deag] 即将开始拖拽")
    }
    
    /// 拖拽会话结束时调用
    /// - Parameters:
    ///   - tableView: 发起拖拽的 tableView
    ///   - session: 拖拽会话对象
    /// - Note:
    ///   - 可以在这里清理资源，取消高亮等
    ///   - 无论拖拽成功还是取消，都会调用
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: any UIDragSession) {
        printLog("[Deag] 拖拽结束")
    }
    
    /// 控制拖拽操作是否允许移动（而不是复制）
    /// - Parameter session: 拖拽会话对象
    /// - Returns: true 表示移动操作，false 表示复制操作
    /// - Note:
    ///   - 默认返回 true（移动操作）
    ///   - 如果返回 false，拖拽将执行复制操作
    func tableView(_ tableView: UITableView, dragSessionAllowsMoveOperation session: any UIDragSession) -> Bool {
        printLog("[Deag] 拖拽否允许移动")
        return true
    }
    
    /// 限制拖拽只能在当前应用内进行
    /// - Parameter session: 拖拽会话对象
    /// - Returns: true 表示只能拖拽到当前应用，false 表示可以拖拽到其他应用
    /// - Note:
    ///   - 默认返回 false（允许跨应用拖拽）
    ///   - 如果返回 true，拖拽数据不会离开当前应用
    func tableView(_ tableView: UITableView, dragSessionIsRestrictedToDraggingApplication session: any UIDragSession) -> Bool {
        printLog("[Deag] 限制拖拽只能在当前应用内进行")
        return true
    }
}

// MARK: - UITableViewDropDelegate
extension CustomDragViewController: UITableViewDropDelegate {
    /// 执行拖拽放下操作（核心方法）
    /// - Parameters:
    ///   - tableView: 目标 tableView
    ///   - coordinator: 拖拽协调器，提供数据访问和动画控制
    /// - Note:
    ///   - 这是唯一必须实现的方法
    ///   - 在这里将拖拽的数据插入到 tableView 中
    ///   - 需要同时更新数据源和 UI
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
//        coordinator.items.forEach { dropItem in
//            guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
//            
//            // 更新数据源
//            let item = dataSource[sourceIndexPath.row]
//            dataSource.remove(at: sourceIndexPath.row)
//            dataSource.insert(item, at: destinationIndexPath.row)
//            // 更新 UI
//            tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
//        }
        
        coordinator.items.forEach { dropItem in
                guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
                
                // 更新数据源
                let item = dataSource[sourceIndexPath.row]
                dataSource.remove(at: sourceIndexPath.row)
                dataSource.insert(item, at: destinationIndexPath.row)
            }
            
        // 无动画刷新
            UIView.performWithoutAnimation {
                tableView.reloadData()
            }
    }
    
    /// 检查是否可以处理拖拽的数据
    /// - Parameters:
    ///   - tableView: 目标 tableView
    ///   - session: 拖拽会话，包含拖拽的数据信息
    /// - Returns: true 表示可以处理，false 表示拒绝拖拽
    /// - Note:
    ///   - 默认返回 true
    ///   - 可以在这里检查数据类型、格式等
    ///   - 返回 false 时，拖拽操作将被取消
    func tableView(_ tableView: UITableView, canHandle session: any UIDropSession) -> Bool {
        printLog("[Deag] 检查是否可以处理拖拽的数据")
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    /// 拖拽进入 tableView 区域时调用
    /// - Parameters:
    ///   - tableView: 目标 tableView
    ///   - session: 拖拽会话
    /// - Note:
    ///   - 可以在这里高亮 tableView 表示可以放下
    ///   - 例如：改变背景色、显示边框等
    func tableView(_ tableView: UITableView, dropSessionDidEnter session: any UIDropSession) {
        printLog("[Deag] 拖拽进入 tableView 区域时调用")
    }
    
    /// 拖拽在 tableView 内移动时调用（核心交互方法）
    /// - Parameters:
    ///   - tableView: 目标 tableView
    ///   - session: 拖拽会话
    ///   - destinationIndexPath: 当前拖拽悬停的目标位置（可能为 nil）
    /// - Returns: 拖拽建议，控制拖拽的视觉效果和行为
    /// - Note:
    ///   - 返回的 `UITableViewDropProposal` 控制拖拽时的视觉反馈
    ///   - 可以在这里动态更新拖拽的插入位置
    ///   - 返回 nil 表示不接受拖拽
    /// - Example:
    ///   ```swift
    ///   func tableView(_ tableView: UITableView,
    ///                  dropSessionDidUpdate session: UIDropSession,
    ///                  withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    ///       return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    ///   }
    ///   ```
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        printLog("[Deag] 拖拽在 tableView 内移动时调用（核心交互方法）")
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    /// 拖拽离开 tableView 区域时调用
    /// - Parameters:
    ///   - tableView: 目标 tableView
    ///   - session: 拖拽会话
    /// - Note:
    ///   - 可以在这里取消高亮，恢复 tableView 原始状态
    func tableView(_ tableView: UITableView, dropSessionDidExit session: any UIDropSession) {
        printLog("[Deag] 拖拽离开 tableView 区域时调用")
    }
    
    /// 拖拽会话结束时调用（无论是否成功放下）
    /// - Parameters:
    ///   - tableView: 目标 tableView
    ///   - session: 拖拽会话
    /// - Note:
    ///   - 可以在这里做清理工作
    ///   - 例如：移除高亮、重置状态等
    func tableView(_ tableView: UITableView, dropSessionDidEnd session: any UIDropSession) {
        printLog("[Deag] 拖拽会话结束时调用（无论是否成功放下）")
    }
    
    /// 自定义放下时的预览参数
    /// - Parameter indexPath: 被放下的 cell 索引位置
    /// - Returns: 预览参数，控制放下动画的圆角和背景
    /// - Note:
    ///   - 只能自定义预览的**圆角路径**和**背景色**
    ///   - 影响放下时的动画效果
    /// - Example:
    ///   ```swift
    ///   func tableView(_ tableView: UITableView,
    ///                  dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
    ///       let parameters = UIDragPreviewParameters()
    ///       parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 12)
    ///       return parameters
    ///   }
    ///   ```
    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        printLog("[Deag] 自定义放下时的预览参数")
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .red
        return parameters
    }
}

class WWManagementAccountListCell: BaseTableViewCell {
    private lazy var bgView = {
        let view = UIView()
        view.backgroundColor = .BG_F7F7F7_1_181818_1
        view.setCornerRadius(UIScale(15))
        return view
    }()
    
    private lazy var avatarView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .Text_000000_1_FFFFFF_1
        return label
    }()
    
    private lazy var balanceLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .Text_000000_1_FFFFFF_1
        return label
    }()
    
    private lazy var arrowView = {
        let view = UIImageView()
        view.image = UIImage(named: "sort")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(UIScale(8))
            make.left.right.equalToSuperview().inset(UIScale(18))
        }
        
        bgView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(UIScale(15))
            make.width.height.equalTo(UIScale(36))
        }
        
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(avatarView.snp.right).offset(UIScale(12))
        }
        
        bgView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIScale(40))
        }
        
        bgView.addSubview(arrowView)
        arrowView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIScale(10))
            make.width.height.equalTo(UIScale(20))
        }
    }
    
    func updateUI(_ text: String) {
        avatarView.image = UIImage(named: "create_icon")
        titleLabel.text = text
    }
}
