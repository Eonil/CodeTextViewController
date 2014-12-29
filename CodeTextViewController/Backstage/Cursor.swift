//
//  Cursor.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/29.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


class Cursor {
	let	target:String
	var	position:UIndex
	
	init(target:String, position:UIndex) {
		self.target		=	target
		self.position	=	position
	}
	
	var restString:String {
		return	String(target.unicodeScalars[position..<target.unicodeScalars.endIndex])
	}
}












extension UnitTest {
	static func testCursor() {
		let	a	=	"ABC"
		let	p	=	a.unicodeScalars.startIndex
		let	c	=	Cursor(target: a, position: p)
		assert(c.restString == "ABC")
		
		c.position++
		assert(c.restString == "BC")
		
		c.position++
		assert(c.restString == "C")
		
		c.position++
		assert(c.restString == "")
	}
}