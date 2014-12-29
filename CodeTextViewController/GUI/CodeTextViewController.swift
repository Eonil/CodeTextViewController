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
class CodeTextViewController: NSViewController {
	private lazy var	_codeTextStorage	=	NSTextStorage()
//	private lazy var	_codeTextStorage	=	CodeTextStorage()
}



///	MARK:	Concrete type accessors.
extension CodeTextViewController {
	var codeTextStorage:NSTextStorage {
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
	
}