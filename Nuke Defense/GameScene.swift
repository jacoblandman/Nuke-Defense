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
    case paused
}

enum CollisionTypes: UInt32 {
    case bullet = 1
    case bomb = 2
    case floor = 4
    case bird = 8
}

enum BirdTypes: Int {
    case chicken = 1
    case duck = 2
    case goose = 3
    case owl = 4
    case sparrow = 5
    case vulture = 6
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .chicken: return "chicken"
        case .duck: return "duck"
        case .goose: return "goose"
        case .owl: return "owl"
        case .sparrow: return "sparrow"
        case .vulture: return "vulture"
        }
    }
}

class turret: SKSpriteNode {
    var canFire: Bool = true
}

class button: SKSpriteNode {
    var touched: Bool = false
}

class Bird: SKSpriteNode {
    var birdType: String = ""
    var direction: String = ""
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    weak var viewController: GameViewController!
    let worldNode = SKNode()
    var logo: SKSpriteNode!
    var playButton: SKSpriteNode!
    var developerButton: SKSpriteNode!
    var pauseButton: SKSpriteNode!
    var soundButton: SKSpriteNode!
    var gameScore: SKLabelNode!
    var livesLabel: SKLabelNode!
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
    var lives: Int = 3 {
        didSet {
            livesLabel.text = "Bird Lives: \(lives)"
        }
    }
    
    var turret1: turret!
    var turret1Background: SKSpriteNode!
    var turret2: turret!
    var turret2Background: SKSpriteNode!
    
    var bombs = [SKSpriteNode]()
    var trails = [SKNode]()
    var birds = [Bird]()
    
    var floor: SKSpriteNode!
    
    var scale: CGFloat!
    var releaseTime = 2.0
    let floorReleaseTime: Double = 0.5
    var bulletNumber = RandomInt(min: 0, max: 2)
    var needsReset: Bool = true
    var useSound: Bool = true
    var bombsNotReleased: Bool = true
    var birdsNotReleased: Bool = true
    var runningActions: Bool = false
    
    var leftTouch: UITouch?
    var rightTouch: UITouch?
    var playButtonTouch: UITouch?
    var developerButtonTouch: UITouch?
    
    var backgroundSound: SKAudioNode?
    
    var gameState = GameState.showingLogo
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    override func didMove(to view: SKView) {
        
        // add the world node which will be used for pausing
        worldNode.name = "world"
        addChild(worldNode)
        
        // set the gravity and speed for the game
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
        physicsWorld.speed = 0.6
        physicsWorld.contactDelegate = self
        
        // load the sound setting
        // load UserDefaults if it exists there already
        let defaults = UserDefaults.standard
        if let useSoundForGame = defaults.object(forKey: "useSound") as? Bool {
            useSound = useSoundForGame
        } else {
            useSound = true
        }
        
        // load the background, logos, scores, turrets, and start releasing bombs
        loadBackground()
        createLogosAndButtons()
        loadScores()
        createTurrets()
        createFloor()
    }
    
    // ------------------------------------------------------------------------------------------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // check the game state
        switch gameState {
            // if a touch happened while the logo is shoing then start the game
            case .showingLogo, .gameOver, .paused:
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
                } else if soundButton.contains(touch.location(in: self)) {
                    soundTapped()
                }
            
            // if a touch happened while playing, set the left or right touch for controlling the turrets
            case .playing:
                guard let touch = touches.first else { return }
                
                if pauseButton.contains(touch.location(in: self)) {
                    pauseGame(appMovedToBackground: false)
                    return
                }
                
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
            case .showingLogo, .gameOver, .paused:
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
            case .showingLogo, .gameOver, .paused:
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
        
        // check if the game is paused
        if gameState == .paused {
            worldNode.isPaused = true
            physicsWorld.speed = 0.0
            return
        }
        
        
        if let touch = leftTouch {
            
            let moveAction = SKAction.run { [unowned self] in
               self.move(self.turret1, toward: touch.location(in: self))
            }
            let shootAction = SKAction.run { [unowned self] in
                self.shootBullet(from: self.turret1, towards: touch.location(in: self))
            }
            let wait = SKAction.wait(forDuration: 0.1)
            run(SKAction.sequence([moveAction, wait, shootAction]))
        }
        
