//
//  GameViewController.swift
//  Nuke Destroyer
//
//  Created by Jacob Landman on 12/19/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var currentGame: GameScene!
    var sceneLoaded: Bool = false
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScene()
    }

    // ------------------------------------------------------------------------------------------
    
    func loadScene() {
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        if let view = self.view as! SKView? {
            
            // create the game scene
            // Detect the screensize
            
            let size = view.frame.size
            let scene = GameScene(size: size)
            scene.scaleMode = .resizeFill
            sceneLoaded = true
            
            view.presentScene(scene)
            
            currentGame = scene
            currentGame.viewController = self
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    // ------------------------------------------------------------------------------------------
    
    override var shouldAutorotate: Bool {
        return true
    }

    // ------------------------------------------------------------------------------------------
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    // ------------------------------------------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // ------------------------------------------------------------------------------------------
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // ------------------------------------------------------------------------------------------
    
    func developerButtonTapped() {
        performSegue(withIdentifier: "segueToJTL", sender: self)
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
        navigationController?.hidesBarsOnSwipe = false
    
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        currentGame.leftTouch = nil
        currentGame.rightTouch = nil
        currentGame.playButtonTouch = nil
        currentGame.developerButtonTouch = nil
    }
    
    // ------------------------------------------------------------------------------------------
    
    func appMovedToBackground() {
        print("App moved to background!")
        
        if currentGame.gameState == .playing {
            currentGame.pauseGame(appMovedToBackground: true)
        }
        
        if currentGame.gameState == .gameOver {
            currentGame.background.removeAllActions()
            currentGame.showGameOverLogos(actionDuration: 0.0)
        }
        
    }
    
    // ------------------------------------------------------------------------------------------
}

