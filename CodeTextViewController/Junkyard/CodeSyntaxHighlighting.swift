////
////  CodeSyntaxHighlighting.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2014/12/27.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//import Cocoa
//
/////	Background syntax highlighting controller.
//class CodeSyntaxHighlighting {
//	weak var delegate:CodeSyntaxHighlightingDelegate?
//	
//	init(processor:CodeSyntaxHighlightingProcessor) {
//		self.proc	=	processor
//		self.proc.setText(self.text)
//	}
//	
//	///	Queues replacement of string.
//	///	This invalidates arbitrary range of text formatting by the syntax logic.
//	///	Invalidated text will be formatted and notified via delegate eventually.
//	func queueReplacement(r:NSRange, string:String) {
//		assertMainThread()
//		
//		cancel.compareAndSwapBarrier(oldValue: true, newValue: false)
//		
//		weak var	o	=	self
//		dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
//			o!.replace(r, s: string)
//		}
//	}
//	
//	///	Clears queue.
//	///	On-going syntax highlight stepping will not stop.
//	///	After cancellation, formatting state will be remain incomplete.
//	///	Queue a new replacement to resume the formatting.
//	func cancelAll() {
//		assertMainThread()
//		
//		cancel.compareAndSwapBarrier(oldValue: false, newValue: true)
//	}
//	
//	////
//	
//	private let	cancel	=	AtomicBoolSlot(false)
//	
//	private let	text	=	NSMutableAttributedString()
//	private let	proc	:	CodeSyntaxHighlightingProcessor
//	
//	private func replace(r:NSRange, s:String) {
//		assertNonMainThread()
//		
//		text.replaceCharactersInRange(r, withString: s)
//		proc.invalidateRange(r)
//		while cancel.value == false && proc.done() == false {
//			proc.step()
//		}
//		
//		weak var	o	=	self
//		dispatch_async(dispatch_get_main_queue()) {
//			o!.notify()
//		}
//		
//	}
//	private func notify() {
//		assertMainThread()
//		
//		self.delegate?.codeBGSHControllerDidFinishFormattingInRange(<#range: NSRange#>, text: <#NSAttributedString#>)
//	}
//}
//
//protocol CodeSyntaxHighlightingDelegate: class {
//	///	Notifies formatting for the range has been completed.
//	func codeBGSHControllerDidFinishFormattingInRange(range:NSRange, text:NSAttributedString)
//}
//
//
//
//
//
//
//
//
//
//
//
/////	Intended to be subclassed to provide proper logic.
//class CodeSyntaxHighlightingProcessor {
//	///	This will be accessible after you pass processor object to a `CodeBGSHController`.
//	var text:NSMutableAttributedString {
//		get {
//			return	_text!
//		}
//	}
//	
//	///	Return `true` when the text is fullt formatted.
//	///	Calling `invalidateRange(range:)` may effectively make this to return `false`.
//	///	This will be called only after the text has been set.
//	func done() -> Bool {
//		return	true
//	}
//	
//	///	This will be called only after the text has been set.
//	///	This will be called continually until you return `true` on `done()`.
//	///	Once set text object will never be changed.
//	func step() {
//	}
//	
//	///	Invalidates formattings in range.
//	///	You must reformat the range at next stepping.
//	///	This will be called only after the text has been set.
//	func invalidateRange(range:NSRange) {
//	}
//	
//	private var	_text:NSMutableAttributedString?
//	private func setText(t:NSMutableAttributedString?) {
//		_text	=	t
//	}
//}
//extension CodeSyntaxHighlightingProcessor {
//	final func reset() {
//		invalidateRange(NSRange(location: 0, length: text.length))
//	}
//}
//
//
