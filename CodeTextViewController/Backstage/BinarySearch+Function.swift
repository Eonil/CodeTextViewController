////
////  BinarySearch+Function.swift
////  CodeTextViewController
////
////  Created by Hoon H. on 2015/01/08.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Swift
//
//func binarySearch<T:CollectionType where T.Index: RandomAccessIndexType>(collection:T, less:T.Generator.Element->Bool, equal:T.Generator.Element->Bool) -> T.Index? {
//	let	r	=	collection.startIndex..<collection.endIndex
//	return	binarySearch(collection, r, less, equal)
//}
//
//func binarySearch<T:CollectionType where T.Index: RandomAccessIndexType>(collection:T, scope:Range<T.Index>, less:T.Generator.Element->Bool, equal:T.Generator.Element->Bool) -> T.Index? {
//	return	RandomAccessibleSubcollection(collection: collection, selection: scope).binarySearch(less, equal)
//}
//
//
//private struct RandomAccessibleSubcollection<T:CollectionType where T.Index: RandomAccessIndexType> {
//	let	collection:T
//	let	selection:Range<T.Index>
//	
//	///	`collection`:	must be sorted in ascending order.
//	init(collection:T, selection:Range<T.Index>) {
//		self.collection	=	collection
//		self.selection	=	selection
//	}
//	
//	func binarySearch(value:T.Generator.Element) -> T.Index? {
//		let	dist	=	distance(selection.startIndex, selection.endIndex)
//		switch dist {
//		case 0:
//			return	nil
//			
//		case 1:
//			assert(selection.startIndex == selection.endIndex)
//			return	equal(collection[selection.startIndex]) ? selection.startIndex : nil
//			
//		default:
//			assert(dist >= 2)
//			assert(selection.startIndex < selection.endIndex)
//			let	halfdist	=	dist / 2
//			let	midpoint	=	selection.startIndex.advancedBy(halfdist)
//			assert(midpoint != selection.startIndex)
//			assert(midpoint != selection.endIndex)
//			let	midvalue	=	collection[midpoint]
//			let	sidedet		=	less(midvalue)	//	midvalue is less than (and not equal to) the target.
//			
//			let	subscope	=	sidedet ? midpoint..<selection.endIndex : selection.startIndex..<midpoint
//			let	solution	=	RandomAccessibleSubcollection(collection: collection, selection: subscope).binarySearch(less, equal)
//			
//			return	solution
//		}
//	}
//	
//	func binarySearch(less:T.Generator.Element->Bool, equal:T.Generator.Element->Bool) -> T.Index? {
//		let	dist	=	distance(selection.startIndex, selection.endIndex)
//		switch dist {
//		case 0:
//			return	nil
//			
//		case 1:
//			assert(selection.startIndex == selection.endIndex)
//			return	equal(collection[selection.startIndex]) ? selection.startIndex : nil
//			
//		default:
//			assert(dist >= 2)
//			assert(selection.startIndex < selection.endIndex)
//			let	halfdist	=	dist / 2
//			let	midpoint	=	selection.startIndex.advancedBy(halfdist)
//			assert(midpoint != selection.startIndex)
//			assert(midpoint != selection.endIndex)
//			let	midvalue	=	collection[midpoint]
//			let	sidedet		=	less(midvalue)	//	midvalue is less than (and not equal to) the target.
//			
//			let	subscope	=	sidedet ? midpoint..<selection.endIndex : selection.startIndex..<midpoint
//			let	solution	=	RandomAccessibleSubcollection(collection: collection, selection: subscope).binarySearch(less, equal)
//			
//			return	solution
//		}
//	}
//}
//
