//
//  BlockDetectionController+Rust.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


extension BlockDetectionController {
	class func syntaxHighlightingBlockDetectionControllerForRust(text:NSMutableAttributedString) -> BlockDetectionController {
		let	def	=	MultiblockDetection.Definition(blocks: [
			BlockDetection.Definition(startMark: "/*", endMark: "*/"),
			BlockDetection.Definition(startMark: "//", endMark: "\n"),
			])
		let	s	=	MultiblockDetection.State.None(position: text.string.unicodeScalars.startIndex)
		let	d	=	CodeData(target: text)
		let	sh	=	BlockDetectionController(definition: def, state: s, data: d)
		return	sh
	}
}