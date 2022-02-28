//
//  InvitationCodeScanViewController.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import AVFoundation
import UIKit

protocol InvitationCodeScanViewControllerDelegate: AnyObject {
    func invitationCodeCaptured(invitationId: String)
}

class InvitationCodeScanViewController: UIViewController {
    
    weak var delegate: InvitationCodeScanViewControllerDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var captureSession: AVCaptureSession = .init()
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        configureCaptureSession()
        configureLayers()
        
        captureSession.startRunning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Configuration
    
    private func configureLayers() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    private func configureCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
    }
}

extension InvitationCodeScanViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            capture(code: stringValue)
        }
    }
    
    private func capture(code: String) {
        self.navigationController?.popViewController(animated: false)
        delegate?.invitationCodeCaptured(invitationId: code)
    }
}
