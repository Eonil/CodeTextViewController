//
//  AppDelegate.swift
//  MinimalExample
//
//  Created by Hoon H. on 2015/01/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextStorageDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
	let	vc	=	CodeTextScrollViewController()
	
//	var	sh	:	BlockColoringController?
//	
//	func coloringControllerDidInvalidateDisplay() {
//		vc.codeTextViewController.codeTextView.needsDisplay	=	true
//	}
//	func codeTextStorageShouldProcessCharacterEditing(sender: CodeTextStorage, range: NSRange) {
//		if sh == nil {
//			sh	=	BlockColoringController(storage: sender, layout: vc.codeTextViewController.codeTextView.layoutManager!)
//			sh!.delegate	=	self
//		}
//		if sh!.isProcessing {
//			sh!.stopProcessing()
//		}
//		sh!.startProcessingFromUTF16Location(range.location)
//	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		window.contentView	=	vc.scrollView
		
		vc.codeTextViewController.codeTextView.font										=	NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())
//		vc.codeTextViewController.codeTextStorage.codeTextStorageDelegate				=	self
		vc.codeTextViewController.codeTextView.layoutManager!.backgroundLayoutEnabled	=	true
		
		///
		
		vc.codeTextViewController.coloringController	=	BlockColoringController(storage: vc.codeTextViewController.codeTextStorage, layout: vc.codeTextViewController.codeTextView.layoutManager!)
		
//		
//		
//		
//		self.codeTextStorageShouldProcessCharacterEditing(vc.codeTextViewController.codeTextStorage, range: NSRange(location: 0, length: 0))
	}
}








