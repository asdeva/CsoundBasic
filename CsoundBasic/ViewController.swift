//
//  ViewController.swift
//  AudioKitExample
//
//  Created by Carlos Millan on 5/2/15.
//  Copyright (c) 2015 Carlos Millan. All rights reserved.
//

import UIKit

struct Constants
{
    static let width = 220
    static let numInstruments = 1
    static let frequencyScale: Float = 1760.0
}
var touchIds = [Int](count: 10, repeatedValue: 0)
var touchX = [Float](count: 10, repeatedValue: 0)
var touchY = [Float](count: 10, repeatedValue: 0)
var touchArray = [UITouch?](count: 10, repeatedValue: nil)
var touchXPtr = [UnsafeMutablePointer<Float>](count: 10, repeatedValue: nil)
var touchYPtr = [UnsafeMutablePointer<Float>](count: 10, repeatedValue: nil)

func cleanup()->Void
{
    for i in 0..<10
    {
        touchXPtr[i] = nil
        touchYPtr[i] = nil
    }
}

func getTouchIdAssingment()->Int
{
    for i in 0..<10
    {
        if touchArray[i] == nil
        {
            return i
        }
    }
    return -1
}

func getTouchId(touch: UITouch)->Int
{
    for i in 0..<10
    {
        if touchArray[i] == touch
        {
            return i
        }
    }
    return -1
}



class ViewController: UIViewController, CsoundBinding
{
    
    var csound: CsoundObj!
    
    override func viewDidLoad()
    {
        for i in 0..<10
        {
            touchIds[i] = 0
            touchX[i] = 0
            touchY[i] = 0
            touchArray[i] = nil
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        csound = CsoundObj()
        let mb: NSBundle = NSBundle.mainBundle()
        let tempFile: String? = mb.pathForResource("orcandsco", ofType: "csd")!
        //let tempFile: String? = mb.pathForResource("flute", ofType: "csd")!
        if tempFile != nil
        {
            print("path for resource tempFile \(tempFile!)")
            csound.addBinding(self)
            csound.play(tempFile!)
        }
        view.multipleTouchEnabled = true
        print(tempFile)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup(csoundObj: CsoundObj)
    {
        for i in 0..<10
        {
            touchXPtr[i] = csoundObj.getInputChannelPtr("touch.\(i).x",
                channelType: CSOUND_CONTROL_CHANNEL)
            touchYPtr[i] = csoundObj.getInputChannelPtr("touch.\(i).y",
                channelType: CSOUND_CONTROL_CHANNEL)
        }
    }
    
    func cleanup()
    {
        for i in 0..<10
        {
            touchXPtr[i] = nil
            touchYPtr[i] = nil
        }
    }
    
    func updateValuesFromCsound()
    {
    }
    
    func updateValuesToCsound()
    {
        for i in 0..<10
        {
            touchXPtr[i].memory = touchX[i]
            touchYPtr[i].memory = touchY[i]
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>,
        withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let touchId = getTouchIdAssingment()
            if touchId != -1
            {
                touchArray[touchId] = touch
                touchIds[touchId] = 1
                let pt = touch.locationInView(self.view)
                touchX[touchId] = Float(pt.x/self.view.frame.size.width)
                touchY[touchId] = 1 - Float(pt.y/self.view.frame.size.height)
                //touchXPtr[touchId].memory = touchX[touchId]
                //touchYPtr[touchId].memory = touchY[touchId]
                self.csound.sendScore("i1.\(touchId) 0 -1 \(touchId)")
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>,
        withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let touchId = getTouchId(touch)
            if touchId != -1
            {
                let pt = touch.locationInView(self.view)
                touchX[touchId] = Float(pt.x/self.view.frame.size.width)
                touchY[touchId] = 1 - Float(pt.y/self.view.frame.size.height)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>,
        withEvent event: UIEvent?)
    {
        for touch in touches
        {
            let touchId = getTouchId(touch)
            if touchId != -1
            {
                touchIds[touchId] = 0
                // touchX[touchId] = 0
                // touchY[touchId] = 0
                touchArray[touchId] = nil
                self.csound.sendScore("i-1.\(touchId) 0 0 \(touchId)")
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?,
        withEvent event: UIEvent?)
    {
        for touch in touches ?? Set<UITouch>()
        {
            let touchId = getTouchId(touch)
            if touchId != -1
            {
                touchIds[touchId] = 0
                // touchX[touchId] = 0
                // touchY[touchId] = 0
                touchArray[touchId] = nil
                self.csound.sendScore("i-1.\(touchId) 0 0")
            }
        }
    }
    
}

