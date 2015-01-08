//
//  BlockColoringController.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2015/01/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit


protocol BlockColoringControllerDelegate: class {
	func syntaxHighlightingDidInvalidateDisplay()
//	func syntaxHighlightingDidInvalidateDisplay(mode:InvalidationMode)
}
class BlockColoringController {
//	enum InvalidationMode {
//	case Quickly
//	case Completely
//	}
	
	weak var delegate:BlockColoringControllerDelegate?
	
	init(storage:CodeTextStorage, layout:NSLayoutManager) {
		self.storage	=	storage
		self.layout		=	layout
		self.processor	=	BlockDetectionProcessor.syntaxHighlightingBlockDetectionControllerForRust(storage.text)
		self.mode		=	Mode.Idle
		self.reactor	=	Reactor(owner: self)
	}

	var isProcessing:Bool {
		get {
			return	mode == Mode.Processing
		}
	}
	
	///	Starts incremental processing.
	///	This queues incremental work on main thread until it to be done.
	///	You need to call `stopProcessing` method to stop it.
	func startProcessingFromUTF16Location(location:Int) {
		assertMainThread()
		assert(mode == Mode.Idle)
		debugLog("startProcessingFromUTF16Location")
		
//		delegate?.processingWillStart()
		mode	=	Mode.Processing
		processor!.invalidateFromIndex(location)
		latestCancellation			=	ProcessingContext()
		stepProcessing(latestCancellation!)
	}
	func stopProcessing() {
		assertMainThread()
		assert(mode == Mode.Processing)
		debugLog("stopProcessing")
		
		mode	=	Mode.Idle
		latestCancellation?.setCancel()
		latestCancellation			=	nil
//		delegate?.processingDidFinish()
		delegate?.syntaxHighlightingDidInvalidateDisplay()
	}
	
	
	////
	
	private let storage:CodeTextStorage
	private let	layout:NSLayoutManager
	private let	processor:BlockDetectionProcessor<Reactor>?
	private let	reactor:Reactor?
	
	private var	mode:Mode
	private var	latestCancellation:ProcessingContext?
	
	private func stepProcessing(context:ProcessingContext) {
		assertMainThread()
		
		if context.cancel {
			return
		}

		for i in 0..<(128) {
			if processor!.available {
				processor!.step(reactor!)
			} else {
				stopProcessing()				
				break
			}
		}
		
		context.iterationCount++
		switch context.iterationCount {
		case 128:
			context.iterationCount	=	0
			delegate?.syntaxHighlightingDidInvalidateDisplay()
			
		case 0, 2, 16, 64:
			delegate?.syntaxHighlightingDidInvalidateDisplay()
			debugLog("processor selection \(processor!.selection)")
		
		default:
			break
		}
		
		if mode == Mode.Processing {
			dispatchMain { [weak self] in
				if let me = self {
					me.stepProcessing(context)
				}
			}
		}
	}
	
	private enum Mode {
		case Idle
		case Processing
	}
}


private final class Reactor: BlockDetectionProcessorReaction {
	unowned let	owner:BlockColoringController
	init(owner:BlockColoringController) {
		self.owner	=	owner
	}
	func onBlockNone(range: UTF16Range) {
		owner.storage.text.removeAttribute(NSForegroundColorAttributeName, range: NSRange.fromUTF16Range(range))
	}
	func onBlockIncomplete(range: UTF16Range) {
		owner.storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
	}
	func onBlockComplete(range: UTF16Range) {
		owner.storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
	}
}



//private final class Reactor: BlockDetectionProcessorReaction {
//	unowned let	owner:BlockColoringController
//	init(owner:BlockColoringController) {
//		self.owner	=	owner
//	}
//	func onBlockNone(range: UTF16Range) {
//		owner.text.setFormat(FormatState.None, range: range)
////		owner.delegate?.syntaxHighlightingWantsDisplayUpdate(range)
//	}
//	func onBlockIncomplete(range: UTF16Range) {
//		owner.text.setFormat(FormatState.Text, range: range)
////		owner.delegate?.syntaxHighlightingWantsDisplayUpdate(range)
//	}
//	func onBlockComplete(range: UTF16Range) {
//		owner.text.setFormat(FormatState.Coment, range: range)
////		owner.delegate?.syntaxHighlightingWantsDisplayUpdate(range)
//	}
//}



//private final class Reactor: BlockDetectionProcessorReaction {
//	unowned let	owner:BlockColoringController
//	init(owner:BlockColoringController) {
//		self.owner	=	owner
//	}
//	func onBlockNone(range: UTF16Range) {
////		owner.layout.addTemporaryAttribute(NSForegroundColorAttributeName, value: NSColor.textColor(), forCharacterRange: NSRange.fromUTF16Range(range))
//		owner.layout.removeTemporaryAttribute(NSForegroundColorAttributeName, forCharacterRange: NSRange.fromUTF16Range(range))
//		owner.delegate?.syntaxHighlightingWantsDisplayUpdate(range)
//	}
//	func onBlockIncomplete(range: UTF16Range) {
//		owner.layout.addTemporaryAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), forCharacterRange: NSRange.fromUTF16Range(range))
//		owner.delegate?.syntaxHighlightingWantsDisplayUpdate(range)
//	}
//	func onBlockComplete(range: UTF16Range) {
//		owner.layout.addTemporaryAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), forCharacterRange: NSRange.fromUTF16Range(range))
//		owner.delegate?.syntaxHighlightingWantsDisplayUpdate(range)
//	}
//}
//private final class Reactor: BlockDetectionProcessorReaction {
//	unowned let	owner:BlockColoringController
//	init(owner:BlockColoringController) {
//		self.owner	=	owner
//	}
//	func onBlockNone(range: UTF16Range) {
//		owner.target.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: NSRange.fromUTF16Range(range))
//		owner.target.addAttribute(NSBackgroundColorAttributeName, value: NSColor.grayColor(), range: NSRange.fromUTF16Range(range))
//	}
//	func onBlockIncomplete(range: UTF16Range) {
//		owner.target.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: NSRange.fromUTF16Range(range))
//		owner.target.addAttribute(NSBackgroundColorAttributeName, value: NSColor.blackColor(), range: NSRange.fromUTF16Range(range))
//	}
//	func onBlockComplete(range: UTF16Range) {
//		owner.target.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
//		owner.target.addAttribute(NSBackgroundColorAttributeName, value: NSColor.yellowColor(), range: NSRange.fromUTF16Range(range))
//	}
//}




private class ProcessingContext {
	var	iterationCount	=	0
	
	var cancel:Bool {
		get {
			return	cancellation
		}
	}
	func setCancel() {
		cancellation	=	true
		
		let	ending	=	NSDate()
		let	delta	=	ending.timeIntervalSinceDate(starting)
		debugLog("processing time until cancel: \(delta) sec.")
	}
	
	private let	starting		=	NSDate()
	private var	cancellation	=	false
}










