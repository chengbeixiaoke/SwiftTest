//
//  CustomDragSortViewController.swift
//  Web3WalletModule
//
//  Created by Codex on 2026/4/15.
//

import UIKit
import SnapKit

class CustomDragSortViewController: BaseViewController {
    private lazy var tableView = {
        let tableView = BaseTableView(frame: .zero, style: .plain)
        tableView.register(cellWithClass: WWManagementAccountListCell2.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .automatic
        if #available(iOS 26.0, *) {
            tableView.topEdgeEffect.isHidden = false
            tableView.bottomEdgeEffect.isHidden = false
        }
        return tableView
    }()
    
    private var dataSource = ["🍎 苹果", "🍌 香蕉", "🍊 橙子", "🍇 葡萄", "🫐蓝莓", "🥑牛油果", "🍐梨子", "🪷荷花", "✈️飞机", "🐘大象", "🦁狮子", "🦓斑马", "🐯老虎", "🐔鸡子", "苹果", "香蕉", "橙子", "葡萄", "蓝莓", "牛油果", "梨子", "荷花", "飞机", "大象", "狮子", "斑马", "老虎", "鸡子"]
    private var longPressGesture: UILongPressGestureRecognizer?
    private var dragIndexPath: IndexPath?
    private var dragSnapshot: UIView?
    private var currentDragLocationInTableView: CGPoint = .zero
    private var currentDragLocationInView: CGPoint = .zero
    
    private var autoScrollDisplayLink: CADisplayLink?
    private var autoScrollVelocity: CGFloat = 0
    private let autoScrollTriggerInset = UIScale(70)
    private let maxAutoScrollVelocity = UIScale(220)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupLongPressGesture()
    }
    
    deinit {
        stopAutoScroll()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScale(110))
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gesture.minimumPressDuration = 0.35
        longPressGesture = gesture
        tableView.addGestureRecognizer(gesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let locationInTableView = gesture.location(in: tableView)
        let locationInView = gesture.location(in: view)
        currentDragLocationInTableView = locationInTableView
        currentDragLocationInView = locationInView
        
        switch gesture.state {
        case .began:
            startDragging(at: locationInTableView, locationInView: locationInView)
        case .changed:
            updateDragging(at: locationInTableView, locationInView: locationInView)
        case .ended, .cancelled, .failed:
            endDragging()
        default:
            break
        }
    }
    
    private func startDragging(at locationInTableView: CGPoint, locationInView: CGPoint) {
        guard let indexPath = tableView.indexPathForRow(at: locationInTableView),
              let cell = tableView.cellForRow(at: indexPath) as? WWManagementAccountListCell2 else {
            return
        }
        
        dragIndexPath = indexPath
        
        let snapshotInfo = cell.startDragging()
        let snapshot = snapshotInfo.snapshotView
        snapshot.center = cell.convert(snapshotInfo.originalCenter, to: view)
        
        view.addSubview(snapshot)
        dragSnapshot = snapshot
        cell.isHidden = true
        
        UIView.animate(withDuration: 0.18) {
            snapshot.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
        
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
    }
    
    private func updateDragging(at locationInTableView: CGPoint, locationInView: CGPoint) {
        guard dragIndexPath != nil else { return }
        
        updateSnapshotPosition(for: locationInView)
        updateAutoScrollIfNeeded(for: locationInTableView)
        moveRowIfNeeded(at: locationInTableView)
    }
    
    private func updateSnapshotPosition(for locationInView: CGPoint) {
        guard let dragSnapshot else { return }
        
        let visibleFrame = tableView.convert(tableView.bounds, to: view)
        let minY = visibleFrame.minY + dragSnapshot.bounds.height / 2
        let maxY = visibleFrame.maxY - dragSnapshot.bounds.height / 2
        let centerY = min(max(locationInView.y, minY), maxY)
        dragSnapshot.center = CGPoint(x: visibleFrame.midX, y: centerY)
    }
    
    private func moveRowIfNeeded(at location: CGPoint) {
        guard let dragIndexPath,
              let targetIndexPath = tableView.indexPathForRow(at: location),
              targetIndexPath != dragIndexPath else {
            return
        }
        
        let movedItem = dataSource.remove(at: dragIndexPath.row)
        dataSource.insert(movedItem, at: targetIndexPath.row)
        tableView.moveRow(at: dragIndexPath, to: targetIndexPath)
        self.dragIndexPath = targetIndexPath
        
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
    }
    
    private func endDragging() {
        stopAutoScroll()
        
        guard let dragIndexPath,
              let dragSnapshot,
              let cell = tableView.cellForRow(at: dragIndexPath) as? WWManagementAccountListCell2 else {
            cleanupDraggingState()
            return
        }
        
        cell.isHidden = false
        let targetFrame = cell.dragTargetFrame(in: view)
        
        UIView.animate(withDuration: 0.2, animations: {
            dragSnapshot.transform = .identity
            dragSnapshot.frame = targetFrame
            dragSnapshot.alpha = 0.96
        }, completion: { _ in
            self.cleanupDraggingState()
        })
        
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }
    
    private func cleanupDraggingState() {
        if let dragIndexPath,
           let cell = tableView.cellForRow(at: dragIndexPath) {
            cell.isHidden = false
        }
        dragSnapshot?.removeFromSuperview()
        dragSnapshot = nil
        self.dragIndexPath = nil
        currentDragLocationInTableView = .zero
        currentDragLocationInView = .zero
        autoScrollVelocity = 0
    }
    
    private func updateAutoScrollIfNeeded(for location: CGPoint) {
        let visibleFrame = tableView.convert(tableView.bounds, to: view)
        let topTriggerY = visibleFrame.minY + autoScrollTriggerInset
        let bottomTriggerY = visibleFrame.maxY - autoScrollTriggerInset
        
        if currentDragLocationInView.y < topTriggerY {
            let progress = min(1, (topTriggerY - currentDragLocationInView.y) / autoScrollTriggerInset)
            autoScrollVelocity = -maxAutoScrollVelocity * max(progress, 0.12)
            startAutoScrollIfNeeded()
        } else if currentDragLocationInView.y > bottomTriggerY {
            let progress = min(1, (currentDragLocationInView.y - bottomTriggerY) / autoScrollTriggerInset)
            autoScrollVelocity = maxAutoScrollVelocity * max(progress, 0.12)
            startAutoScrollIfNeeded()
        } else {
            stopAutoScroll()
        }
    }
    
    private func startAutoScrollIfNeeded() {
        guard autoScrollDisplayLink == nil else { return }
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleAutoScrollTick))
        displayLink.add(to: .main, forMode: .common)
        autoScrollDisplayLink = displayLink
    }
    
    private func stopAutoScroll() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        autoScrollVelocity = 0
    }
    
    @objc private func handleAutoScrollTick() {
        guard dragIndexPath != nil, autoScrollVelocity != 0 else { return }
        
        let minOffsetY = -tableView.adjustedContentInset.top
        let maxOffsetY = max(minOffsetY, tableView.contentSize.height - tableView.bounds.height + tableView.adjustedContentInset.bottom)
        let deltaY = autoScrollVelocity * CGFloat(autoScrollDisplayLink?.duration ?? (1.0 / 60.0))
        let targetOffsetY = min(max(tableView.contentOffset.y + deltaY, minOffsetY), maxOffsetY)
        
        guard targetOffsetY != tableView.contentOffset.y else {
            stopAutoScroll()
            return
        }
        
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: targetOffsetY)
        currentDragLocationInTableView = view.convert(currentDragLocationInView, to: tableView)
        updateSnapshotPosition(for: currentDragLocationInView)
        moveRowIfNeeded(at: currentDragLocationInTableView)
        updateAutoScrollIfNeeded(for: currentDragLocationInTableView)
    }
}

