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
    case gameOver
}

enum CollisionTypes: UInt32 {
    case bullet = 1
    case bomb = 2
    case floor = 4
}

class turret: SKSpriteNode {
    var canFire: Bool = true
}

class button: SKSpriteNode {
    var touched: Bool = false
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    weak var viewController: GameViewController!
    var logo: SKSpriteNode!
    var playButton: SKSpriteNode!
    var developerButton: SKSpriteNode!
    var gameScore: SKLabelNode!
    var background: SKSpriteNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
            if (score > highScore) { highScore = score }
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
    var trails = [SKNode]()
    
    var floor: SKSpriteNode!
    
    var scale: CGFloat!
    var releaseTime = 2.0
    let floorReleaseTime: Double = 0.35
    var bulletNumber = RandomInt(min: 0, max: 2)
    
    var leftTouch: UITouch?
    var rightTouch: UITouch?
    var playButtonTouch: UITouch?
    var developerButtonTouch: UITouch?
    
    var gameState = GameState.showingLogo
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    override func didMove(to view: SKView) {
        
        // set the gravity and speed for the game
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
        physicsWorld.speed = 0.55
        physicsWorld.contactDelegate = self
        
        // load the background, logos, scores, turrets, and start releasing bombs
        loadBackground()
        createLogo()
        loadScores()
        createTurrets()
        createFloor()
    }
    
