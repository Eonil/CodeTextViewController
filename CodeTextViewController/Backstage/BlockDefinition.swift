//
//  BlockDefinition.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/30.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation



///	You can identify source definition of detected block by reference comparison.
///	You can subclass block definition to provide extra informations.
class BlockDefinition {
	let	startMark:String
	let	endMark:String
	
	init(startMark:String, endMark:String) {
		self.startMark	=	startMark
		self.endMark	=	endMark
	}
}




struct BlockMark {
	let	string:String
	let	utf16CountCache:Int

	init(string:String) {
		self.string				=	string
		self.utf16CountCache	=	string.utf16Count
	}
}