        if let touch = rightTouch {
            let moveAction = SKAction.run { [unowned self] in
                self.move(self.turret2, toward: touch.location(in: self))
            }
            let shootAction = SKAction.run { [unowned self] in
                self.shootBullet(from: self.turret2, towards: touch.location(in: self))
            }
            let wait = SKAction.wait(forDuration: 0.1)
            run(SKAction.sequence([moveAction, wait, shootAction]))
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
        gameScore.name = "gameScore"
        addChild(gameScore)
        
        // place the lives label
        livesLabel = SKLabelNode(fontNamed: "Chalkduster")
        livesLabel.text = "Bird Lives: 3"
        livesLabel.horizontalAlignmentMode = .center
        livesLabel.position = CGPoint(x: width * 0.5, y: height - (10 + scoreFontSize))
        livesLabel.fontSize = scoreFontSize
        livesLabel.name = "lives"
        addChild(livesLabel)
        
        // place the high score label
        // load the high score using user defaults
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "highScore")
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.position = convert(CGPoint(x: width - 10, y: height - (10 + scoreFontSize)), to: highScoreLabel)
        highScoreLabel.fontSize = scoreFontSize
        highScoreLabel.name = "highScore"
        addChild(highScoreLabel)
        
        // we'll add the pause button here too
        pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        scale(pauseButton, using: scale)
        pauseButton.position = CGPoint(x: width - 10 - pauseButton.size.width, y: height - (10 + scoreFontSize + pauseButton.size.height))
        pauseButton.zPosition = 50
        pauseButton.alpha = 0.0
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
        
        // also add the sound button
        
        if useSound {
            soundButton = SKSpriteNode(imageNamed: "sound")
        } else {
            soundButton = SKSpriteNode(imageNamed: "noSound")
        }
        scale(soundButton, using: scale)
        soundButton.position = CGPoint(x: width - 10 - pauseButton.size.width, y: height - (10 + scoreFontSize + pauseButton.size.height))
        pauseButton.zPosition = 51
        soundButton.name = "soundButton"
        addChild(soundButton)
        
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func createTurrets() {
  
        let turretNumber = RandomInt(min: 1, max: 2)
        let imageName = "turret_".appending(String(turretNumber))
        let turretTexture = SKTexture(imageNamed: imageName)
        turret1Background = SKSpriteNode(texture: turretTexture)
        turret1Background.zPosition = 9
        scale(turret1Background, using: scale)
        turret1Background.position = convert(CGPoint(x: turret1Background.size.width / 4.0, y: (turret1Background.size.height / 4.0)), to: turret1Background)
        turret1Background.name = "turret"
        addChild(turret1Background)
        
        turret2Background = SKSpriteNode(texture: turretTexture)
        turret2Background.zPosition = 9
        scale(turret2Background, using: scale)
        turret2Background.position = convert(CGPoint(x: view!.frame.size.width - (turret2Background.size.width / 4.0), y: turret2Background.size.height / 4.0), to: turret2Background)
        turret2Background.name = "turret"
        addChild(turret2Background)
        
        // load all the texture frames frames from the sheet
        let spriteSheet = SKTexture(imageNamed: imageName.appending("_sheet"))
        var frames = [SKTexture]()
        let numFrames: CGFloat = 20.0
        
        for i in (0...19).reversed() {
            let rect = CGRect(x: CGFloat(i) / numFrames, y: 0, width: 1/numFrames, height: 1)
            frames.append(SKTexture(rect: rect, in: spriteSheet))
        }
        
        //let gunTexture = SKTexture(imageNamed: imageName.appending("_0"))
        turret1 = turret(texture: frames[0])
        scale(turret1, using: scale)
        turret1.anchorPoint = CGPoint(x: 0.5, y: 0.4059)
        turret1.position = (CGPoint(x: turret1Background.position.x, y: turret1Background.position.y))
        turret1.zPosition = 10
        turret1.name = "gun"
        
        turret2 = turret(texture: frames[0])
        scale(turret2, using: scale)
        turret2.anchorPoint = CGPoint(x: 0.5, y: 0.4059)
        turret2.position = (CGPoint(x: turret2Background.position.x, y: turret2Background.position.y))
        turret2.zPosition = 10
        turret2.name = "gun"
        
        addChild(turret1)
        addChild(turret2)
        
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
            bullet.physicsBody?.isDynamic = true
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = CollisionTypes.bullet.rawValue
            bullet.physicsBody!.contactTestBitMask = CollisionTypes.bomb.rawValue | CollisionTypes.bird.rawValue
            bullet.physicsBody!.collisionBitMask = CollisionTypes.bird.rawValue | CollisionTypes.bomb.rawValue
            worldNode.addChild(bullet)
            
            
            // actions the bullet will make
            let rotate = SKAction.rotate(toAngle: angle, duration: 0.0)
            let move = SKAction.move(to: endPosition, duration: 1.0 / velocity)
            let removeBullet = SKAction.removeFromParent()
            let sequence = SKAction.sequence([rotate, move, removeBullet])
            
            if useSound {
                playQuickSoundWithName("laser.mp3")
            }
            
            // make the bullet perform teh actions
            bullet.run(sequence)
            
            // wait to enable fire
            let waitToEnableFire = SKAction.wait(forDuration: 0.2)
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
        
        let rotate = SKAction.rotate(toAngle: angle, duration: 0.04)
        turret.run(rotate)
    }

