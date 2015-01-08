//
//  CodeTextViewController.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/27.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit


///
///	This owns text-storage, and the text-storage owns layout-manager, text-container and text-view.
///	This also owns the text-view.
///
class CodeTextViewController: NSViewController, CodeTextStorageDelegate, ColoringControllerDelegate {
	var coloringController:ColoringController? {
		willSet {
			assertMainThread()
			if var cc = coloringController {
				if cc.isProcessing {
					cc.stopProcessing()
				}
			}
		}
		didSet {
			assertMainThread()
			if var cc = coloringController {
				cc.delegate	=	self
				if cc.isProcessing {
					cc.stopProcessing()
				}
				cc.startProcessingFromUTF16Location(0)
			}
		}
	}
	
	///
	
	private lazy var	_codeTextStorage	=	CodeTextStorage()
}













///	MARK:
///	MARK:	Delegate Implementations
extension CodeTextViewController {
	func coloringControllerDidInvalidateDisplay() {
		assertMainThread()
		debugLog("coloringControllerDidInvalidateDisplay")
		
		//	Should work, but fails. Nonsense, but happens.
		//
//		let	lm	=	vc.codeTextViewController.codeTextView.layoutManager!
//		let	b1	=	vc.codeTextViewController.codeTextView.bounds
//		let	r0	=	0..<vc.codeTextViewController.codeTextStorage.length
//		let	r1	=	lm.glyphRangeForBoundingRectWithoutAdditionalLayout(b1, inTextContainer: vc.codeTextViewController.codeTextView.textContainer!)
//		let	r1b	=	lm.characterRangeForGlyphRange(r1, actualGlyphRange: nil).toRange()!
//		let	r2	=	intersect(r0, r1b)
//		if let r3 = r2 {
//			debugLog(NSRange.fromUTF16Range(r3))
//			vc.codeTextViewController.codeTextView.layoutManager!.invalidateDisplayForCharacterRange(NSRange.fromUTF16Range(r3))
//		}
		
		//	Safe fallback.
		codeTextView.needsDisplay	=	true
	}
	func codeTextStorageShouldProcessCharacterEditing(sender: CodeTextStorage, range: NSRange) {
		assertMainThread()
		debugLog("codeTextStorageShouldProcessCharacterEditing")
		
		if let cc = coloringController {
			if cc.isProcessing {
				cc.stopProcessing()
			}
			cc.startProcessingFromUTF16Location(range.location)
		}
	}
}



///	MARK:	Concrete type accessors.
extension CodeTextViewController {
	var codeTextStorage:CodeTextStorage {
		get {
			return	_codeTextStorage
		}
	}
	var codeTextView:CodeTextView {
		get {
			return	super.view as CodeTextView
		}
	}
}

///	MARK:	Overridings
extension CodeTextViewController {
//	@availability(*,unavailable)
	override var view:NSView {
		get {
			return	super.view
		}
		set(v) {
			precondition(v is CodeTextView, "This controller accepts only `CodeTextView` class.")
			super.view	=	v
		}
	}
	
	@availability(*,unavailable)
	override func loadView() {		
		let	m	=	NSLayoutManager()
		codeTextStorage.addLayoutManager(m)
		
		let	c	=	NSTextContainer()
		m.addTextContainer(c)
		
		let	v	=	CodeTextView(frame: CGRect.zeroRect, textContainer: c)
		super.view	=	v
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		codeTextStorage.editingDelegate	=	self
	}
	
}