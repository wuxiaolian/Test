//
//  RecomSVideoVc.swift
//  PiPiJock
//
//  Created by Ny_MacBookPro on 2021/3/8.
//

import UIKit
import SafariServices

@objcMembers
class RecomSVideoVc: UIViewController {
    public let tableView : UITableView = {
        let table = UITableView.init(frame: CGRect.init(), style: .grouped)
        table.register(RecommandSmallVideoCell.classForCoder(), forCellReuseIdentifier: "RecommandSmallVideoCell")
        table.backgroundColor = BgColor
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    var dict = NSDictionary.init()
    var bannerDict = NSDictionary.init()
    var collectionView : UICollectionView?
    let W = (kSCREEN_WIDTH - 30)/2
    var dataArray = [MovieModel]()
    var bunnerArray = [NSDictionary]()
    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        creatTableview()
        initHeaderView()
        NetWorkMethod.rotationMethod { (array) in
            self.bunnerArray = array
            self.initTableHeaderView()
        }
        
    }
    func initHeaderView() {
        //搜索
        let searchBtn = UIButton.init(frame: CGRect.init(x: 16, y:11, width: kSCREEN_WIDTH - 16*2, height: 32))
      searchBtn.backgroundColor = UIColor.color(hex: "#F8F8FA")
        searchBtn.layer.cornerRadius = 8
        searchBtn.clipsToBounds = true
        searchBtn.tag = 10
        searchBtn.addTarget(self, action: #selector(self.allMethod(sender:)), for: .touchUpInside)
        self.view.addSubview(searchBtn)
        
        let icon = UIImageView.init(frame: CGRect.init(x: 10, y: (32 - 18)/2, width: 18, height: 18))
        icon.image = UIImage.init(named: "搜索")
        searchBtn.addSubview(icon)
        
        let warn = UILabel.init(frame: CGRect.init(x: 36, y: 0, width: 160, height: 32))
        warn.text = "搜型号、球星、标题等"
        warn.font = UIFont.systemFont(ofSize: 13)
      warn.textColor = UIColor.color(hex: "#999999")
        searchBtn.addSubview(warn)
        
    }
    //MARK:方法合集
    func allMethod(sender: UIButton)  {
        switch sender.tag {
        case 10:
            print("搜索==========")
            let vc = SearchVc()
            vc.type = .SmallVideo
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    func creatTableview() {
        self.view.addSubview(self.tableView)
        self.tableView.mas_makeConstraints { (make) in
            make?.left.right()?.top()?.bottom()?.equalTo()(self.view)?.insets()(UIEdgeInsets.init(top: 54, left: 0, bottom: 0, right: 0))
        }
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.isUserInteractionEnabled = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        SystemUtils.tableViewSetMJHeaderFooter(tableView: tableView, setHeader: true, {
            print("下拉刷新===============")
            self.dataArray.removeAll()
            self.page = 1
            self.getListData()
        }, setFooter: true) {
            print("上拉加载更多============")
            self.page = self.page + 1
            self.getListData()
        }
        
        self.getListData()
        
    }
    //MARK:获取视频列表
    func getListData()  {
        let para = [
            "page":"\(self.page)",
            "id":"\(self.dict["id"] ?? "")"
        ]
        NetWorkMethod.videoRemMethod(para: para) { (array) in
            if self.page == 1 {
                self.dataArray.removeAll()
            }
            for dict in array {
                let model = MovieModel.deserialize(from: dict)
                self.dataArray.append(model!)
            }
            if array.count == 0 {
                self.tableView.mj_footer!.endRefreshingWithNoMoreData()
            }else {
                self.tableView.mj_footer!.endRefreshing()
            }
            self.tableView.mj_header.endRefreshing()
            self.tableView.reloadData()
        }
    }
    func initTableHeaderView() {
        var urlArray = [String]()
        for dict in self.bunnerArray {
            urlArray.append("\(dict["image"] ?? "")")
        }
        
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kSCREEN_WIDTH, height: 166))
        header.backgroundColor = .white
        let scr = SDCycleScrollView.init(frame: CGRect.init(x: 16, y: 16, width: kSCREEN_WIDTH - 32 , height: 150), delegate: self, placeholderImage: randomImage)
        scr?.isUserInteractionEnabled = true
        scr?.layer.cornerRadius = 5
        scr?.clipsToBounds = true
        scr?.autoScrollTimeInterval = 3
        scr?.imageURLStringsGroup = urlArray
        scr?.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter
        scr?.pageDotColor = .white
        scr?.currentPageDotColor = .white
        scr!.bannerImageViewContentMode = .scaleAspectFill
        header.addSubview(scr!)
        
        self.tableView.tableHeaderView = header

    }
    override func viewWillAppear(_ animated: Bool) {
    }
}
extension RecomSVideoVc: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataArray[indexPath.section]

