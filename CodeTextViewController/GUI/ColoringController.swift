//
//  ColoringController.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2015/01/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

protocol ColoringController {
	var isProcessing:Bool { get }
	func startProcessingFromUTF16Location(location:UTF16Index)
	func stopProcessing()
	
	weak var delegate:ColoringControllerDelegate? { get set }
}

protocol ColoringControllerDelegate: class {
	func coloringControllerDidInvalidateDisplay()
}