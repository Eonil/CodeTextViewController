//
//  AppDelegate.swift
//  TesterApp
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextStorageDelegate {
	
	@IBOutlet weak var window: NSWindow!
	
	let	vc	=	CodeTextScrollViewController()
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		window.contentView	=	vc.scrollView
		
		let	p	=	NSBundle.mainBundle().pathForResource("test-example", ofType: "rs")!
		let	s	=	NSString(contentsOfFile: p, encoding: NSUTF8StringEncoding, error: nil)!
		vc.codeTextViewController.codeTextStorage.mutableString.appendString(s)
		
//		vc.codeTextViewController.codeTextStorage.beginEditing()
		vc.codeTextViewController.codeTextView.font	=	NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())
//		vc.codeTextViewController.codeTextStorage.endEditing()
		
		vc.codeTextViewController.codeTextStorage.delegate	=	self
		
		sh	=	Highlighter(target: vc.codeTextViewController.codeTextStorage)
		sh!.startProcessingFromLocation(0)
	}
	
	func textStorageWillProcessEditing(notification: NSNotification) {
		let	ched	=	(UInt(vc.codeTextViewController.codeTextStorage.editedMask) & NSTextStorageEditedOptions.Characters.rawValue) == NSTextStorageEditedOptions.Characters.rawValue
		if ched {
			let	r	=	vc.codeTextViewController.codeTextStorage.editedRange
			sh!.stopProcessing()
			sh!.startProcessingFromLocation(r.location)
			println("restart")
		}
	}
	
	private var	sh:Highlighter?
}





///	Performs incremental syntax-highlighting processing.
private class Highlighter: BlockDetectionControllerDelegate {
	init(target:NSTextStorage) {
		self.text				=	target
		self.continueStepping	=	false
		
		self.sh					=	BlockDetectionController.syntaxHighlightingBlockDetectionControllerForRust(target)
		self.sh.delegate		=	self
	}
	func startProcessingFromLocation(location:Int) {
		startTime			=	NSDate()
		endTime				=	nil
		continueStepping	=	true
		
		let	s1	=	(text.string as NSString).substringToIndex(location)
		sh.invalidateFromIndex(s1.unicodeScalars.endIndex)
		
		stepSyntaxHighlighting()
	}
	func stopProcessing() {
		continueStepping	=	false
	}
	func onBlockComplete(range: URange) {
		let	s1	=	String(text.string.unicodeScalars[text.string.unicodeScalars.startIndex..<range.startIndex])
		let	s2	=	String(text.string.unicodeScalars[range])
		let	r1	=	NSRange(location: s1.utf16Count, length: s2.utf16Count)
		text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: r1)
		println(String(text.string.unicodeScalars[range]))
	}
	
	////
	
	private var	startTime:NSDate?
	private var	endTime:NSDate?
	
	private let	text:NSTextStorage
	private let	sh:BlockDetectionController
	private var	continueStepping:Bool
	
	private func stepSyntaxHighlighting() {
		assert(sh.available)
		
		sh.step()
		if sh.available {
			dispatch_async(dispatch_get_main_queue()) {
				self.stepSyntaxHighlighting()
			}
		} else {
			endTime	=	NSDate()
			let	sec	=	endTime!.timeIntervalSinceDate(startTime!)
			println("done, took \(sec) seconds.")
		}
	}
}


