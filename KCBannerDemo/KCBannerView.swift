//
//  KCBannerView.swift
//  KCBannerDemo
//
//  Created by FanQiLe on 2021/9/28.
//


import UIKit

public protocol BannerCellDataProtocol {
    func setData(data: Any)
}

public class KCBannerView: UICollectionView {
    
    fileprivate var isShow: Bool = false
    
    public var cellSize: CGSize = CGSize.zero
    
    private var totalItemsCount: Int = 0
    
    public var dataList: Array<Any> = [] {
        didSet {
            if dataList.count < 0 {
                return
            }
            if dataList.count > 1{
                totalItemsCount = dataList.count * 100
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {//需要加延时,等reload所有cell之后再滚动
                    let toIndex: Int = Int(CGFloat(self.totalItemsCount) * 0.5)
                    self.forceScroll(toIndex: toIndex, animated: false)
                    self.openTimer = true
                }
            } else {
                 totalItemsCount = 1
                 self.openTimer = false
            }
            reloadData()
        }
    }
    
    public var currentIndex: Int {
        if cellSize.height == 0,
            cellSize.width == 0{
            return 0
        }
        
        let space: CGFloat = self.layout?.minimumLineSpacing ?? 0
        let cellW: CGFloat = space + cellSize.width
        let index = (contentOffset.x + cellW * 0.5) / cellW
        return Int(max(0, index))
    }
    
    public typealias ScrollDidAndEndBlock = ((Int) -> Void)?
    public var scrollDidAndEndBlock: ScrollDidAndEndBlock = nil
    
    public var didSelectBlock: ((Any) -> Void)?
    
    public var displayBlock: ScrollDidAndEndBlock = nil
    
    public var registerCellBlock: ((BannerCellDataProtocol,Int) -> ())?
    
    fileprivate var timeNum: CGFloat = 5
    fileprivate weak var timer: Timer?
    
    fileprivate var openTimer: Bool = false{
        didSet {
            self.timer?.invalidate()
            self.timer = nil
            
            if openTimer,
                isShow{//没有显示则不滚动
                self.timer = Timer.blockTimer(timeInterval: TimeInterval(timeNum)) { [weak self] in
                    self?.timerScroll()
                }
            }
        }
    }
    
    fileprivate let BANNER_CELL_ID: String = "KCScaleBannerViewCELLID"
    var layout: KCScaleBannerFlowLayout?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    public convenience init(registerClass: AnyClass,isScaleType: Bool = false,minimumLineSpacing: CGFloat = 0,timeNum: CGFloat = 5,marginLR: CGFloat = 0) {
        let layout = KCScaleBannerFlowLayout()
        self.init(frame: CGRect.zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = minimumLineSpacing
        layout.minimumInteritemSpacing = 0
        layout.isScaleType = isScaleType
        layout.getCellWBlock = {[weak self]() in
            return self?.cellSize.width ?? 0
        }
        self.layout = layout
        contentInset = UIEdgeInsets(top: 0, left: marginLR, bottom: 0, right: marginLR)
        backgroundColor = UIColor.white
        register(registerClass, forCellWithReuseIdentifier: BANNER_CELL_ID)
        delegate = self
        dataSource = self
        self.timeNum = timeNum
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bounces = false
        decelerationRate = .fast
    }
    
    deinit {
        openTimer = false
    }
}

extension KCBannerView {
    public func changeShowStatus(isShow: Bool) {
        self.isShow = isShow
        if isShow,
            dataList.count > 1 {
            openTimer = true
        } else {
           openTimer = false
        }
    }
}

extension KCBannerView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BANNER_CELL_ID, for: indexPath) as? BannerCellDataProtocol
        let currentIndexRow = pageControlIndex(currentCellIndex: indexPath.row)
        if let itemData = dataList.getSafeIndex(currentIndexRow) {
            cell?.setData(data: itemData)
        }
        if let temp = cell {
            registerCellBlock?(temp,indexPath.row)
        }
        return cell as? UICollectionViewCell ?? UICollectionViewCell()
    }
    
    public func pageControlIndex(currentCellIndex: Int) -> Int{
        if dataList.count <= 0 {
            return 0
        } else {
            return currentCellIndex % dataList.count
        }
    }
}

public extension KCBannerView{
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if abs(velocity.x) < 2 {
//            scrollToIndex(targetIndex: currentIndex)
//        }
//    }
    

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        openTimer = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        openTimer = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滚动回调
        let currentIndexRow = pageControlIndex(currentCellIndex: currentIndex)
        scrollDidAndEndBlock?(currentIndexRow)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let currentIndexRow = pageControlIndex(currentCellIndex: currentIndex)
        displayBlock?(currentIndexRow)
    }
    
    func timerScroll() {
        if totalItemsCount == 0 {
            return
        }
        scrollToIndex(targetIndex: currentIndex + 1)
    }
    
    func scrollToIndex(targetIndex: Int) {
        if targetIndex >= totalItemsCount {
            let toIndex = Int(CGFloat(totalItemsCount) * 0.5) - 1//先滚到中间的前一个,和当前图片一样的在滚动一次有动画的
            forceScroll(toIndex: toIndex, animated: false)
            forceScroll(toIndex: toIndex + 1, animated: true)
            return
        }
        
        forceScroll(toIndex: targetIndex, animated: true)
    }
    
    func forceScroll(toIndex: Int, animated: Bool) {
        let toIndexPath = IndexPath(item: toIndex, section: 0)
        scrollToItem(at: toIndexPath, at: .centeredHorizontally, animated: animated)
    }
}

extension KCBannerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

extension KCBannerView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentIndexRow = pageControlIndex(currentCellIndex: indexPath.row)
        if let itemData = dataList.getSafeIndex(currentIndexRow) {
            didSelectBlock?(itemData)
        }
        
    }
}

