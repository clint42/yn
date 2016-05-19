//
//  AskViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 28/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import AVFoundation

class CreateQuestionViewController: UIViewController {
    
    @IBOutlet weak var controlsView: UIView!
    
    var captureSession: AVCaptureSession? = nil
    var frontCameraDevice: AVCaptureDevice? = nil
    var backCameraDevice: AVCaptureDevice? = nil
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    let captureOutput = AVCaptureStillImageOutput()
    var currentCameraPosition = AVCaptureDevicePosition.Back
    
    var tmpImageData: NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        setCameraDevices()
        configureCaptureOutput()
        previewBackCamera()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func applyStyle() {
    }
    
    // MARK: - Camera methods
    private func configureCaptureOutput() {
        captureOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
    }
    
    
    // Get camera AVCaptureDevice for a specified position (back or front)
    private func getCameraDevice(forPosition position: AVCaptureDevicePosition) throws -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == position {
                    return device as! AVCaptureDevice
                }
            }
        }
        if position == AVCaptureDevicePosition.Front {
            throw CameraError.FrontCameraDoesNotExist
        }
        else if position == AVCaptureDevicePosition.Back {
            throw CameraError.BackCameraDoesNotExist
        }
        else {
            throw CameraError.UnknownError
        }
    }
    
    // Set the two AVCaptureDevies class properties
    private func setCameraDevices() {
        do {
            try frontCameraDevice = getCameraDevice(forPosition: AVCaptureDevicePosition.Front)
        } catch let error as CameraError {
            //TODO: Error handling camera unavailable (should remove switch camera button and/or display an alert message
            switch error {
            case CameraError.FrontCameraDoesNotExist:
                print("Front camera does not exist")
                break
            case CameraError.BackCameraDoesNotExist:
                print("Back camera does not exist")
                break
            case CameraError.UnknownError:
                print("An Unexpected error occured")
                break
            }
        } catch {
            //TODO: Error handling
            print("An unexpected error occured")
        }
        do {
             try backCameraDevice = getCameraDevice(forPosition: AVCaptureDevicePosition.Back)
        } catch let error as CameraError {
            //TODO: Error handling camera unavailable (should remove switch camera button and/or display an alert message
            switch error {
            case CameraError.FrontCameraDoesNotExist:
                print("Front camera does not exist")
                break
            case CameraError.BackCameraDoesNotExist:
                print("Back camera does not exist")
                break
            case CameraError.UnknownError:
                print("An Unexpected error occured")
                break
            }
        } catch {
            //TODO: Error handling
            print("An unexpected error occured")
        }
    }
    
    private func beginCameraPreview(cameraDevice: AVCaptureDevice) {
        do {
            captureSession?.stopRunning()
            captureSession = AVCaptureSession()
            captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
            try cameraDevice.lockForConfiguration()
            if cameraDevice.isFocusModeSupported(.ContinuousAutoFocus) {
                cameraDevice.focusMode = .ContinuousAutoFocus
            }
            else if cameraDevice.isFocusModeSupported(.AutoFocus) {
                cameraDevice.focusMode = .AutoFocus
            }
            cameraDevice.unlockForConfiguration()
            try captureSession!.addInput(AVCaptureDeviceInput(device: cameraDevice))
            cameraPreviewLayer?.removeFromSuperlayer()
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            cameraPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraPreviewLayer!.frame = view.layer.frame
            cameraPreviewLayer!.frame.origin.y = 0
            cameraPreviewLayer!.frame.size.height = view.layer.frame.height
            view.layer.insertSublayer(cameraPreviewLayer!, below: controlsView.layer)
            captureSession!.addOutput(captureOutput)
            captureSession!.startRunning()
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    private func previewFrontCamera() {
        if frontCameraDevice == nil {
            //TODO: Error handling
            print("Front camera unavailable")
        }
        else {
            beginCameraPreview(frontCameraDevice!)
            currentCameraPosition = AVCaptureDevicePosition.Front
        }
    }
    
    private func previewBackCamera() {
        if backCameraDevice == nil {
            //TODO: Error HAndling
            print("Back camera unavaible")
        }
        else {
            beginCameraPreview(backCameraDevice!)
            currentCameraPosition = AVCaptureDevicePosition.Back
        }
    }
    
    // MARK: - @IBActions
    @IBAction func captureButtonTapped(sender: UIButton) {
        if let videoConnection = captureOutput.connectionWithMediaType(AVMediaTypeVideo) {
            captureOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer: CMSampleBuffer!, error: NSError!) in
                self.tmpImageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("editQuestionSegue", sender: self)
                }
            })
        }
    }
    
    @IBAction func galeryButtonTapped(sender: UIButton) {
    }
    
    @IBAction func textOnlyButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("editQuestionSegue", sender: self)
    }
    
    @IBAction func switchCameraButtonTapped(sender: UIButton) {
        if currentCameraPosition == AVCaptureDevicePosition.Back {
            previewFrontCamera()
        }
        else if currentCameraPosition == AVCaptureDevicePosition.Front {
            previewBackCamera()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editQuestionSegue" {
            (segue.destinationViewController as! EditQuestionViewController).imageData = tmpImageData
            tmpImageData = nil
        }
    }
    

}
