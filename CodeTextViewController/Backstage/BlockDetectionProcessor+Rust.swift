//
//  BlockDetectionController+Rust.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


extension BlockDetectionProcessor {
	class func syntaxHighlightingBlockDetectionControllerForRust(text:NSMutableAttributedString) -> BlockDetectionProcessor {
		let	def	=	MultiblockDefinition(blocks: [
			BlockDefinition(startMark: "/*", endMark: "*/"),
			BlockDefinition(startMark: "//", endMark: "\n"),
			BlockDefinition(startMark: "pub", endMark: ""),
			])
		let	s	=	MultiblockDetectionState.none(selection: text.string.utf16.startIndex..<text.string.utf16.startIndex)
		let	d	=	CodeData(target: text)
		let	sh	=	BlockDetectionProcessor(definition: def, state: s, data: d)
		return	sh
	}
}