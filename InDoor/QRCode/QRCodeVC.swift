//
//  QRcodeVC.swift
//  InDoorVs2
//
//  Created by Sap on 18.10.2023.
//

import UIKit
import AVFoundation

class QRcodeVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private let imageFormForQrCode: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = ImageConstants.Image.imageFormForQrCode
        image.clipsToBounds = true
        return image
    }()
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0xD9D9D9)
        
        view.addSubview(imageFormForQrCode)
        setConstrains()
        setupTabbarItem()
        setupQRCodeScanner()
    }
    
    private func setConstrains() {
        NSLayoutConstraint.activate([
            imageFormForQrCode.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            imageFormForQrCode.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageFormForQrCode.widthAnchor.constraint(equalToConstant: 346), // Adjust the size as needed
            imageFormForQrCode.heightAnchor.constraint(equalToConstant: 335), // Adjust the size as needed
        ])
    }
    
    private func setupTabbarItem() {
        tabBarItem = UITabBarItem(
            title: "",
            image: ImageConstants.Image.QRCode.imageTabBarQRcode,
            tag: 4
        )
    }

    private func setupQRCodeScanner() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: .background)) // Запуск на фоновом потоке
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            DispatchQueue.main.async {
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = self.imageFormForQrCode.bounds.insetBy(dx: 4, dy: 4) // Уменьшение размера с отступами
                self.videoPreviewLayer?.cornerRadius = 35
                self.imageFormForQrCode.layer.addSublayer(self.videoPreviewLayer!)
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                // Запуск сессии захвата в фоновом потоке
                captureSession?.startRunning()
            }

        } catch {
            print(error)
            return
        }
    }

    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            print("No QR code is detected")
            return
        }
        
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
            if metadataObj.type == AVMetadataObject.ObjectType.qr {
                if let qrCode = metadataObj.stringValue {
                    if let url = URL(string: qrCode) {
                        UIApplication.shared.open(url)
                    } else {
                        print("Error open link")
                    }
                }
            }
        }
    }
}
