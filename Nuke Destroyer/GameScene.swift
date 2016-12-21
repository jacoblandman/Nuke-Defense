//
//  GameScene.swift
//  Nuke Destroyer
//
//  Created by Jacob Landman on 12/19/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class turret: SKSpriteNode {
    var canFire: Bool = true
}


class GameScene: SKScene {
    
    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var logo: SKSpriteNode!
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var highScoreLabel: SKLabelNode!
    var highScore: Int! {
        didSet {
            highScoreLabel.text = "High Score: \(highScore!)"
            let defaults = UserDefaults.standard
            defaults.set(highScore, forKey: "highScore")
        }
    }
    
    var turret1: turret!
    var turret1Background: SKSpriteNode!
    var turret2: turret!
    var turret2Background: SKSpriteNode!
    
    var bombs = [SKSpriteNode]()
    
    var scale: CGFloat!
    var lives = 3
    var releaseTime = 2.0
    let floorReleaseTime: Double = 0.35
    
    var leftTouch: UITouch?
    var rightTouch: UITouch?
    
    var touchPositionLeft: CGPoint?
    var touchPositionRight: CGPoint?
    var canFire: Bool = true
    var touchingScreen: Bool = false
    var gameState = GameState.showingLogo
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    override func didMove(to view: SKView) {
        
        let height = scene!.size.height
        let width = scene!.size.width
        scene?.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        // load the background image
        let background = SKSpriteNode(imageNamed: "Background")
        let backgroundSize = background.size
        scale = max(width / backgroundSize.width, height / backgroundSize.height)
        background.size = CGSize(width: backgroundSize.width * scale, height: backgroundSize.height * scale)
        background.position = CGPoint(x: width / 2.0 , y: height / 2.0)
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
        physicsWorld.speed = 0.55
        
        createLogo()
        loadScores()
        createTurrets()
        releaseBombs()
    }
    
    // ------------------------------------------------------------------------------------------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        switch gameState {
            case .showingLogo:
                gameState = .playing
                
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let wait = SKAction.wait(forDuration: 0.5)
                let sequence = SKAction.sequence([fadeOut, remove, wait])
                logo.run(sequence)
            
            case .playing:
                touchingScreen = true
                guard let touch = touches.first else { return }
                print(touches)
                touchPositionLeft = touch.location(in: self)
            
