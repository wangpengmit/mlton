(* Copyright (C) 1999-2002 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-1999 NEC Research Institute.
 *
 * MLton is released under the GNU General Public License (GPL).
 * Please see the file MLton-LICENSE for license information.
 *)

structure UniqueString:
   sig
      val unique: string -> string
   end =
   struct
      val set: {counter: Counter.t,
		hash: word,
		original: string} HashSet.t =
	 HashSet.new {hash = #hash}

      fun unique (s: string): string =
	 let
	    val hash = String.hash s
	    val {counter, ...} =
	       HashSet.lookupOrInsert
	       (set, hash, fn {original, ...} => s = original,
		fn () => {counter = Counter.new 0,
			  hash = hash,
			  original = s})
	 in
	    concat [s, "_", Int.toString (Counter.next counter)]
	 end
   end

functor Id (S: ID_STRUCTS): ID =
struct

open S

structure Plist = PropertyList

datatype t = T of {hash: word,
		   originalName: string,
		   printName: string option ref,
		   plist: Plist.t}

local
   fun make f (T r) = f r
in
   val hash = make #hash
   val originalName = make #originalName
   val plist = make #plist
   val printName = make #printName
end

fun clearPrintName x = printName x := NONE
   
fun setPrintName (x, s) = printName x := SOME s

val printNameAlphaNumeric: bool ref = ref false
   
fun toString (T {printName, originalName, ...}) =
   case !printName of
      NONE =>
	 let
	    val s =
	       if not (!printNameAlphaNumeric)
		  orelse String.forall (originalName, fn c =>
					Char.isAlphaNum c orelse c = #"_")
		  then originalName
	       else
		  String.translate
		  (originalName,
		   fn #"!" => "Bang"
		    | #"#" => "Hash"
		    | #"$" => "Dollar"
		    | #"%" => "Percent"
		    | #"&" => "Ampersand"
		    | #"'" => "P"
		    | #"*" => "Star"
		    | #"+" => "Plus"
		    | #"-" => "Minus"
		    | #"." => "D"
		    | #"/" => "Divide"
		    | #":" => "Colon"
		    | #"<" => "Lt"
		    | #"=" => "Eq"
		    | #">" => "Gt"
		    | #"?" => "Ques"
		    | #"@" => "At"
		    | #"\\" => "Slash"
		    | #"^" => "Caret"
		    | #"`" => "Quote"
		    | #"|" => "Pipe"
		    | #"~" => "Tilde"
		    | c => str c)
	    val s = UniqueString.unique s
	    val _ = printName := SOME s
	 in
	    s
	 end
    | SOME s => s

val layout = String.layout o toString
   
fun equals (id, id') = Plist.equals (plist id, plist id')

local
   fun make (originalName, printName) =
      T {hash = Random.word (),
	 originalName = originalName,
	 printName = ref printName,
	 plist = Plist.new ()}
in
   fun fromString s = make (s, SOME s)
   fun newString s = make (s, NONE)
end

val new = newString o originalName

fun newNoname () = newString noname

val bogus = newString "bogus"

val clear = Plist.clear o plist
   
end
