//
//  ViewController.swift
//  Track Fader
//
//  Created by Eric Dolecki on 1/10/20.
//  Copyright © 2020 Eric Dolecki. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    private var trackPlayer: AVAudioPlayer?
    private var naturePlayer: AVAudioPlayer?
    private var timer: Timer!
    private var timerDelay: TimeInterval!
    private var countdownTimer: Timer!
    private var timeLabel: UILabel!
    private var arrowLabel: UILabel!
    @IBOutlet weak var mySlider: UISlider!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
          try audioSession.setActive(true)
        } catch _ {
            print("error setting up audioSession.")
        }
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch let error as NSError {
            print("Could not set the audio session \(error).")
        } catch {
            fatalError()
        }
        
        timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 72.0))
        timeLabel.textColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        // For numerals, this font is monospaced.
        
        timeLabel.font = UIFont(name: "HelveticaNeue", size: 72.0)
        timeLabel.textAlignment = .center
        timeLabel.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        timeLabel.text = "- - -"
        
        arrowLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        arrowLabel.textAlignment = .center
        arrowLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        arrowLabel.textColor = UIColor.lightGray.withAlphaComponent(0.7)
        arrowLabel.center = CGPoint(x: self.view.frame.midX, y: timeLabel.frame.origin.y + timeLabel.frame.height + 30)
        arrowLabel.text = "←→"
        
        self.view.addSubview(timeLabel)
        self.view.addSubview(arrowLabel)
        
        setupAndPlayMusicTrack()
    }

    private func setupAndPlayMusicTrack()
    {
        let path = Bundle.main.path(forResource: "C.m4a", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        let naturePath = Bundle.main.path(forResource: "Nature.m4a", ofType: nil)!
        let natureURL = URL(fileURLWithPath: naturePath)
        
        // Start the music file.
        
        do {
            trackPlayer = try AVAudioPlayer(contentsOf: url)
            trackPlayer?.numberOfLoops = -1
            trackPlayer?.prepareToPlay()
            trackPlayer?.volume = 0.1
            trackPlayer?.play()
            
            // Start things off.
            
            self.timerDelay = self.randomDelay()
            self.generateTimer()
            
        } catch {
            // Houston, we have a problem.
        }
        
        // Start the nature sounds.
        
        do {
            naturePlayer = try AVAudioPlayer(contentsOf: natureURL)
            naturePlayer?.numberOfLoops = -1
            naturePlayer?.prepareToPlay()
            naturePlayer?.volume = 0.05
            naturePlayer?.play()
        } catch {
            // Houston, we have a problem here.
        }
        
    }
    
    private func generateTimer()
    {
        timer = Timer.scheduledTimer(withTimeInterval: timerDelay, repeats: false, block: { (timer) in
            if self.trackPlayer!.volume > 0 {
                self.arrowLabel.text = "↓"
                self.trackPlayer!.setVolume(0.0, fadeDuration: 9.0)
            } else {
                self.trackPlayer!.setVolume(0.1, fadeDuration: 9.0)
                self.arrowLabel.text = "↑"
            }
            self.timerDelay = self.randomDelay()
            self.generateTimer()
        })
        
        var total = 0
        total = Int(self.timerDelay)
        self.timeLabel.text = "\(total)"
        if self.countdownTimer != nil { countdownTimer.invalidate() }
        self.countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            total = total - 1
            self.timeLabel.text = "\(total)"
        })
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        trackPlayer?.pan = sender.value
    }
    
    // Between 10 and 30 seconds for now.
    private func randomDelay() -> TimeInterval {
        let timeInterval = Double.random(in: 10 ..< 30)
        return timeInterval
    }
}
