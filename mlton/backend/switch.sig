(* Copyright (C) 2002-2004 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 *
 * MLton is released under the GNU General Public License (GPL).
 * Please see the file MLton-LICENSE for license information.
 *)
type int = Int.t
   
signature SWITCH_STRUCTS =
   sig
      structure Label: LABEL
      structure Type: REP_TYPE
      structure WordSize: WORD_SIZE
      structure WordX: WORD_X
      sharing WordX = Type.WordX

      structure Use: sig
			type t

			val layout: t -> Layout.t
			val ty: t -> Type.t
		     end
   end

signature SWITCH =
   sig
      include SWITCH_STRUCTS

      datatype t =
	 T of {(* Cases are in increasing order of word. *)
	       cases: (WordX.t * Label.t) vector,
	       default: Label.t option,
	       size: WordSize.t,
	       test: Use.t}

      val foldLabelUse: t * 'a * {label: Label.t * 'a -> 'a,
				  use: Use.t * 'a -> 'a} -> 'a
      val foreachLabel: t * (Label.t -> unit) -> unit
      val isOk: t * {checkUse: Use.t -> unit,
		     labelIsOk: Label.t -> bool} -> bool
      val layout: t -> Layout.t
   end

