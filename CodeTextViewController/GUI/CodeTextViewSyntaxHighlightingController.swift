//
//  CodeTextViewSyntaxHighlightingController.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/30.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import Cocoa






///	Performs incremental syntax-highlighting processing.
class CodeTextViewSyntaxHighlightingController: BlockDetectionProcessorDelegate {
	init(target:NSTextStorage, view:NSTextView) {
		self.text				=	target
		self.view				=	view
		
		self.latestTokenRange	=	UTF16Range(start: 0, end: 0)
		
		self.detectionProcessor				=	BlockDetectionProcessor<CodeTextViewSyntaxHighlightingController>.syntaxHighlightingBlockDetectionControllerForRust(target)
		self.detectionProcessor.delegate	=	self
	}
	func startProcessingFromLocation(location:Int) {
		assertMainThread()
		println("start at \(location)")
		
		startTime			=	NSDate()
		endTime				=	nil
		
		let	s1	=	(text.string as NSString).substringToIndex(location)
		detectionProcessor.invalidateFromIndex(s1.utf16.endIndex)
//		detectionProcessor.invalidateFromIndex(0)
		
		useInteractiveRecoloring	=	location > 0
		latestTokenRange			=	UTF16Range(start: location, end: location)
		
		currentContext	=	ProcessingContext()
		stepSyntaxHighlighting(currentContext!)
	}
	func stopProcessing() {
		assertMainThread()
		println("stop")

		currentContext!.cancel()
		currentContext				=	nil
		useInteractiveRecoloring	=	false
		latestTokenRange			=	nil
	}
	func onBlockNone(range: UTF16Range) {
		if useInteractiveRecoloring {
			if let r2 = latestTokenRange {
				if r2.endIndex < range.startIndex {
					let	r3	=	UTF16Range(start: r2.endIndex, end: range.startIndex)
					text.removeAttribute(NSForegroundColorAttributeName, range: NSRange.fromUTF16Range(r3))
//					println("remove attr: \(r3)")
				}
			}
		}
		
//		println("none: \(range)")
//		setDefaultTypingColor(NSColor.redColor())
	}
	func onBlockIncomplete(range: UTF16Range) {
//		println("incomplete: \(range)")
		if useInteractiveRecoloring {
			text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
		}
//		setDefaultTypingColor(NSColor.greenColor())
	}
	func onBlockComplete(range: UTF16Range) {
		if useInteractiveRecoloring {
			if let r2 = latestTokenRange {
				if r2.endIndex < range.startIndex {
					let	r3	=	UTF16Range(start: r2.endIndex, end: range.startIndex)
					text.removeAttribute(NSForegroundColorAttributeName, range: NSRange.fromUTF16Range(r3))
//					println("remove attr: \(r3)")
				}
			}
		}
		
//		println("complete: \(range)")
		text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
//		setDefaultTypingColor(NSColor.redColor())
		
		latestTokenRange	=	range
	}
	
	////
	
	private var	startTime:NSDate?
	private var	endTime:NSDate?
	
	private let	text:NSTextStorage
	private let	view:NSTextView
	private let	detectionProcessor:BlockDetectionProcessor<CodeTextViewSyntaxHighlightingController>
	
	private var	currentContext:ProcessingContext?
	private var	useInteractiveRecoloring:Bool	=	false
	private var	latestTokenRange:UTF16Range?
	
	
	
//	private func isRangeInVisibleRange(range:UTF16Range) -> Bool {
//		let	gr	=	view.layoutManager!.glyphRangeForBoundingRectWithoutAdditionalLayout(view.bounds, inTextContainer: view.textContainer!)
//		let	cr	=	view.layoutManager!.characterRangeForGlyphRange(gr, actualGlyphRange: nil).toRange()!
//		return	range.endIndex >= cr.startIndex || range.startIndex <= cr.endIndex
//	}
	private func stepSyntaxHighlighting(context:ProcessingContext) {
		assertMainThread()
		
		text.beginEditing()
		
		let	iterationCount	=	useInteractiveRecoloring ? 1 : 8192		//	Larger than 256 doesn't improve performance so much.
		for _ in 0..<iterationCount {
			if context.cancellation {
				break
			}
			if detectionProcessor.available == false {
				//	The text can be mutated between stepping calls.
				break
			}
			detectionProcessor.step()
		}
		
		if context.cancellation == false && detectionProcessor.available {
			dispatch_async(dispatch_get_main_queue()) {
				self.stepSyntaxHighlighting(context)
			}
		} else {
			endTime	=	NSDate()
			let	sec	=	endTime!.timeIntervalSinceDate(startTime!)
			println("done, took \(sec) seconds.")
		}
		
		text.endEditing()
	}
	private func setDefaultTypingColor(color:NSColor) {
		view.typingAttributes	=	[
			NSForegroundColorAttributeName:	color
		]
	}
}







final class ProcessingContext {
	init() {
	}
	var cancellation:Bool {
		get {
			return	flag
		}
	}
	func cancel() {
		flag	=	true
	}
	
	private var	flag	=	false
}




