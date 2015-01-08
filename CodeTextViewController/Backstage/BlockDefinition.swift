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
	let	userData:AnyObject?
	
	convenience init(startMark:String, endMark:String) {
		self.init(startMark: startMark, endMark: endMark, userData: nil)
	}
	
	init(startMark:String, endMark:String, userData:AnyObject?) {
		self.startMark	=	startMark
		self.endMark	=	endMark
		self.userData	=	userData
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