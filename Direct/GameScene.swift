//
//  GameScene.swift
//  Direct
//
//  Created by Arjon Das on 6/24/17.
//  Copyright © 2017 Arjon Das. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init (
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension SKSpriteNode {
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    var lastGeneratedBlockPosition : CGPoint!
    var lastGeneratedBlock : String!
    var lastBouncPosition : CGPoint!
    var generateTimer : Timer!
    var cameraNode = SKCameraNode()
    var ballNode = SKSpriteNode()
    var moveDuration : TimeInterval!
    var moveDistance : CGFloat!
    var minMoveDuration : TimeInterval!
    var diffChangeScore : Int!
    var orientation : String!
    var baseColor = UIColor()
    var scoreLabel = SKLabelNode()
    var playLabel = SKLabelNode()
    var consicutiveBlocks : Int = 0
    var destroyer = SKSpriteNode()
    var numberOfMaxNode : Int = 0
    var corner : CGFloat = 0
    var length : CGFloat = 0
    var maxConsecutiveBlock : Int = 0
    var performanceFactor : CGFloat = 1.5
    var coinScore : Int = 0
    var coinMultiplier : Int = 1
    var highScore : Int = 0
    var globalFont : String = "AvenirNext-Regular"
    var progress1 : CGFloat = 0
    var level : Int = 1
    var currentLevelScore : Int = 0
    var maxLvlReached : Bool = false
    var numberOfNodes : Int = 0
    let animationDuration : Float = 2
    let levelCap : Int = 20
    let directDefaults = UserDefaults.standard
    var adControl : GameViewController!
    var chance : Bool = true
    var audioPlayer = AVAudioPlayer()
    var secBeforDest : Int = 5
    var previousSec : Int = 0
    var state : UIApplicationState!
    var gradient : [[Int]] = [[0x330867,0x30cfd0],[0xfed6e3,0xa8edea],[0xfef9d7,0xd299c2],[0x9890e3,0xb1f4cf],[0xace0f9,0xfff1eb],[0x13547a,0x80d0c7],[0xf5576c,0xf093fb],[0xfddb92,0xd1fdff],[0x72afd3,0x37ecba],[0x6f86d6,0x48c6ef],/*10*/[0x50a7c2,0xb7f8db],[0xff7eb3,0xff758c],[0x09203f,0x537895],[0xfaaca8,0xddd6f3],[0xc71d6f,0xd09693],[0x68e0cf,0x209cff],[0x4e4376,0x2b5876],[0x2a5298,0x1e3c72],[0x8ddad5,0x00cdac],[0x5d4157,0xa8caba],/*20*/[0x92fe9d,0x00c9ff],[0x8fd3f4,0x84fab0],[0xfbc2eb,0xa18cd1],[0xffd1ff,0xfad0c4],[0xfad0c4,0xff9a9e],[0x2580b3,0xcbbacc],[0xd7fffe,0xfffeff],[0xff719a,0xffa99f,0xffe29f],[0xec77ab,0x7873f5],[0x473b7b,0x3584a7,0x30d2be],/*30*/[0xff0066,0xd41872,0xa445b2],[0xc9ffbf,0xd5dee7,0xffafbd],[0xff0844,0xffb199],[0xf43b47,0x453a94],[0xeea2a2,0xbbc1bf,0x57c6e1,0xb49fda,0x7ac5d8]]
    var baseColorChoice : [[UIColor]] = [[UIColor.white],[UIColor.darkGray,UIColor.black,UIColor.purple],[UIColor.white,UIColor.black,UIColor.purple],[UIColor.white,UIColor.purple,UIColor.blue],[UIColor.darkGray,UIColor.purple],[UIColor(red: 175, green: 238, blue: 238),UIColor.black,UIColor.white],[UIColor.darkGray,UIColor.white,UIColor.black],[UIColor.black,UIColor.purple,UIColor(red: 255, green: 30, blue: 130)],[UIColor.white,UIColor.darkGray,UIColor.purple],[UIColor.white,UIColor.purple,UIColor(red: 0, green: 0, blue: 128)]/*10*/,[UIColor.purple,UIColor.white,UIColor.darkGray],[UIColor.purple,UIColor.white,UIColor.black],[UIColor.white,UIColor(red: 175, green: 238, blue: 238)],[UIColor.darkGray,UIColor.black,UIColor.purple,UIColor.white,UIColor(red: 255, green: 30, blue: 130)],[UIColor.purple,UIColor.white,UIColor.darkGray],[UIColor.white,UIColor.black,UIColor.darkGray,UIColor(red: 0, green: 0, blue: 128)],[UIColor.white],[UIColor.white,UIColor(red: 175, green: 238, blue: 238)],[UIColor.purple,UIColor.white,UIColor.darkGray,UIColor(red: 0, green: 0, blue: 128)],[UIColor.white]/*20*/,[UIColor(red: 240, green: 255, blue: 240),UIColor.purple,UIColor(red: 0, green: 0, blue: 128),UIColor.black,UIColor.darkGray],[UIColor.white,UIColor.purple,UIColor.black,UIColor.darkGray],[UIColor.white,UIColor.purple,UIColor.darkGray,UIColor.black,UIColor(red: 175, green: 238, blue: 238)],[UIColor.darkGray,UIColor.purple,UIColor.black],[UIColor.darkGray,UIColor.purple],[UIColor.purple,UIColor.white],[UIColor.purple,UIColor.darkGray,UIColor(red: 0, green: 0, blue: 128),UIColor(red: 255, green: 30, blue: 130)],[UIColor(red: 0, green: 0, blue: 128),UIColor.darkGray,UIColor.white,UIColor.purple],[UIColor.darkGray,UIColor.purple,UIColor.white,UIColor(red: 175, green: 238, blue: 238)],[UIColor.white,UIColor.black]/*30*/,[UIColor.purple,UIColor.white,UIColor.black],[UIColor.darkGray,UIColor.purple],[UIColor.purple,UIColor.darkGray,UIColor.white],[UIColor.white,UIColor.black],[UIColor.white,UIColor.purple]]
    var backgroundNode = SKSpriteNode()
    var ballRadius : CGFloat = 17.5
    
    override func didMove(to view: SKView) {
        let app = UIApplication.shared
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        adControl = self.view?.window?.rootViewController as! GameViewController
        adControl.gamesceneEssentials = self
        if directDefaults.value(forKey: "highscore") == nil {
            directDefaults.set(0, forKey: "highscore")        // key : "highscore" for accessing highscore
            directDefaults.set(1, forKey: "level")            // key : "level" for accessing player experience level
            directDefaults.set(0, forKey: "levelscore")       // key: "levelscore" for accessing current level status
            highScore = 0
            currentLevelScore = 0
            directDefaults.set(true, forKey: "sound")
            directDefaults.set(true, forKey: "resurrect")
            directDefaults.set(false, forKey: "maxLvlReached")
        } else {
            highScore = directDefaults.value(forKey: "highscore") as! Int
            level = directDefaults.value(forKey: "level") as! Int
            currentLevelScore = directDefaults.value(forKey: "levelscore") as! Int
            maxLvlReached = directDefaults.value(forKey: "maxLvlReached") as! Bool
        }
        coinScore = 0
        corner = 10                                         // angle corner radius
        length = 180                                        // angle length
        numberOfMaxNode = 150
        maxConsecutiveBlock = 3
        physicsWorld.contactDelegate = self
        self.camera = cameraNode
        addChild(cameraNode)
        moveDuration = 55                                   // initial difficulty
        minMoveDuration = 50
        diffChangeScore = 30                                // difficulty change with score
        moveDistance = 20000
        cameraNode.position = CGPoint(x: 0, y: 0)
        cameraNode.setScale(scaleUniversal())
        lastGeneratedBlockPosition = CGPoint(x: 0, y: 0)
        lastGeneratedBlock = ""
        
        let texture = backgroundTexture(first: true)
        backgroundNode = SKSpriteNode(texture:texture)
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundNode.zPosition = -10.0
        cameraNode.addChild(backgroundNode)
        changeColor()
        
        if arc4random_uniform(2) == 0 {
            orientation = "horizon+"
        } else {
            orientation = "horizon-"
        }
        generateVerticalWall()
        ballNode = generateBall()                           // Global Ball Node
        addChild(ballNode)
        menuView(type: "play")
        destroyer = SKSpriteNode()
        destroyer.name = "selfdestruct"
        destroyer.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 160, height: 10))
        destroyer.physicsBody?.categoryBitMask = 2
        destroyer.physicsBody?.contactTestBitMask = 1
        destroyer.physicsBody?.collisionBitMask = 0
        destroyer.physicsBody?.isDynamic = false
        destroyer.position.x = ballNode.position.x
        destroyer.position.y = ballNode.position.y - 100
        destroyer.run(SKAction.wait(forDuration: 15), completion: { [unowned self] in
            self.destroyer.removeFromParent()
        })
        destroyer.isPaused = true
        addChild(destroyer)
        generateVerticalWall()
        generateVerticalWall()
        generateVerticalWall()
        generateHorizontalWall()
        generateRandomWall()
        generateRandomWall()
        generateRandomWall()
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontSize = 25
        scoreLabel.fontName = globalFont
        scoreLabel.position = CGPoint(x: self.frame.size.width/2-10, y: self.frame.size.height/2-30)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.colorBlendFactor = 0.8
        scoreLabel.fontColor = baseColor
        scoreLabel.isHidden = true
        cameraNode.addChild(scoreLabel)
        initAudioPlayer(filename: "Direct2D.m4a")
        audioPlayer.pause()
        ballNode.run(SKAction.sequence([SKAction.wait(forDuration: 5),SKAction.run({ [unowned self] in
            self.destroyBall(node: self.ballNode)
        })]))
        
    }
    
    func randomGradient() -> [CGColor] {
        let randIndex = Int(arc4random_uniform(UInt32(gradient.count)))
        var colorPalate = [CGColor]()
        for i in gradient[randIndex] {
            let toCGColor = UIColor(rgb: i).cgColor
            colorPalate.append(toCGColor)
        }
        self.baseColor = randomBaseColor(index: randIndex)
        return colorPalate
    }
    
    func randomBaseColor(index: Int) -> UIColor {
        let colorSet : [UIColor] = baseColorChoice[index]
        let randColorIndex = arc4random_uniform(UInt32(colorSet.count))
        return colorSet[Int(randColorIndex)]
    }
    
    
    func backgroundTexture(first : Bool = false) -> SKTexture {
        let size = CGSize(width: (self.view?.frame.size.width)!*2 ,height: (self.view?.frame.size.height)!*2)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: size)
        if first {
            gradient.colors = [UIColor.white.cgColor,UIColor.black.cgColor]
            gradient.render(in: context!)
        }else {
            gradient.colors = randomGradient()
            gradient.render(in: context!)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let texture = SKTexture(image:image!)
        return texture
    }
    
    func generateBall(position: CGPoint = CGPoint(x: 0, y: 0),isFirstBall: Bool = true) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = "ball"
        ball.size = CGSize(width: 35, height: 35)
        ball.blendMode = SKBlendMode(rawValue: 0)!
        ball.colorBlendFactor = 1
        ball.color = baseColor
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        ball.physicsBody?.categoryBitMask = 1
        ball.physicsBody?.collisionBitMask = 0
        ball.physicsBody?.contactTestBitMask = 2
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.friction = 0
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.userData = NSMutableDictionary()
        ball.position = position
        ball.zPosition = -5
        if isFirstBall {
            if lastGeneratedBlock == "vertical" {
                ball.userData?.setValue("up", forKey: "direction")
                ball.run(SKAction.moveBy(x: 0, y: moveDistance, duration: moveDuration))
            } else if lastGeneratedBlock == "horizon" {
                if orientation == "horizon+" {
                    ball.userData?.setValue("side+", forKey: "direction")
                    ball.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))
                } else {
                    ball.userData?.setValue("side-", forKey: "direction")
                    ball.run(SKAction.moveBy(x: -1 * moveDistance, y: 0, duration: moveDuration))
                }
            }
        } else {
            var direction : String!
            let checkVertical = nodes(at: CGPoint(x: position.x, y: position.y + 160))
            let checkHorizonP = nodes(at: CGPoint(x: position.x + 160, y: position.y))
            let checkHorizonM = nodes(at: CGPoint(x: position.x - 160, y: position.y))
            for i in checkVertical {
                if i.name == "center" && i.userData?.value(forKey: "active") as! Bool {
                    direction = i.userData?.value(forKey: "orientation") as! String!
                    ball.userData?.setValue(direction, forKey: "direction")
                    ball.run(SKAction.moveBy(x: 0, y: moveDistance, duration: moveDuration))
                }
            }
            for i in checkHorizonP {
                if i.name == "center" && i.userData?.value(forKey: "active") as! Bool {
                    direction = i.userData?.value(forKey: "orientation") as! String
                    ball.userData?.setValue(direction, forKey: "direction")
                    ball.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))
                }
            }
            for i in checkHorizonM {
                if i.name == "center" && i.userData?.value(forKey: "active") as! Bool {
                    direction = i.userData?.value(forKey: "orientation") as! String
                    ball.userData?.setValue(direction, forKey: "direction")
                    ball.run(SKAction.moveBy(x: -1 * moveDistance, y: 0, duration: moveDuration))
                }
            }
        }
        ball.isPaused = true
        return ball
    }
    
    func generateRandomWall() {
        var counter = 0
        self.enumerateChildNodes(withName: "*", using: { [unowned self]                
            node,_ in
            if node.name == "wall" || node.name == "destruct" || node.name == "center" {
                counter += 1
                if self.ballNode.position.y - node.position.y > (self.frame.size.height)*self.performanceFactor {
                    node.removeFromParent()
                    counter -= 1
                }
            }
        })
        if arc4random_uniform(2) == 0 {
            self.generateVerticalWall()
        }else {
            self.generateHorizontalWall()
        }
        self.numberOfNodes = counter
        if counter <= numberOfMaxNode {
            if arc4random_uniform(2) == 0 {
                self.generateVerticalWall()
            }else {
                self.generateHorizontalWall()
            }
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    
    func generateHorizontalWall(){
        let positionX : CGFloat!
        if lastGeneratedBlock == "vertical" {
            if arc4random_uniform(2) == 0 {
                orientation = "horizon+"
            }else {
                orientation = "horizon-"
            }
        }
        if orientation == "horizon+" {
            positionX = lastGeneratedBlockPosition.x + 160
        }else {
            positionX = lastGeneratedBlockPosition.x - 160
        }
        
        let positionY : CGFloat!
        
        if lastGeneratedBlock == "vertical" {
            self.consicutiveBlocks = 1
            if self.orientation == "horizon+" {
                let destWall1 = SKSpriteNode()
                destWall1.name = "destruct"
                destWall1.position.x = lastGeneratedBlockPosition.x-80
                destWall1.position.y = lastGeneratedBlockPosition.y+160
                destWall1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 160))
                destWall1.physicsBody?.categoryBitMask = 2
                destWall1.physicsBody?.contactTestBitMask = 1
                destWall1.physicsBody?.collisionBitMask = 0
                destWall1.physicsBody?.isDynamic = false
                self.addChild(destWall1)
                let destWall2 = SKSpriteNode()
                destWall2.name = "destruct"
                destWall2.position.x = lastGeneratedBlockPosition.x
                destWall2.position.y = lastGeneratedBlockPosition.y+240
                destWall2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 160, height: 10))
                destWall2.physicsBody?.categoryBitMask = 2
                destWall2.physicsBody?.contactTestBitMask = 1
                destWall2.physicsBody?.collisionBitMask = 0
                destWall2.physicsBody?.isDynamic = false
                self.addChild(destWall2)
            }else {
                let destWall1 = SKSpriteNode()
                destWall1.name = "destruct"
                destWall1.position.x = lastGeneratedBlockPosition.x+80
                destWall1.position.y = lastGeneratedBlockPosition.y+160
                destWall1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 160))
                destWall1.physicsBody?.categoryBitMask = 2
                destWall1.physicsBody?.contactTestBitMask = 1
                destWall1.physicsBody?.collisionBitMask = 0
                destWall1.physicsBody?.isDynamic = false
                self.addChild(destWall1)
                let destWall2 = SKSpriteNode()
                destWall2.name = "destruct"
                destWall2.position.x = lastGeneratedBlockPosition.x
                destWall2.position.y = lastGeneratedBlockPosition.y+240
                destWall2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 160, height: 10))
                destWall2.physicsBody?.categoryBitMask = 2
                destWall2.physicsBody?.contactTestBitMask = 1
                destWall2.physicsBody?.collisionBitMask = 0
                destWall2.physicsBody?.isDynamic = false
                self.addChild(destWall2)
            }
            self.generateAngle(position: CGPoint(x: self.lastGeneratedBlockPosition.x, y: self.lastGeneratedBlockPosition.y+160))
            positionY = self.lastGeneratedBlockPosition.y + 160
            self.generateCenterizer(position: CGPoint(x: positionX, y: positionY) , orientation: orientation)
        }else {
            if self.consicutiveBlocks >= self.maxConsecutiveBlock {
                self.generateVerticalWall()
                return
            }
            self.consicutiveBlocks += 1
            positionY = self.lastGeneratedBlockPosition.y
        }
        let wall1 = SKSpriteNode(imageNamed: "wall")
        wall1.name = "wall"
        wall1.size = CGSize(width: length, height: 20)
        wall1.blendMode = SKBlendMode(rawValue: 0)!
        wall1.colorBlendFactor = 1
        wall1.color = baseColor
        wall1.position.x = positionX
        wall1.position.y = positionY - 80
        wall1.zPosition = -5
        let wall2 = SKSpriteNode(imageNamed: "wall")
        wall2.name = "wall"
        wall2.size = CGSize(width: length, height: 20)
        wall2.blendMode = SKBlendMode(rawValue: 0)!
        wall2.colorBlendFactor = 1
        wall2.color = baseColor
        wall2.position.x = positionX
        wall2.position.y = positionY + 80
        wall2.zPosition = -5
        self.addChild(wall1)
        self.addChild(wall2)
        if arc4random_uniform(3) != 0 {
            self.generatePoints()
        }
        self.lastGeneratedBlockPosition = CGPoint(x: positionX, y: positionY)
        self.lastGeneratedBlock = "horizon"
    }
    
    func generateVerticalWall(){
        let positionX : CGFloat!
        let positionY = lastGeneratedBlockPosition.y + 160
        if self.lastGeneratedBlock == "horizon" {
            self.consicutiveBlocks = 1
            if self.orientation == "horizon+" {
                self.generateAngle(position: CGPoint(x: self.lastGeneratedBlockPosition.x+160, y: self.lastGeneratedBlockPosition.y))
                positionX = self.lastGeneratedBlockPosition.x + 160
                self.generateCenterizer(position: CGPoint(x: positionX, y: positionY) , orientation: "vertical")
                let destWall1 = SKSpriteNode()
                destWall1.name = "destruct"
                destWall1.position.x = self.lastGeneratedBlockPosition.x+240
                destWall1.position.y = self.lastGeneratedBlockPosition.y
                destWall1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 160))
                destWall1.physicsBody?.categoryBitMask = 2
                destWall1.physicsBody?.contactTestBitMask = 1
                destWall1.physicsBody?.collisionBitMask = 0
                destWall1.physicsBody?.isDynamic = false
                self.addChild(destWall1)
                let destWall2 = SKSpriteNode()
                destWall2.name = "destruct"
                destWall2.position.x = lastGeneratedBlockPosition.x+160
                destWall2.position.y = lastGeneratedBlockPosition.y-80
                destWall2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 160, height: 10))
                destWall2.physicsBody?.categoryBitMask = 2
                destWall2.physicsBody?.contactTestBitMask = 1
                destWall2.physicsBody?.collisionBitMask = 0
                destWall2.physicsBody?.isDynamic = false
                self.addChild(destWall2)
            }else {
                self.generateAngle(position: CGPoint(x: self.lastGeneratedBlockPosition.x-160, y: self.lastGeneratedBlockPosition.y))
                positionX = self.lastGeneratedBlockPosition.x - 160
                self.generateCenterizer(position: CGPoint(x: positionX, y: positionY) , orientation: "vertical")
                let destWall1 = SKSpriteNode()
                destWall1.name = "destruct"
                destWall1.position.x = lastGeneratedBlockPosition.x-240
                destWall1.position.y = lastGeneratedBlockPosition.y
                destWall1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 160))
                destWall1.physicsBody?.categoryBitMask = 2
                destWall1.physicsBody?.contactTestBitMask = 1
                destWall1.physicsBody?.collisionBitMask = 0
                destWall1.physicsBody?.isDynamic = false
                self.addChild(destWall1)
                let destWall2 = SKSpriteNode()
                destWall2.name = "destruct"
                destWall2.position.x = lastGeneratedBlockPosition.x-160
                destWall2.position.y = lastGeneratedBlockPosition.y-80
                destWall2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 160, height: 10))
                destWall2.physicsBody?.categoryBitMask = 2
                destWall2.physicsBody?.contactTestBitMask = 1
                destWall2.physicsBody?.collisionBitMask = 0
                destWall2.physicsBody?.isDynamic = false
                self.addChild(destWall2)
            }
        }else {
            if self.consicutiveBlocks >= self.maxConsecutiveBlock {
                generateHorizontalWall()
                return
            }
            self.consicutiveBlocks += 1
            positionX = self.lastGeneratedBlockPosition.x
        }
        let wall1 = SKSpriteNode(imageNamed: "wall")
        wall1.name = "wall"
        wall1.size = CGSize(width: length, height: 20)
        wall1.blendMode = SKBlendMode(rawValue: 0)!
        wall1.colorBlendFactor = 1
        wall1.color = baseColor
        wall1.zRotation = CGFloat(Double.pi)/2
        wall1.position.x = positionX - 80
        wall1.position.y = positionY
        wall1.zPosition = -5
        let wall2 = SKSpriteNode(imageNamed: "wall")
        wall2.name = "wall"
        wall2.size = CGSize(width: length, height: 20)
        wall2.blendMode = SKBlendMode(rawValue: 0)!
        wall2.colorBlendFactor = 1
        wall2.color = baseColor
        wall2.zRotation = CGFloat(Double.pi)/2
        wall2.position.x = positionX + 80
        wall2.position.y = positionY
        wall2.zPosition = -5
        if arc4random_uniform(3) != 0 {
            self.generatePoints()
        }
        self.addChild(wall1)
        self.addChild(wall2)
        
        self.lastGeneratedBlockPosition = CGPoint(x: positionX, y: positionY)
        self.lastGeneratedBlock = "vertical"
    }
    
    func generateAngle(position: CGPoint){
        let angle = SKSpriteNode(imageNamed: "wall")
        angle.name = "angle"
        angle.size = CGSize(width: 150, height: 10)
        angle.blendMode = SKBlendMode(rawValue: 0)!
        angle.colorBlendFactor = 1
        angle.color = baseColor
        angle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 150, height: 10))
        angle.physicsBody?.categoryBitMask = 2
        angle.physicsBody?.contactTestBitMask = 1
        angle.physicsBody?.collisionBitMask = 0
        angle.physicsBody?.usesPreciseCollisionDetection = true
        angle.physicsBody?.isDynamic = false
        angle.position = position
        angle.zPosition = -5
        angle.userData = NSMutableDictionary()
        let randomAngle = arc4random_uniform(4)
        if randomAngle == 0 {
            angle.zRotation = 0
            angle.userData?.setValue(0, forKey: "degree")
        }else if randomAngle == 1 {
            angle.zRotation = CGFloat(Double.pi)/4
            angle.userData?.setValue(45, forKey: "degree")
        }else if randomAngle == 2 {
            angle.zRotation = CGFloat(Double.pi)/2
            angle.userData?.setValue(90, forKey: "degree")
        }else if randomAngle == 3 {
            angle.zRotation = CGFloat(Double.pi)*(3/4)
            angle.userData?.setValue(135, forKey: "degree")
        }else {
            angle.zRotation = 0
            angle.userData?.setValue(0, forKey: "degree")
        }
        self.addChild(angle)
    }
    
    func generateCenterizer(position: CGPoint,orientation: String) {
        let center = SKSpriteNode(imageNamed: "center")
        center.name = "center"
        center.size = CGSize(width: 120, height: 100)
        center.blendMode = SKBlendMode(rawValue: 0)!
        center.colorBlendFactor = 1
        center.color = baseColor
        center.alpha = 0.4
        center.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 100))
        center.physicsBody?.categoryBitMask = 2
        center.physicsBody?.contactTestBitMask = 1
        center.physicsBody?.collisionBitMask = 0
        center.physicsBody?.isDynamic = false
        center.userData = NSMutableDictionary()
        center.userData?.setValue(true, forKey: "active")
        center.position = position
        center.zPosition = -5
        let incline : CGFloat = 0
        if orientation == "vertical" {
            center.zRotation = CGFloat(Double.pi)/2
            center.userData?.setValue("up", forKey: "orientation")
            center.position.y += incline
        }else if orientation == "horizon+" {
            center.zRotation = 0
            center.position.x += incline
            center.userData?.setValue("side+", forKey: "orientation")
        }else {
            center.zRotation = CGFloat(Double.pi)
            center.position.x -= incline
            center.userData?.setValue("side-", forKey: "orientation")
        }
        self.addChild(center)
    }
    
    func bounce(ball: SKSpriteNode, angle: SKSpriteNode){
        self.lastBouncPosition = angle.position
        angle.physicsBody?.categoryBitMask = 4
        angle.physicsBody?.contactTestBitMask = 0
        var rotation = Int(GLKMathRadiansToDegrees(Float(angle.zRotation)))
        if rotation % 5 != 0 {
            if rotation < 0 {
                rotation = rotation - 1
            }else {
                rotation = rotation + 1
            }
        }
        if ball.userData?.value(forKey: "direction") as! String == "up" {
            let ballPosX = ball.position.x
            if rotation == 45{
                ball.removeAllActions()
                ball.position.x = ballPosX
                ball.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))
                ball.userData?.setValue("side+", forKey: "direction")
            }else if rotation == 135{
                ball.removeAllActions()
                ball.position.x = ballPosX
                ball.run(SKAction.moveBy(x: -1 * moveDistance, y: 0, duration: moveDuration))
                ball.userData?.setValue("side-", forKey: "direction")
            }else if rotation == 90{
                ball.removeAllActions()
                ball.position.x = ballPosX
                ball.run(SKAction.moveBy(x: 0, y: -1 * moveDistance, duration: moveDuration))
            }else if rotation == 0 {
                ball.removeAllActions()
                ball.position.x = ballPosX
                ball.run(SKAction.moveBy(x: 0, y: -1 * moveDistance, duration: moveDuration))
            }else if rotation == 180 {
                ball.removeAllActions()
                ball.position.x = ballPosX
                ball.run(SKAction.moveBy(x: 0, y: -1 * moveDistance, duration: moveDuration))
            }else if rotation == -180 {
                ball.removeAllActions()
                ball.position.x = ballPosX
                ball.run(SKAction.moveBy(x: 0, y: -1 * moveDistance, duration: moveDuration))
            }
        } else if ball.userData?.value(forKey: "direction") as! String == "side+" {
            let ballPosY = ball.position.y
            if rotation == 45 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: 0, y: moveDistance, duration: moveDuration))
                ball.userData?.setValue("up", forKey: "direction")
            } else if rotation == 135 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: 0, y: -1 * moveDistance, duration: moveDuration))
            } else if rotation == 90 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: -1 * moveDistance, y: 0, duration: moveDuration))
                ball.userData?.setValue("side-", forKey: "direction")
            } else if rotation == 0 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: -1 * moveDistance, y: 0, duration: moveDuration))
            } else if rotation == 180 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: -1 * moveDistance, y: 0, duration: moveDuration))
            } else if rotation == -180 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: -1 * moveDistance, y: 0, duration: moveDuration))
            }
        } else if ball.userData?.value(forKey: "direction") as! String == "side-" {
            let ballPosY = ball.position.y
            if rotation == 45 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: 0, y: -1 * moveDistance, duration: moveDuration))
            }else if rotation == 135 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: 0, y: moveDistance, duration: moveDuration))
                ball.userData?.setValue("up", forKey: "direction")
            }else if rotation == 90 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))
                ball.userData?.setValue("side+", forKey: "direction")
            }else if rotation == 0 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))
            }else if rotation == 180 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))
            }else if rotation == -180 {
                ball.removeAllActions()
                ball.position.x = ballPosY
                ball.run(SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration))
            }
        }
        ball.run(SKAction.sequence([SKAction.wait(forDuration: 3),SKAction.run({ [unowned self] in
            self.destroyBall(node: ball)
        })]))
    }
    
    func changeColor() {
        let texture = backgroundTexture()
        backgroundNode.texture = texture
        
        enumerateChildNodes(withName: "*", using: {
            node, stop in
            if node.name == "wall" || node.name == "angle" || node.name == "center" || node.name == "coin" {
                let frenzy = node as! SKSpriteNode
                //frenzy.run(SKAction.colorize(with: self.baseColor, colorBlendFactor: 1, duration: 0.3))
                frenzy.color = self.baseColor
            }
        })
        self.ballNode.color = self.baseColor
        //self.ballNode.run(SKAction.colorize(with: baseColor, colorBlendFactor: 1, duration: 0.5))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let nodeA = contact.bodyA.node as! SKSpriteNode
        let nodeB = contact.bodyB.node as! SKSpriteNode
        
        if nodeA.name == "ball" && nodeB.name == "angle" {
            self.bounce(ball: nodeA, angle: nodeB)
            nodeB.run(SKAction.scaleX(to: 0, duration: 0.2), completion: { [unowned self, weak edonB = nodeB] in
                edonB?.removeFromParent()
                self.generateRandomWall()
                self.changeColor()
            })
        }else if nodeA.name == "angle" && nodeB.name == "ball" {
            self.bounce(ball: nodeB, angle: nodeA)
            nodeA.run(SKAction.scaleX(to: 0, duration: 0.2), completion: { [unowned self, weak edonA = nodeA] in
                edonA?.removeFromParent()
                self.generateRandomWall()
                self.changeColor()
            })
        }
        
        if nodeA.name == "center" && nodeB.name == "ball" {
            nodeA.userData?.setValue(false, forKey: "active")
            if nodeB.userData?.value(forKey: "direction") as! String == "up" {
                nodeB.run(SKAction.moveTo(x: nodeA.position.x, duration: 0.3))
            }else if nodeB.userData?.value(forKey: "direction") as! String == "side+" || nodeB.userData?.value(forKey: "direction") as! String == "side-" {
                nodeB.run(SKAction.moveTo(y: nodeA.position.y, duration: 0.3))
            }
        }else if nodeB.name == "center" && nodeA.name == "ball" {
            nodeB.userData?.setValue(false, forKey: "active")
            if nodeA.userData?.value(forKey: "direction") as! String == "up" {
                nodeA.run(SKAction.moveTo(x: nodeB.position.x, duration: 0.3))
            }else if nodeA.userData?.value(forKey: "direction") as! String == "side+" || nodeA.userData?.value(forKey: "direction") as! String == "side-" {
                nodeA.run(SKAction.moveTo(y: nodeB.position.y, duration: 0.3))
            }
        }
        
        if nodeA.name == "ball" && nodeB.name == "destruct" {
            destroyBall(node: nodeA)
        }else if nodeB.name == "ball" && nodeA.name == "destruct" {
            destroyBall(node: nodeB)
        }
        
        if nodeA.name == "ball" && nodeB.name == "selfdestruct" {
            destroyBall(node: nodeA)
        }else if nodeA.name == "selfdestruct" && nodeB.name == "ball" {
            destroyBall(node: nodeB)
        }
        
        if nodeA.name == "ball" && nodeB.name == "coin" {
            nodeB.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.1),SKAction.scale(to: 0, duration: 0.2)]), completion: { [unowned self, weak edonB = nodeB, weak edonA = nodeA] in
                if !(edonA?.isPaused)!{
                    self.coinScore += 1*self.coinMultiplier
                    if self.coinScore != 0 && self.moveDuration > self.minMoveDuration {
                        if self.coinScore % self.diffChangeScore == 0 {
                            self.moveDuration = self.moveDuration - 1
                        }
                    }
                }
                edonB?.removeFromParent()
            })
        } else if nodeB.name == "ball" && nodeA.name == "coin" {
            nodeA.run(SKAction.sequence([SKAction.scale(to: 1.4, duration: 0.1),SKAction.scale(to: 0, duration: 0.2)]), completion: { [unowned self, weak edonB = nodeB, weak edonA = nodeA] in
                if !(edonB?.isPaused)!{
                    self.coinScore += 1*self.coinMultiplier
                    if self.coinScore != 0 && self.moveDuration > self.minMoveDuration {
                        if self.coinScore % self.diffChangeScore == 0 {
                            self.moveDuration = self.moveDuration - self.ballSpeed(score: self.coinScore)
                        }
                    }
                }
                edonA?.removeFromParent()
            })
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            for node in touchedNodes {
                if node.name == "explevel" {
                    let expInfo = SKShapeNode(rectOf: CGSize(width: 100, height: 25) , cornerRadius: 5)
                    expInfo.name = "expinfo"
                    expInfo.fillColor = UIColor.white
                    expInfo.strokeColor = UIColor.white
                    expInfo.position.x = node.position.x + 100
                    expInfo.position.y = node.position.y + 12
                    expInfo.isAntialiased = true
                    expInfo.glowWidth = 0
                    for i in touchedNodes {
                        if i.name == "menu" {
                            var allow = true
                            for j in i.children {
                                if j.name == "expinfo" {
                                    allow = false
                                    j.removeFromParent()
                                }
                            }
                            if allow {                                      // allow : if clicked experience stats are shown
                                i.addChild(expInfo)
                                let expshapeTriangle = SKShapeNode(rectOf: CGSize(width: 18, height: 18) , cornerRadius: 2)
                                expshapeTriangle.fillColor = UIColor.white
                                expshapeTriangle.zRotation = CGFloat(Double.pi/4)
                                expshapeTriangle.position.x = -47
                                expshapeTriangle.zPosition = 1
                                expshapeTriangle.isAntialiased = true
                                expInfo.addChild(expshapeTriangle)
                                let expStatLabel = SKLabelNode(fontNamed: "AvenirNext-MediumItalic")
                                expStatLabel.fontColor = UIColor.black
                                expStatLabel.text = "\(self.currentLevelScore)/\(self.levelScore(lvl: level)) xp"
                                expStatLabel.position.y = -5
                                expStatLabel.fontSize = 12
                                expStatLabel.zPosition = 2
                                expInfo.addChild(expStatLabel)
                            }
                        }
                    }
                    break
                }else if node.name == "sound" {
                    if directDefaults.value(forKey: "sound") as! Bool {
                        directDefaults.set(false, forKey: "sound")
                        for i in node.children {
                            if i.name == "soundCancellationBar" {
                                i.isHidden = false
                            }
                        }
                    }else {
                        directDefaults.set(true, forKey: "sound")
                        for i in node.children {
                            if i.name == "soundCancellationBar" {
                                i.isHidden = true
                            }
                        }
                    }
                    break
                }else if node.name == "resurrect" {
                    if directDefaults.value(forKey: "resurrect") as! Bool {
                        directDefaults.set(false, forKey: "resurrect")
                        for i in node.children {
                            if i.name == "resurrectCancellationBar" {
                                i.isHidden = false
                            }
                        }
                    }else {
                        directDefaults.set(true, forKey: "resurrect")
                        for i in node.children {
                            if i.name == "resurrectCancellationBar" {
                                i.isHidden = true
                            }
                        }
                    }
                    break
                }else if node.name == "expinfo" {
                    node.removeFromParent()
                    break
                }
                else if node.name == "menu" {
                    for layer in (self.view?.layer.sublayers)! {
                        if layer.name == "experience" || layer.name == "experience2" {
                            layer.removeFromSuperlayer()
                        }
                    }
                    
                    run(SKAction.wait(forDuration: 2), completion: { [unowned self] in
                        if self.adControl.showAd {
                            self.adControl.showBannerAd()
                        }
                    })

                    node.run(SKAction.sequence([SKAction.run { [weak edon = node] in
                        edon?.removeAllChildren()
                        },SKAction.fadeOut(withDuration: 0.3)]), completion: { [unowned self, weak edon = node] in
                        edon?.removeFromParent()
                        self.scoreLabel.isHidden = false
                        self.ballNode.isPaused = false
                        if self.directDefaults.value(forKey: "sound") as! Bool {
                            self.audioPlayer.play()
                        }else {
                            self.audioPlayer.pause()
                        }
                    })
                }else if node.name == "restart" {
                    if adControl.showAd {
                        adControl.hideBannerAd()
                        adControl.showInterstitialAd()
                    }
                    let scene = SKScene(fileNamed: "GameScene")
                    scene?.size = (self.view?.frame.size)!
                    scene?.scaleMode = .aspectFill
                    for layer in (self.view?.layer.sublayers)! {
                        if layer.name == "progresslayer" || layer.name == "progresslayer2" {
                            layer.removeFromSuperlayer()
                        }
                    }
                    view?.presentScene(scene)
                }else if node.name == "watchvideo" {
                    node.parent?.removeFromParent()
                    if adControl.showAd {
                        adControl.showRewardVideo()
                    }else {
                        failedLoadingRewardVideo()
                    }
                }else if node.name == "cancelvideo" {
                    node.parent?.removeFromParent()
                    self.manageScoreAndExit()
                }else if node.name == "failclose" {
                    node.parent?.removeFromParent()
                    self.manageScoreAndExit()
                }
            }
        }

        if !self.ballNode.isPaused {
            enumerateChildNodes(withName: "angle", using: { [unowned self]
                node,_ in
                var degree = node.userData?.value(forKey: "degree") as! Int
                degree = degree + 45
                node.userData?.setValue(degree, forKey: "degree")
                if degree == 180 {
                    node.zRotation = 0
                    degree = 0
                    node.userData?.setValue(degree, forKey: "degree")
                }
                self.isUserInteractionEnabled = false
                node.run(SKAction.rotate(byAngle:(CGFloat(Double.pi)/4), duration: 0), completion: { [unowned self] in
                    self.isUserInteractionEnabled = true
                })
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if directDefaults.value(forKey: "sound") as! Bool {
            if ballNode.isPaused {
                audioPlayer.pause()
            } else {
                audioPlayer.play()
            }
        }
        
        if maxConsecutiveBlock == 3 {
            performanceFactor = 1.5                 // 1.5
        }else {
            performanceFactor = 1.2                 // 1.2
        }
        if coinScore == -1 {
            scoreLabel.text = "0"
        }else {
            scoreLabel.text = "\(coinScore)"
        }
        scoreLabel.fontColor = baseColor
        cameraNode.position = ballNode.position
        
        if cameraNode.childNode(withName: "menu") != nil {
            ballNode.isPaused = true
            destroyer.isPaused = true
        }else {
            removeCircleSublayer(name: "experience")
            removeCircleSublayer(name: "experience2")
        }

        if numberOfNodes <= numberOfMaxNode {
            generateRandomWall()
        }
        
        if coinScore > 300 {
            maxConsecutiveBlock = 2
        }
    }
    
    func colorCombination() -> (UIColor, UIColor) {
        var color0 = UIColor()
        var color1 = UIColor()
        switch arc4random_uniform(11) {
        case 0:
            color0 = UIColor.black
            color1 = randomColor(reject: [0,1,2,4,9])
        case 1:
            color0 = UIColor.blue
            color1 = randomColor(reject: [0,1,2,4,7,9,11])
        case 2:
            color0 = UIColor.yellow
            color1 = randomColor(reject: [2,3,5,10])
        case 3:
            color0 = UIColor.cyan
            color1 = randomColor(reject: [2,3,5,6,10])
        case 4:
            color0 = UIColor.darkGray
            color1 = randomColor(reject: [0,1,4,9,11])
        case 5:
            color0 = UIColor.green
            color1 = randomColor(reject: [2,3,5,6,7,8,9,11])
        case 6:
            color0 = UIColor.orange
            color1 = randomColor(reject: [1,2,3,5,6,8,10,11])
        case 7:
            color0 = UIColor.red
            color1 = randomColor(reject: [1,3,5,7,8,9,11])
        case 8:
            color0 = UIColor.magenta
            color1 = randomColor(reject: [6,7,8,11])
        case 9:
            color0 = UIColor.purple
            color1 = randomColor(reject: [1,4,7,9,11])
        case 10:
            color0 = UIColor.white
            color1 = randomColor(reject: [2,3,10])
        default:
            color0 = randomColor(reject: [])
            color1 = randomColor(reject: [])
        }
        return (color0,color1)
    }
    
    
    func randomColor(reject: [Int]) -> UIColor {
        var loop = true
        var color : Int!
        while loop {
            var found = false
            color = Int(arc4random_uniform(12))
            if reject.count == 0 {
                break
            }
            for i in reject {
                if color == i {
                    found = true
                }
            }
            if found {
                loop = true
            }else {
                loop = false
            }
        }
        
        switch color {
        case 0:
            return UIColor.black
        case 1:
            return UIColor.blue
        case 2:
            return UIColor.yellow
        case 3:
            return UIColor.cyan
        case 4:
            return UIColor.darkGray
        case 5:
            return UIColor.green
        case 6:
            return UIColor.orange
        case 7:
            return UIColor.red
        case 8:
            return UIColor.magenta
        case 9:
            return UIColor.purple
        case 10:
            return UIColor.white
        case 11:
            return UIColor.brown
        default:
            return UIColor.black
        }
    }
    
    func destroyBall(node: SKSpriteNode){
        node.run(SKAction.scale(by: 3, duration: 0.5))
        node.run(SKAction.fadeOut(withDuration: 0.5), completion: { [unowned self, weak edon = node] in
            edon?.removeAllActions()
            edon?.removeFromParent()
            edon?.isPaused = true
            
            if self.directDefaults.value(forKey: "resurrect") as! Bool && self.chance {
                self.audioPlayer.pause()
                let resurrectMenu = SKShapeNode(rectOf: CGSize(width: 640, height: 500), cornerRadius: 20)
                resurrectMenu.position = self.cameraNode.position
                resurrectMenu.fillColor = UIColor.black
                resurrectMenu.strokeColor = UIColor.black
                resurrectMenu.alpha = 0.8
                resurrectMenu.isAntialiased = true
                self.addChild(resurrectMenu)
                let infoLabelNode = SKLabelNode(text: "Get an extra ball by watching")
                infoLabelNode.fontColor = UIColor.white
                infoLabelNode.fontName = "AvenirNext-Regular"
                infoLabelNode.position.y = 130
                infoLabelNode.fontSize = 40
                let infoLabelNode2 = SKLabelNode(text: "sponsored video")
                infoLabelNode2.fontName = "AvenirNext-Regular"
                infoLabelNode2.fontColor = UIColor.white
                infoLabelNode2.fontSize = 40
                infoLabelNode2.position.y = 80
                resurrectMenu.addChild(infoLabelNode)
                resurrectMenu.addChild(infoLabelNode2)
                let watchLabel = SKLabelNode(text: "Watch Video")
                watchLabel.name = "watchvideo"
                watchLabel.fontName = self.globalFont
                watchLabel.fontColor = UIColor.white
                watchLabel.position.y = -45
                watchLabel.fontSize = 50
                resurrectMenu.addChild(watchLabel)
                let cancelLabel = SKLabelNode(text: "Cancel")
                cancelLabel.name = "cancelvideo"
                cancelLabel.fontSize = 50
                cancelLabel.fontName = self.globalFont
                cancelLabel.fontColor = UIColor.white
                cancelLabel.position.y = -160
                resurrectMenu.addChild(cancelLabel)
            }else{
                self.manageScoreAndExit()
            }
        })
    }
    
    func menuView(type: String) {
        let baseColorM = UIColor.white
        let menuRect : CGSize!
        if scaleUniversal() == 2.0 {
            menuRect = CGSize(width: self.frame.size.width/2, height: self.frame.size.height/2)
        }else {
            menuRect = CGSize(width: (self.frame.size.width)-20, height: (self.frame.size.height)-20)
        }
        let menuShape = SKShapeNode(rectOf: menuRect, cornerRadius: 20)
        menuShape.fillColor = UIColor.black.withAlphaComponent(0.8)
        menuShape.strokeColor = UIColor.black.withAlphaComponent(0.8)
        menuShape.zPosition = 5
        scoreLabel.isHidden = true
        cameraNode.addChild(menuShape)
        if type == "play" {
            menuShape.name = "menu"
            let playLabel = SKLabelNode(text: "Tap to Start")
            playLabel.fontColor = baseColorM
            playLabel.fontName = globalFont
            playLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeAlpha(to: 0.6, duration: 1),SKAction.fadeAlpha(to: 1, duration: 1)])))
            playLabel.fontSize = 30
            menuShape.addChild(playLabel)
            let expLabelNo = SKLabelNode(text: "\(level)")
            expLabelNo.fontColor = baseColorM
            expLabelNo.fontName = globalFont
            expLabelNo.fontSize = 30
            expLabelNo.position = CGPoint(x: 0, y: 85)
            expLabelNo.horizontalAlignmentMode = .center
            menuShape.addChild(expLabelNo)
            let expButton = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 65, height: 65))
            expButton.name = "explevel"
            expButton.position = expLabelNo.position
            menuShape.addChild(expButton)
            if !maxLvlReached {
                experienceWithAnimationCircle(position: convert(CGPoint(x: 0,y: 100), from: menuShape), color: baseColorM, label: expLabelNo)
            }else {
                expCircle(position: convert(CGPoint(x: 0,y: 100), from: menuShape), color: baseColorM)
            }
            let expLabel = SKLabelNode(text: "lvl")
            expLabel.fontColor = baseColorM
            expLabel.fontName = globalFont
            expLabel.fontSize = 20
            expLabel.position = CGPoint(x: 0, y: 60)
            menuShape.addChild(expLabel)
            let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
            highScoreLabel.fontName = globalFont
            highScoreLabel.fontColor = baseColorM
            highScoreLabel.fontSize = 30
            highScoreLabel.position.y = -100
            menuShape.addChild(highScoreLabel)
            let musicLabel = SKLabelNode(text: "\u{266B}")
            musicLabel.name = "sound"
            musicLabel.fontName = globalFont
            musicLabel.fontSize = 30
            musicLabel.fontColor = baseColorM
            musicLabel.position.y = -(menuShape.frame.size.height/2 - 20)
            musicLabel.position.x = -menuShape.frame.size.width/4
            menuShape.addChild(musicLabel)
            let musicButton = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 50, height: 50))
            musicButton.name = "sound"
            musicButton.position.x = musicLabel.position.x
            musicButton.position.y = musicLabel.position.y + 10
            menuShape.addChild(musicButton)
            let cancellation1 = SKShapeNode(rectOf: CGSize(width: 40, height: 2) , cornerRadius: 1)
            cancellation1.fillColor = baseColorM
            cancellation1.name = "soundCancellationBar"
            cancellation1.strokeColor = baseColorM
            cancellation1.zRotation = CGFloat(Double.pi/4)
            if directDefaults.value(forKey: "sound") as! Bool {
                cancellation1.isHidden = true
            }else {
                cancellation1.isHidden = false
            }
            cancellation1.position.y = 2
            cancellation1.position.x = 2
            musicButton.addChild(cancellation1)
            let resurrentionLabel = SKLabelNode(text: "1UP")
            resurrentionLabel.fontColor = baseColorM
            resurrentionLabel.fontName = "AvenirNextCondensed-Regular"
            resurrentionLabel.fontSize = 30
            resurrentionLabel.position.y = -(menuShape.frame.size.height/2 - 20)
            resurrentionLabel.position.x = menuShape.frame.size.width/4
            menuShape.addChild(resurrentionLabel)
            let resurrectButton = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 50, height: 50))
            resurrectButton.name = "resurrect"
            resurrectButton.position.x = resurrentionLabel.position.x
            resurrectButton.position.y = resurrentionLabel.position.y + 10
            menuShape.addChild(resurrectButton)
            let cancellation2 = SKShapeNode(rectOf: CGSize(width: 40, height: 2) , cornerRadius: 1)
            cancellation2.fillColor = baseColorM
            cancellation2.name = "resurrectCancellationBar"
            cancellation2.strokeColor = baseColorM
            cancellation2.zRotation = CGFloat(Double.pi/4)
            cancellation2.zPosition = resurrentionLabel.zPosition + 1
            if directDefaults.value(forKey: "resurrect") as! Bool {
                cancellation2.isHidden = true
            }else {
                cancellation2.isHidden = false
            }
            cancellation2.position.y = 2
            cancellation2.position.x = -1
            resurrectButton.addChild(cancellation2)
        }else if type == "pause" {
            ballNode.isPaused = true
            destroyer.isPaused = true
            menuShape.removeAllChildren()
            let playLabel = SKLabelNode(text: "Resume")
            playLabel.name = "play"
            playLabel.fontColor = baseColorM
            playLabel.fontName = globalFont
            playLabel.position.y = 50
            playLabel.fontSize = 30
            menuShape.addChild(playLabel)
            let restartLabel = SKLabelNode(text: "Restart")
            restartLabel.fontName = globalFont
            restartLabel.fontColor = baseColorM
            restartLabel.position.y = -50
            restartLabel.fontSize = 30
            menuShape.addChild(restartLabel)
        }else if type == "gameova" {
            self.scoreLabel.isHidden = true
            self.audioPlayer.pause()
            menuShape.name = "gameover"
            let gameOvaLabel = SKLabelNode(text: "Game Over")
            var tempHigh : CGFloat = 0
            if highScore == 0 {
                tempHigh = 1
            }else {
                tempHigh = CGFloat(highScore)
            }
            let count = Int(CGFloat(coinScore)*100/tempHigh)
            var i = 0
            gameOvaLabel.fontName = globalFont
            gameOvaLabel.fontColor = baseColorM
            gameOvaLabel.fontSize = 30
            gameOvaLabel.position.y = 120
            menuShape.addChild(gameOvaLabel)
            let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
            highScoreLabel.fontName = globalFont
            highScoreLabel.fontColor = baseColorM
            highScoreLabel.fontSize = 30
            highScoreLabel.position.y = 60
            menuShape.addChild(highScoreLabel)
            let presentScoreLabel = SKLabelNode(text: "Score: \(coinScore)")
            presentScoreLabel.fontName = globalFont
            presentScoreLabel.fontSize = 30
            presentScoreLabel.position.y = 0
            presentScoreLabel.fontColor = baseColorM
            menuShape.addChild(presentScoreLabel)
            self.progressBar(position: convert(CGPoint(x: 0,y: -55), from: menuShape),color: baseColorM)
            let smallProgressLabel = SKLabelNode(text: "Score Progress: 0%")
            smallProgressLabel.name = "progress"
            smallProgressLabel.fontName = globalFont
            smallProgressLabel.fontColor = baseColorM
            smallProgressLabel.fontSize = 10
            smallProgressLabel.position.x = 0
            smallProgressLabel.position.y = -45
            smallProgressLabel.run(SKAction.repeat(SKAction.sequence([SKAction.run({ [weak label = smallProgressLabel] in
                i += 1
                label?.text = "Score Progress: \(i)%"
            }),SKAction.wait(forDuration: 0.03)]), count: count))
            menuShape.addChild(smallProgressLabel)
            let restartLabel = SKLabelNode(text: "Restart")
            restartLabel.fontName = globalFont
            restartLabel.fontColor = baseColorM
            restartLabel.position.y = -120
            restartLabel.fontSize = 30
            menuShape.addChild(restartLabel)
            let restartButton = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 200, height: 70))
            restartButton.name = "restart"
            restartButton.position = restartLabel.position
            menuShape.addChild(restartButton)
            
            let copyrightLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            copyrightLabel.fontSize = 15
            copyrightLabel.fontColor = UIColor.white
            copyrightLabel.text = "© ARJON DAS"
            copyrightLabel.position.y = -(menuShape.frame.size.height/2 - 10)
            menuShape.addChild(copyrightLabel)
        }
    }
    
    func scaleUniversal() -> CGFloat {
        var scale : CGFloat = 1
        switch UIScreen.main.bounds.size.height {
        case 736.0:
            scale = 2.2
        case 667.0:
            scale = 2.3
        case 568.0:
            scale = 2.5
        case 480.0:
            scale = 2.6
        default:
            scale = 2.0
        }
        return scale
    }
    
    func generatePoints() {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 40, height: 40)
        coin.name = "coin"
        coin.blendMode = SKBlendMode(rawValue: 0)!
        coin.colorBlendFactor = 1
        coin.color = baseColor
        coin.zPosition = -5
        coin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        coin.physicsBody?.categoryBitMask = 8
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.contactTestBitMask = 1
        coin.physicsBody?.isDynamic = false
        coin.position = lastGeneratedBlockPosition
        coin.alpha = 0.7
        addChild(coin)
    }
    
    func progressBar(position: CGPoint,color: UIColor) {
        let path = CGMutablePath()
        let pointA = convertPoint(toView: CGPoint(x: position.x-200, y: position.y))
        let pointB = convertPoint(toView: CGPoint(x: position.x+200, y: position.y))
        path.move(to: pointA)
        path.addLine(to: pointB)
        let progressLayer = CAShapeLayer()
        progressLayer.name = "progresslayer"
        progressLayer.path = path
        progressLayer.strokeColor = color.cgColor
        progressLayer.fillColor = color.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = kCALineCapRound
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        let percentage = CGFloat(coinScore)/CGFloat(highScore)
        animation.fromValue = 0.0
        let duration = 3.0 * percentage
        animation.duration = CFTimeInterval(duration)
        if highScore != 0 {
            animation.toValue = percentage
        }else {
            animation.toValue = 0
        }
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        progressLayer.zPosition = 2
        progressLayer.add(animation, forKey: "drawLineAnimation")
        self.view?.layer.addSublayer(progressLayer)
        let progressLayer2 = CAShapeLayer()
        progressLayer2.name = "progresslayer2"
        progressLayer2.path = path
        progressLayer2.strokeColor = color.withAlphaComponent(0.4).cgColor
        progressLayer2.fillColor = color.withAlphaComponent(0.4).cgColor
        progressLayer2.lineWidth = 10
        progressLayer2.lineCap = kCALineCapRound
        progressLayer2.zPosition = 1
        self.view?.layer.addSublayer(progressLayer2)
    }
    
    func expCircle(position: CGPoint,percentage: CGFloat=1,radius: CGFloat = 35, color: UIColor,createSecondLayer: Bool = true) {
        let arcCenter = convertPoint(toView: position)
        let path = CGMutablePath()
        path.addArc(center: arcCenter, radius: radius, startAngle: CGFloat(Double.pi*3/4), endAngle: CGFloat(Double.pi/4), clockwise: false)
        let realColor : UIColor!
        if ballNode.isPaused {
            realColor = color
        } else {
            realColor = UIColor.clear
        }
        let expShapeLayer = CAShapeLayer()
        expShapeLayer.name = "experience"
        expShapeLayer.path = path
        expShapeLayer.lineCap = kCALineCapRound
        expShapeLayer.strokeColor = realColor.cgColor
        expShapeLayer.fillColor = UIColor.clear.cgColor
        expShapeLayer.lineWidth = 3
        expShapeLayer.zPosition = 2
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.duration = CFTimeInterval(animationDuration)
        animation.toValue = percentage
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        expShapeLayer.add(animation, forKey: "drawLineAnimation")
        self.view?.layer.addSublayer(expShapeLayer)
        
        if createSecondLayer {
            let expShapeLayer2 = CAShapeLayer()
            expShapeLayer2.name = "experience2"
            expShapeLayer2.path = path
            expShapeLayer2.lineCap = kCALineCapRound
            expShapeLayer2.strokeColor = realColor.withAlphaComponent(0.35).cgColor
            expShapeLayer2.fillColor = UIColor.clear.cgColor
            expShapeLayer2.lineWidth = 3
            expShapeLayer2.zPosition = 1
            self.view?.layer.addSublayer(expShapeLayer2)
        }
    }
    
    func experienceWithAnimationCircle(position: CGPoint,color: UIColor,label: SKLabelNode) {
        let loop = self.projectedLevel(currentLvl: self.level, currentLevelScore: self.currentLevelScore)
        for i in 0...loop-level {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(1100 * animationDuration) * i) , execute: { [unowned self] in
                let lvl = self.level + i
                let percent : CGFloat = CGFloat(self.currentLevelScore)/CGFloat(self.levelScore(lvl: lvl))
                if percent >= 1.00 {
                    if lvl > self.levelCap {
                        self.maxLvlReached = true
                        self.currentLevelScore = self.levelScore(lvl: self.levelCap)
                        self.directDefaults.set(self.currentLevelScore, forKey: "levelscore")
                        self.directDefaults.set(self.levelCap, forKey: "level")
                        self.expCircle(position: position, color: color)
                    }else {
                        self.removeCircleSublayer(name: "experience")
                        if i == 0 {
                            self.expCircle(position: position, color: color)
                            label.text = "\(lvl)"
                        }else {
                            self.expCircle(position: position, color: color, createSecondLayer: false)
                            label.text = "\(lvl)"
                        }
                        self.currentLevelScore = self.currentLevelScore - self.levelScore(lvl: lvl)
                    }
                }else {
                    if lvl > self.levelCap {
                        self.maxLvlReached = true
                        self.directDefaults.set(true, forKey: "maxLvlReached")
                        self.currentLevelScore = self.levelScore(lvl: self.levelCap)
                        self.directDefaults.set(self.currentLevelScore, forKey: "levelscore")
                        self.directDefaults.set(self.levelCap, forKey: "level")
                        self.expCircle(position: position, color: color)
                    }else {
                        self.removeCircleSublayer(name: "experience")
                        self.expCircle(position: position, percentage: percent, color: color)
                        label.text = "\(lvl)"
                        self.level = lvl
                        self.directDefaults.set(lvl, forKey: "level")
                        self.directDefaults.set(self.currentLevelScore, forKey: "levelscore")
                    }
                }
            })
        }
    }
    
    func failedLoadingRewardVideo() {
        let failed = SKShapeNode(rectOf: CGSize(width: 640, height: 320), cornerRadius: 20)
        failed.fillColor = UIColor.black
        failed.strokeColor = UIColor.black
        failed.isAntialiased = true
        failed.alpha = 0.8
        failed.zPosition = 5
        failed.position = ballNode.position
        self.addChild(failed)
        let failLabel = SKLabelNode(text: "There are no sponsored video")
        failLabel.position.y = 60
        failLabel.fontName = "AvenirNext-Regular"
        failLabel.fontSize = 40
        failLabel.fontColor = UIColor.white
        failed.addChild(failLabel)
        let failLabel1 = SKLabelNode(text: "at these moment")
        failLabel1.position.y = 15
        failLabel1.fontName = "AvenirNext-Regular"
        failLabel1.fontSize = 40
        failLabel1.fontColor = UIColor.white
        failed.addChild(failLabel1)
        let failClose = SKLabelNode(text: "Close")
        failClose.position.y = -90
        failClose.fontName = self.globalFont
        failClose.fontSize = 55
        failClose.fontColor = UIColor.white
        failed.addChild(failClose)
        let failBack = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 200, height: 100))
        failBack.name = "failclose"
        failBack.position = failClose.position
        failed.addChild(failBack)
    }
    
    func removeCircleSublayer(name: String) {
        for layer in (self.view?.layer.sublayers)! {
            if layer.name == name {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func resurrectBall() {
        ballNode.removeAllActions()
        ballNode = generateBall(position: lastBouncPosition, isFirstBall: false)
        run(SKAction.wait(forDuration: 1), completion: { [unowned self] in
            self.ballNode.isPaused = false
            self.chance = false
        })
        toggleBackgroundMusic()
        self.addChild(ballNode)
    }
    
    func manageScoreAndExit() {
        if self.highScore < self.coinScore {
            self.highScore = self.coinScore
            self.directDefaults.set(self.highScore, forKey: "highscore")
        }
        if self.maxLvlReached {
            self.currentLevelScore += 0
        }else {
            self.currentLevelScore += self.coinScore
        }
        self.directDefaults.set(self.currentLevelScore, forKey: "levelscore")
        self.toggleBackgroundMusic()
        self.menuView(type: "gameova")
    }
    
    
    func levelScore(lvl: Int) -> Int {
        switch lvl {
        case 1:
            return 50
        case 2:
            return 100
        case 3:
            return 250
        case 4:
            return 500
        case 5:
            return 750
        case 6:
            return 1000
        case 7:
            return 1500
        case 8:
            return 2000
        case 9:
            return 2500
        case 10:
            return 3000
        case 11:
            return 5000
        case 12:
            return 7500
        case 13:
            return 10000
        case 14:
            return 12500
        case 15:
            return 15000
        case 16:
            return 17500
        case 17:
            return 20000
        case 18:
            return 22500
        case 19:
            return 25000
        case 20:
            return 30000
        default:
            return 1000000
        }
    }
    
    func projectedLevel(currentLvl: Int, currentLevelScore: Int) -> Int {
        var score = 0
        var lvl = currentLvl
        while(true) {
            score += levelScore(lvl: lvl)
            if score <= currentLevelScore {
                lvl += 1
            }else {
                break
            }
        }
        return lvl
    }
    
    func projectedLevelScore(currentLvl: Int, currentLevelScore: Int) -> Int {
        var score = 0
        let lvl = projectedLevel(currentLvl: currentLvl, currentLevelScore: currentLevelScore)
        if currentLvl == lvl {
            return currentLevelScore
        }else {
            for i in currentLvl...lvl-1 {
                score += levelScore(lvl: i)
            }
            return (currentLevelScore - score)
        }
    }
    
    func ballSpeed(score: Int) -> TimeInterval {
        if score >= 0 && score < 100 {
            return TimeInterval(5)
        }else if score >= 100 && score < 180 {
            return TimeInterval(1)
        }else {
            return TimeInterval(0.5)
        }
    }
    
    func initAudioPlayer(filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: newURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func toggleBackgroundMusic() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        audioPlayer.pause()
    }
    
}
