//
//  GameView.swift
//  RussianDiamond
//
//  Created by poplar on 2017/7/3.
//  Copyright © 2017年 poplar. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol GameViewDelegate {
    func updateScore(score:Int)
    func updateSpeed(speed:Int)
}

class GameView: UIView {
    
    var cellSize : Int?
    let tetrisRows = 22
    let tetrisCol = 15
    //绘制网格的笔触的粗细
    let strokeWidth : Double = 1
    let baseSpeed : Double = 0.6
    
    var image : UIImage!
    var disPlayer : AVAudioPlayer!
    
    var speed = 1
    var score : Int = 0
    var time : Timer!
    
    var delegate : GameViewDelegate!
    //获取 Quart2D的绘图对象
    var ctx : CGContext!
    
    //建一个数组 存储颜色
    let colors = [UIColor.brown.cgColor,
                  UIColor.red.cgColor,
                  UIColor.gray.cgColor,
                  UIColor.green.cgColor,
                  UIColor.blue.cgColor,
                  UIColor.yellow.cgColor,
                  UIColor.magenta.cgColor,
                  UIColor.purple.cgColor
    ]
    //定义集中可能出现的方块的组合
    var blockArr = [[Block]]()
    
    //建一个二维数组 记录俄罗斯方块的状态
    var tetris_status = [[Int32]]()
    
    var currentFall = [Block]()
    
