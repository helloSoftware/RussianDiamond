//
//  ViewController.swift
//  RussianDiamond
//
//  Created by poplar on 2017/7/3.
//  Copyright © 2017年 poplar. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,GameViewDelegate {
    
    let MARGIN:CGFloat = 10
    let BUTTON_SIZE : CGFloat = 48
    let BUTTON_ALPHA : CGFloat = 0.6
    
    var screenWidth : CGFloat = 0.0
    var screenHeight : CGFloat = 0.0
    
    let ToolBarHeight : CGFloat = 44
    
    var gameView : GameView!
    
    var speed : UILabel!
    var scoreShow : UILabel!
    
    var bgMusicPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let imageView : UIImageView = UIImageView.init(image: UIImage.init(named: "test"))
        imageView.frame = self.view.bounds
        self.view.addSubview(imageView)
        
        let rect : CGRect = UIScreen.main.bounds
        screenWidth = rect.size.width
        screenHeight = rect.size.height
        
        //添加工具条
        self.addToolBar()
        
        //添加游戏界面
        self.gameView = GameView.init(frame: CGRect.init(x: rect.origin.x + MARGIN, y: rect.origin.y + MARGIN * 2 + ToolBarHeight, width: rect.size.width - MARGIN * 2, height: rect.size.height))
        self.gameView.delegate = self
        //添加绘制游戏状态的自定义view
        self.view.addSubview(self.gameView!)
        
        
        self.gameView.startGame()
        
        self.addControlButton()
        
        self.addMusic()
    }
    
    func updateSpeed(speed:Int){
        self.speed.text = "\(speed)"
    }
    
    func updateScore(score:Int) {
        self.scoreShow.text = "\(score)"
    }
    
    //添加工具条
    func addToolBar() {
        
        let toolBar : UIToolbar = UIToolbar.init(frame: CGRect(x:0, y:MARGIN*2,width:screenWidth,height:ToolBarHeight))
        self.view.addSubview(toolBar)
        //创建 速度 标签
        let speedLabel : UILabel = UILabel.init(frame: CGRect(x:0, y:0, width:50, height: ToolBarHeight))
        speedLabel.text = "速度"
        let speedItem : UIBarButtonItem = UIBarButtonItem.init(customView: speedLabel)
        
        //创建 速度值 标签
        speed = UILabel.init(frame: CGRect(x:0, y:0, width:20, height:ToolBarHeight))
        speed.textColor = UIColor.red
        let speedShowItem = UIBarButtonItem.init(customView: speed)
        
        //创建 当前积分 标签
        let scoreLabel : UILabel = UILabel.init(frame: CGRect(x:0,y:0,width:90,height:ToolBarHeight))
        scoreLabel.text = "当前积分"
        let scoreItem = UIBarButtonItem.init(customView: scoreLabel)
        
        //创建显示 积分值 标签
        scoreShow = UILabel.init(frame: CGRect(x:0,y:0,width:40,height:ToolBarHeight))
        scoreShow.textColor = UIColor.red
        let scoreShowItem : UIBarButtonItem = UIBarButtonItem.init(customView: scoreShow)
        
        let flexItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //为工具条设置工具项
        toolBar.items = [speedItem, speedShowItem,flexItem,scoreItem,scoreShowItem]
        
    }
    
    func left(sender:AnyObject) {
        gameView?.moveLeft()
    }
    func down(sender:AnyObject) {
        gameView?.fallDown()
    }
    func right(sender:AnyObject) {
        gameView?.moveRight()
    }
    func up(sender:AnyObject) {
        gameView?.changeStatus()
    }

    
    //添加控制按钮
    func addControlButton() {
        //定义4个按钮的x坐标
        let xArray : Array = [screenWidth - BUTTON_SIZE * 3 - MARGIN,
                              screenWidth - BUTTON_SIZE * 2 - MARGIN,
                              screenWidth - BUTTON_SIZE * 1 - MARGIN,
                              screenWidth - BUTTON_SIZE * 2 - MARGIN]
        //定义4个按钮的y坐标
        let yArray : Array = [screenHeight - BUTTON_SIZE - MARGIN,
                              screenHeight - BUTTON_SIZE - MARGIN,
                              screenHeight - BUTTON_SIZE - MARGIN,
                              screenHeight - BUTTON_SIZE * 2 - MARGIN]
        //定义4个按钮的图片
        let imageNames : Array = ["left","down","right","up"]
        let selectors : [Selector] = [#selector(left(sender:)),#selector(down(sender:)),#selector(right(sender:)),#selector(up(sender:))]
        
        //添加4个按钮
    
        for i:Int in 0 ..< xArray.count
        {
            //创建按钮
            let btn = UIButton.init(type: UIButtonType.custom)
            btn.frame = CGRect(x:xArray[i],y:yArray[i],width:BUTTON_SIZE,height:BUTTON_SIZE)
            btn.alpha = BUTTON_ALPHA
            btn.setImage(UIImage.init(named: imageNames[i]), for: UIControlState.normal)
            btn.setImage(UIImage.init(named: imageNames[i]), for: UIControlState.highlighted)
            btn.addTarget(self, action:selectors[i], for: UIControlEvents.touchUpInside)
            self.view.addSubview(btn)
        }
    }
    
    
    //添加音效
    func addMusic() {
        let bgMusicURL : URL = Bundle.main.url(forResource: "five Hundred miles", withExtension: "mp3")!
        bgMusicPlayer = try! AVAudioPlayer.init(contentsOf: bgMusicURL)
        bgMusicPlayer.numberOfLoops = -1
        bgMusicPlayer.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

