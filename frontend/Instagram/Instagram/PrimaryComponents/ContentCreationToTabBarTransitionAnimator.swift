//
//  ContentCreationToTabBarTransitionAnimator.swift
//  InstagramClone
//
//  Created by brock davis on 11/5/22.
//

import UIKit

class ContentCreationToTabBarTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {
    
    var gestureRecognizer: UIPanGestureRecognizer
    private let swipeDirection: UIRectEdge
    private var animator: UIViewPropertyAnimator?
    private weak var context: UIViewControllerContextTransitioning?
    private unowned var navigationController: UINavigationController?
    private unowned var primaryPageVC: PrimaryPageViewController?
    private var contentCreationVC: ContentCreationViewController? {
        self.navigationController?.viewControllers.first as? ContentCreationViewController
    }
    var isInteracting: Bool = false
    private let animationDuration: TimeInterval = 0.3
    var delegate: ContentCreationToTabBarTransitionAnimatorDelegate?
    
    
    init(swipeDirection: UIRectEdge, navigationController: UINavigationController, primaryPageVC: PrimaryPageViewController) {
        self.navigationController = navigationController
        self.primaryPageVC = primaryPageVC
        self.swipeDirection = swipeDirection
        self.gestureRecognizer = UIPanGestureRecognizer()
        super.init()
        self.gestureRecognizer.delegate = self
        self.gestureRecognizer.addTarget(self, action: #selector(self.userPanned))
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard
            gestureRecognizer == self.gestureRecognizer,
            let recognizer = gestureRecognizer as? UIPanGestureRecognizer
        else { return true }
        
        let translation = recognizer.translation(in: recognizer.view)
        
        let isValidPan = self.swipeDirection == .right ? translation.x > 0 : translation.x < 0
        
        return isValidPan && self.delegate?.transitionAnimatorShouldRecognize(animator: self) ?? true
    }
    
    @objc private func userPanned(recognizer: UIPanGestureRecognizer) {
        let containerView = gestureRecognizer.view!
        let translation = recognizer.translation(in: containerView)
        switch recognizer.state {
        case .began:
            self.isInteracting = true
            self.triggerTransitionAnimation()
        case .changed:
            let fractionComplete = abs(translation.x / containerView.bounds.width)
            self.animator?.fractionComplete = fractionComplete
            self.context?.updateInteractiveTransition(fractionComplete)
        default:
            self.animator?.pauseAnimation()
            self.animator?.isReversed = !((animator!.fractionComplete > 0.5) || abs(recognizer.velocity(in: containerView).x) >= 1000)
            if let animator, animator.isReversed {
                self.context?.cancelInteractiveTransition()
            } else {
                self.context?.finishInteractiveTransition()
            }
            self.animator?.continueAnimation(withTimingParameters: UICubicTimingParameters(animationCurve: .easeOut), durationFactor: 0.5)
        }
    }
    
    private func triggerTransitionAnimation() {
        if let navigationController {
            switch self.swipeDirection {
            case .left:
                if let primaryPageVC {
                    navigationController.pushViewController(primaryPageVC, animated: true)
                }
            default:
                navigationController.popViewController(animated: true)
            }
        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = self.interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = self.animator {
            return animator
        }
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        let container = transitionContext.containerView
        let fromViewInitialFrame = transitionContext.initialFrame(for: fromVC)
        let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        
        let transitioningToPrimaryView = toVC is PrimaryPageViewController
        
        var fromViewFinalFrame: CGRect
        var opacityViewFinalFrame: CGRect
        
        if transitioningToPrimaryView {
            let toViewInitialFrame = toViewFinalFrame.offsetBy(dx: toViewFinalFrame.width, dy: 0)
            container.addSubview(toView)
            toView.frame = toViewInitialFrame
            toView.layer.shadowOpacity = 0.2
            toView.layer.shadowOffset = CGSize(width: -1.5, height: 0)
            
            fromViewFinalFrame = fromViewInitialFrame.offsetBy(dx: -fromViewInitialFrame.width / 5, dy: 0)
            opacityViewFinalFrame = fromViewFinalFrame
            fromView.addSubview(opacityView)
            opacityView.frame = fromView.bounds
            opacityView.alpha = 0
        } else {
            let toViewIntialFrame = toViewFinalFrame.offsetBy(dx: -toViewFinalFrame.width / 5, dy: 0)
            container.insertSubview(toView, belowSubview: fromView)
            toView.frame = toViewIntialFrame
            
            toView.addSubview(opacityView)
            opacityView.alpha = 1
            opacityView.frame = toViewIntialFrame
            
            fromViewFinalFrame = fromViewInitialFrame.offsetBy(dx: fromViewInitialFrame.width, dy: 0)
            opacityViewFinalFrame = toViewFinalFrame
            
            fromView.layer.shadowOpacity = 0.2
            fromView.layer.shadowOffset = CGSize(width: -1.5, height: 0)
        }
        
        let animator = UIViewPropertyAnimator(duration: self.animationDuration, curve: .linear)
        
        animator.addAnimations {
            fromView.frame = fromViewFinalFrame
            toView.frame = toViewFinalFrame
            opacityView.frame = opacityViewFinalFrame
            opacityView.alpha = transitioningToPrimaryView ? 1 : 0
        }
        
        animator.addCompletion { postion in
            opacityView.removeFromSuperview()
            transitionContext.completeTransition(postion == .end)
        }
        self.animator = animator
        return self.animator!
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.context = transitionContext
        self.animator = self.interruptibleAnimator(using: transitionContext) as? UIViewPropertyAnimator
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        self.animator = nil
        self.context = nil
        self.isInteracting = false
    }
}

protocol ContentCreationToTabBarTransitionAnimatorDelegate {
    
    func transitionAnimatorShouldRecognize(animator: ContentCreationToTabBarTransitionAnimator) -> Bool
}

