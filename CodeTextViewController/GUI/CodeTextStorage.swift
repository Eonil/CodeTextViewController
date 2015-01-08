//
//  CodeTextStorage.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/27.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit




protocol CodeTextStorageDelegate: NSTextStorageDelegate {
	func codeTextStorageShouldProcessCharacterEditing(sender:CodeTextStorage, range:NSRange)
}

///	Ignores all per-character styling attributes.
class CodeTextStorage: NSTextStorage {
	
	weak var codeTextStorageDelegate:CodeTextStorageDelegate?
	
	///	Provides internal text storage.
	///	Editing this object will change the text attributes but will not cause any layout.
	var text:NSMutableAttributedString {
		get {
			return	s
		}
	}
	
	///	Must be `NSTextStorage` class. No `NSMutableAttributedString`.
	///	`NSMutableAttributedString` class doesn't seem to be optimised for random positional editing
	///	and makes editing slow down. `NSTextStorage` doesn't have such issue.
	private let	s	=	NSTextStorage()
//	private let	s	=	NSMutableAttributedString()
	
	private var	aa	=	[] as [FormatState]
	
	func setFormat(format:FormatState, range:UTF16Range) {
		for i in range {
			aa[i]	=	format
		}
	}
}

enum FormatState {
case None
case Text
case Coment
}







///	MARK:	Essential Overridings
extension CodeTextStorage {
	override var string:String {
		get {
			return	s.string
		}
	}
	
	override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
		//	Nonsense, but happens.
		if location >= s.length {
			return	[:]
		}
		
		return	s.attributesAtIndex(location, effectiveRange: range)
	}
	
	override func replaceCharactersInRange(range: NSRange, withString str: String) {
		aa.replaceRange(range.toRange()!, with: Array<FormatState>(count: str.utf16Count, repeatedValue: FormatState.None))
		s.replaceCharactersInRange(range, withString: str)
		let	d	=	(str as NSString).length - range.length
		self.edited(Int(NSTextStorageEditedOptions.Characters.rawValue), range: range, changeInLength: d)	//	`d` must be delta. Keep the sign.
	}
	
	override func setAttributes(attrs: [NSObject : AnyObject]?, range: NSRange) {
		s.setAttributes(attrs, range: range)
		self.edited(Int(NSTextStorageEditedOptions.Attributes.rawValue), range: range, changeInLength: 0)
	}
	
	
	
	override func processEditing() {
		let	m	=	self.editedMask
		if (UInt(m) & NSTextStorageEditedOptions.Characters.rawValue) == NSTextStorageEditedOptions.Characters.rawValue {
			let	r	=	self.editedRange
			debugLog(r)
			codeTextStorageDelegate?.codeTextStorageShouldProcessCharacterEditing(self, range: r)
		}
		super.processEditing()
		debugLog("processEditing")
	}

}



extension CodeTextStorage {
//	override var fixesAttributesLazily:Bool {
//		get {
//			return	true
//		}
//	}
}











