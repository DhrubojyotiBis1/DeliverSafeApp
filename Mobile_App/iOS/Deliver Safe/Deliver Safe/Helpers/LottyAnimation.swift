//
//  LottyAnimation.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 21/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import Lottie

public class Animator {
    
    init(view: UIView) {
        self.view = view
        self.animationBackgroundView = UIView(frame: view.frame)
        self.animationBackgroundView.backgroundColor = CustomColour.viewColour.withAlphaComponent(0.3)
    }
    
    private var animationView: AnimationView!
    private var view: UIView!
    private var animationBackgroundView: UIView!
    
    
    func playAnimationWith(name: String, mode: LottieLoopMode) {
        self.animationBackgroundView.isHidden = false
        self.animationView = .init(name: name)
        animationView.frame = animationBackgroundView.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = mode
        if mode != .playOnce {
            animationView.animationSpeed = 2
        }
        animationBackgroundView.addSubview(animationView)
        view.addSubview(animationBackgroundView)
        animationView.play { (isColpleted) in
            if mode == .playOnce {
                self.animationBackgroundView.isHidden = true
            }
        }
    }
    
    func stopAnimation() {
        self.animationBackgroundView.isHidden = true
        if self.animationView != nil && self.animationView.isAnimationPlaying {
            self.animationView.stop()
        }
    }
    
}
