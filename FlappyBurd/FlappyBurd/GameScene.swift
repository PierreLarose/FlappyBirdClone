//
//  GameScene.swift
//  FlappyBurd
//
//  Created by Pierre Larose on 1/9/15.
//  Copyright (c) 2015 Pierre Larose. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    
    let birdCategory : UInt32 = 1 << 0
    let groundCategory : UInt32 = 1 << 1
    let polesCategory : UInt32 = 1 << 2
    let scoreCategory : UInt32 = 1 << 3
    
    var sky = SKSpriteNode(imageNamed: "sky")
    
    var movingParts = SKNode()
    
    var poles = SKNode()
    
    var scoreLabel = SKLabelNode()
    var score = NSInteger()
    
    override func didMoveToView(view: SKView) {
        
        self.addChild(self.movingParts)
        self.movingParts.addChild(self.poles)
        
        self.physicsWorld.gravity = CGVectorMake(0, -3)
        self.physicsWorld.contactDelegate = self
        
        self.sky.position = CGPoint(x: self.frame.size.width / 2, y:  self.frame.size.height / 2)
        
        self.addChild(self.sky)
        
        let createPoles = SKAction.runBlock({() in self.createPoles()})
        let waitAMinute = SKAction.waitForDuration(3)
        let createAndWait = SKAction.sequence([createPoles, waitAMinute])
        let createAndWaitForever = SKAction.repeatActionForever(createAndWait)
        self.runAction(createAndWaitForever)
        
        let groundTexture = SKTexture(imageNamed: "ground")
        
        let groundMovingLeft = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: NSTimeInterval( groundTexture.size().width * 0.015))
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0)
        let groundMovingLeftForever = SKAction.repeatActionForever(SKAction.sequence([groundMovingLeft,resetGround]))
        
        for i:CGFloat in 0 ..< self.frame.size.width / (groundTexture.size().width) {
            let groundPiece = SKSpriteNode(texture: groundTexture)
            groundPiece.position = CGPoint(x: i * groundPiece.size.width, y: groundPiece.size.height / 2)
            groundPiece.runAction(groundMovingLeftForever)
            self.movingParts.addChild(groundPiece)
        }
        
        let birdTexture1 = SKTexture(imageNamed: "bird1")
        let birdTexture2 = SKTexture(imageNamed: "bird2")
        let birdTexture3 = SKTexture(imageNamed: "bird3")
        self.bird = SKSpriteNode(texture: birdTexture1)
        self.bird.zPosition = 100
        
        let flap = SKAction.animateWithTextures([birdTexture1,birdTexture2,birdTexture3], timePerFrame: 0.15)
        let flapForver = SKAction.repeatActionForever(flap)
        self.bird.runAction(flapForver)
        
        self.bird.position = CGPoint(x: self.frame.size.width / 2 , y: self.frame.size.height / 2)
        
        self.bird.physicsBody = SKPhysicsBody(circleOfRadius: self.bird.size.height / 2)
        self.bird.physicsBody?.dynamic = true
        self.bird.physicsBody?.allowsRotation = false
        
        self.bird.physicsBody?.categoryBitMask = self.birdCategory
        self.bird.physicsBody?.collisionBitMask = self.groundCategory | self.polesCategory
        self.bird.physicsBody?.contactTestBitMask = self.groundCategory | self.polesCategory
        
        self.addChild(self.bird)
        
        let fakeGround = SKNode()
        fakeGround.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height))
        fakeGround.position = CGPointMake(0, groundTexture.size().height / 2)
        fakeGround.physicsBody?.dynamic = false
        fakeGround.physicsBody?.categoryBitMask = self.groundCategory
        self.addChild(fakeGround)
        
        self.score = 0
        self.addChild(self.scoreLabel)
        self.scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 4 * 3)
        self.scoreLabel.fontSize = 100
        self.scoreLabel.zPosition = 200
        self.scoreLabel.text = "\(self.score)"
    }
    
    func createPoles() {
        
        let twinPoles = SKNode()
        
        let random = arc4random_uniform(15)
        
        twinPoles.position = CGPoint(x: self.frame.size.width, y: CGFloat(random * 15) - 100)
        
        let topPole = SKSpriteNode(imageNamed: "topPole")
        topPole.position = CGPoint(x: 0, y: self.frame.size.height)
        topPole.physicsBody = SKPhysicsBody(rectangleOfSize: topPole.size)
        topPole.physicsBody?.dynamic = false
        topPole.physicsBody?.categoryBitMask = self.polesCategory
        twinPoles.addChild(topPole)
        
        let bottomPole = SKSpriteNode(imageNamed: "bottomPole")
        bottomPole.position = CGPoint(x: 0, y: 0)
        bottomPole.physicsBody = SKPhysicsBody(rectangleOfSize: bottomPole.size)
        bottomPole.physicsBody?.dynamic = false
        bottomPole.physicsBody?.categoryBitMask = self.polesCategory
        twinPoles.addChild(bottomPole)
        
        let scoreArea = SKNode()
        scoreArea.position = CGPoint(x: bottomPole.size.width, y: self.frame.size.height / 2)
        scoreArea.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(bottomPole.size.width, self.frame.size.height))
        scoreArea.physicsBody?.dynamic = false
        scoreArea.physicsBody?.categoryBitMask = self.scoreCategory
        scoreArea.physicsBody?.contactTestBitMask = self.birdCategory
        twinPoles.addChild(scoreArea)
        
        
        let movingDistance = CGFloat(self.frame.size.width + 2 * topPole.size.width)
        let movePoles = SKAction.moveByX(-movingDistance, y: 0, duration: NSTimeInterval(movingDistance * 0.015))
        let removePoles = SKAction.removeFromParent()
        let moveAndRemovePoles = SKAction.sequence([movePoles,removePoles])
        
        twinPoles.runAction(moveAndRemovePoles)
        
        self.poles.addChild(twinPoles)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
        if self.movingParts.speed > 0 {
            self.bird.physicsBody?.velocity = CGVectorMake(0, 0)
            self.bird.physicsBody?.applyImpulse(CGVectorMake(0, 25))
        } else {
            resetGame()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == self.scoreCategory || contact.bodyB.categoryBitMask == self.scoreCategory {
            self.score += 1
            self.scoreLabel.text = "\(self.score)"
        } else {
            endGame()
        }
    }
    
    func resetGame() {
        
        // reset the position of the bird
        self.bird.position = CGPoint(x: self.frame.size.width / 2 , y: self.frame.size.height / 2)
        self.bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // remove all the pipes
        self.poles.removeAllChildren()
        
        // set the speed again for the movingParts
        self.movingParts.speed = 1
        
        self.bird.physicsBody?.collisionBitMask = self.groundCategory | self.polesCategory
        
        self.score = 0
        self.scoreLabel.text = "\(self.score)"
    }
    
    func endGame() {
        
        if self.movingParts.speed > 0 {
            self.movingParts.speed = 0
            
            self.bird.physicsBody?.collisionBitMask = self.groundCategory
            
            let hideSky = SKAction.runBlock({() in self.sky.hidden = true})
            let whiteBackground = SKAction.runBlock({() in self.backgroundColor = UIColor.whiteColor()})
            let wait = SKAction.waitForDuration(0.06)
            let orangeBackground = SKAction.runBlock({() in self.backgroundColor = UIColor.orangeColor()})
            let showSky = SKAction.runBlock({() in self.sky.hidden = false})
            let gameOver = SKAction.sequence([hideSky, whiteBackground, wait, orangeBackground, wait, whiteBackground, wait, showSky])
            self.runAction(gameOver)
        }
    }
}
