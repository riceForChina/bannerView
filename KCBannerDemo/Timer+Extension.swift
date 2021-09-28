//
//  Timer+Extension.swift
//
//
//  Created by 范其乐 on 2018/9/30.
//  Copyright © 2018年 com.baidu. All rights reserved.
//

import UIKit

//block UIButton
var TimeActionBlockKey: UInt8 = 0

// a type for our action block closure
public typealias TimerBlockButtonActionBlock = (() -> Void)?

public class TimerActionBlockWrapper : NSObject {
    var block : TimerBlockButtonActionBlock
    init(block: TimerBlockButtonActionBlock) {
        self.block = block
    }
    @objc func block_handleAction() {
        block?()
    }
}

extension Timer{
   
    /// timerblock封装,可以解决循环引用问题
    ///
    /// - Parameters:
    ///   - timeInterval: 间隔时间
    ///   - Customblock: 回调block
    /// - Returns: timer对象
    @discardableResult
    public class func blockTimer(timeInterval: TimeInterval,Customblock: TimerBlockButtonActionBlock) -> Timer{
        let obj = TimerActionBlockWrapper(block: Customblock)
        let timer = Timer(timeInterval: timeInterval, target: obj, selector: #selector(obj.block_handleAction), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }
    
    
    
    public class func blockTimerNewRunLoop(timeInterval: TimeInterval,customblock: TimerBlockButtonActionBlock, timeBlock:((Timer) ->())){
        let obj = TimerActionBlockWrapper(block: customblock)
        let timer = Timer(timeInterval: timeInterval, target: obj, selector: #selector(obj.block_handleAction), userInfo: nil, repeats: true)
        timeBlock(timer)
        let runLoop = RunLoop.current
        runLoop.add(timer, forMode: .common)
        runLoop.run()
    }
}

extension Array {
    
    /// 获取数组元素方法,会进行数据越界判断,越界后会返回nil
    ///
    /// - Parameter index: index
    /// - Returns: 取出的元素
    public func getSafeIndex(_ index:Int) -> Any?{
        if index >= 0, index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
    @discardableResult
    public mutating func removeSafeIndex(_ index:Int) -> Bool{
        if index >= 0, index < self.count {
            remove(at: index)
            return true
        } else {
            return false
        }
    }
}
