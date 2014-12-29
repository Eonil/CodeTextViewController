//
//  CodeTextView.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/27.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit

class CodeTextView: NSTextView {
	
	@availability(*,unavailable)
	override init() {
		fatalError("Use `init(frame:,textContainer:)` initialiser.")
	}
	
	override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
		super.init(frame: frameRect, textContainer: container)
	}

	@availability(*,unavailable)
	required init?(coder: NSCoder) {
	    fatalError("Using in IB is unsupported. `init(coder:)` has not been implemented")
	}
}