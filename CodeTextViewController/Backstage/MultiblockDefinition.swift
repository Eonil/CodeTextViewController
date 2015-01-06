//
//  MultiblockDefinition.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/30.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


class MultiblockDefinition {
	///	Contiguous array is at least 20% faster by eliminating retain/release calls.
	///	I don't know why the elision doesn't work on default array type.
	let	blocks:ContiguousArray<BlockDefinition>
	init(blocks:[BlockDefinition]) {
		self.blocks	=	ContiguousArray(blocks)
	}
}
	