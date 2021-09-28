//
//  ViewController.swift
//  KCBannerDemo
//
//  Created by FanQiLe on 2021/9/28.
//

import UIKit

class KCHomeBannerCell: UICollectionViewCell,BannerCellDataProtocol {
    func setData(data: Any) {
        let temp = data as? Int ?? 0
        if temp % 2 == 0 {
            self.backgroundColor = .red
        } else {
            self.backgroundColor = .green
        }
        
        print("data = \(data)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ViewController: UIViewController {
    
    lazy var firstBannerView: KCBannerView = {
        let bannerView = KCBannerView(registerClass: KCHomeBannerCell.self,timeNum: 5)
        self.view.addSubview(bannerView)
        
       bannerView.changeShowStatus(isShow: true)
       bannerView.backgroundColor = .gray
        bannerView.didSelectBlock = { [weak self, weak bannerView](data) in
            print("didSelectBlock")
        }
        
        bannerView.scrollDidAndEndBlock = { [weak self, weak bannerView](index) in
            print("didSelectBlock")
        }
        return bannerView
    }()
    
    public var scrollDidAndEndBlock: ((Int,UIView) -> Void)?
    lazy var containerV: KCScrollContainerView = {
        let containerView = KCScrollContainerView()
        containerView.backgroundColor = .gray
        containerView.collectionView.backgroundColor = .gray
        containerView.scrollDidAndEndBlock = { [weak self, weak containerView](index, itemView) in
            
        }
        
        containerView.createListViewBlock = { [weak self](titleStr,rowIndex) in
            //自定义view
            let temp = UIView()
            if rowIndex%2 == 0 {
                temp.backgroundColor = UIColor.red
            } else {
                temp.backgroundColor = UIColor.blue
            }
            return temp
        }
        
        self.view.addSubview(containerView)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        firstBannerView.frame = CGRect(x: 20, y: 20, width: 200, height: 100)
        
        firstBannerView.dataList = [1,2,3,4,5,6]
        firstBannerView.cellSize = CGSize(width: 200, height: 100)
        
        containerV.frame = CGRect(x: 10, y: 140, width: self.view.bounds.width - 20, height: 500)
        containerV.dataList = ["1","2","3"]
    }


}