    // ------------------------------------------------------------------------------------------
    
    func createLogosAndButtons() {
        logo = SKSpriteNode(imageNamed: "Logo")
        scale(logo, using: scale)
        logo.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + frame.height / 6)
        logo.name = "logo"
        addChild(logo)
        
        let spacing: CGFloat = 5 * UIScreen.main.scale
        playButton = SKSpriteNode(imageNamed: "PlayButton")
        scale(playButton, using: scale)
        //playButton.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        playButton.position = CGPoint(x: logo.position.x - playButton.size.width * 0.5 - spacing, y: logo.position.y - (spacing + playButton.size.height * 0.5))
        playButton.name = "playButton"
        playButton.zPosition = 51
        addChild(playButton)
        
        developerButton = SKSpriteNode(imageNamed: "DeveloperButton")
        scale(developerButton, using: scale)
        //developerButton.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        developerButton.position = CGPoint(x: logo.position.x + developerButton.size.width * 0.5 + spacing, y: logo.position.y - (spacing + playButton.size.height * 0.5))
        developerButton.name = "developerButton"
        developerButton.zPosition = 51
        addChild(developerButton)
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func createBomb() {
        
        if gameState == .playing {
            let bomb = SKSpriteNode(imageNamed: "Bomb")
            scale(bomb, using: scale)
            let xPos = RandomCGFloat(min: Float(2.5 * bomb.size.width), max: Float(frame.size.width - 2.5 * bomb.size.width))
            bomb.position = CGPoint(x: xPos, y: frame.size.height + bomb.size.height * 0.5)
            bomb.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
            bomb.physicsBody?.isDynamic = true
            bomb.physicsBody!.categoryBitMask = CollisionTypes.bomb.rawValue
            bomb.physicsBody!.contactTestBitMask = CollisionTypes.bullet.rawValue | CollisionTypes.floor.rawValue
            bomb.physicsBody!.collisionBitMask = CollisionTypes.bullet.rawValue | CollisionTypes.floor.rawValue | CollisionTypes.bomb.rawValue
            
            bomb.zPosition = 50
            bomb.name = "bomb"
            worldNode.addChild(bomb)
            bombs.append(bomb)
            
            // add a trail to the bomb, which is the target node
            let trailNode = SKNode()
            trailNode.zPosition = 1
            trailNode.name = "trailNode"
            worldNode.addChild(trailNode)
            trails.append(trailNode)
            
            // add the emitter
            let trail = SKEmitterNode(fileNamed: "BallTrail")!
            trail.targetNode = trailNode
            trail.position = CGPoint(x: 0, y: bomb.size.height * 0.5)
            trail.name = "trail"
            bomb.addChild(trail)
        } else {
            return
        }
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func releaseBombs() {
    
        // if the gameState isn't playing then repeat this function call after a delay
        if gameState == .playing {
            
            if (releaseTime > floorReleaseTime) { releaseTime *= 0.91 }
            
            let maxReleaseTime = releaseTime * 2.0
            let minReleaseTime = releaseTime * 0.5
            
            let nextReleaseTime = RandomDouble(min: minReleaseTime, max: maxReleaseTime)
            
            //print(nextReleaseTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + nextReleaseTime) { [unowned self] in
                self.createBomb()
                self.releaseBombs()
            }
        } else {
            bombsNotReleased = true
            return
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func startBirds() {
        
        if gameState == .playing {
            
            // for now lets release a bird every half a second to 5 seconds
            
            let releaseTime = 1.0
            
            let minReleaseTime = 0.5 * releaseTime
            let maxReleaseTime = 7.0 * releaseTime
            
            let nextReleaseTime = RandomDouble(min: minReleaseTime, max: maxReleaseTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + nextReleaseTime) { [unowned self] in
                self.createBird()
                self.startBirds()
            }
        } else {
            birdsNotReleased = true
            return
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func createBird() {
        
        if gameState == .playing {
            // pick which bird
            // random int between 1 and 6
            let viewWidth = frame.width
            let viewHeight = frame.height
            let birdNumber = RandomInt(min: 1, max: 6)
            let birdName = BirdTypes(rawValue: birdNumber)?.description
            let birdTexture = SKTexture(imageNamed: (birdName?.appending("1"))!)
            
            // create the bird object
            let bird = Bird(texture: birdTexture)
            scale(bird, using: scale)
            
            // set its name
            bird.birdType = birdName!
            
            // figure out its direction and flip it if necessary
            let randomInt = CGFloat(RandomInt(min: 0, max: 1))
            if randomInt == 0 {
                bird.xScale = -1.0
                bird.direction = "right"
            } else {
                bird.direction = "left"
            }
            
            // get a random position
            let xPos = randomInt * viewWidth + (2.0 * randomInt - 1.0) * (bird.size.width)
            let yPos = RandomCGFloat(min: Float(0.2 * viewHeight), max: Float(0.9 * viewHeight))
            bird.position = CGPoint(x: xPos, y: yPos)
            worldNode.addChild(bird)
            
            // set the physics body
            bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
            bird.physicsBody?.isDynamic = true
            bird.physicsBody?.affectedByGravity = false
            bird.physicsBody!.categoryBitMask = CollisionTypes.bird.rawValue
            bird.physicsBody!.contactTestBitMask = CollisionTypes.bullet.rawValue
            bird.physicsBody!.collisionBitMask = CollisionTypes.bullet.rawValue
            bird.zPosition = 50
            bird.name = "bird"
            
            // get all the bird frames to animate it flying
            var frames = [birdTexture]
            var numFrames: Int = 9
            if BirdTypes(rawValue: birdNumber) == .sparrow { numFrames = 8 }
            for i in 2...numFrames {
                frames.append(SKTexture(imageNamed: (birdName?.appending(String(i)))! ))
            }
            
            // add the bird to the birds array
            birds.append(bird)
            
            // create the animations
            let fly = SKAction.animate(with: frames, timePerFrame: 0.1)
            let flyForever = SKAction.repeatForever(fly)
            let move = SKAction.moveBy(x: (1.0 - 2.0*randomInt) * (viewWidth + bird.size.width) , y: 0.0, duration: 5.0)
            let remove = SKAction.run { [unowned self] in
                if let index = self.birds.index(of: bird) {
                    self.birds.remove(at: index)
                }
                bird.removeFromParent()
            }
            //let remove = SKAction.removeFromParent()
    
            // run the animations
            bird.run(flyForever)
            bird.run(SKAction.sequence([move, remove]))
        } else {
            // if the gamestate is not playing then return
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
        blackRect.name = "background"
        addChild(blackRect)
        
        // load the background image
        background = SKSpriteNode(imageNamed: "Background")
        let backgroundSize = background.size
        scale = max(width / backgroundSize.width, height / backgroundSize.height)
        background.size = CGSize(width: backgroundSize.width * scale, height: backgroundSize.height * scale)
        background.position = CGPoint(x: width / 2.0 , y: height / 2.0)
        background.zPosition = -1
        background.alpha = 0.5
        background.name = "background"
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
                endGame(from: contact.bodyA.node)
            } else if contact.bodyB.node?.name == "bomb" {
                gameState = .gameOver
                endGame(from: contact.bodyB.node)
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
            } else if contact.bodyA.node?.name == "bird" {
                if contact.bodyB.node?.parent != nil {
                    
                    kill(contact.bodyA.node as! Bird)
                    contact.bodyB.node!.removeFromParent()
                    lives = lives - 1
                    if lives == 0 {
                        gameState = .gameOver
                        endGame(from: nil)
                    }
                }
            } else if contact.bodyB.node?.name == "bird" {
                if contact.bodyA.node?.parent != nil {
                    
                    kill(contact.bodyB.node as! Bird)
                    contact.bodyA.node!.removeFromParent()
                    lives = lives - 1
                    if lives == 0 {
                        gameState = .gameOver
                        endGame(from: nil)
                    }
                }
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func endGame(from bomb: SKNode?) {
        
        leftTouch = nil
        rightTouch = nil
        
        // remove the background sound
        removeSound()
        
        // kill the rest of the birds
        for bird in birds {
            kill(bird)
        }
        
        birds.removeAll()
        
        // make the bomb that hit the ground have a big explosion
        if let exploding_bomb = bomb {
            if let bomb_index = bombs.index(of: exploding_bomb as! SKSpriteNode) {
                var trail: SKNode?
                bombs.remove(at: bomb_index)
                trail = trails[bomb_index]
                trails.remove(at: bomb_index)
                animateBigExplosion(from: exploding_bomb, trail: trail)
            }
        }
        
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
            sprite.name = "explosion"
            worldNode.addChild(sprite)
            
            if useSound {
                playQuickSoundWithName("QuickBomb.mp3")
            }
            
            sprite.run(sequence)
            remainingBomb.removeAllChildren()
            remainingBomb.run(remove)
        }
        
        trails.removeAll()
        bombs.removeAll()
        
        showGameOverLogos(actionDuration: 0.2)
        needsReset = true
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
        sprite.name = "explosion"
        worldNode.addChild(sprite)
        
        // animate the explision and remove the node afterwards
        let bomb_explosion = SKAction.animate(with: frames, timePerFrame: 0.03)
        let sequence = SKAction.sequence([bomb_explosion, remove])
        
        // use the SKAudio node for quick sounds becuase the skaction is buggy and has a memory leak
        if useSound {
            playQuickSoundWithName("QuickBomb.mp3")
        }
        
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
        scale(sprite, using: 3)
        whiteSpace = whiteSpace * 2 * scale
        sprite.position = CGPoint(x: frame.midX, y: sprite.size.height / 2 - whiteSpace)
        sprite.zPosition = 50
        sprite.name = "explosion"
        worldNode.addChild(sprite)

        // animate the explision and remove the node afterwards
        let bomb_explosion = SKAction.animate(with: frames, timePerFrame: 0.05)
        let sequence = SKAction.sequence([bomb_explosion, remove])
        
        if let bombTrail = trail {
            bombTrail.removeFromParent()
        }
        
        if useSound {
            playQuickSoundWithName("NuclearBomb.mp3")
        }
        
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
            beginPlay()
            
        } else if (name == "developerButton") {
            // change the view to the developer info stuff
            //self.isPaused = true
            backgroundSound?.removeFromParent()
            viewController.developerButtonTapped()
            
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func showGameOverLogos(actionDuration: Double) {
        
        self.runningActions = true
        pauseButton.run(SKAction.fadeAlpha(to: 0.0, duration: 0.2))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (5.0 * actionDuration)) { [unowned self] in
            self.playButton.texture = SKTexture(imageNamed: "PlayAgainButton")
            
            if self.logo.parent == nil {
                self.logo = SKSpriteNode(imageNamed: "GameOverLogo")
                self.scale(self.logo, using: self.scale)
                self.logo.anchorPoint = CGPoint(x: 0.5, y: 0.0)
                self.logo.position = CGPoint(x: self.frame.midX, y: self.frame.size.height + self.logo.size.height)
                self.logo.zPosition = 51
                self.addChild(self.logo)
            }
            self.logo.name = "logo-end"
            
            let logoPosition = self.frame.midY + self.frame.height / 6
            let spacing: CGFloat = 15
            let moveDown = SKAction.moveTo(y: logoPosition, duration: actionDuration)
            let moveUp = SKAction.moveTo(y: logoPosition - (spacing + self.playButton.size.height * 0.5), duration: actionDuration)
            let fadeAlpha = SKAction.fadeAlpha(to: 0.5, duration: actionDuration)
            let wait = SKAction.wait(forDuration: actionDuration)
            let moveLogo = SKAction.run { [unowned self] in
                self.logo.run(moveDown)
            }
            let moveButtons = SKAction.run { [unowned self] in
                self.developerButton.run(moveUp)
                self.playButton.run(moveUp)
            }
            let fadeSound = SKAction.run { [unowned self] in
                self.soundButton.run(SKAction.fadeAlpha(to: 1.0, duration: actionDuration))
            }
            let setActionsBool = SKAction.run { [unowned self] in
                self.runningActions = false
            }
            self.background.run(SKAction.sequence([fadeAlpha, wait, moveLogo, fadeSound, wait, moveButtons, wait, setActionsBool]))
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func reset() {
        score = 0
        releaseTime = 2.0
        bulletNumber = RandomInt(min: 0, max: 2)
        lives = 3
        bombsNotReleased = true
        birdsNotReleased = true
    }
    
    // ------------------------------------------------------------------------------------------
    
    func presentPauseMenu(actionDuration: Double) {
        
        self.runningActions = true
        playButton.texture = SKTexture(imageNamed: "PlayButton")
        
        // only add the logo again if it isn't already there
        if logo.parent == nil {
            logo = SKSpriteNode(imageNamed: "PausedLogo")
            self.scale(self.logo, using: self.scale)
            logo.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            logo.position = CGPoint(x: frame.midX, y: frame.size.height + logo.size.height)
            logo.zPosition = 51
            logo.name = "logo-paused"
            addChild(logo)
        }
        
        let logoPosition = self.frame.midY + self.frame.height / 6
        let spacing: CGFloat = 15
        let moveDown = SKAction.moveTo(y: logoPosition, duration: actionDuration)
        let moveUp = SKAction.moveTo(y: logoPosition - (spacing + self.playButton.size.height * 0.5), duration: actionDuration)
        let fadeAlpha = SKAction.fadeAlpha(to: 0.5, duration: actionDuration)
        let wait = SKAction.wait(forDuration: actionDuration)
        let moveLogo = SKAction.run { [unowned self] in
            self.logo.run(moveDown)
        }
        let moveButtons = SKAction.run { [unowned self] in
            self.developerButton.run(moveUp)
            self.playButton.run(moveUp)
        }
        let fadePause = SKAction.run { [unowned self] in
            self.pauseButton.run(SKAction.fadeAlpha(to: 0.0, duration: actionDuration))
        }
        let fadeSound = SKAction.run { [unowned self] in
            self.soundButton.run(SKAction.fadeAlpha(to: 1.0, duration: actionDuration))
        }
        let setActionsBool = SKAction.run { [unowned self] in
            self.runningActions = false
        }
        self.background.run(SKAction.sequence([fadeAlpha, fadePause, wait, moveLogo, fadeSound, wait, moveButtons, wait, setActionsBool]))
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func pauseGame(appMovedToBackground: Bool) {
        gameState = .paused
        //bombsNotReleased = true
        //birdsNotReleased = true
        removeSound()
        physicsWorld.speed = 0.0
        leftTouch = nil
        rightTouch = nil
        
        worldNode.isPaused = true
        
        if (appMovedToBackground) {
            presentPauseMenu(actionDuration: 0.0)
        } else {
            presentPauseMenu(actionDuration: 0.0)
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func unpauseGame() {
        physicsWorld.speed = 0.6
        worldNode.isPaused = false
    }

    // ------------------------------------------------------------------------------------------
    
    func soundTapped() {
        
        if useSound {
            useSound = false
            soundButton.texture = SKTexture(imageNamed: "noSound")
            backgroundSound?.removeFromParent()
        } else {
            useSound = true
            soundButton.texture = SKTexture(imageNamed: "sound")
        }
        
        let defaults = UserDefaults.standard
        defaults.set(useSound, forKey: "useSound")
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func kill(_ bird: Bird) {
        
        // stop the birds current actions
        bird.removeAllActions()
        
        // remove the bird from the birds array
        if let bird_index = birds.index(of: bird) {
            birds.remove(at: bird_index)
        }
        
        //figure out the direction to animate the bird falling
        var multiplier: CGFloat = 1.0
        //let endX: CGFloat
        if bird.direction == "right" {
            multiplier = 1.0
            //endX = bird.position.x + bird.position.y
            
        } else {
            multiplier = -1.0
            //endX = bird.position.x - bird.position.y
        }
        
        //let path = UIBezierPath()
        //path.move(to: CGPoint(x: 0, y: 0))
        //path.addQuadCurve(to: convert(CGPoint(x: endX , y: 0), to: bird), controlPoint: convert(CGPoint(x: endX , y: bird.position.y), to: bird) )
        
        //print(path)
        //let followArc = SKAction.follow(path.cgPath, duration: 2.0)
        
        // flip the bird upside down
        bird.yScale = -1
        
        // change the texture to make it look dead
        bird.texture = SKTexture(imageNamed: bird.birdType.appending("7.png"))
        
        // make it affected by gravity so that it falls to the ground
        // change its collision stuff so nothing collides or contacts it
        bird.physicsBody!.categoryBitMask = 0
        bird.physicsBody!.contactTestBitMask = 0
        bird.physicsBody!.collisionBitMask = 0

        bird.physicsBody!.allowsRotation = false
        
        bird.physicsBody!.velocity = CGVector(dx: multiplier * 300.0, dy: -300.0)
        
        // create a wait action and remove action
        let wait = SKAction.wait(forDuration: 3.0)
        let remove = SKAction.removeFromParent()
        
        // run the actions
        
        if useSound {
            playQuickSoundWithName("bird.mp3")
        }
        
        bird.run(SKAction.sequence([wait, remove]))
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    func setBackgroundSound() {
        if let musicURL = Bundle.main.url(forResource: "night", withExtension: "wav") {
            backgroundSound = SKAudioNode(url: musicURL)
            backgroundSound!.name = "background Sound"
            addChild(backgroundSound!)
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func checkForSound() {
        if useSound {
            if backgroundSound?.parent == nil {
                setBackgroundSound()
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func removeSound() {
        if let sound = backgroundSound {
            if sound.parent != nil {
                sound.removeFromParent()
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func quickPlay() {
        
        // check to make sure actions aren't already happening. If so, we need to stop them
        beginPlay()
        return
    }
    
    // ------------------------------------------------------------------------------------------
    
    func beginPlay() {
        // create the actions to start the game
        // move the buttons down
        // move the logo up
        // remove the logo
        // fade the background alpha
        
        if (needsReset) {
            reset()
            needsReset = false
        }
        
        checkForSound()
        
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
            //self.pauseButton.run(fadeAlpha)
        }
        
        playButton.run(moveDown)
        developerButton.run(SKAction.sequence([moveDown, wait, moveLogo, fadeBackground]))
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [unowned self] in
            // set the gameState to playing and release the bombs
            if self.worldNode.isPaused { self.unpauseGame() }
            self.gameState = .playing
            
            // if the game was paused, the bombs and birds may still be released,
            // so we have to check if the method has returned yet
            // if they did return, they will set the bombsNotRelease or birdsNotReleased to false
            // release the bombs if they haven't been released yet
            if self.bombsNotReleased {
                //print("releasingBombs")
                self.bombsNotReleased = false
                self.releaseBombs()
            }
            
            // release the birds if they havent yet
            if self.birdsNotReleased {
                self.birdsNotReleased = false
                self.startBirds()
            }
            
            self.soundButton.alpha = 0.0
            self.pauseButton.alpha = 1.0
            
        }

    }
    
    // ------------------------------------------------------------------------------------------
    
    func playQuickSoundWithName(_ fileName: String) {
        let audioNode = SKAudioNode(fileNamed: fileName)
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        let wait = SKAction.wait(forDuration: 2.0)
        let remove = SKAction.removeFromParent()
        audioNode.run(SKAction.sequence([playAction, wait, remove]))
    }
    
    // ------------------------------------------------------------------------------------------
    
}
