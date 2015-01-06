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
}







///	MARK:	Essential Overridings
extension CodeTextStorage {
	override var string:String {
		get {
			return	s.string
		}
	}
	
	override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
		return	s.attributesAtIndex(location, effectiveRange: range)
	}
	
	override func replaceCharactersInRange(range: NSRange, withString str: String) {
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
			codeTextStorageDelegate?.codeTextStorageShouldProcessCharacterEditing(self, range: r)
		}
		super.processEditing()
	}

}



//
//	Setting attributes without triggering layout will not work. It results broken rendering.
//	Seems to be an optimisation.
//
















/////	Ignores all per-character styling attributes.
//class CodeTextStorage: NSTextStorage {	
//	private var	s	=	""
//	private var	aa	=	[] as [UInt8]
//	private var	f	=	NSFont(name: "Menlo", size: NSFont.smallSystemFontSize())!
//}
//
//
//
//
//
//
//
/////	MARK:	Essential Overridings
//extension CodeTextStorage {
//	override var string:String {
//		get {
//			return	s
//		}
//	}
//	
//	override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
//		
//		//
//		//	`range` is an output parameter! You must set it to a proper value.
//		//
//		if range != nil {
//			range.memory	=	NSRange(location: 0, length: self.length)
//		}
//		
//		return	[NSFontAttributeName: f]
//	}
//
//	override func replaceCharactersInRange(range: NSRange, withString str: String) {
//		s	=	(s as NSString).stringByReplacingCharactersInRange(range, withString: str)
//		
//		//
//		//	Changes must be notified!
//		//
//		let	d	=	(str as NSString).length - range.length
//		self.edited(Int(NSTextStorageEditedOptions.Characters.rawValue), range: range, changeInLength: d)	//	`d` must be delta. Keep the sign.
//	}
//	
//	override func setAttributes(attrs: [NSObject : AnyObject]?, range: NSRange) {
//		
//		//
//		//	Changes must be notified!
//		//
//		self.edited(Int(NSTextStorageEditedOptions.Attributes.rawValue), range: range, changeInLength: 0)
//	}
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
/////	MARK:	Extra Overridings
//extension CodeTextStorage {
////	@availability(*,unavailable)
//	override var font:NSFont? {
//		get {
//			fatalError("Unsupported inefficient method.")
//		}
//		set(v) {
//			fatalError("Unsupported inefficient method.")
//		}
//	}
//}














