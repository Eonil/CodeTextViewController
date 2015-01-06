//
//  SyntaxHighlightingController.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2015/01/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit


protocol SyntaxHighlightingControllerDelegate: class {
	func syntaxHighlightingWantsDisplayUpdate()
	func processingWillStart()
	func processingDidFinish()
}
class SyntaxHighlightingController: SyntaxHighlightingProtocol {
	weak var delegate:SyntaxHighlightingControllerDelegate?
	
	init(target:NSMutableAttributedString) {
		self.target		=	target
		self.processor	=	BlockDetectionProcessor.syntaxHighlightingBlockDetectionControllerForRust(target)
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
		
		delegate?.processingWillStart()
		mode	=	Mode.Processing
		processor!.invalidateFromIndex(location)
		latestCancellation			=	CancellationContext()
		stepProcessing(latestCancellation!)
	}
	func stopProcessing() {
		assertMainThread()
		assert(mode == Mode.Processing)
		println("Done.")
		
		mode	=	Mode.Idle
		latestCancellation?.flag	=	true
		latestCancellation			=	nil
		delegate?.processingDidFinish()
		delegate?.syntaxHighlightingWantsDisplayUpdate()
	}
	
	
	////
	
	private let	target:NSMutableAttributedString
	private let	processor:BlockDetectionProcessor<Reactor>?
	private let	reactor:Reactor?
	
	private var	mode:Mode {
		didSet {
			println(mode.hashValue)
			if mode == .Idle {
				
			}
		}
	}
	private var	latestCancellation:CancellationContext?
	
	private func stepProcessing(cancel:CancellationContext) {
		assertMainThread()
		
		if cancel.flag {
			return
		}

		for i in 0..<128 {
			if processor!.available {
				processor!.step(reactor!)
			} else {
				stopProcessing()				
				break
			}
		}
		delegate?.syntaxHighlightingWantsDisplayUpdate()
		
		if mode == Mode.Processing {
			dispatchMain { [weak self] in
				if let me = self {
					me.stepProcessing(cancel)
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
	unowned let	owner:SyntaxHighlightingController
	init(owner:SyntaxHighlightingController) {
		self.owner	=	owner
	}
	func onBlockNone(range: UTF16Range) {
		owner.target.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: NSRange.fromUTF16Range(range))
		owner.target.addAttribute(NSBackgroundColorAttributeName, value: NSColor.grayColor(), range: NSRange.fromUTF16Range(range))
	}
	func onBlockIncomplete(range: UTF16Range) {
		owner.target.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: NSRange.fromUTF16Range(range))
		owner.target.addAttribute(NSBackgroundColorAttributeName, value: NSColor.blackColor(), range: NSRange.fromUTF16Range(range))
	}
	func onBlockComplete(range: UTF16Range) {
		owner.target.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange.fromUTF16Range(range))
		owner.target.addAttribute(NSBackgroundColorAttributeName, value: NSColor.yellowColor(), range: NSRange.fromUTF16Range(range))
	}
}




private class CancellationContext {
	var	flag	=	false
}










