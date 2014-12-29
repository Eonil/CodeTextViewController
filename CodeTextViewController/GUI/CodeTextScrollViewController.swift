//
//  CodeTextScrollViewController.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/27.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import Cocoa






class CodeTextScrollViewController: NSViewController {
	private lazy var	_codeTextViewController	=	CodeTextViewController()
}



extension CodeTextScrollViewController {
	var codeTextViewController:CodeTextViewController {
		get {
			return	_codeTextViewController
		}
	}
	var scrollView:NSScrollView {
		get {
			return	super.view as NSScrollView
		}
	}
//	@availability(*,unavailable)
	override var view:NSView {
		get {
			return	super.view
		}
		set(v) {
			fatalError("You cannot change `view` of this object.")
//			precondition(v is NSScrollView, "This object accepts only `NSScrollView`.")
//			super.view	=	v
		}
	}
	override func loadView() {
		super.view	=	NSScrollView()
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.documentView					=	_codeTextViewController.codeTextView
		scrollView.hasHorizontalScroller		=	true
		scrollView.hasVerticalScroller			=	true
		
		let	v									=	_codeTextViewController.codeTextView
		v.verticallyResizable					=	true
		v.horizontallyResizable					=	true
		v.textContainer!.containerSize			=	CGSize(width: CGFloat.max, height: CGFloat.max)
		v.textContainer!.widthTracksTextView	=	false
		v.textContainer!.heightTracksTextView	=	false
		v.minSize								=	CGSize.zeroSize
		v.maxSize								=	CGSize(width: CGFloat.max, height: CGFloat.max)
	}
}