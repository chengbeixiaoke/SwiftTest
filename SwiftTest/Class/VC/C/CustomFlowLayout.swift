//
//  CustomFlowLayout.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/31.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        // 设置滚动方向为垂直
        scrollDirection = .vertical
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        // 获取 collectionView 的内容高度
        guard let collectionView = collectionView else {
            return attributes
        }
        
        let contentHeight = collectionViewContentSize.height
        
        // 对每个属性进行垂直翻转
        var modifiedAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributes {
            let modifiedAttribute = attribute.copy() as! UICollectionViewLayoutAttributes
            // 计算新的 y 位置（从底部开始）
            modifiedAttribute.frame.origin.y = contentHeight - attribute.frame.maxY
            modifiedAttributes.append(modifiedAttribute)
        }
        
        print(modifiedAttributes.map {$0.frame.minY})
        return modifiedAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attribute = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        // 获取 collectionView 的内容高度
        guard let collectionView = collectionView else {
            return attribute
        }
        
        let contentHeight = collectionViewContentSize.height
        
        // 创建新的属性并调整位置
        let modifiedAttribute = attribute.copy() as! UICollectionViewLayoutAttributes
        modifiedAttribute.frame.origin.y = contentHeight - attribute.frame.maxY
        
        return modifiedAttribute
    }
    
    override var collectionViewContentSize: CGSize {
        let size = super.collectionViewContentSize
        return size
    }
}
