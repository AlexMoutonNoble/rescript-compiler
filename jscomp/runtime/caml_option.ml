(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)

let%private undefinedHeader = [| |]
type nest = (int array * int)


let some ( x : Obj.t) : Obj.t = 
  if Obj.magic x =  None then 
    (let block = Obj.repr (undefinedHeader, 0) in
    Obj.set_tag block 256;
    block)
  else 
    if x != Obj.repr Js.null && match (Obj.magic x :nest ) with (x,_) -> x ==  undefinedHeader then   
      (
      let nid =   match (Obj.magic x : nest) with (_,x) -> x + 1 in 
      let block = Obj.repr (undefinedHeader, nid) in 
       Obj.set_tag block 256;        
       block
      )
    else  x 

let nullable_to_opt (type t) ( x : t Js.null_undefined) : t option = 
  if (Obj.magic x) == Js.null ||  (Obj.magic x) == Js.undefined then 
    None 
  else Obj.magic (some (Obj.magic x : 'a))

let undefined_to_opt (type t) ( x : t Js.undefined) : t option = 
    if (Obj.magic x) == Js.undefined then None 
    else Obj.magic (some (Obj.magic x : 'a))

let null_to_opt (type t ) ( x : t Js.null) : t option = 
  if (Obj.magic x) == Js.null then None 
  else Obj.magic (some (Obj.magic x : 'a) )

(* external valFromOption : 'a option -> 'a = 
  "#val_from_option"   *)



(** The input is already of [Some] form, [x] is not None, 
    make sure [x[0]] will not throw *)
let valFromOption (x : Obj.t) : Obj.t =   
  if  x != Obj.repr Js.null && match (Obj.magic x : nest) with (x,_) -> x ==  undefinedHeader 
  then 
    (match (Obj.magic x : nest) with _, depth ->  
    if depth = 0 then Obj.magic None
    else Obj.magic (undefinedHeader, depth - 1))
  else Obj.magic x   


let option_get (x : 'a option) = 
  if x = None then Caml_undefined_extern.empty
  else Obj.magic (valFromOption (Obj.repr x))


(** [input] is optional polymorphic variant *)  
let option_unwrap (x : 'a option)  =
  if x = None then Caml_undefined_extern.empty
  else Obj.magic (Obj.field (Obj.repr ((Obj.repr x))) 1 )
(* INVARIANT: polyvar encoding*)