         var count = model.movies.count
         var number = 0
         for Model in model.movies {
            if Model.type == "0"  {
               count = count - 1
               number = number + 1
             }
         }
        let hei = CGFloat(count % 2 + count/2) *  (SmallAvHeigh + 10)
        return hei  +  CGFloat(number)  * AdHeigh  + 10 + 40
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kSCREEN_WIDTH, height: 65))
        if section == 0 {
            let bg = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kSCREEN_WIDTH, height: 65))
            header.addSubview(bg)
            let image = GetImageWithColors.init().createImageSize(CGSize.init(width: kSCREEN_WIDTH, height: 65), gradientColors: [UIColor.white, BgColor], percentage: [0,1])
            bg.image = image
        }
        let la = UILabel.init(frame: CGRect.init(x: 15, y: 24, width:200, height: 25))
      la.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
      la.textColor = UIColor.color(hex: "#223150")
        header.addSubview(la)
        
        let more = UIButton.init(frame: CGRect.init(x: kSCREEN_WIDTH - 60, y: 24, width: 50, height: 20))
        more.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        more.setTitle("更多", for: .normal)
        more.setTitleColor(UIColor.color(hex: "#9AA0B0"), for: .normal)
        more.tag = 20 + section
        more.addTarget(self, action: #selector(self.moreMethod(sender:)), for: .touchUpInside)
        more.setImage(UIImage.init(named: "向右黑色箭头"), for: .normal)
        more.layoutButton(with: .right, imageTitleToSpace: 5)
        header.addSubview(more)
        let model = self.dataArray[section]

        if section == 0 {
            header.backgroundColor = .clear
            la.text = model.title
        }else if section == 1 {
            la.text = model.title
//            la.font = UIFont.init(name: "HelveticaNeue-Medium", size: 16)
//            header.backgroundColor = BgColor
        }else  {
            la.text = model.title
//            la.font = UIFont.init(name: "HelveticaNeue-Medium", size: 16)
//            header.backgroundColor = BgColor
        }
      header.backgroundColor = .red
        return header
    }
    //MARK:更多方法
    func moreMethod(sender: UIButton)  {
       print("MARK:更多方法===================")
        let vc = SmallVideoListVc()
        vc.model = self.dataArray[sender.tag - 20]
        self.navigationController?.pushViewController(vc, animated: true)
    
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kSCREEN_WIDTH, height: 0))
        header.backgroundColor = BgColor
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RecommandSmallVideoCell.init(style: .default, reuseIdentifier: "RecommandSmallVideoCell")
        cell.dataArray = self.dataArray[indexPath.section].movies
        cell.section = indexPath.section
        cell.model = self.dataArray[indexPath.section]
        cell.creatCollectionView()
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
extension RecomSVideoVc: SDCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        print("==========SDCycleScrollViewDelegate============")
        let dict = self.bunnerArray[index]
        if UIApplication.shared.canOpenURL(URL.init(string: "\(dict["url"] ?? "")")!) {
            let safari = SFSafariViewController(url: URL.init(string: "\(dict["url"] ?? "")")!)
            self.present(safari, animated: true, completion: nil)
        }
        
    }
    
}