    func initFallBlock() {
        //生成随机数
        let rand = Int(arc4random()) % blockArr.count
        print("rand === \(rand)");
        currentFall = blockArr[rand]
        for i:Int in 0..<currentFall.count {
            let cur = currentFall[i]
            ctx.setFillColor(colors[cur.color])
            ctx.fill(CGRect.init(x: Double(cur.x * cellSize!)+strokeWidth, y: Double(cur.y*cellSize!) + strokeWidth, width: Double(cellSize!) - strokeWidth * 2, height: Double(cellSize!) - strokeWidth * 2))
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        self.setNeedsDisplay()
    }
    
    //初始化游戏状态
    func initTetrisStatus() {
        let tmpRow = Array.init(repeating: Int32(0), count: tetrisCol)
        tetris_status = Array.init(repeating: tmpRow, count: tetrisRows)
        
        self.blockArr = [
            //组合 Z
            [Block(x:tetrisCol/2 - 1,y:0,color:1),
             Block(x:tetrisCol/2,y:0,color:1),
             Block(x:tetrisCol/2,y:1,color:1),
             Block(x:tetrisCol/2+1,y:1,color:1)],
            //组合 反Z
            [Block(x:tetrisCol/2 + 1,y:0,color:2),
             Block(x:tetrisCol/2,y:0,color:2),
             Block(x:tetrisCol/2,y:1,color:2),
             Block(x:tetrisCol/2 - 1,y:1,color:2)
            ],
            //组合 田
            [Block(x:tetrisCol/2 - 1,y:0,color:3),
             Block(x:tetrisCol/2,y:0,color:3),
             Block(x:tetrisCol/2 - 1,y:1,color:3),
             Block(x:tetrisCol/2,y:1,color:3)
            ],
            //组合 L
            [Block(x:tetrisCol/2 - 1,y:0,color:4),
             Block(x:tetrisCol/2 - 1,y:1,color:4),
             Block(x:tetrisCol/2 - 1,y:2,color:4),
             Block(x:tetrisCol/2,y:2,color:4),
             ],
            //组合 J
            [Block(x:tetrisCol/2,y:0,color:5),
             Block(x:tetrisCol/2,y:1,color:5),
             Block(x:tetrisCol/2,y:2,color:5),
             Block(x:tetrisCol/2 - 1,y:2,color:5),
             ],
            //组合 I
            [Block(x:tetrisCol/2,y:0,color:6),
             Block(x:tetrisCol/2,y:1,color:6),
             Block(x:tetrisCol/2,y:2,color:6),
             Block(x:tetrisCol/2,y:3,color:6),
             ],
            //组合 倒T
            [Block(x:tetrisCol/2 - 1,y:0,color:7),
             Block(x:tetrisCol/2,y:0,color:7),
             Block(x:tetrisCol/2 + 1,y:0,color:7),
             Block(x:tetrisCol/2,y:1,color:7),
             ]
        ]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //计算俄罗斯方块的大小
        self.cellSize = Int(frame.size.width) / self.tetrisCol
        
        //获取消除方块的音频文件的url
        let dismissMusicURL : URL = Bundle.main.url(forResource: "dis", withExtension: "wav")!
        //创建播放器
        self.disPlayer = try! AVAudioPlayer.init(contentsOf: dismissMusicURL)
        self.disPlayer.numberOfLoops = 0;
        
        //开启内存中的绘图
        UIGraphicsBeginImageContext(self.bounds.size)
        
        self.ctx = UIGraphicsGetCurrentContext()!
        
//        let bgImage : UIImage = UIImage.init(named: "test")!
//        bgImage.draw(in: self.bounds)
        
        //填充背景色
        self.ctx.setFillColor(UIColor.clear.cgColor)
        self.ctx.fill(self.bounds)
        
        //绘制俄罗斯方块的网格
        createCells(self.ctx,tetrisRows,tetrisCol,cellSize!, cellSize!);
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        
    }
    
    func startGame() {
        //将当前速度设置为1
        self.speed = 1
        self.delegate.updateSpeed(speed: self.speed)
        //将积分设置为0
        self.score = 0
        self.delegate.updateScore(score: self.score)
        //初始化数据
        initTetrisStatus()
        //初始化向下掉的方块
        initFallBlock()
        //控制每隔固定时间执行一次下落 tetris_status baseSpeed/Double(speed)
        time = Timer.scheduledTimer(withTimeInterval:baseSpeed/Double(speed) , repeats: true, block: { (Void) in
            self.fallDown()
        })

    }
    
    //控制方块向下掉
    func fallDown() {
        
        //定义是否向下掉的旗标
        var canDown = true
        //判断每个方块看是否能向下掉落
        for i:Int in 0..<currentFall.count {
            //判断是否到了最底下
            if currentFall[i].y >= tetrisRows - 1{
                canDown = false
                break
            }
            //判断下一格是否“有方块”,如果有方块，不能掉落
            if tetris_status[currentFall[i].y + 1][currentFall[i].x] != 0 {
                canDown = false
                break
            }
        }
        
        if canDown{
            
            self.drawBlock()

//            将下移前的每个方块涂成白色
            self.clear(min: 0,max: currentFall.count, arr: currentFall)
            //遍历方块 使方块的y+1
            for i:Int in 0..<currentFall.count {
                currentFall[i].y += 1
            }
            
            //将下移后的方块涂上颜色
            self.draw()

        }else{
            //不能向下掉落
            //设置填充颜色
            for i:Int in 0..<currentFall.count {
                let cur = currentFall[i]
                //如果方块已经到最上面 表示输了
                if cur.y < 2{
                    
                    //清除计时器
                    time.invalidate()
                    //显示提示框
                    let alert = UIAlertController.init(title: "end", message: "restart?", preferredStyle: .alert)
                    //为提示框设置按钮
                    let actionExit = UIAlertAction.init(title: "No", style: .cancel, handler: { (Void) in
                    })
                    alert.addAction(actionExit)
                    
                    let actionRestart = UIAlertAction.init(title: "Yes", style: .default, handler: { (action)->Void in
                        self.startGame()
                    })
                    alert.addAction(actionRestart)
                    
                    //获取控件所在的控制器
                    let nextResponder = self.superview?.next as! UIViewController
                    nextResponder.present(alert, animated: true, completion: {
                        
                    })
                    
                }
                //把每个方块当前所在的位置赋值为当前色块的颜色值
                tetris_status[cur.y][cur.x] = Int32(cur.color)
            }
            //判断是否有可“消除的行”
            lineFull()
            self.drawBlock()

            //开始一组新的方块
            initFallBlock()
        }
        //获取缓冲区的图片
        image = UIGraphicsGetImageFromCurrentImageContext()
        //通知该组件重绘
        self.setNeedsDisplay()
    }
    
    func lineFull() {
        
        //一次遍历每一行
        for i:Int in 0..<tetrisRows {
            var flag = true
            //遍历当前行的每个单元格
            for j:Int in 0..<tetrisCol {
                if tetris_status[i][j] == 0{
                    
                    flag = false
                    break
                }
            }
            //当前行全部有了方块
            if flag{
                
                //将当前积分增加10
                score += 10
                self.delegate.updateScore(score: score)
                //如果当前分值达到最大 则速度增加1
                if score >= speed * speed * 500 {
                    speed += 1
                    self.delegate.updateSpeed(speed: speed)
                    //让原有的计时器失效 重新开启新的计时器
                    time.invalidate()
                    time = Timer.scheduledTimer(withTimeInterval: baseSpeed/Double(speed), repeats: true, block: { (Void) in
                        self.fallDown()
                    })
                }
                //把当前行的所有方块下移
                for j in (1...i).reversed() {
                    for k:Int in 0..<tetrisCol {
                        tetris_status[j][k] = tetris_status[j-1][k]
                    }
                }
                //播放消除方块的音乐
                if  !disPlayer.isPlaying{
                    disPlayer.play()
                }
            }
            
        }
        
    }
    
    func moveLeft() {
        //定义是否能左移的flag
        var canLeft = true
        for i:Int in 0..<currentFall.count {
            //如果已经到了最左边 不能移动
            if currentFall[i].x <= 0 {
                canLeft = false
                break
            }
            //如果左边有方块 不能移动
            if tetris_status[currentFall[i].y][currentFall[i].x - 1] != 0 {
                canLeft = false
                break
            }
        }
        
        //如果能左移
        if canLeft {
            self.drawBlock()
            //将左移前的每个方块的背景涂成白色
            self.clear(min: 0,max: currentFall.count, arr: currentFall)
            //左移正在掉落的方块
            for i : Int in 0..<currentFall.count {
                currentFall[i].x -= 1
            }
            //将左移后的方块的背景色涂成方块对应的颜色
            self.draw()
            //获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            //通知该组件重绘
            self.setNeedsDisplay()
        }
        
    }
    func moveRight() {
        
        //定义是否能左移的flag
        var canRight = true
        for i:Int in 0..<currentFall.count {
            //如果已经到了最右边 不能移动
            if currentFall[i].x >= tetrisCol - 1 {
                canRight = false
                break
            }
            //如果右边边有方块 不能移动
            if tetris_status[currentFall[i].y][currentFall[i].x + 1] != 0 {
                canRight = false
                break
            }
        }
        
        if canRight{
            self.drawBlock()
            //将左移前的每个方块的背景涂成白色
            self.clear(min: 0,max: currentFall.count, arr: currentFall)            //左移正在掉落的方块
            for i : Int in 0..<currentFall.count {
                currentFall[i].x += 1
            }
            //将左移后的方块的背景色涂成方块对应的颜色
            self.draw()
            //获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            //通知该组件重绘
            self.setNeedsDisplay()
        }
    }
    //旋转
    func changeStatus() {
        var canChange = true
        for i:Int in 0..<currentFall.count {
            let preX = currentFall[i].x
            let preY = currentFall[i].y
            //始终以第三个方块作为旋转的中心
            //i == 2时，说明是旋转的中心
            if i != 2{
                
                //计算方块旋转之后的坐标
                let afterX = currentFall[2].x + preY - currentFall[2].y
                let afterY = currentFall[2].y + currentFall[2].x - preX
                //如果旋转后的 x , y坐标越界，或者旋转后的位置已经有了方块，不能旋转
                if  afterY < 0 ||
                    afterX < 0 ||
                    afterX > tetrisCol - 1 ||
                    afterY > tetrisRows - 1 ||
                    tetris_status[afterY][afterX] != 0{
                    canChange = false
                    break
                }
                
            }
            
        }
        
        if canChange{
            
            //将旋转钱的方块的背景色设成白色
            self.clear(min: 0,max: currentFall.count, arr: currentFall)
            //旋转
            for i:Int in 0..<currentFall.count {
                let preX = currentFall[i].x
                let preY = currentFall[i].y
                //计算方块旋转之后的坐标
                if i != 2 {
                    let afterX = currentFall[2].x + preY - currentFall[2].y
                    let afterY = currentFall[2].y + currentFall[2].x - preX
                    currentFall[i].x = afterX
                    currentFall[i].y = afterY
                }
                
            }
            
            //将旋转后的结果涂成对应颜色
            self.draw()
            //获取缓冲区图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            //重绘
            self.setNeedsDisplay()
            
        }
        
    }
    
    func drawBlock() {
        for i:Int in 0..<tetrisRows {
            for j:Int in 0..<tetrisCol {
                //有方块的地方绘制颜色
                if tetris_status[i][j] != 0{
                    
                    //设置填充色
                    ctx.setFillColor(colors[Int(tetris_status[i][j])])
                    //绘制矩形
                    ctx.fill(CGRect.init(x: Double(j*cellSize!)+strokeWidth, y: Double(i*cellSize!) + strokeWidth, width: Double(cellSize!)-strokeWidth * 2, height: Double(cellSize!) - strokeWidth * 2))
                }
                else{
                    
                    ctx.clear(CGRect.init(x: Double(j*cellSize!)+strokeWidth, y: Double(i*cellSize!) + strokeWidth, width: Double(cellSize!)-strokeWidth * 2, height: Double(cellSize!) - strokeWidth * 2))

                }
                
            }
        }
        //获取缓冲区的图片
        image = UIGraphicsGetImageFromCurrentImageContext()
        //通知该组件重绘
        self.setNeedsDisplay()
        
    }
    
    
    func createCells(_ ctx:CGContext, _ rows:Int,_ cols:Int,_ width:Int,_ height:Int) {
        //创建路径
        ctx.beginPath()
        //绘制横向网格对应的路径
        for i:Int in 0...rows {
            ctx.move(to: CGPoint(x:0,y:CGFloat(i*cellSize!)))
            ctx.addLine(to: CGPoint.init(x: cols * cellSize!, y: cellSize! * i))
        }
        
        //绘制竖线
        for i : Int in 0...cols {
            ctx.move(to: CGPoint.init(x: i*cellSize!, y: 0))
            ctx.addLine(to: CGPoint.init(x: i*cellSize!, y: rows * cellSize!))
        }
        
        ctx.closePath()
        //设置笔触颜色
        ctx.setStrokeColor(UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6).cgColor)
        ctx.setLineWidth(CGFloat(strokeWidth))
        ctx.strokePath()
    }
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.clear
        super.draw(rect)
        //将内存中的image图片绘制在该组件的左上角
        image.draw(at: CGPoint.init(x: 0, y: 0))
        
        self.layoutIfNeeded()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clear(min:Int,max:Int,arr:[Block]) {
        for i:Int in min..<max {
            let cur = arr[i]
            ctx.clear(CGRect.init(x: Double(cur.x * cellSize!) + strokeWidth, y: Double(cur.y * cellSize!) + strokeWidth, width: Double(cellSize!) - strokeWidth * 2, height: Double(cellSize!) - strokeWidth * 2))
        }

    }
    
    func draw() {
        for i:Int in 0..<currentFall.count {
            let cur = currentFall[i]
            ctx.setFillColor(colors[cur.color])
            ctx.fill(CGRect.init(x: Double(cur.x*cellSize!)+strokeWidth, y: Double(cur.y*cellSize!)+strokeWidth, width: Double(cellSize!) - strokeWidth * 2, height: Double(cellSize!) - strokeWidth * 2))
        }

    }
    
}
