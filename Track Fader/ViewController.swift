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
    @IBOutlet weak var descLabel: UILabel!
    
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
        //timeLabel.text = "- - -"
        
        arrowLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        arrowLabel.textAlignment = .center
        arrowLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        arrowLabel.textColor = UIColor.lightGray.withAlphaComponent(0.7)
        arrowLabel.center = CGPoint(x: self.view.frame.midX, y: timeLabel.frame.origin.y + timeLabel.frame.height + 30)
        arrowLabel.text = "←→"
        
        self.view.addSubview(timeLabel)
        self.view.addSubview(arrowLabel)
        
        setupAndPlayNatureTrack()
        setupAndPlayMusicTrack()
    }

    private func setupAndPlayMusicTrack()
    {
        // Found: https://freemusicarchive.org/genre/Ambient?sort=track_date_published&d=1&page=5
        let path = Bundle.main.path(forResource: "Lee_Rosevere_and_Daniel_Birch_-_09_-_Halo.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        // Start the music file.
        
        do {
            trackPlayer = try AVAudioPlayer(contentsOf: url)
            trackPlayer?.numberOfLoops = -1
            trackPlayer?.prepareToPlay()
            trackPlayer?.volume = 0.1
            trackPlayer?.play()
            
            // Start things off.
            
            self.timerDelay = 5.0
            //self.timerDelay = self.randomDelay()
            self.generateTimer()
            
        } catch {
            // Houston, we have a problem.
        }
    }
    
    private func setupAndPlayNatureTrack()
    {
        // Based upon the time of day launching, you can get three different nature sounds.
        var naturePath: String
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 17 {
            naturePath = Bundle.main.path(forResource: "Spring-peeper-sound.mp3", ofType: nil)!
            descLabel.text = "( 5 PM -> Midnight. Peepers )".uppercased()
        } else if hour < 9 {
            naturePath = Bundle.main.path(forResource: "Forest-birds-ambience-early-spring.mp3", ofType: nil)!
            descLabel.text = "( Midnight -> 9 AM. Forest Birds )".uppercased()
        } else {
            naturePath = Bundle.main.path(forResource: "Nature.m4a", ofType: nil)!
            descLabel.text = "( 9 AM -> 5PM. Water with birds )".uppercased()
        }
        let natureURL = URL(fileURLWithPath: naturePath)
        
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
                self.arrowLabel.flash(numberOfFlashes: 5.0)
                self.trackPlayer!.setVolume(0.0, fadeDuration: 10.0)
            } else {
                self.trackPlayer!.setVolume(0.1, fadeDuration: 10.0)
                self.arrowLabel.flash(numberOfFlashes: 5.0)
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
    
    // Between 10 and 45 seconds for now.
    private func randomDelay() -> TimeInterval {
        let timeInterval = Double.random(in: 11 ..< 45)
        return timeInterval
    }
}

extension UIView {
    func flash(numberOfFlashes: Float)
    {
        CATransaction.begin()
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 1.0
        flash.fromValue = 0
        flash.toValue = 1.0
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = numberOfFlashes
        
        CATransaction.setCompletionBlock {
            self.alpha = 0
        }
        
        layer.add(flash, forKey: nil)
        
        CATransaction.commit()
    }
}