    // ------------------------------------------------------------------------------------------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // check the game state
        switch gameState {
            // if a touch happened while the logo is shoing then start the game
            case .showingLogo, .gameOver:
                guard let touch = touches.first else { return }
                if playButton.contains(touch.location(in: self)) {
                    if playButtonTouch == nil {
                        playButtonTouch = touch
                        pressed(playButton)
                    }
                } else if developerButton.contains(touch.location(in: self)) {
                    if developerButtonTouch == nil {
                        developerButtonTouch = touch
                        pressed(developerButton)
                    }
                }
            
            // if a touch happened while playing, set the left or right touch for controlling the turrets
            case .playing:
                guard let touch = touches.first else { return }
                if touch.location(in: self).x < frame.size.width / 2 {
                    if leftTouch == nil { leftTouch = touch }
                } else {
                    if rightTouch == nil { rightTouch = touch }
                }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
            case .showingLogo, .gameOver:
                for touch in touches {
                    if (touch == playButtonTouch) {
                        playButtonTouch = nil
                        // unshrink the button to animate it being touched
                        let unShrink = SKAction.scale(by: 1.0/0.9, duration: 0.0)
                        playButton.run(unShrink)
                        if playButton.contains(touch.location(in: self)) {
                            if (developerButtonTouch != nil) {
                                developerButton.run(unShrink)
                                developerButtonTouch = nil
                            }
                        }
                    } else if (touch == developerButtonTouch) {
                        developerButtonTouch = nil
                        // unshrink the button to animate it being touched
                        let unShrink = SKAction.scale(by: 1.0/0.9, duration: 0.0)
                        developerButton.run(unShrink)
                        if developerButton.contains(touch.location(in: self)) {
                            if (playButtonTouch != nil) {
                                playButton.run(unShrink)
                                playButtonTouch = nil
                            }
                        }
                    }
                }
            
            case .playing:
                for touch in touches {
                    print("touch cacnelled")
                    print(touch)
                    if (touch == leftTouch) { leftTouch = nil }
                    if (touch == rightTouch) { rightTouch = nil}
            }
        }
    }
    // ------------------------------------------------------------------------------------------
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // check the game state
        switch gameState {
        // if a touch happened while the logo is shoing then start the game
            case .showingLogo, .gameOver:
                for touch in touches {
                    if (touch == playButtonTouch) {
                        playButtonTouch = nil
                        // unshrink the button to animate it being touched
                        let unShrink = SKAction.scale(by: 1.0/0.9, duration: 0.0)
                        playButton.run(unShrink)
                        if playButton.contains(touch.location(in: self)) {
                            if (developerButtonTouch != nil) {
                                developerButton.run(unShrink)
                                developerButtonTouch = nil
                            }
                            released(playButton)
                        }
                    } else if (touch == developerButtonTouch) {
                        developerButtonTouch = nil
                        // unshrink the button to animate it being touched
                        let unShrink = SKAction.scale(by: 1.0/0.9, duration: 0.0)
                        developerButton.run(unShrink)
                        if developerButton.contains(touch.location(in: self)) {
                            if (playButtonTouch != nil) {
                                playButton.run(unShrink)
                                playButtonTouch = nil
                            }
                            released(developerButton)
                        }
                    }
                }
                    
            
        // if a touch happened while playing, set the left or right touch for controlling the turrets
            case .playing:
                for touch in touches {
                    if (touch == leftTouch) { leftTouch = nil }
                    if (touch == rightTouch) { rightTouch = nil}
                }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func update(_ currentTime: TimeInterval) {
        
        
        if let touch = leftTouch {
            move(turret1, toward: touch.location(in: self))
            shootBullet(from: turret1, towards: touch.location(in: self))
        }
        
        if let touch = rightTouch {
            move(turret2, toward: touch.location(in: self))
            shootBullet(from: turret2, towards: touch.location(in: self))
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
        scale(turret1, using: scale)
        turret1.anchorPoint = CGPoint(x: 0.5, y: 0.4059)
        turret1.position = (CGPoint(x: turret1Background.position.x, y: turret1Background.position.y))
        turret1.zPosition = 10
        
        turret2 = turret(texture: gunTexture)
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
            let bullet = SKSpriteNode(imageNamed: "Bullet".appending("\(bulletNumber)"))
            scale(bullet, using: scale)
            bullet.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            bullet.position = startingPosition
            bullet.name = "bullet"
            // set the physics
            bullet.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
            //bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: bullet.size)
            bullet.physicsBody?.isDynamic = false
            bullet.physicsBody!.categoryBitMask = CollisionTypes.bullet.rawValue
            //bullet.physicsBody!.contactTestBitMask = CollisionTypes.bomb.rawValue
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
    
    func createLogo() {
        logo = SKSpriteNode(imageNamed: "Logo")
        logo.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + frame.height / 6)
        addChild(logo)
        
        let spacing: CGFloat = 15
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        //playButton.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        playButton.position = CGPoint(x: logo.position.x - playButton.size.width * 0.5 - spacing, y: logo.position.y - (spacing + playButton.size.height * 0.5))
        playButton.name = "playButton"
        addChild(playButton)
        
        developerButton = SKSpriteNode(imageNamed: "DeveloperButton")
        //developerButton.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        developerButton.position = CGPoint(x: logo.position.x + developerButton.size.width * 0.5 + spacing, y: logo.position.y - (spacing + playButton.size.height * 0.5))
        developerButton.name = "developerButton"
        addChild(developerButton)
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func createBomb() {
        
        let bomb = SKSpriteNode(imageNamed: "Bomb")
        scale(bomb, using: scale)
        let xPos = RandomCGFloat(min: Float(bomb.size.width), max: Float(frame.size.width - bomb.size.width))
        bomb.position = CGPoint(x: xPos, y: frame.size.height + bomb.size.height * 0.5)
        bomb.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.isDynamic = true
        bomb.physicsBody!.categoryBitMask = CollisionTypes.bomb.rawValue
        bomb.physicsBody!.contactTestBitMask = CollisionTypes.bullet.rawValue | CollisionTypes.floor.rawValue
        bomb.zPosition = 50
        bomb.name = "bomb"
        addChild(bomb)
        bombs.append(bomb)
        
        // add a trail to the bomb, which is the target node
        let trailNode = SKNode()
        trailNode.zPosition = 1
        trailNode.name = "trail"
        addChild(trailNode)
        trails.append(trailNode)
        
        // add the emitter
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        trail.position = CGPoint(x: 0, y: bomb.size.height * 0.5)
        bomb.addChild(trail)
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
            
            //print(nextReleaseTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + nextReleaseTime) { [unowned self] in
                self.releaseBombs()
            }
        } else {
            return
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func loadBackground() {
        let height = scene!.size.height
        let width = scene!.size.width
        scene?.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        let blackRect = SKSpriteNode(color: UIColor.black, size: CGSize(width:width, height: height))
        blackRect.position = CGPoint(x: frame.midX, y: frame.midY)
        blackRect.zPosition = -2
        addChild(blackRect)
        
        // load the background image
        background = SKSpriteNode(imageNamed: "Background")
        let backgroundSize = background.size
        scale = max(width / backgroundSize.width, height / backgroundSize.height)
        background.size = CGSize(width: backgroundSize.width * scale, height: backgroundSize.height * scale)
        background.position = CGPoint(x: width / 2.0 , y: height / 2.0)
        background.zPosition = -1
        background.alpha = 0.5
        addChild(background)

    }
    
    // ------------------------------------------------------------------------------------------
    
    func createFloor() {
        
        floor = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.size.width, height: 1))
        floor.position = CGPoint(x: floor.size.width / 2, y: -floor.size.height / 2)
        addChild(floor)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.physicsBody!.categoryBitMask = CollisionTypes.floor.rawValue
        floor.name = "floor"
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // check if the game ended
        if contact.bodyA.node?.name == "floor" || contact.bodyB.node?.name == "floor" {
            if contact.bodyA.node?.name == "bomb" {
                gameState = .gameOver
                endGame(from: contact.bodyA.node!)
            } else if contact.bodyB.node?.name == "bomb" {
                gameState = .gameOver
                endGame(from: contact.bodyB.node!)
            }
        }
        
        // at this point if one of the bodies isn't a floor, then a bomb contacted a bullet
        // but lets check to make sure
        if contact.bodyA.node?.name == "bullet" || contact.bodyB.node?.name == "bullet" {
            if contact.bodyA.node?.name == "bomb" {
                if contact.bodyB.node?.parent != nil {
                    collision(with: contact.bodyA.node!, by: contact.bodyB.node!)
                }
            } else if contact.bodyB.node?.name == "bomb" {
                if contact.bodyA.node?.parent != nil {
                    collision(with: contact.bodyB.node!, by: contact.bodyA.node!)
                }
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func endGame(from bomb: SKNode) {
        
        leftTouch = nil
        rightTouch = nil
        
        // make the bomb that hit the ground have a big explosion
        var trail: SKNode?
        if let bomb_index = bombs.index(of: bomb as! SKSpriteNode) {
            bombs.remove(at: bomb_index)
            trail = trails[bomb_index]
            trails.remove(at: bomb_index)
        }
        animateBigExplosion(from: bomb, trail: trail)
        
        
        // remove the rest of the bombs
        let spriteSheet = SKTexture(imageNamed: "Four")
        var frames = [SKTexture]()
        let numFrames: CGFloat = 4
        
        // create all the sprite textures from the sprite sheet
        // there should be 16
        for y in (2...3).reversed() {
            for x in (0...3) {
                let rect = CGRect(x: CGFloat(x)/numFrames, y: CGFloat(y)/numFrames, width: 1/numFrames, height: 1/numFrames)
                frames.append(SKTexture(rect: rect, in: spriteSheet))
            }
        }
        
        let remove = SKAction.removeFromParent()
        // animate the explision and remove the node afterwards
        let bomb_explosion = SKAction.animate(with: frames, timePerFrame: 0.03)
        let sequence = SKAction.sequence([bomb_explosion, remove])
        
        // remove the trail target node before removeing the trail emitter node
        for trail in trails {
            trail.removeFromParent()
        }
        
        // remove the bombs and its emitter nodes and add the explosion sprite
        for remainingBomb in bombs {
            // add the explosion sprite
            let sprite = SKSpriteNode(texture: frames[0])
            scale(sprite, using: scale)
            sprite.position = remainingBomb.position
            sprite.zPosition = 50
            addChild(sprite)
            sprite.run(sequence)
            remainingBomb.removeAllChildren()
            remainingBomb.run(remove)
        }
        
        trails.removeAll()
        bombs.removeAll()
        
        showGameOverLogos()
    }
    
    // ------------------------------------------------------------------------------------------
    
    func collision(with bomb: SKNode, by bullet: SKNode) {
        // check again that the node is a bomb
        guard bomb.name == "bomb" else { return }
        score += 1
        
        // remove the trail and bomb from the array
        if let bomb_index = bombs.index(of: bomb as! SKSpriteNode) {
            bombs.remove(at: bomb_index)
            let trail = trails[bomb_index]
            trail.removeFromParent()
            trails.remove(at: bomb_index)
        }
        
        // create the sequence of actions to take place
        let remove = SKAction.removeFromParent()
        
        let spriteSheet = SKTexture(imageNamed: "Four")
        var frames = [SKTexture]()
        let numFrames: CGFloat = 4
        
        // create all the sprite textures from the sprite sheet
        // there should be 16
        for y in (2...3).reversed() {
            for x in (0...3) {
                let rect = CGRect(x: CGFloat(x)/numFrames, y: CGFloat(y)/numFrames, width: 1/numFrames, height: 1/numFrames)
                frames.append(SKTexture(rect: rect, in: spriteSheet))
            }
        }
        
        // add the explosion sprite
        let sprite = SKSpriteNode(texture: frames[0])
        scale(sprite, using: scale)
        sprite.position = bomb.position
        sprite.zPosition = 50
        addChild(sprite)
        
        // animate the explision and remove the node afterwards
        let bomb_explosion = SKAction.animate(with: frames, timePerFrame: 0.03)
        let sequence = SKAction.sequence([bomb_explosion, remove])
        
        // run the actions
        bomb.removeAllChildren()
        bomb.run(remove)
        sprite.run(sequence)
        bullet.run(remove)
        
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func animateBigExplosion(from bomb: SKNode, trail: SKNode?) {
        // create the sequence of actions to take place
        let remove = SKAction.removeFromParent()
        
        let spriteSheet = SKTexture(imageNamed: "Five")
        var frames = [SKTexture]()
        let numFrames: CGFloat = 4
        
        // create all the sprite textures from the sprite sheet
        // there should be 16
        for y in (0...3).reversed() {
            for x in (0...3) {
                let rect = CGRect(x: CGFloat(x)/numFrames, y: CGFloat(y)/numFrames, width: 1/numFrames, height: 1/numFrames)
                frames.append(SKTexture(rect: rect, in: spriteSheet))
            }
        }
        
        // add the explosion sprite
        let sprite = SKSpriteNode(texture: frames[0])
        var whiteSpace: CGFloat = 30
        scale(sprite, using: scale)
        scale(sprite, using: 2)
        whiteSpace = whiteSpace * 2 * scale
        sprite.position = CGPoint(x: frame.midX, y: sprite.size.height / 2 - whiteSpace)
        sprite.zPosition = 50
        addChild(sprite)

        // animate the explision and remove the node afterwards
        let bomb_explosion = SKAction.animate(with: frames, timePerFrame: 0.05)
        let sequence = SKAction.sequence([bomb_explosion, remove])
        
        trail!.removeFromParent()
        bomb.removeAllChildren()
        bomb.run(remove)
        sprite.run(sequence)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func pressed(_ button: SKNode) {
        let shrink = SKAction.scale(by: 0.9, duration: 0.0)
        button.run(shrink)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func released(_ button: SKNode) {
        
        let name = button.name!
        if name == "playButton" {
            
            reset()
            // create the actions to start the game
            // move the buttons down
            // move the logo up
            // remove the logo
            // fade the background alpha
            let moveDown = SKAction.moveTo(y: 0.0 - playButton.size.height, duration: 0.2)
            let moveUp = SKAction.moveTo(y: frame.size.height + logo.size.height, duration: 0.2)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.2)
            let fadeAlpha = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let moveLogo = SKAction.run { [unowned self] in
                self.logo.run(SKAction.sequence([moveUp, remove, wait]))
            }
            let fadeBackground = SKAction.run{ [unowned self] in
                self.background.run(fadeAlpha)
            }
            playButton.run(SKAction.sequence([moveDown, wait]))
            developerButton.run(SKAction.sequence([moveDown, wait, moveLogo, fadeBackground]))
            
            // set the gameState to playing and release the bombs
            gameState = .playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
                self.releaseBombs()
                
                // create the playAgain button and the Game Over logo
                self.createEndGameLogos()
            }
            
            for node in self.children {
                print(node)
            }
            
        } else if (name == "developerButton") {
            // change the view to the developer info stuff
            //self.isPaused = true
            viewController.developerButtonTapped()
        }
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func createEndGameLogos() {
        playButton.texture = SKTexture(imageNamed: "PlayAgainButton")
        logo = SKSpriteNode(imageNamed: "GameOverLogo")
        logo.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        logo.position = CGPoint(x: frame.midX, y: frame.size.height + logo.size.height)
        logo.zPosition = 50
        addChild(logo)
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func showGameOverLogos() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            let logoPosition = self.frame.midY + self.frame.height / 6
            let spacing: CGFloat = 15
            let moveDown = SKAction.moveTo(y: logoPosition, duration: 0.2)
            let moveUp = SKAction.moveTo(y: logoPosition - (spacing + self.playButton.size.height * 0.5), duration: 0.2)
            let fadeAlpha = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
            let wait = SKAction.wait(forDuration: 0.2)
            let moveLogo = SKAction.run { [unowned self] in
                self.logo.run(moveDown)
            }
            let moveButtons = SKAction.run { [unowned self] in
                self.developerButton.run(moveUp)
                self.playButton.run(moveUp)
            }
            
            self.background.run(SKAction.sequence([fadeAlpha, wait, moveLogo, wait, moveButtons]))
            
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func reset() {
        score = 0
        releaseTime = 2.0
        bulletNumber = RandomInt(min: 0, max: 2)
    }
    
    
}
