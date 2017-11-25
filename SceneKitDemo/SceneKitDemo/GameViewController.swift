//
//  GameViewController.swift
//  SceneKitDemo
//
//  Created by CallMeDaKing on 2017/8/7.
//  Copyright © 2017年 CallMeDaKing. All rights reserved.
//
/**
 需要注意的是，往SCNsene 中添加节Nodes 时，需要让Node 有自己默认的本地坐标位置，，即相对于父节点的坐标位置，而不是世界坐标系的位置
 
 */

import UIKit
import SceneKit

class GameViewController: UIViewController {
    //1 声明了一个SCNView 的属性，用于渲染需要展示的 SCNScene的内容
    var sceneView : SCNView!
    //声明一个场景，在这个场景中我们可以添加一些组件，例如 灯光、几何体、粒子发射器、相机等作为场景中的子节点
    var scnScene : SCNScene!
    //添加摄像机
    var caemeraNode :SCNNode!
    
    var spawnTime:TimeInterval = 0
    //利用封装好的第三方GameUtitles 生成的实例shareInstance 可以快速集成关于最高分、当前分数以及生命值等复杂的功能。
    var game = GameHelper.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创想一个新的view
        setUpView()
        
        // create a new scene
        setUpScene()
        //creatCamera
        setUpCamera()
        //creat geometryNode
//        spawnShape()
        //第三方集成分数和声明值显示
         setupHUP()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // 将self.view 类型转换（映射）为SCNView 并将其存储在 sceneView 中，这样我们每次引用视图的时候就不用重复进行转换，需要注意的是，我们在这可以之所以可以直接转换是因为我们已经将Main.storyboard 已经拖入了SCNView
    func setUpView(){
        sceneView = self.view as! SCNView
        //showStatistics 会在屏幕下方有个实时的统计面板
        sceneView.showsStatistics = true
        //通过简单的手势控制相机的旋转和运动
        sceneView.allowsCameraControl = true
        //默认生成光源
        sceneView.autoenablesDefaultLighting = true
        //注; SCNView 是MacOS 中的NSView 的子类， 是iOS中UIView 的子类， 所以无论您使用MacOS 还是iOS ，SCNView 都能提供一个特定于SceneKit内容的视图
        //设置代理 确定是gameViewController 执行相应的代理方法
        sceneView.delegate = self
        
        sceneView.isPlaying = true
    }
    
    func setUpScene(){
        //在这里实例化SCNScene类 并将其存储在声明中的scnScene 中，然后将这个空白的场景设置为sceneView 的使用场景
        scnScene = SCNScene()
        sceneView.scene = scnScene
//        scnScene.background.contents = #imageLiteral(resourceName: "Logo_Diffuse.png")
        
    }
    
    func setUpCamera() {
        
        caemeraNode = SCNNode()
        caemeraNode.camera = SCNCamera()
        caemeraNode.position = SCNVector3(0, 5, 10)
        scnScene.rootNode.addChildNode(caemeraNode)
        
    }
    
    func spawnShape(){
        
        var geometry: SCNGeometry
        
        switch ShapeType.random() {
        case .box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .sphere:
            geometry = SCNSphere(radius: 0.5)
            
        case .pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 0.25)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.3, height: 2)
        case .cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        let color = UIColor.random()
        geometry.firstMaterial?.diffuse.contents = color
        let geometryNode = SCNNode(geometry: geometry)
//        let shape = SCNPhysicsShape()
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        //应用力
        let randomx = Float.random(min: -2, max: 2)
        let randomy = Float.random(min: 10, max: 18)
        let force = SCNVector3(x: randomx, y: randomy, z: 0)
        let position = SCNVector3(0.05, 0.05, 0.05)
        print(geometryNode.position)
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
        
        let trailEmitter = creatTrail(color: color , geometory: geometry)
        geometryNode .addParticleSystem(trailEmitter)
        scnScene.rootNode.addChildNode(geometryNode)
        
        if color == UIColor.black{
            geometryNode.name = "BAD"
        }else{
            geometryNode.name = "GOOD"
        }
        
    }
    
    func cleanScene() {
        
        for node in scnScene.rootNode.childNodes {
            
            if node.presentation.position.y < -2 {
                
                node.removeFromParentNode()
            }
        }
    }
    
    func  creatTrail(color :UIColor , geometory :SCNGeometry) -> SCNParticleSystem {
        
        let trail = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil)
        
        trail?.particleColor = color
        trail?.emitterShape = geometory
        
        return trail!
    }
    
    func setupHUP() {
        
        game.hudNode.position = SCNVector3(0.0 , 10.0, 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func handleTocuFor(node: SCNNode) {
        
        if node.name == "GOOD" {
            game.score += 1
            
            createExplosion(geometry: node.geometry!, position: node.presentation.position, rotation: node.presentation.rotation)
            
            node.removeFromParentNode()
        }else if node.name == "BAD"{
            
            game.lives -= 1
            
            createExplosion(geometry: node.geometry!
            , position: node.presentation.position, rotation: node.presentation.rotation)
            
            node.removeFromParentNode()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //1获取第一个手势，如果是多指操作，那么获取到的点击事件将不止一个
        let touch = touches.first!
        
        //2将手势的点击位置转为sceneView 中3D坐标
        let location = touch.location(in: sceneView)
        
        //3将会给你返回一个SCNHitTestResult对象的数组，里面存放着射线依次与3d对象产生的交互，就是用户点击的屏幕位置转化为3d场景中的一个点发射出的射线与任何一个空间对象的交互。
        let hutResults = sceneView.hitTest(location, options: nil)
        
        //4选取第一个交互事件
        if let result =  hutResults.first{
            
            handleTocuFor(node: result.node)
        }
    }
    //1创建一个函数有是三个参数
    /**
     geometry: 定义了粒子效果的形状
     position：
     rotation： 后两个参数均作为粒子效果在场景中更好的定位和出现更逼真的效果
     */
    func createExplosion(geometry: SCNGeometry,position: SCNVector3,rotation: SCNVector4) {
        //2加载Explode.scnp,并创建发射器，发射器使用几何体，作为发射器的外形，这样栗子就能从几何体表面发射。
        let explosion = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        
        //3 使用矩阵，提供一个组合的旋转和位置（或转换）转换矩阵来添加粒子系统
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x
            , position.y, position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        //4 调用addparticlesystem 方法，在屏幕上添加爆炸的效果。
        scnScene.addParticleSystem(explosion, transform: transformMatrix)
        
    }
}

//给GameViewController 添加扩展，遵从协议，允许在单独的代码块中维护协议中的方法
extension GameViewController:SCNSceneRendererDelegate{
    
    //render Loop 在60fps 的游戏环境中会将9个渲染步骤执行60次 ，也就是每秒执行60次渲染循环
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if time > spawnTime {
            
            spawnShape()
            spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5))
            
        }
        
        cleanScene()
        
        game.updateHUD()
        
    }
    
}