            case .dead:
                return
            
        }
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = false
        print(touches)
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchPositionLeft = touch.location(in: self)
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func update(_ currentTime: TimeInterval) {
        if touchingScreen {
            if let position = touchPositionLeft {
                if position.x < (scene?.size.width)! / 2.0 {
                    move(turret1, toward: position)
                    move(turret2, toward: position)
                    shootBullet(from: turret1, towards: position)
                    shootBullet(from: turret2, towards: position)
                } else {
                    move(turret2, toward: position)
                    move(turret1, toward: position)
                    shootBullet(from: turret2, towards: position)
                    shootBullet(from: turret1, towards: position)
                }
            }
            
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func loadScores() {
        
        let height = scene!.size.height
        let width = scene!.size.width
        let scoreFontSize = height / 32
        
        // place the score Label
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.position = convert(CGPoint(x: 10, y: height - (10 + scoreFontSize)), to: gameScore)
        gameScore.fontSize = scoreFontSize
        addChild(gameScore)
        
        // place the high score label
        // load the high score using user defaults
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "highScore")
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.position = convert(CGPoint(x: width - 10, y: height - (10 + scoreFontSize)), to: highScoreLabel)
        highScoreLabel.fontSize = scoreFontSize
        addChild(highScoreLabel)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func createTurrets() {
        scale = 0.75
        let turretNumber = arc4random_uniform(2)+1
        let imageName = "turret_".appending(String(turretNumber))
        let turretTexture = SKTexture(imageNamed: imageName)
        turret1Background = SKSpriteNode(texture: turretTexture)
        turret1Background.zPosition = 9
        scale(turret1Background, using: scale)
        turret1Background.position = convert(CGPoint(x: turret1Background.size.width / 4.0, y: (turret1Background.size.height / 4.0)), to: turret1Background)
        addChild(turret1Background)
        
        turret2Background = SKSpriteNode(texture: turretTexture)
        turret2Background.zPosition = 9
        scale(turret2Background, using: scale)
        turret2Background.position = convert(CGPoint(x: view!.frame.size.width - (turret2Background.size.width / 4.0), y: turret2Background.size.height / 4.0), to: turret2Background)
        addChild(turret2Background)
        
        let gunTexture = SKTexture(imageNamed: imageName.appending("_0"))
        turret1 = turret(texture: gunTexture)
        //turret1 = SKSpriteNode(texture: gunTexture)
        scale(turret1, using: scale)
        turret1.anchorPoint = CGPoint(x: 0.5, y: 0.4059)
        turret1.position = (CGPoint(x: turret1Background.position.x, y: turret1Background.position.y))
        turret1.zPosition = 10
        
        turret2 = turret(texture: gunTexture)
        //turret2 = SKSpriteNode(texture: gunTexture)
        scale(turret2, using: scale)
        turret2.anchorPoint = CGPoint(x: 0.5, y: 0.4059)
        turret2.position = (CGPoint(x: turret2Background.position.x, y: turret2Background.position.y))
        turret2.zPosition = 10
        
        addChild(turret1)
        addChild(turret2)
        
        var frames = [gunTexture]
        
        for i in 1...19 {
            let newTexture = SKTexture(imageNamed: imageName.appending("_\(i)"))
            //let rotate = SKAction.rotate(byAngle: CGFloat.pi, duration: 0.0)
            frames.append(newTexture)
        }
        
        let turret1_animation = SKAction.animate(with: frames, timePerFrame: 0.1)
        let turret1_rotation = SKAction.rotate(byAngle: -1.0 * CGFloat.pi / 6, duration: 0.1)
        
        let turret2_animation = SKAction.animate(with: frames, timePerFrame: 0.1)
        let turret2_rotation = SKAction.rotate(byAngle: CGFloat.pi / 6, duration: 0.1)
        
        turret1.run(SKAction.sequence([turret1_animation, turret1_rotation]))
        turret2.run(SKAction.sequence([turret2_animation, turret2_rotation]))
        
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func scale(_ node: SKSpriteNode, using scale: CGFloat) {
        node.size = CGSize(width: node.size.width * scale, height: node.size.height * scale)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func shootBullet(from turret: turret, towards location: CGPoint) {
        
        let turretPosition = turret.position
        let turretCurrentAngle = turret.zRotation
        let turretLength = (anchorPoint.y)*turret.size.height
        let shootingPosition = CGPoint(x: turretPosition.x + turretLength*cos( CGFloat.pi / 2 + turretCurrentAngle), y: turretPosition.y + turretLength*sin( CGFloat.pi / 2 + turretCurrentAngle) )
        
        let angle = turretCurrentAngle
        let startingPosition = shootingPosition
        if (!turret.canFire) { return } else {
            turret.canFire = false
            
            let phoneSize = view!.frame.size
            let diagonal = sqrt(phoneSize.width * phoneSize.width + phoneSize.height * phoneSize.height)
            
            // set the bullets end position and velocity
            let endPosition = CGPoint(x: startingPosition.x + diagonal*cos(CGFloat.pi / 2 + angle) , y: startingPosition.y + diagonal*sin(CGFloat.pi / 2 + angle))
            let velocity: Double = 1.5
            
            // create a bullet and added it to the scene
            let bullet = SKSpriteNode(imageNamed: "Bullet0")
            scale(bullet, using: scale)
            bullet.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            bullet.position = startingPosition
            addChild(bullet)
            
            // actions the bullet will make
            let rotate = SKAction.rotate(toAngle: angle, duration: 0.0)
            let move = SKAction.move(to: endPosition, duration: 1.0 / velocity)
            let removeBullet = SKAction.removeFromParent()
            let sequence = SKAction.sequence([rotate, move, removeBullet])
            
            // make the bullet perform teh actions
            bullet.run(sequence)
            
            // wait to enable fire
            let waitToEnableFire = SKAction.wait(forDuration: 0.15)
            run(waitToEnableFire) { [unowned turret] in
                turret.canFire = true
            }
        }

        
//        let shootBulletAction = SKAction.run { [unowned self] in
//            self.shootBullet(from: shootingPosition, at: turretCurrentAngle)
//        }
//        
//        run(shootBulletAction)
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func move(_ turret: SKSpriteNode, toward location: CGPoint) {

        let center = turret.position
        let p1 = CGPoint(x: center.x, y: center.y + 50)
        let p2 = location
        
        let v1 = CGVector(dx: p1.x - center.x, dy: p1.y - center.y)
        let v2 = CGVector(dx: p2.x - center.x, dy: p2.y - center.y)
        
        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
        
        let rotate = SKAction.rotate(toAngle: angle, duration: 0.1)
        turret.run(rotate)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func shootBullet(from startingPosition: CGPoint, at angle: CGFloat) {
        
        if (!canFire) { return } else {
            canFire = false
            
            let phoneSize = view!.frame.size
            let diagonal = sqrt(phoneSize.width * phoneSize.width + phoneSize.height * phoneSize.height)
            
            // set the bullets end position and velocity
            let endPosition = CGPoint(x: startingPosition.x + diagonal*cos(CGFloat.pi / 2 + angle) , y: startingPosition.y + diagonal*sin(CGFloat.pi / 2 + angle))
            let velocity: Double = 1.5
            
            // create a bullet and added it to the scene
            let bullet = SKSpriteNode(imageNamed: "Bullet0")
            scale(bullet, using: scale)
            bullet.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            bullet.position = startingPosition
            addChild(bullet)
            
            // actions the bullet will make
            let rotate = SKAction.rotate(toAngle: angle, duration: 0.0)
            let move = SKAction.move(to: endPosition, duration: 1.0 / velocity)
            let removeBullet = SKAction.removeFromParent()
            let sequence = SKAction.sequence([rotate, move, removeBullet])
            
            // make the bullet perform teh actions
            bullet.run(sequence)
            
            // wait to enable fire
            let waitToEnableFire = SKAction.wait(forDuration: 0.15)
            run(waitToEnableFire) { [unowned self] in
                self.canFire = true
            }
        }
    }
        
    
    // ------------------------------------------------------------------------------------------
    
    func createLogo() {
        logo = SKSpriteNode(imageNamed: "Logo")
        logo.anchorPoint = CGPoint(x: 0.5, y: 0.4)
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func createBomb() {
        
        let bomb = SKSpriteNode(imageNamed: "Bomb")
        scale(bomb, using: scale)
        bomb.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        let xPos = RandomCGFloat(min: Float(bomb.size.width), max: Float(frame.size.width - bomb.size.width))
        bomb.position = CGPoint(x: xPos, y: frame.size.height)
        bomb.physicsBody = SKPhysicsBody(texture: bomb.texture!, size: bomb.size)
        bomb.physicsBody?.isDynamic = true
        bomb.zPosition = 50
        addChild(bomb)
        bombs.append(bomb)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func releaseBombs() {
        // if the gameState isn't playing then repeat this function call after a delay
        if gameState == .playing {
            
            if (releaseTime > floorReleaseTime) { releaseTime *= 0.91 }
            
            createBomb()
            
            let maxReleaseTime = releaseTime * 2.0
            let minReleaseTime = releaseTime * 0.5
            
            let nextReleaseTime = RandomDouble(min: minReleaseTime, max: maxReleaseTime)
            
            print(nextReleaseTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + nextReleaseTime) { [unowned self] in
                self.releaseBombs()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                self.releaseBombs()
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
}