extension CustomDragSortViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: WWManagementAccountListCell2.self)
        cell.updateUI(dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIScale(68)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView(frame: .zero)
    }
}

class WWManagementAccountListCell2: BaseTableViewCell {
    private lazy var bgView = {
        let view = UIView()
        view.backgroundColor = .BG_F7F7F7_1_181818_1
        view.setCornerRadius(UIScale(15))
        return view
    }()
    
    private lazy var avatarView = UIImageView()
    
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
        view.contentMode = .center
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
        balanceLabel.text = ""
    }
    
    func startDragging() -> (snapshotView: UIView, originalCenter: CGPoint) {
        let originalColor = bgView.backgroundColor
        bgView.backgroundColor = .BG_FFFFFF_1_222222_1
        
        let snapshotContainer = UIView(frame: bgView.bounds)
        snapshotContainer.layer.cornerRadius = UIScale(15)
        snapshotContainer.layer.shadowColor = UIColor.BG_000000_03_FFFFFF_03.cgColor
        snapshotContainer.layer.shadowOpacity = 1
        snapshotContainer.layer.shadowOffset = .zero
        snapshotContainer.layer.shadowRadius = 10
        snapshotContainer.layer.shadowPath = UIBezierPath(roundedRect: snapshotContainer.bounds, cornerRadius: UIScale(15)).cgPath
        
        let snapshotContent = bgView.snapshotView(afterScreenUpdates: true) ?? UIView(frame: bgView.bounds)
        snapshotContent.frame = snapshotContainer.bounds
        snapshotContent.layer.cornerRadius = UIScale(15)
        snapshotContent.layer.masksToBounds = true
        snapshotContainer.addSubview(snapshotContent)
        
        bgView.backgroundColor = originalColor
        return (snapshotContainer, bgView.center)
    }
    
    func dragTargetFrame(in targetView: UIView) -> CGRect {
        bgView.convert(bgView.bounds, to: targetView)
    }
}
