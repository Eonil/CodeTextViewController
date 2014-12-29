//
//  AppDelegate.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/27.
//  Copyright (c) 2014 Eonil. All rights reserved.
//






//
/////	Performs incremental syntax-highlighting processing.
//private class Highlighter {
//	weak var owner:AppDelegate?
//	
//	init() {
//	}
//	func startProcessingFromLocation(location:Int) {
//		startTime	=	NSDate()
//		endTime		=	nil
//		
//		cont	=	true
//		stepSyntaxHighlighting()
//	}
//	func stopProcessing() {
//		cont	=	false
//	}
//	
//	////
//	
//	private var	startTime:NSDate?
//	private var	endTime:NSDate?
//	
//	private var	idx		=	0
//	private var cont	=	false
//	
//	private func stepSyntaxHighlighting() {
//		if idx < owner!.vc.codeTextViewController.codeTextStorage.length / 2 {
//			let	aa	=	[
//				NSForegroundColorAttributeName:	NSColor.grayColor(),
//			]
//			let	r	=	NSRange(location: idx * 2, length: 1)
////			owner!.vc.codeTextViewController.codeTextStorage.setAttributes(aa, range: r)
//			owner!.vc.codeTextViewController.codeTextView.layoutManager!.setTemporaryAttributes(aa, forCharacterRange: r)
//			idx++
//			
//			dispatch_async(dispatch_get_main_queue()) {
//				self.stepSyntaxHighlighting()
//			}
//		} else {
//			endTime	=	NSDate()
//			let	sec	=	endTime!.timeIntervalSinceDate(startTime!)
//			println("done, took \(sec) seconds.")
//		}
//	}
//}














//private struct IncrementalMultiDetector {
//	let	cursor:Cursor
//	let	definition:Definition
//	var	state:State
//	
//	mutating func step() -> URange? {
//		return	state.step(definition, cursor: cursor)
//	}
//	
//	struct Definition {
//		let	blockDefinitions:[IncrementalEnclosedBlockDetector.Definition]
//	}
//	struct State {
//		var	selection:DetectorSelection?
//		
//		struct DetectorSelection {
//			let	index:Int
//			var	state:IncrementalEnclosedBlockDetector.State
//		}
//		
//		mutating func step(definition:Definition, cursor:Cursor) -> URange? {
//			if let s = selection {
//				let	bdef	=	definition.blockDefinitions[s.index]
//				var	s2		=	s
//				s2.state.step(bdef, cursor: cursor)
//				selection	=	s2
//			} else {
//				cursor.position++
//				for i in 0..<definition.blockDefinitions.count {
//					let	bdef	=	definition.blockDefinitions[i]
//					let	s		=	IncrementalEnclosedBlockDetector.State()
//					if s.startingAt(bdef, cursor: cursor) {
//						selection	=	DetectorSelection(index: i, state: s)
//					}
//				}
//			}
//		}
//	}
//}
//
//
//
//
/////	Returns `nil` if a block has been found at this position.
/////
/////		| |B|B| |
/////		      ^
/////		      Discover at here.
/////
//private class IncrementalEnclosedBlockDetector {
//	struct Definition {
//		let startMarker:String
//		let	endMarker:String
//		
//		init(startMarker:String, endMarker:String) {
//			self.startMarker	=	startMarker
//			self.endMarker		=	endMarker
//			
//			self.startEC		=	countElements(startMarker)
//			self.endEC			=	countElements(endMarker)
//		}
//		
//		func startMarkerUnicodeScalarCount() -> UDistance {
//			return	startEC
//		}
//		func endMarkerUnicodeScalarCount() -> UDistance {
//			return	endEC
//		}
//		
//		////
//		
//		private let startEC:UDistance
//		private let endEC:UDistance
//	}
//	struct State {
//		init() {
//		}
//		var	selectionStartingIndex:UIndex?
//		var	startSelection:URange?
//		var	endSelection:URange?
//		var	blockDiscovery:URange?
//		
//		func startingAt(definition:Definition, cursor:Cursor) -> Bool {
//			return	String(cursor.target.unicodeScalars[cursor.position]).hasPrefix(definition.startMarker)
//		}
//		func endingAt(definition:Definition, cursor:Cursor) -> Bool {
//			return	String(cursor.target.unicodeScalars[cursor.position]).hasPrefix(definition.endMarker)
//		}
//		mutating func step(definition:Definition, cursor:Cursor) -> URange? {
//			cursor.position++
//			
//			if selectionStartingIndex == nil {
//				if startingAt(definition, cursor: cursor) {
//					selectionStartingIndex	=	cursor.position
//					advance(cursor.position, definition.startMarkerUnicodeScalarCount())
//					return	nil
//				}
//			} else {
//				if endingAt(definition, cursor: cursor) {
//					let	e	=	cursor.position
//					let	r	=	URange(start: selectionStartingIndex!, end: e)
//					advance(cursor.position, definition.endMarkerUnicodeScalarCount())
//					return	r
//				}
//			}
//			return	nil
//		}
//	}
//}












