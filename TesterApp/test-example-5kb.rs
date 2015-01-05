// Copyright 2012-2014 The Rust Project Developers. See the COPYRIGHT
// file at the top-level directory of this distribution and at
// http://rust-lang.org/COPYRIGHT.
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

// The Rust abstract syntax tree.

pub use self::AsmDialect::*;
pub use self::AttrStyle::*;
pub use self::BindingMode::*;
pub use self::BinOp::*;
pub use self::BlockCheckMode::*;
pub use self::CaptureClause::*;
pub use self::Decl_::*;
pub use self::ExplicitSelf_::*;
pub use self::Expr_::*;
pub use self::FloatTy::*;
pub use self::FunctionRetTy::*;
pub use self::ForeignItem_::*;
pub use self::ImplItem::*;
pub use self::InlinedItem::*;
pub use self::IntTy::*;
pub use self::Item_::*;
pub use self::KleeneOp::*;
pub use self::Lit_::*;
pub use self::LitIntType::*;
pub use self::LocalSource::*;
pub use self::Mac_::*;
pub use self::MacStmtStyle::*;
pub use self::MetaItem_::*;
pub use self::Method_::*;
pub use self::Mutability::*;
pub use self::Onceness::*;
pub use self::Pat_::*;
pub use self::PathListItem_::*;
pub use self::PatWildKind::*;
pub use self::PrimTy::*;
pub use self::Sign::*;
pub use self::Stmt_::*;
pub use self::StrStyle::*;
pub use self::StructFieldKind::*;
pub use self::TokenTree::*;
pub use self::TraitItem::*;
pub use self::Ty_::*;
pub use self::TyParamBound::*;
pub use self::UintTy::*;
pub use self::UnboxedClosureKind::*;
pub use self::UnOp::*;
pub use self::UnsafeSource::*;
pub use self::VariantKind::*;
pub use self::ViewItem_::*;
pub use self::ViewPath_::*;
pub use self::Visibility::*;
pub use self::PathParameters::*;

use codemap::{Span, Spanned, DUMMY_SP, ExpnId};
use abi::Abi;
use ast_util;
use owned_slice::OwnedSlice;
use parse::token::{InternedString, str_to_ident};
use parse::token;
use ptr::P;

use std::fmt;
use std::fmt::Show;
use std::num::Int;
use std::rc::Rc;
use serialize::{Encodable, Decodable, Encoder, Decoder};

// FIXME #6993: in librustc, uses of "ident" should be replaced
// by just "Name".

/// An identifier contains a Name (index into the interner
/// table) and a SyntaxContext to track renaming and
/// macro expansion per Flatt et al., "Macros
/// That Work Together"
#[deriving(Clone, Copy, Hash, PartialOrd, Eq, Ord)]
pub struct Ident {
    pub name: Name,
    pub ctxt: SyntaxContext
}

impl Ident {
    /// Construct an identifier with the given name and an empty context:
    pub fn new(name: Name) -> Ident { Ident {name: name, ctxt: EMPTY_CTXT}}

    pub fn as_str<'a>(&'a self) -> &'a str {
        self.name.as_str()
    }

    pub fn encode_with_hygiene(&self) -> String {
        format!("\x00name_{},ctxt_{}\x00",
                self.name.uint(),
                self.ctxt)
    }
}

impl Show for Ident {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}#{}", self.name, self.ctxt)
    }
}

impl Show for Name {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let Name(nm) = *self;
        write!(f, "\"{}\"({})", token::get_name(*self).get(), nm)
    }
}

impl PartialEq for Ident {
    fn eq(&self, other: &Ident) -> bool {
        if self.ctxt == other.ctxt {
            self.name == other.name
        } else {
            // IF YOU SEE ONE OF THESE FAILS: it means that you're comparing
            // idents that have different contexts. You can't fix this without
            // knowing whether the comparison should be hygienic or non-hygienic.
            // if it should be non-hygienic (most things are), just compare the
            // 'name' fields of the idents. Or, even better, replace the idents
            // with Name's.
            //
            // On the other hand, if the comparison does need to be hygienic,
            // one example and its non-hygienic counterpart would be:
            //      syntax::parse::token::Token::mtwt_eq
            //      syntax::ext::tt::macro_parser::token_name_eq
            panic!("not allowed to compare these idents: {}, {}. \
                   Probably related to issue \\#6993", self, other);
        }
    }
    fn ne(&self, other: &Ident) -> bool {
        ! self.eq(other)
    }
}

/// A SyntaxContext represents a chain of macro-expandings
/// and renamings. Each macro expansion corresponds to
/// a fresh uint

// I'm representing this syntax context as an index into
// a table, in order to work around a compiler bug
// that's causing unreleased memory to cause core dumps
// and also perhaps to save some work in destructor checks.
// the special uint '0' will be used to indicate an empty
// syntax context.

// this uint is a reference to a table stored in thread-local
// storage.
pub type SyntaxContext = u32;
pub const EMPTY_CTXT : SyntaxContext = 0;
pub const ILLEGAL_CTXT : SyntaxContext = 1;

/// A name is a part of an identifier, representing a string or gensym. It's
/// the result of interning.
#[deriving(Eq, Ord, PartialEq, PartialOrd, Hash,
           RustcEncodable, RustcDecodable, Clone, Copy)]
pub struct Name(pub u32);
