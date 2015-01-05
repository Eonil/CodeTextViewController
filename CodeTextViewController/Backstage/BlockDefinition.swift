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
	
//	let	startMark:BlockMark
//	let	endMark:BlockMark
	
	init(startMark:String, endMark:String) {
		self.startMark	=	startMark
		self.endMark	=	endMark
		
//		self.startMark	=	BlockMark(string: startMark)
//		self.endMark	=	BlockMark(string: endMark)
	}
	
//	var	startMarkUnicodeScalarCount:UDistance {
//		get {
//			return	countElements(startMark.unicodeScalars)
//		}
//	}
//	var	endMarkUnicodeScalarCount:UDistance {
//		get {
//			return	countElements(startMark.unicodeScalars)
//		}
//	}
	
}




struct BlockMark {
	let	string:String
	let	utf16CountCache:Int

	init(string:String) {
		self.string				=	string
		self.utf16CountCache	=	string.utf16Count
	}
}