//
//  SmallVideoVc.swift
//  PiPiJock
//
//  Created by Ny_MacBookPro on 2021/3/22.
//

import UIKit



@objcMembers
class SmallVideoVc: VTMagicController  {

    var titleArray = [NSDictionary]()
    var dataArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadNavigationBar()
        self.navigationBar.isHidden = true
        NetWorkMethod.videoCaseMethod { (array) in
            for i in 0...array.count - 1 {
                let dict = array[i]
                if i == 1 {
                    self.dataArray.append("最新")
                }
                self.dataArray.append("\(dict["title"] ?? "")")
                self.titleArray.append(dict)
            }
            self.initMagicView()
        }

    }
    
    func initMagicView()  {
        let magicView = VTMagicView.init(frame: CGRect.init(x: 0, y:WD_NavBarHeight - 25, width: kSCREEN_WIDTH, height: kSCREEN_HEIGHT -  WD_NavBarHeight - WD_TabBarHeight + 25))
        magicView.magicController = self
        magicView.delegate = self
        magicView.dataSource = self
        magicView.isAgainstStatusBar = true
        magicView.headerView.backgroundColor = .white
        magicView.layoutStyle = .default
        magicView.switchStyle = .stiff
        magicView.itemSpacing = 16
      magicView.sliderColor = UIColor.color(hex: "#E62021")
      magicView.sliderWidth = 20
      magicView.sliderHeight = 3
      magicView.bubbleRadius = 2
      magicView.sliderOffset = -6
        magicView.navigationColor = .white
      magicView.separatorColor = .white
      magicView.navigationInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        magicView.separatorHeight = 0
        self.view.addSubview(magicView)
        magicView.reloadData()

        let more = UIButton.init(frame: CGRect.init(x: kSCREEN_WIDTH - 44, y: WD_NavBarHeight - 5, width: 44, height: 44))
        more.setImage(UIImage.init(named: "更多"), for: .normal)
        more.backgroundColor = .white
        more.addTarget(self, action: #selector(self.moreMethod), for: .touchUpInside)
        self.view.addSubview(more)

    }
    
    //MARK:更多方法
    func moreMethod()  {
        print("更多方法==================")
        let vc = SmallVideoCatoryVc()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
//thmem_list?list=1&page=1
}
extension SmallVideoVc {
    override func menuTitles(for magicView: VTMagicView) -> [String] {
        return self.dataArray
    }
    
    override func magicView(_ magicView: VTMagicView, menuItemAt itemIndex: UInt) -> UIButton {
        
        let itemIdentifier  = "itemIdentifier"
        var menuItem = magicView.dequeueReusableItem(withIdentifier: itemIdentifier)
        if menuItem == nil {
            menuItem = UIButton.init(type: .custom)
          menuItem?.setTitleColor(UIColor.color(hex: "#999999"), for: .normal)
          menuItem?.setTitleColor(UIColor.color(hex: "#223150"), for: .selected)
          let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
          menuItem?.titleLabel?.font = font

        }
        return menuItem!
    }
    
    override func magicView(_ magicView: VTMagicView, viewControllerAtPage pageIndex: UInt) -> UIViewController {
        
        if pageIndex == 0 {
            let vc = RecomSVideoVc.init()
            vc.dict = self.titleArray[Int(pageIndex)]
            return vc
        }else if pageIndex == 1 {
            let vc = NewSmallVideoVc.init()
            vc.dict = ["name":"最新"]
            return vc
        }else {
            let vc = NewSmallVideoVc()
            vc.dict = self.titleArray[Int(pageIndex - 1)]
            return vc
        }
    }
    

}


