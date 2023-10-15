//
//  OverlayView.swift
//  Afloat
//
//  Created by Tanishk Deo on 2/20/21.
//

import UIKit

class OverlayView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    
    var vc: MarketViewController?
    var row: Int = 0
    
    var delegate: OverlayDelegate?
    
    
    @IBOutlet weak var slideIndicator: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        slideIndicator.roundCorners(.allCorners, radius: 10)
        
        self.picker.delegate = self
        self.picker.dataSource = self
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Int(Model.shared.market[row].apr)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1000 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 200)
                }
            }
        }
    }
    
    @IBAction func bidPressed(_ sender: UIButton) {
        dismiss(animated: true)
        print(picker.selectedRow(inComponent: 0))
            delegate?.bid(row: row, apr: Double(Int(picker.selectedRow(inComponent: 0))))
        }
        
        
    }

protocol OverlayDelegate {
    func bid(row: Int, apr: Double)
}
