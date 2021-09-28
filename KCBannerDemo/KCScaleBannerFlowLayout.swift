//
//  KCScaleBannerFlowLayout.swift
//  KCWormHoleModule
//
//  Created by 范其乐 on 2020/7/2.
//

import UIKit

public class KCScaleBannerFlowLayout: UICollectionViewFlowLayout {

    
    var isScaleType: Bool = false
    
    var getCellWBlock: (()->CGFloat)?
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes: [UICollectionViewLayoutAttributes] = NSArray(array: super.layoutAttributesForElements(in: rect) ?? [], copyItems: true) as! [UICollectionViewLayoutAttributes]
        if isScaleType == false {
            return attributes
        }
        
        if let tempView = self.collectionView {
            var cellW: CGFloat = self.getCellWBlock?() ?? 0
            let centerX = tempView.contentOffset.x + cellW * 0.5
            
            if cellW <= 0 {
                return attributes
            }
            cellW = cellW + self.minimumLineSpacing
            for item in attributes {
                let offset = abs(item.center.x - centerX)
                let tempScale:CGFloat = 0.9
                var scale = tempScale + abs((cellW - offset)/cellW) * CGFloat(1-tempScale)
                if scale > 1 {
                    scale = 1
                }
                item.transform = CGAffineTransform(scaleX: 1, y: scale);
            }
            
        }
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var point = proposedContentOffset
        if let collectionView = collectionView {

            /// 计算出最终显示的矩形框
            let rect = CGRect(x: point.x, y: 0.0, width: collectionView.bounds.width, height: collectionView.bounds.height)
            /// 计算collectionView最中心点的y值
            let centerX = point.x + collectionView.bounds.size.width * 0.5
            /// 存放最小的间距值
            var minDelta = CGFloat(MAXFLOAT)
            /// 获得super已经计算好的布局属性
            if let attributes = super.layoutAttributesForElements(in: rect) {
                for attr in attributes {
                    if abs(minDelta) > abs(attr.center.x - centerX) {
                        minDelta = attr.center.x - centerX
                    }
                }
            }
            /// 修改原有的偏移量
            point.x += minDelta
        }
        return point
    }
}

