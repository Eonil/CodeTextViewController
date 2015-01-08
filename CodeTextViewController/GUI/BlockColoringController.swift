//
//  BlockColoringController.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2015/01/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit


///	Developed to provide correct multi-line spanning comment block (by `/*...*/`) coloring.
///	The multiline block comment usually spans over very long range.
class BlockColoringController: ColoringController {
	weak var delegate:ColoringControllerDelegate?
	
	init(storage:CodeTextStorage) {
		self.storage	=	storage
		self.processor	=	BlockDetectionProcessor.syntaxHighlightingBlockDetectionControllerForRust(storage.text)
		self.mode		=	Mode.Idle
		self.reactor	=	ReactorOpt(owner: self)
	}

	var isProcessing:Bool {
		get {
			return	mode == Mode.Processing
		}
	}
	
	///	Starts incremental processing.
	///	This queues incremental work on main thread until it to be done.
	///	You need to call `stopProcessing` method to stop it.
	func startProcessingFromUTF16Location(location:UTF16Index) {
		assertMainThread()
		assert(mode == Mode.Idle)
		debugLog("startProcessingFromUTF16Location")
		
//		delegate?.processingWillStart()
		mode	=	Mode.Processing
		reactor!.invalidate()
		processor!.invalidateFromIndex(location)
		startingPoint			=	location
		latestCancellation		=	ProcessingContext()
		stepProcessing(latestCancellation!)
	}
	func stopProcessing() {
		assertMainThread()
		assert(mode == Mode.Processing)
		debugLog("stopProcessing")
		
		mode	=	Mode.Idle
		
		latestCancellation?.setCancel()
		latestCancellation	=	nil
		startingPoint		=	nil
//		delegate?.processingDidFinish()
		delegate?.coloringControllerDidInvalidateDisplay()
	}
	
	////
	
	private let storage:CodeTextStorage
	private let	processor:BlockDetectionProcessor<ReactorOpt>?
	private let	reactor:ReactorOpt?
	
	private var	mode:Mode
	private var	startingPoint:UTF16Index?
	private var	latestCancellation:ProcessingContext?
	
	
	private func stepProcessing(context:ProcessingContext) {
		assertMainThread()
		
		if context.cancel {
			return
		}
		
		let	STEPPING_COUNT_AT_ONCE	=	128
		for i in 0..<(STEPPING_COUNT_AT_ONCE) {
			if processor!.available {
				processor!.step(reactor!)
			} else {
				stopProcessing()				
				break
			}
		}
		
		context.iterationCount++
		if context.iterationCount < 128 {
			switch context.iterationCount {
			case 0, 2, 16, 64:
				delegate?.coloringControllerDidInvalidateDisplay()
				
			default:
				break
			}
		} else {
			if context.iterationCount % 128 == 0 {
				delegate?.coloringControllerDidInvalidateDisplay()
			}
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


private final class ReactorOpt: BlockDetectionProcessorReaction {
	unowned let	owner:BlockColoringController
	init(owner:BlockColoringController) {
		self.owner	=	owner
	}
	func invalidate() {
		noneRangeUnion	=	nil
	}
	func onBlockNone(range: UTF16Range) {
		uniteNoneRange(range)
		if range.endIndex == owner.storage.length {
			applyNoneColor()
		}
	}
	func onBlockIncomplete(range: UTF16Range) {
		applyNoneColor()
		
		////
		
		let	distFromStart	=	range.endIndex - owner.startingPoint!
		switch distFromStart {
		case 0, 1, 2, 4, 8, 16, 32, 64, 128, 1024, 8192, (128 * 1024), (1024*1024):
			applyIncompleteColorWithRange(range)
			break
			
		default:
			break
		}
		
		if range.endIndex == owner.storage.length {
			applyIncompleteColorWithRange(range)
		}
	}
	func onBlockComplete(range: UTF16Range) {
		applyCompleteColorWithRange(range)
	}
	
	////
	
	//
	//	Optimisations.
	//
	//	1.	Don't set attributes for each none counting. Instead, set it on starting incompletion.

	private var	noneRangeUnion	:	UTF16Range?
	
	private func uniteNoneRange(range:UTF16Range) {
		if noneRangeUnion == nil {
			noneRangeUnion	=	range
		} else {
			noneRangeUnion!.endIndex	=	range.endIndex
		}
	}
	private func applyNoneColor() {
		if let r = noneRangeUnion {
			owner.storage.text.removeAttribute(NSForegroundColorAttributeName, range: NSRange.fromUTF16Range(r))
			noneRangeUnion	=	nil
		}
	}
	private func applyIncompleteColorWithRange(range:UTF16Range) {
		owner.storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
		debugLog("incompletion coloring update \(range)")
	}
	private func applyCompleteColorWithRange(range:UTF16Range) {
		owner.storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
//		debugLog("completion coloring update \(range)")
	}
}

//private final class ReactorRef: BlockDetectionProcessorReaction {
//	unowned let	owner:BlockColoringController
//	init(owner:BlockColoringController) {
//		self.owner	=	owner
//	}
//	func onBlockNone(range: UTF16Range) {
//		owner.storage.text.removeAttribute(NSForegroundColorAttributeName, range: NSRange.fromUTF16Range(range))
//	}
//	func onBlockIncomplete(range: UTF16Range) {
//		owner.storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
//	}
//	func onBlockComplete(range: UTF16Range) {
//		owner.storage.text.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
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





///	Counts interation to perform operation at exponential number.
private struct ExponentialCounter {
	var isExponentPoint:Bool {
		get {
			return	num	== dst
		}
	}
	mutating func reset() {
		num	=	1
		dst	=	1
	}
	mutating func step() {
		precondition(num < Int.max)
		precondition(dst < Int.max)
		
		num	+=	1
		if num == dst {
			dst	*=	2
		}
	}
	
	private var	num	=	1
	private var	dst	=	1
}











