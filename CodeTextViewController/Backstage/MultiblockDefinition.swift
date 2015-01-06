//
//  MultiblockDefinition.swift
//  CodeTextViewController
//
//  Created by Hoon H. on 2014/12/30.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


class MultiblockDefinition {
	let	blocks:[BlockDefinition]
	let	blockUnownedReferences:[Unowned1<BlockDefinition>]	=	[]
	init(blocks:[BlockDefinition]) {
		self.blocks	=	blocks
		
		for b in blocks {
			blockUnownedReferences.append(Unowned1(b))
		}
	}
		
		
//	let	blocks:ContiguousArray<BlockDefinition>
//	init(blocks:[BlockDefinition]) {
//		self.blocks	=	ContiguousArray<BlockDefinition>(blocks)
//		
//		unsafeArray	=	UnsafeMutablePointer<BlockDefinition>.alloc(blocks.count)
//
//		var	a1	=	unsafeArray
//		for b in blocks {
//			a1.put(b)
//			a1	=	a1.successor()
//		}
//	}
//	deinit {
//		unsafeArray.dealloc(blocks.count)
//	}
//	
//	func unownedBlockAtIndex(index:Int) -> Unowned1<BlockDefinition> {
//		return	unsafeArray.advancedBy(index).memory
//	}
//	
//	////
//	
//	private var	unsafeArray:UnsafeMutablePointer<BlockDefinition>
}
	