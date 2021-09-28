//
//  KCScrollContainerView.swift
//  KCBannerDemo
//
//  Created by FanQiLe on 2021/9/28.
//


import UIKit
import SnapKit

public class KCScrollContainerView: UIView {
    public var dataList: Array<String>  = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public typealias ScrollDidAndEndBlock = ((Int,UIView) -> Void)?
    public var scrollDidAndEndBlock: ScrollDidAndEndBlock = nil
    
    public typealias ScrollDidBlock = ((UIScrollView) -> Void)?
    public var scrollDidBlock: ScrollDidBlock = nil
    
    public var createListViewBlock: ((String,Int) -> UIView)?
    public var reloadDataBlock: ((String,Int,UIView) -> ())?
    
    var listViewDic: [String:UIView] = [:]
    
    let SCROLLVIEW_CELL_ID: String = "scrollview_cell_id"
    
    var isForceScroll: Bool = false
    
    public lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    public lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: SCROLLVIEW_CELL_ID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSelf()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout.itemSize = bounds.size
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension KCScrollContainerView {
    func forceScroll(toIndex: Int) {
        if collectionView.visibleCells.count <= 0 {//目前还没有进行reload
            return
        }
        
        let toIndexPath = IndexPath(item: toIndex, section: 0)
        if toIndex >= dataList.count,
            toIndex < 0{//判断是否数组越界
            return
        }
        
        isForceScroll = true
        collectionView.scrollToItem(at: toIndexPath, at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {//处理某些情况没有调用下面的handleDidAndEnd方法
            self.isForceScroll = false
        }
    }
    
    func getListView(rowIndex: Int) -> UIView {
        guard let titleStr = dataList.getSafeIndex(rowIndex) as? String  else {
            return UIView()
        }
        if let listView = listViewDic[titleStr] {
            reloadDataBlock?(titleStr,rowIndex,listView)
            return listView
        }
        let listView = createListViewBlock?(titleStr,rowIndex) ?? UIView()
        listViewDic[titleStr] = listView
        reloadDataBlock?(titleStr,rowIndex,listView)
        return listView
    }
    
    
}

extension KCScrollContainerView {
    func layoutSelf() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension KCScrollContainerView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SCROLLVIEW_CELL_ID, for: indexPath)
        
        let subView: UIView = getListView(rowIndex: indexPath.row)
        for item in cell.contentView.subviews {
            item.removeFromSuperview()
        }

        cell.contentView.addSubview(subView)
        subView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return cell
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleDidAndEnd(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleDidAndEnd(scrollView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isForceScroll {//手动滚动不回调scrollDidBlock
            scrollDidBlock?(scrollView)
        }
    }
    
    func handleDidAndEnd(_ scrollView: UIScrollView) {
        let appWidth:CGFloat = UIApplication.shared.delegate?.window??.bounds.size.width ?? UIScreen.main.bounds.size.width
        let index = Int(scrollView.contentOffset.x / appWidth)
        let subView = getListView(rowIndex: index)
        scrollDidAndEndBlock?(index, subView)
        isForceScroll = false
    }
}



