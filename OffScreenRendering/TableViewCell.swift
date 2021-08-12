//
//  TableViewCell.swift
//  OffScreenRendering
//
//  Created by 林文俊 on 2021/8/12.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    static func cellForRow(tableView: UITableView) -> TableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "myCell")
        if cell == nil {
            cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        }
        return cell as! TableViewCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCell()
    }
    
    private func setCell() {
//        wj_shouldRasterize() // 光栅化
//        wj_mask()  // 遮罩
//        wj_shadows() // 阴影
//        wj_shadowsOptimize() // 阴影优化
//        wj_edgeAntialiasing() // 抗锯齿
//        wj_allowsGroupOpacity() // 不透明
        wj_radius() // 圆角
//        wj_radiusBezier() // 圆角优化
    }
    
    // 光栅 - 触发离屏渲染
    private func wj_shouldRasterize() {
        // 缓存机制 -- bitmap -- cpu直接从缓存取数据 -- gpu渲染 -- 可提供性能 -- 缓存在100ms内  慎用！！！
        // 面试尽量别提光栅化。若当视图内容是动态变化(如后台下载图片完毕后切换到主线程设置)时，使用此方案反而为增加系统负荷。
        imageV.layer.shouldRasterize = true
        imageV.layer.rasterizationScale = imageV.layer.contentsScale
    }
    
    // 遮罩Mask - 触发离屏渲染
    private func wj_mask() {
        // mask是添加在imageV.layer的上层
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: imageV.bounds.size.width, height: imageV.bounds.size.height)
        layer.backgroundColor = UIColor.red.cgColor
        imageV.layer.mask = layer
    }
    
    // 阴影 - 触发离屏渲染
    private func wj_shadows() {
        // shadow是在imageV.layer的下层
        imageV.layer.shadowColor = UIColor.red.cgColor
        imageV.layer.shadowOpacity = 0.1
        imageV.layer.shadowRadius = 5
        imageV.layer.shadowOffset = CGSize(width: 10, height: 10)
    }
    
    // 阴影优化！
    private func wj_shadowsOptimize() {
        imageV.layer.shadowColor = UIColor.red.cgColor
        imageV.layer.shadowOpacity = 0.1
        imageV.layer.shadowRadius = 5
        // CoreAnimation - 阴影的几何形状
        imageV.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: imageV.bounds.size.width+10, height: imageV.bounds.size.height+10)).cgPath // 10是阴影偏移量
    }
    
    // 抗锯齿 - 触发离屏渲染
    private func wj_edgeAntialiasing() {
        let angel = CGFloat.pi/20.0
        imageV.layer.transform = CATransform3DRotate(imageV.layer.transform, angel, 0, 0, 1);
        imageV.clipsToBounds = true
        imageV.layer.allowsEdgeAntialiasing = true
    }
    
    // 视图组不透明 alpha 只要有子视图并设置父视图的alpha<1就会离屏渲染
    private func wj_allowsGroupOpacity() {
        // 没有子视图是不会离屏渲染
        let view = UIView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        view.backgroundColor = .green
        imageV.addSubview(view)
        
        imageV.alpha = 0.5
        imageV.layer.allowsGroupOpacity = true // 设置view与imageV透明度一样
    }
    
    // 圆角
    private func wj_radius() {
        
        // 情况1：不会触发离屏渲染
        
        imageV.backgroundColor = .red // 加了背景颜色会触发离屏渲染, 其实设置layer的backgroundColor
//        imageV.image = nil // 实际是把contents层设置为nil
//        imageV.layer.backgroundColor = UIColor.blue.cgColor
        imageV.layer.cornerRadius = 20
        imageV.clipsToBounds = true
        
        
        // 情况4：label
        label.backgroundColor = .red // 它设置的是contents这个backgroundColor
        label.layer.backgroundColor = UIColor.blue.cgColor // 它设置的是layer的backgroundColor
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        
        
        // 情况2：四个角就会离屏渲染
        // 设置borderWidth、borderColor只要Color不为clear，四个角就会离屏渲染
        /*
        imageV.layer.borderWidth = 1
        imageV.layer.borderColor = UIColor.red.cgColor
        imageV.layer.cornerRadius = 20
        imageV.clipsToBounds = true
        */
        
        // 情况3： 添加子视图
        /*
        let view = UIView(frame: CGRect(x: 30, y: 30, width: 30, height: 30))
        view.backgroundColor = .green
        imageV.addSubview(view)
        imageV.layer.cornerRadius = 20
        imageV.clipsToBounds = true
        */
    }
    
    // 圆角优化贝塞尔曲线 --- 不是最优解
    private func wj_radiusBezier() {
        imageV.backgroundColor = .red
        
        UIGraphicsBeginImageContextWithOptions(imageV.bounds.size, false, 0.0)
        imageV.draw(imageV.bounds)
        imageV.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
