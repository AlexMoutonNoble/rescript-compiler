module Bs_version : sig val version : string val package_name : string end =
  struct let version = "7.3.0-dev.1"
         let package_name = "bs-platform" end 
module Bsb_build_schemas =
  struct
    let version = "version"
    let name = "name"
    let ppx_flags = "ppx-flags"
    let pp_flags = "pp-flags"
    let refmt = "refmt"
    let bs_external_includes = "bs-external-includes"
    let bs_dependencies = "bs-dependencies"
    let bs_dev_dependencies = "bs-dev-dependencies"
    let sources = "sources"
    let dir = "dir"
    let files = "files"
    let subdirs = "subdirs"
    let bsc_flags = "bsc-flags"
    let excludes = "excludes"
    let slow_re = "slow-re"
    let resources = "resources"
    let public = "public"
    let js_post_build = "js-post-build"
    let cmd = "cmd"
    let package_specs = "package-specs"
    let generate_merlin = "generate-merlin"
    let type_ = "type"
    let export_all = "all"
    let export_none = "none"
    let bsb_dir_group = "bsb_dir_group"
    let g_lib_incls = "g_lib_incls"
    let use_stdlib = "use-stdlib"
    let reason = "reason"
    let react_jsx = "react-jsx"
    let cut_generators = "cut-generators"
    let generators = "generators"
    let command = "command"
    let edge = "edge"
    let namespace = "namespace"
    let in_source = "in-source"
    let warnings = "warnings"
    let number = "number"
    let error = "error"
    let suffix = "suffix"
    let gentypeconfig = "gentypeconfig"
    let path = "path"
    let ignored_dirs = "ignored-dirs"
  end
module Ext_array :
  sig
    val reverse_of_list : 'a list -> 'a array
    val to_list_f : 'a array -> ('a -> 'b) -> 'b list
    val to_list_map : ('a -> 'b option) -> 'a array -> 'b list
    val to_list_map_acc : 'a array -> 'b list -> ('a -> 'b option) -> 'b list
    val of_list_map : 'a list -> ('a -> 'b) -> 'b array
    type 'a split = [ `No_split  | `Split of ('a array * 'a array) ]
    val find_and_split : 'a array -> ('a -> 'b -> bool) -> 'b -> 'a split
    val is_empty : 'a array -> bool
    val map : 'a array -> ('a -> 'b) -> 'b array
    val iter : 'a array -> ('a -> unit) -> unit
    val fold_left : 'b array -> 'a -> ('a -> 'b -> 'a) -> 'a
  end =
  struct
    let reverse_of_list =
      function
      | [] -> [||]
      | hd::tl as l ->
          let len = List.length l in
          let a = Array.make len hd in
          let rec fill i =
            function
            | [] -> a
            | hd::tl ->
                (Array.unsafe_set a ((len - i) - 2) hd; fill (i + 1) tl) in
          fill 0 tl
    let rec tolist_f_aux a f i res =
      if i < 0
      then res
      else
        (let v = Array.unsafe_get a i in
         tolist_f_aux a f (i - 1) ((f v) :: res))
    let to_list_f a f = tolist_f_aux a f ((Array.length a) - 1) []
    let rec tolist_aux a f i res =
      if i < 0
      then res
      else
        (let v = Array.unsafe_get a i in
         tolist_aux a f (i - 1)
           (match f v with | Some v -> v :: res | None -> res))
    let to_list_map f a = tolist_aux a f ((Array.length a) - 1) []
    let to_list_map_acc a acc f = tolist_aux a f ((Array.length a) - 1) acc
    let of_list_map a f =
      match a with
      | [] -> [||]
      | a0::[] -> let b0 = f a0 in [|b0|]
      | a0::a1::[] -> let b0 = f a0 in let b1 = f a1 in [|b0;b1|]
      | a0::a1::a2::[] ->
          let b0 = f a0 in let b1 = f a1 in let b2 = f a2 in [|b0;b1;b2|]
      | a0::a1::a2::a3::[] ->
          let b0 = f a0 in
          let b1 = f a1 in let b2 = f a2 in let b3 = f a3 in [|b0;b1;b2;b3|]
      | a0::a1::a2::a3::a4::[] ->
          let b0 = f a0 in
          let b1 = f a1 in
          let b2 = f a2 in
          let b3 = f a3 in let b4 = f a4 in [|b0;b1;b2;b3;b4|]
      | a0::a1::a2::a3::a4::tl ->
          let b0 = f a0 in
          let b1 = f a1 in
          let b2 = f a2 in
          let b3 = f a3 in
          let b4 = f a4 in
          let len = (List.length tl) + 5 in
          let arr = Array.make len b0 in
          (Array.unsafe_set arr 1 b1;
           Array.unsafe_set arr 2 b2;
           Array.unsafe_set arr 3 b3;
           Array.unsafe_set arr 4 b4;
           (let rec fill i =
              function
              | [] -> arr
              | hd::tl -> (Array.unsafe_set arr i (f hd); fill (i + 1) tl) in
            fill 5 tl))
    type 'a split = [ `No_split  | `Split of ('a array * 'a array) ]
    let find_with_index arr cmp v =
      let len = Array.length arr in
      let rec aux i len =
        if i >= len
        then (-1)
        else if cmp (Array.unsafe_get arr i) v then i else aux (i + 1) len in
      aux 0 len
    let find_and_split arr cmp v =
      (let i = find_with_index arr cmp v in
       if i < 0
       then `No_split
       else
         `Split
           ((Array.sub arr 0 i),
             (Array.sub arr (i + 1) (((Array.length arr) - i) - 1))) : 
      _ split)
    [@@@ocaml.text " TODO: available since 4.03, use {!Array.exists} "]
    let is_empty arr = (Array.length arr) = 0
    let map a f =
      let open Array in
        let l = length a in
        if l = 0
        then [||]
        else
          (let r = make l (f (unsafe_get a 0)) in
           for i = 1 to l - 1 do unsafe_set r i (f (unsafe_get a i)) done; r)
    let iter a f =
      let open Array in
        for i = 0 to (length a) - 1 do f (unsafe_get a i) done
    let fold_left a x f =
      let open Array in
        let r = ref x in
        for i = 0 to (length a) - 1 do r := (f (!r) (unsafe_get a i)) done;
        !r
  end 
module Ext_list :
  sig
    val map : 'a list -> ('a -> 'b) -> 'b list
    val append : 'a list -> 'a list -> 'a list
    val map_append : 'b list -> 'a list -> ('b -> 'a) -> 'a list
    [@@@ocaml.text
      "\n\n   {[length xs = length ys + n ]}\n   input n should be positive \n   TODO: input checking\n"]
    val flat_map : 'a list -> ('a -> 'b list) -> 'b list
    val flat_map_append : 'a list -> 'b list -> ('a -> 'b list) -> 'b list
    val find_first : 'a list -> ('a -> bool) -> 'a option
    [@@@ocaml.text
      " [find_opt f l] returns [None] if all return [None],  \n    otherwise returns the first one. \n"]
    val find_opt : 'a list -> ('a -> 'b option) -> 'b option
    val rev_iter : 'a list -> ('a -> unit) -> unit
    val iter : 'a list -> ('a -> unit) -> unit
    val exists : 'a list -> ('a -> bool) -> bool
    val fold_left : 'a list -> 'b -> ('b -> 'a -> 'b) -> 'b
    val mem_string : string list -> string -> bool
  end =
  struct
    let rec map l f =
      match l with
      | [] -> []
      | x1::[] -> let y1 = f x1 in [y1]
      | x1::x2::[] -> let y1 = f x1 in let y2 = f x2 in [y1; y2]
      | x1::x2::x3::[] ->
          let y1 = f x1 in let y2 = f x2 in let y3 = f x3 in [y1; y2; y3]
      | x1::x2::x3::x4::[] ->
          let y1 = f x1 in
          let y2 = f x2 in let y3 = f x3 in let y4 = f x4 in [y1; y2; y3; y4]
      | x1::x2::x3::x4::x5::tail ->
          let y1 = f x1 in
          let y2 = f x2 in
          let y3 = f x3 in
          let y4 = f x4 in
          let y5 = f x5 in y1 :: y2 :: y3 :: y4 :: y5 :: (map tail f)
    let rec append_aux l1 l2 =
      match l1 with
      | [] -> l2
      | a0::[] -> a0 :: l2
      | a0::a1::[] -> a0 :: a1 :: l2
      | a0::a1::a2::[] -> a0 :: a1 :: a2 :: l2
      | a0::a1::a2::a3::[] -> a0 :: a1 :: a2 :: a3 :: l2
      | a0::a1::a2::a3::a4::[] -> a0 :: a1 :: a2 :: a3 :: a4 :: l2
      | a0::a1::a2::a3::a4::rest -> a0 :: a1 :: a2 :: a3 :: a4 ::
          (append_aux rest l2)
    let append l1 l2 = match l2 with | [] -> l1 | _ -> append_aux l1 l2
    let rec map_append l1 l2 f =
      match l1 with
      | [] -> l2
      | a0::[] -> (f a0) :: l2
      | a0::a1::[] -> let b0 = f a0 in let b1 = f a1 in b0 :: b1 :: l2
      | a0::a1::a2::[] ->
          let b0 = f a0 in
          let b1 = f a1 in let b2 = f a2 in b0 :: b1 :: b2 :: l2
      | a0::a1::a2::a3::[] ->
          let b0 = f a0 in
          let b1 = f a1 in
          let b2 = f a2 in let b3 = f a3 in b0 :: b1 :: b2 :: b3 :: l2
      | a0::a1::a2::a3::a4::[] ->
          let b0 = f a0 in
          let b1 = f a1 in
          let b2 = f a2 in
          let b3 = f a3 in let b4 = f a4 in b0 :: b1 :: b2 :: b3 :: b4 :: l2
      | a0::a1::a2::a3::a4::rest ->
          let b0 = f a0 in
          let b1 = f a1 in
          let b2 = f a2 in
          let b3 = f a3 in
          let b4 = f a4 in b0 :: b1 :: b2 :: b3 :: b4 ::
            (map_append rest l2 f)
    let rec rev_append l1 l2 =
      match l1 with
      | [] -> l2
      | a0::[] -> a0 :: l2
      | a0::a1::[] -> a1 :: a0 :: l2
      | a0::a1::a2::rest -> rev_append rest (a2 :: a1 :: a0 :: l2)
    let rec flat_map_aux f acc append lx =
      match lx with
      | [] -> rev_append acc append
      | a0::rest ->
          let new_acc =
            match f a0 with
            | [] -> acc
            | a0::[] -> a0 :: acc
            | a0::a1::[] -> a1 :: a0 :: acc
            | a0::a1::a2::rest -> rev_append rest (a2 :: a1 :: a0 :: acc) in
          flat_map_aux f new_acc append rest[@@ocaml.doc
                                              " It is not worth loop unrolling, \n    it is already tail-call, and we need to be careful \n    about evaluation order when unroll\n"]
    let flat_map lx f = flat_map_aux f [] [] lx
    let flat_map_append lx append f = flat_map_aux f [] append lx
    let rec find_first x p =
      match x with
      | [] -> None
      | x::l -> if p x then Some x else find_first l p
    let rec rev_iter l f =
      match l with
      | [] -> ()
      | x1::[] -> f x1
      | x1::x2::[] -> (f x2; f x1)
      | x1::x2::x3::[] -> (f x3; f x2; f x1)
      | x1::x2::x3::x4::[] -> (f x4; f x3; f x2; f x1)
      | x1::x2::x3::x4::x5::tail ->
          (rev_iter tail f; f x5; f x4; f x3; f x2; f x1)
    let rec iter l f =
      match l with
      | [] -> ()
      | x1::[] -> f x1
      | x1::x2::[] -> (f x1; f x2)
      | x1::x2::x3::[] -> (f x1; f x2; f x3)
      | x1::x2::x3::x4::[] -> (f x1; f x2; f x3; f x4)
      | x1::x2::x3::x4::x5::tail ->
          (f x1; f x2; f x3; f x4; f x5; iter tail f)
    let rec find_opt xs p =
      match xs with
      | [] -> None
      | x::l -> (match p x with | Some _ as v -> v | None -> find_opt l p)
    let rec exists l p =
      match l with | [] -> false | x::xs -> (p x) || (exists xs p)
    let rec fold_left l accu f =
      match l with | [] -> accu | a::l -> fold_left l (f accu a) f
    let rec mem_string (xs : string list) (x : string) =
      match xs with | [] -> false | a::l -> (a = x) || (mem_string l x)
  end 
module Ext_bytes :
  sig
    external unsafe_blit_string :
      string -> int -> bytes -> int -> int -> unit = "caml_blit_string"
    [@@noalloc ]
  end =
  struct
    external unsafe_blit_string :
      string -> int -> bytes -> int -> int -> unit = "caml_blit_string"
    [@@noalloc ]
  end 
module Ext_string :
  sig
    [@@@ocaml.text
      " Extension to the standard library [String] module, fixed some bugs like\n    avoiding locale sensitivity "]
    val trim : string -> string[@@ocaml.doc
                                 " remove whitespace letters ('\\t', '\\n', ' ') on both side"]
    val split : ?keep_empty:bool -> string -> char -> string list[@@ocaml.doc
                                                                   " default is false "]
    val starts_with : string -> string -> bool
    val ends_with_index : string -> string -> int[@@ocaml.doc
                                                   "\n   return [-1] when not found, the returned index is useful \n   see [ends_with_then_chop]\n"]
    val ends_with : string -> string -> bool
    val for_all_from : string -> int -> (char -> bool) -> bool[@@ocaml.doc
                                                                "\n  [for_all_from  s start p]\n  if [start] is negative, it raises,\n  if [start] is too large, it returns true\n"]
    val for_all : string -> (char -> bool) -> bool
    val is_empty : string -> bool
    val equal : string -> string -> bool
    [@@@ocaml.text
      "\n  [extract_until s cursor sep]\n   When [sep] not found, the cursor is updated to -1,\n   otherwise cursor is increased to 1 + [sep_position]\n   User can not determine whether it is found or not by\n   telling the return string is empty since \n   \"\\n\\n\" would result in an empty string too.\n"]
    val find : ?start:int -> sub:string -> string -> int[@@ocaml.doc
                                                          "\n  [find ~start ~sub s]\n  returns [-1] if not found\n"]
    val tail_from : string -> int -> string[@@ocaml.doc
                                             " [tail_from s 1]\n  return a substring from offset 1 (inclusive)\n"]
    val rindex_neg : string -> char -> int[@@ocaml.doc
                                            " returns negative number if not found "]
    val no_slash_idx : string -> int[@@ocaml.doc
                                      " return negative means no slash, otherwise [i] means the place for first slash "]
    val no_slash_idx_from : string -> int -> int
    val replace_slash_backward : string -> string[@@ocaml.doc
                                                   " if no conversion happens, reference equality holds "]
    val empty : string
    external compare :
      string -> string -> int = "caml_string_length_based_compare"[@@noalloc
                                                                    ]
    val single_space : string
    val concat3 : string -> string -> string -> string
    val inter2 : string -> string -> string
    val inter3 : string -> string -> string -> string
    val inter4 : string -> string -> string -> string -> string
    val concat_array : string -> string array -> string
    val single_colon : string
    val parent_dir_lit : string
    val current_dir_lit : string
    val capitalize_ascii : string -> string
    val capitalize_sub : string -> int -> string
  end =
  struct
    let split_by ?(keep_empty= false)  is_delim str =
      let len = String.length str in
      let rec loop acc last_pos pos =
        if pos = (-1)
        then
          (if (last_pos = 0) && (not keep_empty)
           then acc
           else (String.sub str 0 last_pos) :: acc)
        else
          if is_delim (str.[pos])
          then
            (let new_len = (last_pos - pos) - 1 in
             if (new_len <> 0) || keep_empty
             then
               let v = String.sub str (pos + 1) new_len in
               loop (v :: acc) pos (pos - 1)
             else loop acc pos (pos - 1))
          else loop acc last_pos (pos - 1) in
      loop [] len (len - 1)
    let trim s =
      let i = ref 0 in
      let j = String.length s in
      while
        ((!i) < j) &&
          ((let u = String.unsafe_get s (!i) in
            (u = '\t') || ((u = '\n') || (u = ' '))))
        do incr i done;
      (let k = ref (j - 1) in
       while
         ((!k) >= (!i)) &&
           ((let u = String.unsafe_get s (!k) in
             (u = '\t') || ((u = '\n') || (u = ' '))))
         do decr k done;
       String.sub s (!i) (((!k) - (!i)) + 1))
    let split ?keep_empty  str on =
      if str = ""
      then []
      else split_by ?keep_empty (fun x -> (x : char) = on) str
    let starts_with s beg =
      let beg_len = String.length beg in
      let s_len = String.length s in
      (beg_len <= s_len) &&
        (let i = ref 0 in
         while
           ((!i) < beg_len) &&
             ((String.unsafe_get s (!i)) = (String.unsafe_get beg (!i)))
           do incr i done;
         (!i) = beg_len)
    let rec ends_aux s end_ j k =
      if k < 0
      then j + 1
      else
        if (String.unsafe_get s j) = (String.unsafe_get end_ k)
        then ends_aux s end_ (j - 1) (k - 1)
        else (-1)
    let ends_with_index s end_ =
      (let s_finish = (String.length s) - 1 in
       let s_beg = (String.length end_) - 1 in
       if s_beg > s_finish then (-1) else ends_aux s end_ s_finish s_beg : 
      int)[@@ocaml.doc
            " return an index which is minus when [s] does not \n    end with [beg]\n"]
    let ends_with s end_ = (ends_with_index s end_) >= 0
    let rec unsafe_for_all_range s ~start  ~finish  p =
      (start > finish) ||
        ((p (String.unsafe_get s start)) &&
           (unsafe_for_all_range s ~start:(start + 1) ~finish p))
    let for_all_from s start p =
      let len = String.length s in
      if start < 0
      then invalid_arg "Ext_string.for_all_from"
      else unsafe_for_all_range s ~start ~finish:(len - 1) p
    let for_all s (p : char -> bool) =
      unsafe_for_all_range s ~start:0 ~finish:((String.length s) - 1) p
    let is_empty s = (String.length s) = 0
    let unsafe_is_sub ~sub  i s j ~len  =
      let rec check k =
        if k = len
        then true
        else
          ((String.unsafe_get sub (i + k)) = (String.unsafe_get s (j + k)))
            && (check (k + 1)) in
      ((j + len) <= (String.length s)) && (check 0)
    let find ?(start= 0)  ~sub  s =
      let exception Local_exit  in
        let n = String.length sub in
        let s_len = String.length s in
        let i = ref start in
        try
          while ((!i) + n) <= s_len do
            (if unsafe_is_sub ~sub 0 s (!i) ~len:n
             then raise_notrace Local_exit;
             incr i)
            done;
          (-1)
        with | Local_exit -> !i
    let tail_from s x =
      let len = String.length s in
      if x > len
      then
        invalid_arg
          ("Ext_string.tail_from " ^ (s ^ (" : " ^ (string_of_int x))))
      else String.sub s x (len - x)
    let equal (x : string) y = x = y
    let rec rindex_rec s i c =
      if i < 0
      then i
      else if (String.unsafe_get s i) = c then i else rindex_rec s (i - 1) c
    let rindex_neg s c = rindex_rec s ((String.length s) - 1) c
    let rec unsafe_no_char x ch i last_idx =
      (i > last_idx) ||
        (((String.unsafe_get x i) <> ch) &&
           (unsafe_no_char x ch (i + 1) last_idx))[@@ocaml.doc
                                                    " TODO: can be improved to return a positive integer instead "]
    let rec unsafe_no_char_idx x ch i last_idx =
      if i > last_idx
      then (-1)
      else
        if (String.unsafe_get x i) <> ch
        then unsafe_no_char_idx x ch (i + 1) last_idx
        else i
    let no_slash_idx x = unsafe_no_char_idx x '/' 0 ((String.length x) - 1)
    let no_slash_idx_from x from =
      let last_idx = (String.length x) - 1 in
      assert (from >= 0); unsafe_no_char_idx x '/' from last_idx
    let replace_slash_backward (x : string) =
      let len = String.length x in
      if unsafe_no_char x '/' 0 (len - 1)
      then x
      else String.map (function | '/' -> '\\' | x -> x) x
    let empty = ""
    external compare :
      string -> string -> int = "caml_string_length_based_compare"[@@noalloc
                                                                    ]
    let single_space = " "
    let single_colon = ":"
    let concat_array sep (s : string array) =
      let s_len = Array.length s in
      match s_len with
      | 0 -> empty
      | 1 -> Array.unsafe_get s 0
      | _ ->
          let sep_len = String.length sep in
          let len = ref 0 in
          (for i = 0 to s_len - 1 do
             len := ((!len) + (String.length (Array.unsafe_get s i)))
           done;
           (let target = Bytes.create ((!len) + ((s_len - 1) * sep_len)) in
            let hd = Array.unsafe_get s 0 in
            let hd_len = String.length hd in
            String.unsafe_blit hd 0 target 0 hd_len;
            (let current_offset = ref hd_len in
             for i = 1 to s_len - 1 do
               (String.unsafe_blit sep 0 target (!current_offset) sep_len;
                (let cur = Array.unsafe_get s i in
                 let cur_len = String.length cur in
                 let new_off_set = (!current_offset) + sep_len in
                 String.unsafe_blit cur 0 target new_off_set cur_len;
                 current_offset := (new_off_set + cur_len)))
             done;
             Bytes.unsafe_to_string target)))
    let concat3 a b c =
      let a_len = String.length a in
      let b_len = String.length b in
      let c_len = String.length c in
      let len = (a_len + b_len) + c_len in
      let target = Bytes.create len in
      String.unsafe_blit a 0 target 0 a_len;
      String.unsafe_blit b 0 target a_len b_len;
      String.unsafe_blit c 0 target (a_len + b_len) c_len;
      Bytes.unsafe_to_string target
    let concat5 a b c d e =
      let a_len = String.length a in
      let b_len = String.length b in
      let c_len = String.length c in
      let d_len = String.length d in
      let e_len = String.length e in
      let len = (((a_len + b_len) + c_len) + d_len) + e_len in
      let target = Bytes.create len in
      String.unsafe_blit a 0 target 0 a_len;
      String.unsafe_blit b 0 target a_len b_len;
      String.unsafe_blit c 0 target (a_len + b_len) c_len;
      String.unsafe_blit d 0 target ((a_len + b_len) + c_len) d_len;
      String.unsafe_blit e 0 target (((a_len + b_len) + c_len) + d_len) e_len;
      Bytes.unsafe_to_string target
    let inter2 a b = concat3 a single_space b
    let inter3 a b c = concat5 a single_space b single_space c
    let inter4 a b c d = concat_array single_space [|a;b;c;d|]
    let parent_dir_lit = ".."
    let current_dir_lit = "."
    let capitalize_ascii (s : string) =
      (if (String.length s) = 0
       then s
       else
         (let c = String.unsafe_get s 0 in
          if
            ((c >= 'a') && (c <= 'z')) ||
              (((c >= '\224') && (c <= '\246')) ||
                 ((c >= '\248') && (c <= '\254')))
          then
            let uc = Char.unsafe_chr ((Char.code c) - 32) in
            let bytes = Bytes.of_string s in
            (Bytes.unsafe_set bytes 0 uc; Bytes.unsafe_to_string bytes)
          else s) : string)
    let capitalize_sub (s : string) len =
      (let slen = String.length s in
       if (len < 0) || (len > slen)
       then invalid_arg "Ext_string.capitalize_sub"
       else
         if len = 0
         then ""
         else
           (let bytes = Bytes.create len in
            let uc =
              let c = String.unsafe_get s 0 in
              if
                ((c >= 'a') && (c <= 'z')) ||
                  (((c >= '\224') && (c <= '\246')) ||
                     ((c >= '\248') && (c <= '\254')))
              then Char.unsafe_chr ((Char.code c) - 32)
              else c in
            Bytes.unsafe_set bytes 0 uc;
            for i = 1 to len - 1 do
              Bytes.unsafe_set bytes i (String.unsafe_get s i)
            done;
            Bytes.unsafe_to_string bytes) : string)
  end 
module Map_gen =
  struct
    [@@@ocaml.text " adapted from stdlib "]
    type ('key, 'a) t =
      | Empty 
      | Node of ('key, 'a) t * 'key * 'a * ('key, 'a) t * int 
    type ('key, 'a) enumeration =
      | End 
      | More of 'key * 'a * ('key, 'a) t * ('key, 'a) enumeration 
    let rec cardinal_aux acc =
      function
      | Empty -> acc
      | Node (l, _, _, r, _) -> cardinal_aux (cardinal_aux (acc + 1) r) l
    let cardinal s = cardinal_aux 0 s
    let height = function | Empty -> 0 | Node (_, _, _, _, h) -> h
    let create l x d r =
      let hl = height l
      and hr = height r in
      Node (l, x, d, r, (if hl >= hr then hl + 1 else hr + 1))
    let singleton x d = Node (Empty, x, d, Empty, 1)
    let bal l x d r =
      let hl = match l with | Empty -> 0 | Node (_, _, _, _, h) -> h in
      let hr = match r with | Empty -> 0 | Node (_, _, _, _, h) -> h in
      if hl > (hr + 2)
      then
        match l with
        | Empty -> invalid_arg "Map.bal"
        | Node (ll, lv, ld, lr, _) ->
            (if (height ll) >= (height lr)
             then create ll lv ld (create lr x d r)
             else
               (match lr with
                | Empty -> invalid_arg "Map.bal"
                | Node (lrl, lrv, lrd, lrr, _) ->
                    create (create ll lv ld lrl) lrv lrd (create lrr x d r)))
      else
        if hr > (hl + 2)
        then
          (match r with
           | Empty -> invalid_arg "Map.bal"
           | Node (rl, rv, rd, rr, _) ->
               if (height rr) >= (height rl)
               then create (create l x d rl) rv rd rr
               else
                 (match rl with
                  | Empty -> invalid_arg "Map.bal"
                  | Node (rll, rlv, rld, rlr, _) ->
                      create (create l x d rll) rlv rld (create rlr rv rd rr)))
        else Node (l, x, d, r, (if hl >= hr then hl + 1 else hr + 1))
    let empty = Empty
    let is_empty = function | Empty -> true | _ -> false
    let rec min_binding_exn =
      function
      | Empty -> raise Not_found
      | Node (Empty, x, d, _, _) -> (x, d)
      | Node (l, _, _, _, _) -> min_binding_exn l
    let rec remove_min_binding =
      function
      | Empty -> invalid_arg "Map.remove_min_elt"
      | Node (Empty, _, _, r, _) -> r
      | Node (l, x, d, r, _) -> bal (remove_min_binding l) x d r
    let rec iter x f =
      match x with
      | Empty -> ()
      | Node (l, v, d, r, _) -> (iter l f; f v d; iter r f)
    let rec mapi x f =
      match x with
      | Empty -> Empty
      | Node (l, v, d, r, h) ->
          let l' = mapi l f in
          let d' = f v d in let r' = mapi r f in Node (l', v, d', r', h)
    let rec fold m accu f =
      match m with
      | Empty -> accu
      | Node (l, v, d, r, _) -> fold r (f v d (fold l accu f)) f
    let rec add_min_binding k v =
      function
      | Empty -> singleton k v
      | Node (l, x, d, r, _) -> bal (add_min_binding k v l) x d r
    let rec add_max_binding k v =
      function
      | Empty -> singleton k v
      | Node (l, x, d, r, _) -> bal l x d (add_max_binding k v r)
    let rec join l v d r =
      match (l, r) with
      | (Empty, _) -> add_min_binding v d r
      | (_, Empty) -> add_max_binding v d l
      | (Node (ll, lv, ld, lr, lh), Node (rl, rv, rd, rr, rh)) ->
          if lh > (rh + 2)
          then bal ll lv ld (join lr v d r)
          else
            if rh > (lh + 2)
            then bal (join l v d rl) rv rd rr
            else create l v d r
    let concat t1 t2 =
      match (t1, t2) with
      | (Empty, t) -> t
      | (t, Empty) -> t
      | (_, _) ->
          let (x, d) = min_binding_exn t2 in
          join t1 x d (remove_min_binding t2)
    let concat_or_join t1 v d t2 =
      match d with | Some d -> join t1 v d t2 | None -> concat t1 t2
    module type S  =
      sig
        type key
        type +'a t
        val empty : 'a t
        val is_empty : 'a t -> bool
        val mem : 'a t -> key -> bool
        val add : 'a t -> key -> 'a -> 'a t[@@ocaml.doc
                                             " [add x y m] \n        If [x] was already bound in [m], its previous binding disappears. "]
        val adjust : 'a t -> key -> ('a option -> 'a) -> 'a t[@@ocaml.doc
                                                               " [add x y m] \n        If [x] was already bound in [m], its previous binding disappears. "]
        [@@ocaml.doc
          " [adjust acc k replace ] if not exist [add (replace None ], otherwise \n        [add k v (replace (Some old))]\n    "]
        val merge :
          'a t ->
            'b t -> (key -> 'a option -> 'b option -> 'c option) -> 'c t
        [@@ocaml.doc
          " [merge f m1 m2] computes a map whose keys is a subset of keys of [m1]\n        and of [m2]. The presence of each such binding, and the corresponding\n        value, is determined with the function [f].\n        @since 3.12.0\n     "]
        val iter : 'a t -> (key -> 'a -> unit) -> unit[@@ocaml.doc
                                                        " [iter f m] applies [f] to all bindings in map [m].\n        The bindings are passed to [f] in increasing order. "]
        val fold : 'a t -> 'b -> (key -> 'a -> 'b -> 'b) -> 'b[@@ocaml.doc
                                                                " [fold f m a] computes [(f kN dN ... (f k1 d1 a)...)],\n       where [k1 ... kN] are the keys of all bindings in [m]\n       (in increasing order) "]
        val cardinal : 'a t -> int[@@ocaml.doc
                                    " Return the number of bindings of a map. "]
        val find_exn : 'a t -> key -> 'a[@@ocaml.doc
                                          " [find x m] returns the current binding of [x] in [m],\n       or raises [Not_found] if no such binding exists. "]
        val find_opt : 'a t -> key -> 'a option[@@ocaml.doc
                                                 " [find x m] returns the current binding of [x] in [m],\n       or raises [Not_found] if no such binding exists. "]
        val mapi : 'a t -> (key -> 'a -> 'b) -> 'b t[@@ocaml.doc
                                                      " Same as {!Map.S.map}, but the function receives as arguments both the\n       key and the associated value for each binding of the map. "]
        val of_list : (key * 'a) list -> 'a t
      end
  end
module Map_string : sig include (Map_gen.S with type  key =  string) end =
  struct
    type key = string
    let compare_key = Ext_string.compare
    type 'a t = (key, 'a) Map_gen.t
    exception Duplicate_key of key 
    let empty = Map_gen.empty
    let is_empty = Map_gen.is_empty
    let iter = Map_gen.iter
    let fold = Map_gen.fold
    let cardinal = Map_gen.cardinal
    let mapi = Map_gen.mapi
    let bal = Map_gen.bal
    let height = Map_gen.height
    let rec add (tree : _ Map_gen.t as 'a) x data =
      (match tree with
       | Empty -> Node (Empty, x, data, Empty, 1)
       | Node (l, v, d, r, h) ->
           let c = compare_key x v in
           if c = 0
           then Node (l, x, data, r, h)
           else
             if c < 0
             then bal (add l x data) v d r
             else bal l v d (add r x data) : 'a)
    let rec adjust (tree : _ Map_gen.t as 'a) x replace =
      (match tree with
       | Empty -> Node (Empty, x, (replace None), Empty, 1)
       | Node (l, v, d, r, h) ->
           let c = compare_key x v in
           if c = 0
           then Node (l, x, (replace (Some d)), r, h)
           else
             if c < 0
             then bal (adjust l x replace) v d r
             else bal l v d (adjust r x replace) : 'a)
    let rec find_exn (tree : _ Map_gen.t) x =
      match tree with
      | Empty -> raise Not_found
      | Node (l, v, d, r, _) ->
          let c = compare_key x v in
          if c = 0 then d else find_exn (if c < 0 then l else r) x
    let rec find_opt (tree : _ Map_gen.t) x =
      match tree with
      | Empty -> None
      | Node (l, v, d, r, _) ->
          let c = compare_key x v in
          if c = 0 then Some d else find_opt (if c < 0 then l else r) x
    let rec mem (tree : _ Map_gen.t) x =
      match tree with
      | Empty -> false
      | Node (l, v, _, r, _) ->
          let c = compare_key x v in
          (c = 0) || (mem (if c < 0 then l else r) x)
    let rec split (tree : _ Map_gen.t as 'a) x =
      (match tree with
       | Empty -> (Empty, None, Empty)
       | Node (l, v, d, r, _) ->
           let c = compare_key x v in
           if c = 0
           then (l, (Some d), r)
           else
             if c < 0
             then
               (let (ll, pres, rl) = split l x in
                (ll, pres, (Map_gen.join rl v d r)))
             else
               (let (lr, pres, rr) = split r x in
                ((Map_gen.join l v d lr), pres, rr)) : ('a * _ option * 'a))
    let rec merge (s1 : _ Map_gen.t) (s2 : _ Map_gen.t) f =
      (match (s1, s2) with
       | (Empty, Empty) -> Empty
       | (Node (l1, v1, d1, r1, h1), _) when h1 >= (height s2) ->
           let (l2, d2, r2) = split s2 v1 in
           Map_gen.concat_or_join (merge l1 l2 f) v1 (f v1 (Some d1) d2)
             (merge r1 r2 f)
       | (_, Node (l2, v2, d2, r2, _)) ->
           let (l1, d1, r1) = split s1 v2 in
           Map_gen.concat_or_join (merge l1 l2 f) v2 (f v2 d1 (Some d2))
             (merge r1 r2 f)
       | _ -> assert false : _ Map_gen.t)
    let add_list (xs : _ list) init =
      Ext_list.fold_left xs init (fun acc -> fun (k, v) -> add acc k v)
    let of_list xs = add_list xs empty
  end 
module Bsb_db :
  sig
    [@@@ocaml.text
      " Store a file called [.bsbuild] that can be communicated \n    between [bsb.exe] and [bsb_helper.exe]. \n    [bsb.exe] stores such data which would be retrieved by \n    [bsb_helper.exe]. It is currently used to combine with \n    ocamldep to figure out which module->file it depends on\n"]
    type case = bool
    type info =
      | Mli 
      | Ml 
      | Ml_mli 
    type module_info =
      {
      mutable info: info ;
      dir: string ;
      is_re: bool ;
      case: bool ;
      name_sans_extension: string }
    type t = module_info Map_string.t
    type ts = t array
    [@@@ocaml.text
      " store  the meta data indexed by {!Bsb_dir_index}\n  {[\n    0 --> lib group\n    1 --> dev 1 group\n    .\n    \n  ]}\n"]
  end =
  struct
    type case = bool[@@ocaml.doc " true means upper case"]
    type info =
      | Mli 
      | Ml 
      | Ml_mli 
    type module_info =
      {
      mutable info: info ;
      dir: string ;
      is_re: bool ;
      case: bool ;
      name_sans_extension: string }
    type t = module_info Map_string.t
    type ts = t array[@@ocaml.doc " indexed by the group "]
  end 
module Bsb_dir_index :
  sig
    type t = private int[@@ocaml.doc
                          " Used to index [.bsbuildcache] may not be needed if we flatten dev \n  into  a single group\n"]
    val lib_dir_index : t
    val is_lib_dir : t -> bool
    val get_dev_index : unit -> t
    val of_int : int -> t
    val get_current_number_of_dev_groups : unit -> int
    val string_of_bsb_dev_include : t -> string
    val reset : unit -> unit[@@ocaml.doc
                              " TODO: Need reset\n   when generating each ninja file to provide stronger guarantee. \n   Here we get a weak guarantee because only dev group is \n  inside the toplevel project\n   "]
  end =
  struct
    type t = int
    external of_int : int -> t = "%identity"[@@ocaml.doc
                                              " \n   0 : lib \n   1 : dev 1 \n   2 : dev 2 \n"]
    let lib_dir_index = 0
    let is_lib_dir x = x = lib_dir_index
    let dir_index = ref 0
    let get_dev_index () = incr dir_index; !dir_index
    let get_current_number_of_dev_groups () = !dir_index
    let bsc_group_1_includes = "bsc_group_1_includes"[@@ocaml.doc
                                                       " bsb generate pre-defined variables [bsc_group_i_includes]\n  for each rule, there is variable [bsc_extra_excludes]\n  [g_dev_incls] are for app test etc\n  it will be like\n  {[\n    g_dev_incls = ${bsc_group_1_includes}\n  ]}\n  where [bsc_group_1_includes] will be pre-calcuated\n"]
    let bsc_group_2_includes = "bsc_group_2_includes"
    let bsc_group_3_includes = "bsc_group_3_includes"
    let bsc_group_4_includes = "bsc_group_4_includes"
    let string_of_bsb_dev_include i =
      match i with
      | 1 -> bsc_group_1_includes
      | 2 -> bsc_group_2_includes
      | 3 -> bsc_group_3_includes
      | 4 -> bsc_group_4_includes
      | _ -> "bsc_group_" ^ ((string_of_int i) ^ "_includes")
    let reset () = dir_index := 0
  end 
module Set_gen =
  struct
    [@@@ocaml.text " balanced tree based on stdlib distribution "]
    type ('a, 'id) t0 =
      | Empty 
      | Node of ('a, 'id) t0 * 'a * ('a, 'id) t0 * int 
    type ('a, 'id) enumeration0 =
      | End 
      | More of 'a * ('a, 'id) t0 * ('a, 'id) enumeration0 
    let height = function | Empty -> 0 | Node (_, _, _, h) -> h
    let empty = Empty
    exception Height_invariant_broken 
    exception Height_diff_borken 
    let create l v r =
      let hl = match l with | Empty -> 0 | Node (_, _, _, h) -> h in
      let hr = match r with | Empty -> 0 | Node (_, _, _, h) -> h in
      Node (l, v, r, (if hl >= hr then hl + 1 else hr + 1))
    let internal_bal l v r =
      let hl = match l with | Empty -> 0 | Node (_, _, _, h) -> h in
      let hr = match r with | Empty -> 0 | Node (_, _, _, h) -> h in
      if hl > (hr + 2)
      then
        match l with
        | Empty -> assert false
        | Node (ll, lv, lr, _) ->
            (if (height ll) >= (height lr)
             then create ll lv (create lr v r)
             else
               (match lr with
                | Empty -> assert false
                | Node (lrl, lrv, lrr, _) ->
                    create (create ll lv lrl) lrv (create lrr v r)))
      else
        if hr > (hl + 2)
        then
          (match r with
           | Empty -> assert false
           | Node (rl, rv, rr, _) ->
               if (height rr) >= (height rl)
               then create (create l v rl) rv rr
               else
                 (match rl with
                  | Empty -> assert false
                  | Node (rll, rlv, rlr, _) ->
                      create (create l v rll) rlv (create rlr rv rr)))
        else Node (l, v, r, (if hl >= hr then hl + 1 else hr + 1))
    let singleton x = Node (Empty, x, Empty, 1)
    let of_sorted_list l =
      let rec sub n l =
        match (n, l) with
        | (0, l) -> (Empty, l)
        | (1, x0::l) -> ((Node (Empty, x0, Empty, 1)), l)
        | (2, x0::x1::l) ->
            ((Node ((Node (Empty, x0, Empty, 1)), x1, Empty, 2)), l)
        | (3, x0::x1::x2::l) ->
            ((Node
                ((Node (Empty, x0, Empty, 1)), x1,
                  (Node (Empty, x2, Empty, 1)), 2)), l)
        | (n, l) ->
            let nl = n / 2 in
            let (left, l) = sub nl l in
            (match l with
             | [] -> assert false
             | mid::l ->
                 let (right, l) = sub ((n - nl) - 1) l in
                 ((create left mid right), l)) in
      fst (sub (List.length l) l)
    module type S  =
      sig
        type elt
        type t
        val empty : t
        val mem : t -> elt -> bool
        val add : t -> elt -> t
        val of_list : elt list -> t
      end
  end
module Set_string : sig include (Set_gen.S with type  elt =  string) end =
  struct
    [@@@warning "-34"]
    type elt = string
    let compare_elt = Ext_string.compare
    type ('a, 'id) t0 = ('a, 'id) Set_gen.t0 =
      | Empty 
      | Node of ('a, 'id) t0 * 'a * ('a, 'id) t0 * int 
    type ('a, 'id) enumeration0 = ('a, 'id) Set_gen.enumeration0 =
      | End 
      | More of 'a * ('a, 'id) t0 * ('a, 'id) enumeration0 
    type t = (elt, unit) t0
    type enumeration = (elt, unit) Set_gen.enumeration0
    let empty = Set_gen.empty
    let singleton = Set_gen.singleton
    let of_sorted_list = Set_gen.of_sorted_list
    let rec add (tree : t) x =
      (match tree with
       | Empty -> Node (Empty, x, Empty, 1)
       | Node (l, v, r, _) as t ->
           let c = compare_elt x v in
           if c = 0
           then t
           else
             if c < 0
             then Set_gen.internal_bal (add l x) v r
             else Set_gen.internal_bal l v (add r x) : t)
    let rec mem (tree : t) x =
      match tree with
      | Empty -> false
      | Node (l, v, r, _) ->
          let c = compare_elt x v in
          (c = 0) || (mem (if c < 0 then l else r) x)
    let of_list l =
      match l with
      | [] -> empty
      | x0::[] -> singleton x0
      | x0::x1::[] -> add (singleton x0) x1
      | x0::x1::x2::[] -> add (add (singleton x0) x1) x2
      | x0::x1::x2::x3::[] -> add (add (add (singleton x0) x1) x2) x3
      | x0::x1::x2::x3::x4::[] ->
          add (add (add (add (singleton x0) x1) x2) x3) x4
      | _ -> of_sorted_list (List.sort_uniq compare_elt l)
  end 
module Bsb_file_groups :
  sig
    type public =
      | Export_none 
      | Export_all 
      | Export_set of Set_string.t 
    type build_generator =
      {
      input: string list ;
      output: string list ;
      command: string }
    type file_group =
      {
      dir: string ;
      sources: Bsb_db.t ;
      resources: string list ;
      public: public ;
      dir_index: Bsb_dir_index.t ;
      generators: build_generator list }
    type file_groups = file_group list
    type t = private {
      files: file_groups ;
      globbed_dirs: string list }
    val empty : t
    val merge : t -> t -> t
    val cons : file_group:file_group -> ?globbed_dir:string -> t -> t
    val is_empty : file_group -> bool
  end =
  struct
    type public =
      | Export_none 
      | Export_all 
      | Export_set of Set_string.t 
    type build_generator =
      {
      input: string list ;
      output: string list ;
      command: string }
    type file_group =
      {
      dir: string ;
      sources: Bsb_db.t ;
      resources: string list ;
      public: public ;
      dir_index: Bsb_dir_index.t ;
      generators: build_generator list }
    type file_groups = file_group list
    type t = {
      files: file_groups ;
      globbed_dirs: string list }
    let empty : t = { files = []; globbed_dirs = [] }
    let merge (u : t) (v : t) =
      if u == empty
      then v
      else
        if v == empty
        then u
        else
          {
            files = (Ext_list.append u.files v.files);
            globbed_dirs = (Ext_list.append u.globbed_dirs v.globbed_dirs)
          }
    let cons ~file_group  ?globbed_dir  (v : t) =
      ({
         files = (file_group :: (v.files));
         globbed_dirs =
           (match globbed_dir with
            | None -> v.globbed_dirs
            | Some f -> f :: (v.globbed_dirs))
       } : t)[@@ocaml.doc
               " when [is_empty file_group]\n    we don't need issue [-I] [-S] in [.merlin] file\n"]
    let is_empty (x : file_group) =
      (Map_string.is_empty x.sources) &&
        ((x.resources = []) && (x.generators = []))[@@ocaml.doc
                                                     " when [is_empty file_group]\n    we don't need issue [-I] [-S] in [.merlin] file\n"]
  end 
module Ext_pervasives :
  sig
    [@@@ocaml.text
      " Extension to standard library [Pervavives] module, safe to open \n  "]
    external reraise : exn -> 'a = "%reraise"
    val finally : 'a -> clean:('a -> 'c) -> ('a -> 'b) -> 'b
    [@@@ocaml.text
      " Copied from {!Btype.hash_variant}:\n    need sync up and add test case\n "]
  end =
  struct
    external reraise : exn -> 'a = "%reraise"
    let finally v ~clean:action  f =
      match f v with
      | exception e -> (action v; reraise e)
      | e -> (action v; e)
  end 
module Ext_fmt =
  struct
    let failwithf ~loc  fmt =
      Format.ksprintf (fun s -> failwith (loc ^ s)) fmt
  end
module Ext_sys : sig val is_windows_or_cygwin : bool end =
  struct
    [@@@ocaml.text " TODO: not exported yet, wait for Windows Fix"]
    let is_windows_or_cygwin = Sys.win32 || Sys.cygwin
  end 
module Literals :
  sig
    [@@@ocaml.text " callback actually, not exposed to user yet "]
    [@@@ocaml.text " nodejs "]
    val node_modules : string
    val package_json : string
    val bsconfig_json : string
    val build_ninja : string
    val suffix_cmj : string
    val suffix_cmi : string
    val suffix_ml : string
    val suffix_mlast : string
    val suffix_mliast : string
    val suffix_reast : string
    val suffix_reiast : string
    val suffix_mlmap : string
    val suffix_re : string
    val suffix_rei : string
    val suffix_d : string
    val suffix_js : string
    val suffix_bs_js : string
    val suffix_gen_js : string
    val suffix_gen_tsx : string
    val suffix_mli : string
    val suffix_cmt : string
    val suffix_cmti : string
    val commonjs : string
    val es6 : string
    val es6_global : string
    val js : string
    val bsbuild_cache : string
    val sourcedirs_meta : string
    val ns_sep_char : char
    val ns_sep : string
  end =
  struct
    let node_modules = "node_modules"[@@ocaml.doc " nodejs "]
    let package_json = "package.json"
    let bsconfig_json = "bsconfig.json"
    let build_ninja = "build.ninja"
    let suffix_cmj = ".cmj"
    let suffix_cmi = ".cmi"
    let suffix_ml = ".ml"
    let suffix_mli = ".mli"
    let suffix_re = ".re"
    let suffix_rei = ".rei"
    let suffix_mlmap = ".mlmap"
    let suffix_cmt = ".cmt"
    let suffix_cmti = ".cmti"
    let suffix_mlast = ".mlast"
    let suffix_mliast = ".mliast"
    let suffix_reast = ".reast"
    let suffix_reiast = ".reiast"
    let suffix_d = ".d"
    let suffix_js = ".js"
    let suffix_bs_js = ".bs.js"
    let suffix_gen_js = ".gen.js"
    let suffix_gen_tsx = ".gen.tsx"
    let commonjs = "commonjs"
    let es6 = "es6"
    let es6_global = "es6-global"
    let js = "js"
    let bsbuild_cache = ".bsbuild"
    let sourcedirs_meta = ".sourcedirs.json"
    let ns_sep_char = '-'
    let ns_sep = "-"
  end 
module Ext_path :
  sig
    type t
    val simple_convert_node_path_to_os_path : string -> string[@@ocaml.doc
                                                                " Js_output is node style, which means \n    separator is only '/'\n\n    if the path contains 'node_modules', \n    [node_relative_path] will discard its prefix and \n    just treat it as a library instead\n"]
    val combine : string -> string -> string[@@ocaml.doc
                                              "\n   [combine path1 path2]\n   1. add some simplifications when concatenating\n   2. when [path2] is absolute, return [path2]\n"]
    [@@@ocaml.text
      "\n   {[\n     get_extension \"a.txt\" = \".txt\"\n       get_extension \"a\" = \"\"\n   ]}\n"]
    val normalize_absolute_path : string -> string
    val concat : string -> string -> string[@@ocaml.doc
                                             " [concat dirname filename]\n    The same as {!Filename.concat} except a tiny optimization \n    for current directory simplification\n"]
  end =
  struct
    type t =
      | Dir of string [@@unboxed ]
    let simple_convert_node_path_to_os_path =
      if Sys.unix
      then fun x -> x
      else
        if Sys.win32 || Sys.cygwin
        then Ext_string.replace_slash_backward
        else failwith ("Unknown OS : " ^ Sys.os_type)
    let combine path1 path2 =
      if Filename.is_relative path2
      then
        (if Ext_string.is_empty path2
         then path1
         else
           if path1 = Filename.current_dir_name
           then path2
           else
             if path2 = Filename.current_dir_name
             then path1
             else Filename.concat path1 path2)
      else path2
    let split_aux p =
      let rec go p acc =
        let dir = Filename.dirname p in
        if dir = p
        then (dir, acc)
        else
          (let new_path = Filename.basename p in
           if Ext_string.equal new_path Filename.dir_sep
           then go dir acc
           else go dir (new_path :: acc)) in
      go p [][@@ocaml.doc
               "\n   {[\n     split_aux \"//ghosg//ghsogh/\";;\n     - : string * string list = (\"/\", [\"ghosg\"; \"ghsogh\"])\n   ]}\n   Note that \n   {[\n     Filename.dirname \"/a/\" = \"/\"\n       Filename.dirname \"/a/b/\" = Filename.dirname \"/a/b\" = \"/a\"\n   ]}\n   Special case:\n   {[\n     basename \"//\" = \"/\"\n       basename \"///\"  = \"/\"\n   ]}\n   {[\n     basename \"\" =  \".\"\n       basename \"\" = \".\"\n       dirname \"\" = \".\"\n       dirname \"\" =  \".\"\n   ]}  \n"]
    let normalize_absolute_path x =
      let drop_if_exist xs = match xs with | [] -> [] | _::xs -> xs in
      let rec normalize_list acc paths =
        match paths with
        | [] -> acc
        | x::xs ->
            if Ext_string.equal x Ext_string.current_dir_lit
            then normalize_list acc xs
            else
              if Ext_string.equal x Ext_string.parent_dir_lit
              then normalize_list (drop_if_exist acc) xs
              else normalize_list (x :: acc) xs in
      let (root, paths) = split_aux x in
      let rev_paths = normalize_list [] paths in
      let rec go acc rev_paths =
        match rev_paths with
        | [] -> Filename.concat root acc
        | last::rest -> go (Filename.concat last acc) rest in
      match rev_paths with | [] -> root | last::rest -> go last rest[@@ocaml.doc
                                                                    " See tests in {!Ounit_path_tests} "]
    let concat dirname filename =
      if filename = Filename.current_dir_name
      then dirname
      else
        if dirname = Filename.current_dir_name
        then filename
        else Filename.concat dirname filename
  end 
module Bsb_config :
  sig
    val proj_rel : string -> string
    val lib_js : string
    val lib_bs : string
    val lib_es6 : string
    val lib_es6_global : string
    val lib_ocaml : string
    val all_lib_artifacts : string list
    val rev_lib_bs_prefix : string -> string
    [@@@ocaml.text
      " default not install, only when -make-world, its dependencies will be installed  "]
  end =
  struct
    let (//) = Ext_path.combine
    let lib_lit = "lib"
    let lib_js = lib_lit // "js"
    let lib_ocaml = lib_lit // "ocaml"
    let lib_bs = lib_lit // "bs"
    let lib_es6 = lib_lit // "es6"
    let lib_es6_global = lib_lit // "es6_global"
    let all_lib_artifacts =
      [lib_js; lib_ocaml; lib_bs; lib_es6; lib_es6_global]
    let rev_lib_bs = ".." // ".."
    let rev_lib_bs_prefix p = rev_lib_bs // p
    let lazy_src_root_dir = "$src_root_dir"
    let proj_rel path = lazy_src_root_dir // path
    [@@@ocaml.text
      " it may not be a bad idea to hard code the binary path \n    of bsb in configuration time\n"]
  end 
module Bsb_pkg_types :
  sig
    type t =
      | Global of string 
      | Scope of string * scope [@dead "Bsb_pkg_types.t.+Scope"]
    and scope = string
    val to_string : t -> string
    val print : Format.formatter -> t -> unit
    val equal : t -> t -> bool
    val extract_pkg_name_and_file : string -> (t * string)
    val string_as_package : string -> t
  end =
  struct
    let (//) = Filename.concat
    type t =
      | Global of string 
      | Scope of string * scope 
    and scope = string
    let to_string (x : t) =
      match x with | Global s -> s | Scope (s, scope) -> scope // s
    let print fmt (x : t) =
      match x with
      | Global s -> Format.pp_print_string fmt s
      | Scope (name, scope) -> Format.fprintf fmt "%s/%s" scope name
    let equal (x : t) y =
      match (x, y) with
      | (Scope (a0, a1), Scope (b0, b1)) -> (a0 = b0) && (a1 = b1)
      | (Global a0, Global b0) -> a0 = b0
      | (Scope _, Global _)|(Global _, Scope _) -> false
    let extract_pkg_name_and_file (s : string) =
      let len = String.length s in
      assert (len > 0);
      (let v = String.unsafe_get s 0 in
       if v = '@'
       then
         let scope_id = Ext_string.no_slash_idx s in
         (assert (scope_id > 0);
          (let pkg_id = Ext_string.no_slash_idx_from s (scope_id + 1) in
           let scope = String.sub s 0 scope_id in
           if pkg_id < 0
           then
             ((Scope
                 ((String.sub s (scope_id + 1) ((len - scope_id) - 1)),
                   scope)), "")
           else
             ((Scope
                 ((String.sub s (scope_id + 1) ((pkg_id - scope_id) - 1)),
                   scope)), (String.sub s (pkg_id + 1) ((len - pkg_id) - 1)))))
       else
         (let pkg_id = Ext_string.no_slash_idx s in
          if pkg_id < 0
          then ((Global s), "")
          else
            ((Global (String.sub s 0 pkg_id)),
              (String.sub s (pkg_id + 1) ((len - pkg_id) - 1)))))[@@ocaml.doc
                                                                   "\n  input: {[\n    @hello/yy/xx\n    hello/yy\n  ]}\n  FIXME: fix invalid input\n  {[\n    hello//xh//helo\n  ]}\n"]
    let string_as_package (s : string) =
      (let len = String.length s in
       assert (len > 0);
       (let v = String.unsafe_get s 0 in
        if v = '@'
        then
          let scope_id = Ext_string.no_slash_idx s in
          (assert (scope_id > 0);
           Scope
             ((String.sub s (scope_id + 1) ((len - scope_id) - 1)),
               (String.sub s 0 scope_id)))
        else Global s) : t)
  end 
module Ext_json_types =
  struct
    type loc = Lexing.position
    type json_str = {
      str: string ;
      loc: loc }
    type json_flo = {
      flo: string ;
      loc: loc }
    type json_array = {
      content: t array ;
      loc_start: loc ;
      loc_end: loc }
    and json_map = {
      map: t Map_string.t ;
      loc: loc }
    and t =
      | True of loc 
      | False of loc 
      | Null of loc 
      | Flo of json_flo 
      | Str of json_str 
      | Arr of json_array 
      | Obj of json_map 
  end
module Ext_position :
  sig
    type t = Lexing.position =
      {
      pos_fname: string ;
      pos_lnum: int ;
      pos_bol: int ;
      pos_cnum: int }
    val lexbuf_from_channel_with_fname :
      in_channel -> string -> Lexing.lexbuf
    val print : Format.formatter -> t -> unit
  end =
  struct
    type t = Lexing.position =
      {
      pos_fname: string ;
      pos_lnum: int ;
      pos_bol: int ;
      pos_cnum: int }
    let print fmt (pos : t) =
      Format.fprintf fmt "(line %d, column %d)" pos.pos_lnum
        (pos.pos_cnum - pos.pos_bol)
    let lexbuf_from_channel_with_fname ic fname =
      let x = Lexing.from_function (fun buf -> fun n -> input ic buf 0 n) in
      let pos : t =
        { pos_fname = fname; pos_lnum = 1; pos_bol = 0; pos_cnum = 0 } in
      x.lex_start_p <- pos; x.lex_curr_p <- pos; x
  end 
module Ext_json :
  sig
    type path = string list
    type status =
      | No_path [@dead "Ext_json.status.+No_path"]
      | Found of Ext_json_types.t [@dead "Ext_json.status.+Found"]
      | Wrong_type of path [@dead "Ext_json.status.+Wrong_type"]
    type callback =
      [ `Str of string -> unit 
      | `Str_loc of string -> Lexing.position -> unit 
      | `Flo of string -> unit 
      | `Flo_loc of string -> Lexing.position -> unit 
      | `Bool of bool -> unit 
      | `Obj of Ext_json_types.t Map_string.t -> unit 
      | `Arr of Ext_json_types.t array -> unit 
      | `Arr_loc of
          Ext_json_types.t array ->
            Lexing.position -> Lexing.position -> unit
           | `Null of unit -> unit 
      | `Not_found of unit -> unit  | `Id of Ext_json_types.t -> unit ]
    val test :
      ?fail:(unit -> unit) ->
        string ->
          callback ->
            Ext_json_types.t Map_string.t -> Ext_json_types.t Map_string.t
    val loc_of : Ext_json_types.t -> Ext_position.t
  end =
  struct
    type callback =
      [ `Str of string -> unit 
      | `Str_loc of string -> Lexing.position -> unit 
      | `Flo of string -> unit 
      | `Flo_loc of string -> Lexing.position -> unit 
      | `Bool of bool -> unit 
      | `Obj of Ext_json_types.t Map_string.t -> unit 
      | `Arr of Ext_json_types.t array -> unit 
      | `Arr_loc of
          Ext_json_types.t array ->
            Lexing.position -> Lexing.position -> unit
           | `Null of unit -> unit 
      | `Not_found of unit -> unit  | `Id of Ext_json_types.t -> unit ]
    type path = string list
    type status =
      | No_path 
      | Found of Ext_json_types.t 
      | Wrong_type of path 
    let test ?(fail= fun () -> ())  key (cb : callback)
      (m : Ext_json_types.t Map_string.t) =
      (match ((Map_string.find_exn m key), cb) with
       | exception Not_found ->
           (match cb with | `Not_found f -> f () | _ -> fail ())
       | (True _, `Bool cb) -> cb true
       | (False _, `Bool cb) -> cb false
       | (Flo { flo = s }, `Flo cb) -> cb s
       | (Flo { flo = s; loc }, `Flo_loc cb) -> cb s loc
       | (Obj { map = b }, `Obj cb) -> cb b
       | (Arr { content }, `Arr cb) -> cb content
       | (Arr { content; loc_start; loc_end }, `Arr_loc cb) ->
           cb content loc_start loc_end
       | (Null _, `Null cb) -> cb ()
       | (Str { str = s }, `Str cb) -> cb s
       | (Str { str = s; loc }, `Str_loc cb) -> cb s loc
       | (any, `Id cb) -> cb any
       | (_, _) -> fail ());
      m
    let loc_of (x : Ext_json_types.t) =
      match x with
      | True p|False p|Null p -> p
      | Str p -> p.loc
      | Arr p -> p.loc_start
      | Obj p -> p.loc
      | Flo p -> p.loc
  end 
module Bsb_exception :
  sig
    type error[@@ocaml.doc "\n    This module is used for fatal errros\n"]
    exception Error of error 
    val print : Format.formatter -> error -> unit
    val package_not_found : pkg:Bsb_pkg_types.t -> json:string option -> 'a
    val conflict_module : string -> string -> string -> 'a
    val errorf : loc:Ext_position.t -> ('a, unit, string, 'b) format4 -> 'a
    val config_error : Ext_json_types.t -> string -> 'a
    val invalid_spec : string -> 'a
    val invalid_json : string -> 'a
    val no_implementation : string -> 'a
  end =
  struct
    type error =
      | Package_not_found of Bsb_pkg_types.t * string option 
      | Json_config of Ext_position.t * string 
      | Invalid_json of string 
      | Invalid_spec of string 
      | Conflict_module of string * string * string 
      | No_implementation of string 
      | Not_consistent of string 
    exception Error of error 
    let error err = raise (Error err)
    let package_not_found ~pkg  ~json  =
      error (Package_not_found (pkg, json))
    let print (fmt : Format.formatter) (x : error) =
      match x with
      | Conflict_module (modname, dir1, dir2) ->
          Format.fprintf fmt
            "@{<error>Error:@} %s found in two directories: (%s, %s)\nFile names must be unique per project"
            modname dir1 dir2
      | Not_consistent modname ->
          Format.fprintf fmt
            "@{<error>Error:@} %s has implementation/interface in non-consistent syntax(reason/ocaml)"
            modname
      | No_implementation modname ->
          Format.fprintf fmt
            "@{<error>Error:@} %s does not have implementation file" modname
      | Package_not_found (name, json_opt) ->
          let in_json =
            match json_opt with
            | None -> Ext_string.empty
            | Some x -> " in " ^ x in
          let name = Bsb_pkg_types.to_string name in
          if Ext_string.equal name Bs_version.package_name
          then
            Format.fprintf fmt
              "File \"bsconfig.json\", line 1\n@{<error>Error:@} package @{<error>bs-platform@} is not found %s\nIt's the basic, required package. If you have it installed globally,\nPlease run `npm link bs-platform` to make it available"
              in_json
          else
            Format.fprintf fmt
              "File \"bsconfig.json\", line 1\n@{<error>Error:@} package @{<error>%s@} not found or built %s\n- Did you install it?\n- If you did, did you run `bsb -make-world`?"
              name in_json
      | Json_config (pos, s) ->
          Format.fprintf fmt
            "File \"bsconfig.json\", line %d:\n@{<error>Error:@} %s \nFor more details, please checkout the schema http://bucklescript.github.io/bucklescript/docson/#build-schema.json"
            pos.pos_lnum s
      | Invalid_spec s ->
          Format.fprintf fmt "@{<error>Error: Invalid bsconfig.json %s@}" s
      | Invalid_json s ->
          Format.fprintf fmt
            "File %S, line 1\n@{<error>Error: Invalid json format@}" s
    let conflict_module modname dir1 dir2 =
      error (Conflict_module (modname, dir1, dir2))
    let no_implementation modname = error (No_implementation modname)
    let errorf ~loc  fmt =
      Format.ksprintf (fun s -> error (Json_config (loc, s))) fmt
    let config_error config fmt =
      let loc = Ext_json.loc_of config in error (Json_config (loc, fmt))
    let invalid_spec s = error (Invalid_spec s)
    let invalid_json s = error (Invalid_json s)
    let () =
      Printexc.register_printer
        (fun x ->
           match x with
           | Error x -> Some (Format.asprintf "%a" print x)
           | _ -> None)
  end 
module Ext_buffer :
  sig
    [@@@ocaml.text
      " Extensible buffers.\n\n   This module implements buffers that automatically expand\n   as necessary.  It provides accumulative concatenation of strings\n   in quasi-linear time (instead of quadratic time when strings are\n   concatenated pairwise).\n"]
    type t[@@ocaml.doc " The abstract type of buffers. "]
    val create : int -> t[@@ocaml.doc
                           " [create n] returns a fresh buffer, initially empty.\n   The [n] parameter is the initial size of the internal byte sequence\n   that holds the buffer contents. That byte sequence is automatically\n   reallocated when more than [n] characters are stored in the buffer,\n   but shrinks back to [n] characters when [reset] is called.\n   For best performance, [n] should be of the same order of magnitude\n   as the number of characters that are expected to be stored in\n   the buffer (for instance, 80 for a buffer that holds one output\n   line).  Nothing bad will happen if the buffer grows beyond that\n   limit, however. In doubt, take [n = 16] for instance.\n   If [n] is not between 1 and {!Sys.max_string_length}, it will\n   be clipped to that interval. "]
    val contents : t -> string[@@ocaml.doc
                                " Return a copy of the current contents of the buffer.\n    The buffer itself is unchanged. "]
    [@@@ocaml.text " Empty the buffer. "]
    val add_char : t -> char -> unit[@@ocaml.doc
                                      " [add_char b c] appends the character [c] at the end of the buffer [b]. "]
    [@@@ocaml.text
      " [add_string b s] appends the string [s] at the end of the buffer [b].\n    @since 4.02 "]
    [@@@ocaml.text
      " [add_substring b s ofs len] takes [len] characters from offset\n   [ofs] in string [s] and appends them at the end of the buffer [b]. "]
    [@@@ocaml.text
      " [add_substring b s ofs len] takes [len] characters from offset\n    [ofs] in byte sequence [s] and appends them at the end of the buffer [b].\n    @since 4.02 "]
    [@@@ocaml.text
      " [add_buffer b1 b2] appends the current contents of buffer [b2]\n   at the end of buffer [b1].  [b2] is not modified. "]
    [@@@ocaml.text
      " [add_channel b ic n] reads exactly [n] character from the\n   input channel [ic] and stores them at the end of buffer [b].\n   Raise [End_of_file] if the channel contains fewer than [n]\n   characters. "]
    val output_buffer : out_channel -> t -> unit[@@ocaml.doc
                                                  " [output_buffer oc b] writes the current contents of buffer [b]\n   on the output channel [oc]. "]
    val digest : t -> Digest.t
    val add_int_1 : t -> int -> unit
    val add_int_2 : t -> int -> unit
    val add_int_3 : t -> int -> unit
    val add_int_4 : t -> int -> unit
    val add_string_char : t -> string -> char -> unit
    val add_char_string : t -> char -> string -> unit
  end =
  struct
    type t =
      {
      mutable buffer: bytes ;
      mutable position: int ;
      mutable length: int ;
      initial_buffer: bytes }
    let create n =
      let n = if n < 1 then 1 else n in
      let n = if n > Sys.max_string_length then Sys.max_string_length else n in
      let s = Bytes.create n in
      { buffer = s; position = 0; length = n; initial_buffer = s }
    let contents b = Bytes.sub_string b.buffer 0 b.position
    let resize b more =
      let len = b.length in
      let new_len = ref len in
      while (b.position + more) > (!new_len) do new_len := (2 * (!new_len))
        done;
      if (!new_len) > Sys.max_string_length
      then
        (if (b.position + more) <= Sys.max_string_length
         then new_len := Sys.max_string_length
         else failwith "Ext_buffer.add: cannot grow buffer");
      (let new_buffer = Bytes.create (!new_len) in
       Bytes.blit b.buffer 0 new_buffer 0 b.position;
       b.buffer <- new_buffer;
       b.length <- (!new_len);
       assert ((b.position + more) <= b.length))
    let add_char b c =
      let pos = b.position in
      if pos >= b.length then resize b 1;
      Bytes.unsafe_set b.buffer pos c;
      b.position <- (pos + 1)
    let add_string_char b s c =
      let s_len = String.length s in
      let len = s_len + 1 in
      let new_position = b.position + len in
      if new_position > b.length then resize b len;
      (let b_buffer = b.buffer in
       Ext_bytes.unsafe_blit_string s 0 b_buffer b.position s_len;
       Bytes.unsafe_set b_buffer (new_position - 1) c;
       b.position <- new_position)
    let add_char_string b c s =
      let s_len = String.length s in
      let len = s_len + 1 in
      let new_position = b.position + len in
      if new_position > b.length then resize b len;
      (let b_buffer = b.buffer in
       let b_position = b.position in
       Bytes.unsafe_set b_buffer b_position c;
       Ext_bytes.unsafe_blit_string s 0 b_buffer (b_position + 1) s_len;
       b.position <- new_position)
    let output_buffer oc b = output oc b.buffer 0 b.position
    external unsafe_string :
      bytes -> int -> int -> Digest.t = "caml_md5_string"
    let digest b = unsafe_string b.buffer 0 b.position
    let add_int_1 (b : t) (x : int) =
      let c = Char.unsafe_chr (x land 0xff) in
      let pos = b.position in
      if pos >= b.length then resize b 1;
      Bytes.unsafe_set b.buffer pos c;
      b.position <- (pos + 1)[@@ocaml.doc
                               "\n  It could be one byte, two bytes, three bytes and four bytes \n  TODO: inline for better performance\n"]
    let add_int_2 (b : t) (x : int) =
      let c1 = Char.unsafe_chr (x land 0xff) in
      let c2 = Char.unsafe_chr ((x lsr 8) land 0xff) in
      let pos = b.position in
      if (pos + 1) >= b.length then resize b 2;
      (let b_buffer = b.buffer in
       Bytes.unsafe_set b_buffer pos c1;
       Bytes.unsafe_set b_buffer (pos + 1) c2;
       b.position <- (pos + 2))
    let add_int_3 (b : t) (x : int) =
      let c1 = Char.unsafe_chr (x land 0xff) in
      let c2 = Char.unsafe_chr ((x lsr 8) land 0xff) in
      let c3 = Char.unsafe_chr ((x lsr 16) land 0xff) in
      let pos = b.position in
      if (pos + 2) >= b.length then resize b 3;
      (let b_buffer = b.buffer in
       Bytes.unsafe_set b_buffer pos c1;
       Bytes.unsafe_set b_buffer (pos + 1) c2;
       Bytes.unsafe_set b_buffer (pos + 2) c3;
       b.position <- (pos + 3))
    let add_int_4 (b : t) (x : int) =
      let c1 = Char.unsafe_chr (x land 0xff) in
      let c2 = Char.unsafe_chr ((x lsr 8) land 0xff) in
      let c3 = Char.unsafe_chr ((x lsr 16) land 0xff) in
      let c4 = Char.unsafe_chr ((x lsr 24) land 0xff) in
      let pos = b.position in
      if (pos + 3) >= b.length then resize b 4;
      (let b_buffer = b.buffer in
       Bytes.unsafe_set b_buffer pos c1;
       Bytes.unsafe_set b_buffer (pos + 1) c2;
       Bytes.unsafe_set b_buffer (pos + 2) c3;
       Bytes.unsafe_set b_buffer (pos + 3) c4;
       b.position <- (pos + 4))
  end 
module Ext_filename :
  sig
    [@@@ocaml.text
      " An extension module to calculate relative path follow node/npm style. \n    TODO : this short name will have to change upon renaming the file.\n"]
    val is_dir_sep : char -> bool
    val maybe_quote : string -> string
    val chop_extension_maybe : string -> string
    val get_extension_maybe : string -> string
    type module_info = {
      module_name: string ;
      case: bool }
    val as_module : basename:string -> module_info option
  end =
  struct
    let is_dir_sep_unix c = c = '/'
    let is_dir_sep_win_cygwin c = (c = '/') || ((c = '\\') || (c = ':'))
    let is_dir_sep =
      if Sys.unix then is_dir_sep_unix else is_dir_sep_win_cygwin
    let maybe_quote (s : string) =
      let noneed_quote =
        Ext_string.for_all s
          (function
           | '0'..'9'|'a'..'z'|'A'..'Z'|'_'|'+'|'-'|'.'|'/'|'@' -> true
           | _ -> false) in
      if noneed_quote then s else Filename.quote s
    let chop_extension_maybe name =
      let rec search_dot i =
        if (i < 0) || (is_dir_sep (String.unsafe_get name i))
        then name
        else
          if (String.unsafe_get name i) = '.'
          then String.sub name 0 i
          else search_dot (i - 1) in
      search_dot ((String.length name) - 1)
    let get_extension_maybe name =
      let name_len = String.length name in
      let rec search_dot name i name_len =
        if (i < 0) || (is_dir_sep (String.unsafe_get name i))
        then ""
        else
          if (String.unsafe_get name i) = '.'
          then String.sub name i (name_len - i)
          else search_dot name (i - 1) name_len in
      search_dot name (name_len - 1) name_len
    type module_info = {
      module_name: string ;
      case: bool }
    let rec valid_module_name_aux name off len =
      if off >= len
      then true
      else
        (let c = String.unsafe_get name off in
         match c with
         | 'A'..'Z'|'a'..'z'|'0'..'9'|'_'|'\'' ->
             valid_module_name_aux name (off + 1) len
         | _ -> false)
    type state =
      | Invalid 
      | Upper 
      | Lower 
    let valid_module_name name len =
      if len = 0
      then Invalid
      else
        (let c = String.unsafe_get name 0 in
         match c with
         | 'A'..'Z' ->
             if valid_module_name_aux name 1 len then Upper else Invalid
         | 'a'..'z' ->
             if valid_module_name_aux name 1 len then Lower else Invalid
         | _ -> Invalid)
    let as_module ~basename  =
      let rec search_dot i name name_len =
        if i < 0
        then
          match valid_module_name name name_len with
          | Invalid -> None
          | Upper -> Some { module_name = name; case = true }
          | Lower ->
              Some
                {
                  module_name = (Ext_string.capitalize_ascii name);
                  case = false
                }
        else
          if (String.unsafe_get name i) = '.'
          then
            (match valid_module_name name i with
             | Invalid -> None
             | Upper ->
                 Some
                   {
                     module_name = (Ext_string.capitalize_sub name i);
                     case = true
                   }
             | Lower ->
                 Some
                   {
                     module_name = (Ext_string.capitalize_sub name i);
                     case = false
                   })
          else search_dot (i - 1) name name_len in
      let name_len = String.length basename in
      search_dot (name_len - 1) basename name_len
  end 
module Ext_js_file_kind =
  struct
    type t =
      | Upper_js [@dead "Ext_js_file_kind.t.+Upper_js"]
      | Upper_bs [@dead "Ext_js_file_kind.t.+Upper_bs"]
      | Little_js [@dead "Ext_js_file_kind.t.+Little_js"]
      | Little_bs [@dead "Ext_js_file_kind.t.+Little_bs"]
  end
module Ext_namespace :
  sig
    val change_ext_ns_suffix : string -> string -> string
    val is_valid_npm_package_name : string -> bool
    val namespace_of_package_name : string -> string
  end =
  struct
    let rec rindex_rec s i =
      if i < 0
      then i
      else
        (let char = String.unsafe_get s i in
         if Ext_filename.is_dir_sep char
         then (-1)
         else if char = Literals.ns_sep_char then i else rindex_rec s (i - 1))
    let change_ext_ns_suffix name ext =
      let i = rindex_rec name ((String.length name) - 1) in
      if i < 0 then name ^ ext else (String.sub name 0 i) ^ ext
    let is_valid_npm_package_name (s : string) =
      let len = String.length s in
      (len <= 214) &&
        ((len > 0) &&
           (match String.unsafe_get s 0 with
            | 'a'..'z'|'@' ->
                Ext_string.for_all_from s 1
                  (fun x ->
                     match x with
                     | 'a'..'z'|'0'..'9'|'_'|'-' -> true
                     | _ -> false)
            | _ -> false))
    let namespace_of_package_name (s : string) =
      (let len = String.length s in
       let buf = Ext_buffer.create len in
       let add capital ch =
         Ext_buffer.add_char buf
           (if capital then Char.uppercase_ascii ch else ch) in
       let rec aux capital off len =
         if off >= len
         then ()
         else
           (let ch = String.unsafe_get s off in
            match ch with
            | 'a'..'z'|'A'..'Z'|'0'..'9'|'_' ->
                (add capital ch; aux false (off + 1) len)
            | '/'|'-' -> aux true (off + 1) len
            | _ -> aux capital (off + 1) len) in
       aux true 0 len; Ext_buffer.contents buf : string)
  end 
module Bsb_package_specs :
  sig
    type t
    val default_package_specs : t
    val from_json : Ext_json_types.t -> t
    val get_list_of_output_js : t -> bool -> string -> string list
    val package_flag_of_package_specs : t -> string -> string[@@ocaml.doc
                                                               "\n  Sample output: {[ -bs-package-output commonjs:lib/js/jscomp/test]}\n"]
    val list_dirs_by : t -> (string -> unit) -> unit
  end =
  struct
    let (//) = Ext_path.combine
    type format =
      | NodeJS 
      | Es6 
      | Es6_global 
    type spec = {
      format: format ;
      in_source: bool }
    module Spec_set =
      (Set.Make)(struct type t = spec
                        let compare = Pervasives.compare end)
    type t = Spec_set.t
    let bad_module_format_message_exn ~loc  format =
      Bsb_exception.errorf ~loc
        "package-specs: `%s` isn't a valid output module format. It has to be one of:  %s, %s or %s"
        format Literals.commonjs Literals.es6 Literals.es6_global
    let supported_format (x : string) loc =
      if x = Literals.commonjs
      then NodeJS
      else
        if x = Literals.es6
        then Es6
        else
          if x = Literals.es6_global
          then Es6_global
          else bad_module_format_message_exn ~loc x
    let string_of_format (x : format) =
      match x with
      | NodeJS -> Literals.commonjs
      | Es6 -> Literals.es6
      | Es6_global -> Literals.es6_global
    let prefix_of_format (x : format) =
      match x with
      | NodeJS -> Bsb_config.lib_js
      | Es6 -> Bsb_config.lib_es6
      | Es6_global -> Bsb_config.lib_es6_global
    let rec from_array (arr : Ext_json_types.t array) =
      (let spec = ref Spec_set.empty in
       let has_in_source = ref false in
       Ext_array.iter arr
         (fun x ->
            let result = from_json_single x in
            if result.in_source
            then
              (if not (!has_in_source)
               then has_in_source := true
               else
                 Bsb_exception.errorf ~loc:(Ext_json.loc_of x)
                   "package-specs: we've detected two module formats that are both configured to be in-source.");
            spec := (Spec_set.add result (!spec)));
       !spec : Spec_set.t)
    and from_json_single (x : Ext_json_types.t) =
      (match x with
       | Str { str = format; loc } ->
           { format = (supported_format format loc); in_source = false }
       | Obj { map; loc } ->
           (match Map_string.find_exn map "module" with
            | Str { str = format } ->
                let in_source =
                  match Map_string.find_opt map Bsb_build_schemas.in_source
                  with
                  | Some (True _) -> true
                  | Some _|None -> false in
                { format = (supported_format format loc); in_source }
            | Arr _ ->
                Bsb_exception.errorf ~loc
                  "package-specs: when the configuration is an object, `module` field should be a string, not an array. If you want to pass multiple module specs, try turning package-specs into an array of objects (or strings) instead."
            | _ ->
                Bsb_exception.errorf ~loc
                  "package-specs: the `module` field of the configuration object should be a string."
            | exception _ ->
                Bsb_exception.errorf ~loc
                  "package-specs: when the configuration is an object, the `module` field is mandatory.")
       | _ ->
           Bsb_exception.errorf ~loc:(Ext_json.loc_of x)
             "package-specs: we expect either a string or an object." : 
      spec)
    let from_json (x : Ext_json_types.t) =
      (match x with
       | Arr { content;_} -> from_array content
       | _ -> Spec_set.singleton (from_json_single x) : Spec_set.t)
    let bs_package_output = "-bs-package-output"
    let package_flag ({ format; in_source } : spec) dir =
      Ext_string.inter2 bs_package_output
        (Ext_string.concat3 (string_of_format format) Ext_string.single_colon
           (if in_source then dir else (prefix_of_format format) // dir))
      [@@ocaml.doc
        " Assume input is valid \n    {[ -bs-package-output commonjs:lib/js/jscomp/test ]}\n"]
    let package_flag_of_package_specs (package_specs : t) (dirname : string)
      =
      (Spec_set.fold
         (fun format ->
            fun acc -> Ext_string.inter2 acc (package_flag format dirname))
         package_specs Ext_string.empty : string)
    let default_package_specs =
      Spec_set.singleton { format = NodeJS; in_source = false }
    let get_list_of_output_js (package_specs : Spec_set.t) (bs_suffix : bool)
      (output_file_sans_extension : string) =
      Spec_set.fold
        (fun (spec : spec) ->
           fun acc ->
             let basename =
               Ext_namespace.change_ext_ns_suffix output_file_sans_extension
                 (if bs_suffix
                  then Literals.suffix_bs_js
                  else Literals.suffix_js) in
             (Bsb_config.proj_rel @@
                (if spec.in_source
                 then basename
                 else (prefix_of_format spec.format) // basename))
               :: acc) package_specs [][@@ocaml.doc
                                         "\n    [get_list_of_output_js specs \"src/hi/hello\"]\n\n"]
    let list_dirs_by (package_specs : Spec_set.t) (f : string -> unit) =
      Spec_set.iter
        (fun (spec : spec) ->
           if not spec.in_source then f (prefix_of_format spec.format))
        package_specs
  end 
module Bsc_warnings =
  struct
    [@@@ocaml.text
      "\n  See the meanings of the warning codes here: https://caml.inria.fr/pub/docs/manual-ocaml/comp.html#sec281\n\n  - 30 Two labels or constructors of the same name are defined in two mutually recursive types.\n  - 40 Constructor or label name used out of scope.\n\n  - 6 Label omitted in function application.\n  - 7 Method overridden.\n  - 9 Missing fields in a record pattern. (*Not always desired, in some cases need [@@@warning \"+9\"] *)\n  - 27 Innocuous unused variable: unused variable that is not bound with let nor as, and doesn\226\128\153t start with an underscore (_) character.\n  - 29 Unescaped end-of-line in a string constant (non-portable code).\n  - 32 .. 39 Unused blabla\n  - 44 Open statement shadows an already defined identifier.\n  - 45 Open statement shadows an already defined label or constructor.\n  - 48 Implicit elimination of optional arguments. https://caml.inria.fr/mantis/view.php?id=6352\n  - 101 (bsb-specific) unsafe polymorphic comparison.\n"]
    let defaults_w = "+a-4-9-40-41-42-50-61-102"
  end
module Bsb_warning :
  sig
    type t
    val to_merlin_string : t -> string[@@ocaml.doc
                                        " Extra work is need to make merlin happy "]
    val from_map : Ext_json_types.t Map_string.t -> t
    val to_bsb_string : toplevel:bool -> t -> string[@@ocaml.doc
                                                      " [to_bsb_string not_dev warning]\n"]
    val use_default : t
  end =
  struct
    type warning_error =
      | Warn_error_false 
      | Warn_error_true 
      | Warn_error_number of string 
    type t0 = {
      number: string option ;
      error: warning_error }
    type nonrec t = t0 option
    let use_default = None
    let prepare_warning_concat ~beg:(beg : bool)  s =
      let s = Ext_string.trim s in
      if s = ""
      then s
      else
        (match s.[0] with
         | '0'..'9' -> if beg then "-w +" ^ s else "+" ^ s
         | 'a'..'z' -> if beg then "-w " ^ s else "-" ^ s
         | 'A'..'Z' -> if beg then "-w " ^ s else "+" ^ s
         | _ -> if beg then "-w " ^ s else s)
    let to_merlin_string x =
      "-w " ^
        (Bsc_warnings.defaults_w ^
           (match x with
            | Some { number = None }|None -> Ext_string.empty
            | Some { number = Some x } -> prepare_warning_concat ~beg:false x))
    let from_map (m : Ext_json_types.t Map_string.t) =
      let number_opt = Map_string.find_opt m Bsb_build_schemas.number in
      let error_opt = Map_string.find_opt m Bsb_build_schemas.error in
      match (number_opt, error_opt) with
      | (None, None) -> None
      | (_, _) ->
          let error =
            match error_opt with
            | Some (True _) -> Warn_error_true
            | Some (False _) -> Warn_error_false
            | Some (Str { str }) -> Warn_error_number str
            | Some x ->
                Bsb_exception.config_error x "expect true/false or string"
            | None -> Warn_error_false in
          let number =
            match number_opt with
            | Some (Str { str = number }) -> Some number
            | None -> None
            | Some x -> Bsb_exception.config_error x "expect a string" in
          Some { number; error }
    let to_bsb_string ~toplevel  warning =
      if toplevel
      then
        match warning with
        | None -> Ext_string.empty
        | Some warning ->
            (match warning.number with
             | None -> Ext_string.empty
             | Some x -> prepare_warning_concat ~beg:true x) ^
              ((match warning.error with
                | Warn_error_true -> " -warn-error A"
                | Warn_error_number y -> " -warn-error " ^ y
                | Warn_error_false -> Ext_string.empty))
      else " -w a"
  end 
module Bs_hash_stubs =
  struct
    external hash_string : string -> int = "caml_bs_hash_string"[@@noalloc ]
  end
module Ext_util : sig val power_2_above : int -> int -> int end =
  struct
    let rec power_2_above x n =
      if x >= n
      then x
      else
        if (x * 2) > Sys.max_array_length then x else power_2_above (x * 2) n
      [@@ocaml.doc
        "\n   {[\n     (power_2_above 16 63 = 64)\n       (power_2_above 16 76 = 128)\n   ]}\n"]
  end 
module Hash_set_gen =
  struct
    type 'a bucket =
      | Empty 
      | Cons of {
      mutable key: 'a ;
      mutable next: 'a bucket } 
    type 'a t =
      {
      mutable size: int ;
      mutable data: 'a bucket array ;
      initial_size: int }
    let create initial_size =
      let s = Ext_util.power_2_above 16 initial_size in
      { initial_size = s; size = 0; data = (Array.make s Empty) }
    let resize indexfun h =
      let odata = h.data in
      let osize = Array.length odata in
      let nsize = osize * 2 in
      if nsize < Sys.max_array_length
      then
        let ndata = Array.make nsize Empty in
        let ndata_tail = Array.make nsize Empty in
        (h.data <- ndata;
         (let rec insert_bucket =
            function
            | Empty -> ()
            | Cons { key; next } as cell ->
                let nidx = indexfun h key in
                ((match Array.unsafe_get ndata_tail nidx with
                  | Empty -> Array.unsafe_set ndata nidx cell
                  | Cons tail -> tail.next <- cell);
                 Array.unsafe_set ndata_tail nidx cell;
                 insert_bucket next) in
          for i = 0 to osize - 1 do insert_bucket (Array.unsafe_get odata i)
          done;
          for i = 0 to nsize - 1 do
            (match Array.unsafe_get ndata_tail i with
             | Empty -> ()
             | Cons tail -> tail.next <- Empty)
          done))
    let iter h f =
      let rec do_bucket =
        function | Empty -> () | Cons l -> (f l.key; do_bucket l.next) in
      let d = h.data in
      for i = 0 to (Array.length d) - 1 do do_bucket (Array.unsafe_get d i)
      done
    let rec small_bucket_mem eq key lst =
      match lst with
      | Empty -> false
      | Cons lst ->
          (eq key lst.key) ||
            ((match lst.next with
              | Empty -> false
              | Cons lst ->
                  (eq key lst.key) ||
                    ((match lst.next with
                      | Empty -> false
                      | Cons lst ->
                          (eq key lst.key) ||
                            (small_bucket_mem eq key lst.next)))))
    module type S  =
      sig
        type key
        type t
        val create : int -> t
        val add : t -> key -> unit
        val iter : t -> (key -> unit) -> unit
      end
  end
module Hash_set_string :
  sig include (Hash_set_gen.S with type  key =  string) end =
  struct
    [@@@warning "-32"]
    type key = string
    let key_index (h : _ Hash_set_gen.t) (key : key) =
      (Bs_hash_stubs.hash_string key) land ((Array.length h.data) - 1)
    let eq_key = Ext_string.equal
    type t = key Hash_set_gen.t
    let create = Hash_set_gen.create
    let iter = Hash_set_gen.iter
    let add (h : _ Hash_set_gen.t) key =
      let i = key_index h key in
      let h_data = h.data in
      let old_bucket = Array.unsafe_get h_data i in
      if not (Hash_set_gen.small_bucket_mem eq_key key old_bucket)
      then
        (Array.unsafe_set h_data i (Cons { key; next = old_bucket });
         h.size <- (h.size + 1);
         if h.size > ((Array.length h_data) lsl 1)
         then Hash_set_gen.resize key_index h)
  end 
module Bsb_config_types =
  struct
    type dependency =
      {
      package_name: Bsb_pkg_types.t
        [@dead "Bsb_config_types.dependency.+package_name"];
      package_install_path: string }
    type dependencies = dependency list
    type entries_t =
      | JsTarget of string [@dead "Bsb_config_types.entries_t.+JsTarget"]
      | NativeTarget of string
      [@dead "Bsb_config_types.entries_t.+NativeTarget"]
      | BytecodeTarget of string
      [@dead "Bsb_config_types.entries_t.+BytecodeTarget"]
    type compilation_kind_t =
      | Js 
      | Bytecode [@dead "Bsb_config_types.compilation_kind_t.+Bytecode"]
      | Native [@dead "Bsb_config_types.compilation_kind_t.+Native"]
    type reason_react_jsx =
      | Jsx_v2 
      | Jsx_v3 
    type refmt = string option
    type gentype_config = {
      path: string }
    type command = string
    type ppx = {
      name: string ;
      args: string list }
    type t =
      {
      package_name: string ;
      namespace: string option ;
      external_includes: string list ;
      bsc_flags: string list ;
      ppx_files: ppx list ;
      pp_file: string option ;
      bs_dependencies: dependencies ;
      bs_dev_dependencies: dependencies ;
      built_in_dependency: dependency option ;
      warning: Bsb_warning.t ;
      refmt: refmt ;
      js_post_build_cmd: string option ;
      package_specs: Bsb_package_specs.t ;
      file_groups: Bsb_file_groups.t ;
      files_to_install: Hash_set_string.t ;
      generate_merlin: bool ;
      reason_react_jsx: reason_react_jsx option ;
      entries: entries_t list [@dead "Bsb_config_types.t.+entries"];
      generators: command Map_string.t ;
      cut_generators: bool [@dead "Bsb_config_types.t.+cut_generators"];
      bs_suffix: bool ;
      gentype_config: gentype_config option ;
      number_of_dev_groups: int }
  end
module Ext_color :
  sig
    type color =
      | Black [@dead "Ext_color.color.+Black"]
      | Red [@dead "Ext_color.color.+Red"]
      | Green [@dead "Ext_color.color.+Green"]
      | Yellow [@dead "Ext_color.color.+Yellow"]
      | Blue [@dead "Ext_color.color.+Blue"]
      | Magenta [@dead "Ext_color.color.+Magenta"]
      | Cyan [@dead "Ext_color.color.+Cyan"]
      | White [@dead "Ext_color.color.+White"]
    type style =
      | FG of color [@dead "Ext_color.style.+FG"]
      | BG of color [@dead "Ext_color.style.+BG"]
      | Bold [@dead "Ext_color.style.+Bold"]
      | Dim [@dead "Ext_color.style.+Dim"]
    val ansi_of_tag : string -> string[@@ocaml.doc
                                        " Input is the tag for example `@{<warning>@}` return escape code "]
    val reset_lit : string
  end =
  struct
    type color =
      | Black 
      | Red 
      | Green 
      | Yellow 
      | Blue 
      | Magenta 
      | Cyan 
      | White 
    type style =
      | FG of color 
      | BG of color 
      | Bold 
      | Dim 
    let code_of_style =
      function
      | FG (Black) -> "30"
      | FG (Red) -> "31"
      | FG (Green) -> "32"
      | FG (Yellow) -> "33"
      | FG (Blue) -> "34"
      | FG (Magenta) -> "35"
      | FG (Cyan) -> "36"
      | FG (White) -> "37"
      | BG (Black) -> "40"
      | BG (Red) -> "41"
      | BG (Green) -> "42"
      | BG (Yellow) -> "43"
      | BG (Blue) -> "44"
      | BG (Magenta) -> "45"
      | BG (Cyan) -> "46"
      | BG (White) -> "47"
      | Bold -> "1"
      | Dim -> "2"
    let style_of_tag s =
      match s with
      | "error" -> [Bold; FG Red]
      | "warning" -> [Bold; FG Magenta]
      | "info" -> [Bold; FG Yellow]
      | "dim" -> [Dim]
      | "filename" -> [FG Cyan]
      | _ -> [][@@ocaml.doc " TODO: add more styles later "]
    let ansi_of_tag s =
      let l = style_of_tag s in
      let s = String.concat ";" (Ext_list.map l code_of_style) in
      "\027[" ^ (s ^ "m")
    let reset_lit = "\027[0m"
  end 
module Bsb_log :
  sig
    val setup : unit -> unit
    type level =
      | Debug [@dead "Bsb_log.level.+Debug"]
      | Info [@dead "Bsb_log.level.+Info"]
      | Warn [@dead "Bsb_log.level.+Warn"]
      | Error [@dead "Bsb_log.level.+Error"]
    type 'a fmt =
      Format.formatter -> ('a, Format.formatter, unit) format -> 'a
    type 'a log = ('a, Format.formatter, unit) format -> 'a
    val verbose : unit -> unit
    val info : 'a log
    val warn : 'a log
    val error : 'a log
    val info_args : string array -> unit
  end =
  struct
    let ninja_ansi_forced =
      lazy (try Sys.getenv "NINJA_ANSI_FORCED" with | Not_found -> "")
    let color_enabled = lazy (Unix.isatty Unix.stdout)
    let get_color_enabled () =
      let colorful =
        match ninja_ansi_forced with
        | (lazy "1") -> true
        | (lazy ("0"|"false")) -> false
        | _ -> Lazy.force color_enabled in
      colorful
    let color_functions : Format.formatter_tag_functions =
      {
        mark_open_tag =
          (fun s ->
             if get_color_enabled ()
             then Ext_color.ansi_of_tag s
             else Ext_string.empty);
        mark_close_tag =
          (fun _ ->
             if get_color_enabled ()
             then Ext_color.reset_lit
             else Ext_string.empty);
        print_open_tag = (fun _ -> ());
        print_close_tag = (fun _ -> ())
      }
    let setup () =
      Format.pp_set_mark_tags Format.std_formatter true;
      Format.pp_set_mark_tags Format.err_formatter true;
      Format.pp_set_formatter_tag_functions Format.std_formatter
        color_functions;
      Format.pp_set_formatter_tag_functions Format.err_formatter
        color_functions
    type level =
      | Debug 
      | Info 
      | Warn 
      | Error 
    let int_of_level (x : level) =
      match x with | Debug -> 0 | Info -> 1 | Warn -> 2 | Error -> 3
    let log_level = ref Warn
    let verbose () = log_level := Debug
    let dfprintf level fmt =
      if (int_of_level level) >= (int_of_level (!log_level))
      then Format.fprintf fmt
      else Format.ifprintf fmt
    type 'a fmt =
      Format.formatter -> ('a, Format.formatter, unit) format -> 'a
    type 'a log = ('a, Format.formatter, unit) format -> 'a
    let info fmt = dfprintf Info Format.std_formatter fmt
    let warn fmt = dfprintf Warn Format.err_formatter fmt
    let error fmt = dfprintf Error Format.err_formatter fmt
    let info_args (args : string array) =
      if (int_of_level Info) >= (int_of_level (!log_level))
      then
        (for i = 0 to (Array.length args) - 1 do
           (Format.pp_print_string Format.std_formatter
              (Array.unsafe_get args i);
            Format.pp_print_string Format.std_formatter
              Ext_string.single_space)
         done;
         Format.pp_print_newline Format.std_formatter ())
      else ()
  end 
module Bsb_real_path :
  sig val is_same_paths_via_io : string -> string -> bool end =
  struct
    let (//) = Filename.concat
    let getchdir s = let p = Sys.getcwd () in Unix.chdir s; p
    let normalize s = getchdir (getchdir s)
    let real_path p =
      match try Some (Sys.is_directory p) with | Sys_error _ -> None with
      | None ->
          let rec resolve dir =
            if Sys.file_exists dir
            then normalize dir
            else
              (let parent = Filename.dirname dir in
               if dir = parent
               then dir
               else (resolve parent) // (Filename.basename dir)) in
          let p = if Filename.is_relative p then (Sys.getcwd ()) // p else p in
          resolve p
      | Some (true) -> normalize p
      | Some (false) ->
          let dir = normalize (Filename.dirname p) in
          (match Filename.basename p with | "." -> dir | base -> dir // base)
    let is_same_paths_via_io a b =
      if a = b then true else (real_path a) = (real_path b)
  end 
module Hash_gen =
  struct
    type ('a, 'b) bucket =
      | Empty 
      | Cons of
      {
      mutable key: 'a ;
      mutable data: 'b ;
      mutable next: ('a, 'b) bucket } 
    type ('a, 'b) t =
      {
      mutable size: int ;
      mutable data: ('a, 'b) bucket array ;
      initial_size: int }
    let create initial_size =
      let s = Ext_util.power_2_above 16 initial_size in
      { initial_size = s; size = 0; data = (Array.make s Empty) }
    let length h = h.size
    let resize indexfun h =
      let odata = h.data in
      let osize = Array.length odata in
      let nsize = osize * 2 in
      if nsize < Sys.max_array_length
      then
        let ndata = Array.make nsize Empty in
        let ndata_tail = Array.make nsize Empty in
        (h.data <- ndata;
         (let rec insert_bucket =
            function
            | Empty -> ()
            | Cons { key; next } as cell ->
                let nidx = indexfun h key in
                ((match Array.unsafe_get ndata_tail nidx with
                  | Empty -> Array.unsafe_set ndata nidx cell
                  | Cons tail -> tail.next <- cell);
                 Array.unsafe_set ndata_tail nidx cell;
                 insert_bucket next) in
          for i = 0 to osize - 1 do insert_bucket (Array.unsafe_get odata i)
          done;
          for i = 0 to nsize - 1 do
            (match Array.unsafe_get ndata_tail i with
             | Empty -> ()
             | Cons tail -> tail.next <- Empty)
          done))
    let iter h f =
      let rec do_bucket =
        function | Empty -> () | Cons l -> (f l.key l.data; do_bucket l.next) in
      let d = h.data in
      for i = 0 to (Array.length d) - 1 do do_bucket (Array.unsafe_get d i)
      done
    let fold h init f =
      let rec do_bucket b accu =
        match b with
        | Empty -> accu
        | Cons l -> do_bucket l.next (f l.key l.data accu) in
      let d = h.data in
      let accu = ref init in
      for i = 0 to (Array.length d) - 1 do
        accu := (do_bucket (Array.unsafe_get d i) (!accu))
      done;
      !accu
    let to_list h f =
      fold h [] (fun k -> fun data -> fun acc -> (f k data) :: acc)
    let rec small_bucket_mem (lst : _ bucket) eq key =
      match lst with
      | Empty -> false
      | Cons lst ->
          (eq key lst.key) ||
            ((match lst.next with
              | Empty -> false
              | Cons lst ->
                  (eq key lst.key) ||
                    ((match lst.next with
                      | Empty -> false
                      | Cons lst ->
                          (eq key lst.key) ||
                            (small_bucket_mem lst.next eq key)))))
    let rec small_bucket_opt eq key (lst : _ bucket) =
      (match lst with
       | Empty -> None
       | Cons lst ->
           if eq key lst.key
           then Some (lst.data)
           else
             (match lst.next with
              | Empty -> None
              | Cons lst ->
                  if eq key lst.key
                  then Some (lst.data)
                  else
                    (match lst.next with
                     | Empty -> None
                     | Cons lst ->
                         if eq key lst.key
                         then Some (lst.data)
                         else small_bucket_opt eq key lst.next)) : _ option)
    module type S  =
      sig
        type key
        type 'a t
        val create : int -> 'a t
        val add : 'a t -> key -> 'a -> unit
        val find_exn : 'a t -> key -> 'a
        val find_opt : 'a t -> key -> 'a option
        val mem : 'a t -> key -> bool
        val iter : 'a t -> (key -> 'a -> unit) -> unit
        val length : 'a t -> int
        val to_list : 'a t -> (key -> 'a -> 'c) -> 'c list
      end
  end
module Hash :
  sig
    module Make :
    functor (Key : Hashtbl.HashedType) ->
      (Hash_gen.S with type  key =  Key.t)
  end =
  struct
    module Make(Key:Hashtbl.HashedType) =
      struct
        type key = Key.t
        type 'a t = (key, 'a) Hash_gen.t
        let key_index (h : _ t) (key : key) =
          (Key.hash key) land ((Array.length h.data) - 1)
        let eq_key = Key.equal
        type ('a, 'b) bucket = ('a, 'b) Hash_gen.bucket
        let create = Hash_gen.create
        let iter = Hash_gen.iter
        let to_list = Hash_gen.to_list
        let length = Hash_gen.length
        let add (h : _ t) key data =
          let i = key_index h key in
          let h_data = h.data in
          Array.unsafe_set h_data i
            (Cons { key; data; next = (Array.unsafe_get h_data i) });
          h.size <- (h.size + 1);
          if h.size > ((Array.length h_data) lsl 1)
          then Hash_gen.resize key_index h
        let rec find_rec key (bucketlist : _ bucket) =
          match bucketlist with
          | Empty -> raise Not_found
          | Cons rhs ->
              if eq_key key rhs.key then rhs.data else find_rec key rhs.next
        let find_exn (h : _ t) key =
          match Array.unsafe_get h.data (key_index h key) with
          | Empty -> raise Not_found
          | Cons rhs ->
              if eq_key key rhs.key
              then rhs.data
              else
                (match rhs.next with
                 | Empty -> raise Not_found
                 | Cons rhs ->
                     if eq_key key rhs.key
                     then rhs.data
                     else
                       (match rhs.next with
                        | Empty -> raise Not_found
                        | Cons rhs ->
                            if eq_key key rhs.key
                            then rhs.data
                            else find_rec key rhs.next))
        let find_opt (h : _ t) key =
          Hash_gen.small_bucket_opt eq_key key
            (Array.unsafe_get h.data (key_index h key))
        let mem (h : _ t) key =
          Hash_gen.small_bucket_mem
            (Array.unsafe_get h.data (key_index h key)) eq_key key
      end
  end 
module Bsb_pkg :
  sig
    [@@@ocaml.text
      " [resolve cwd module_name], \n    [cwd] is current working directory, absolute path\n    Trying to find paths to load [module_name]\n    it is sepcialized for option [-bs-package-include] which requires\n    [npm_package_name/lib/ocaml]\n\n    it relies on [npm_config_prefix] env variable for global npm modules\n"]
    val resolve_bs_package : cwd:string -> Bsb_pkg_types.t -> string[@@ocaml.doc
                                                                    " @raise  when not found "]
    val to_list : (Bsb_pkg_types.t -> string -> 'a) -> 'a list
  end =
  struct
    let (//) = Filename.concat
    type t = Bsb_pkg_types.t
    let make_sub_path (x : t) =
      (Literals.node_modules // (Bsb_pkg_types.to_string x) : string)
    let node_paths : string list Lazy.t =
      lazy
        (try
           Ext_string.split (Sys.getenv "NODE_PATH")
             (if Sys.win32 then ';' else ':')
         with | _ -> [])[@@ocaml.doc
                          " It makes sense to have this function raise, when [bsb] could not resolve a package, it used to mean\n    a failure\n"]
    let check_dir dir =
      match Sys.file_exists dir with | true -> Some dir | false -> None
      [@@ocaml.doc
        " It makes sense to have this function raise, when [bsb] could not resolve a package, it used to mean\n    a failure\n"]
    let resolve_bs_package_aux ~cwd  (pkg : t) =
      let sub_path = make_sub_path pkg in
      let rec aux cwd =
        let abs_marker = cwd // sub_path in
        if Sys.file_exists abs_marker
        then abs_marker
        else
          (let another_cwd = Filename.dirname cwd in
           if (String.length another_cwd) < (String.length cwd)
           then aux another_cwd
           else
             (match Ext_list.find_opt (Lazy.force node_paths)
                      (fun dir ->
                         check_dir (dir // (Bsb_pkg_types.to_string pkg)))
              with
              | Some resolved_dir -> resolved_dir
              | None -> Bsb_exception.package_not_found ~pkg ~json:None)) in
      aux cwd
    module Coll =
      (Hash.Make)(struct
                    type nonrec t = t
                    let equal = Bsb_pkg_types.equal
                    let hash (x : t) = Hashtbl.hash x
                  end)
    let cache : string Coll.t = Coll.create 0
    let to_list cb = Coll.to_list cache cb
    let custom_resolution =
      lazy
        (match Sys.getenv "bs_custom_resolution" with
         | exception Not_found -> false
         | "true" -> true
         | _ -> false)
    let pkg_name_as_variable package =
      (Bsb_pkg_types.to_string package) |>
        (fun s ->
           ((Ext_string.split s '@') |> (String.concat "")) |>
             (fun s ->
                ((Ext_string.split s '_') |> (String.concat "__")) |>
                  (fun s ->
                     ((Ext_string.split s '/') |> (String.concat "__slash__"))
                       |>
                       (fun s ->
                          ((Ext_string.split s '.') |>
                             (String.concat "__dot__"))
                            |>
                            (fun s ->
                               (Ext_string.split s '-') |>
                                 (String.concat "_"))))))
    let resolve_bs_package ~cwd  (package : t) =
      if Lazy.force custom_resolution
      then
        (Bsb_log.info "@{<info>Using Custom Resolution@}@.";
         (let custom_pkg_loc = (pkg_name_as_variable package) ^ "__install" in
          let custom_pkg_location = lazy (Sys.getenv custom_pkg_loc) in
          match Lazy.force custom_pkg_location with
          | exception Not_found ->
              (Bsb_log.error
                 "@{<error>Custom resolution of package %s does not exist in var %s @}@."
                 (Bsb_pkg_types.to_string package) custom_pkg_loc;
               Bsb_exception.package_not_found ~pkg:package ~json:None)
          | path when not (Sys.file_exists path) ->
              (Bsb_log.error
                 "@{<error>Custom resolution of package %s does not exist on disk: %s=%s @}@."
                 (Bsb_pkg_types.to_string package) custom_pkg_loc path;
               Bsb_exception.package_not_found ~pkg:package ~json:None)
          | path ->
              (Bsb_log.info
                 "@{<info>Custom Resolution of package %s in var %s found at %s@}@."
                 (Bsb_pkg_types.to_string package) custom_pkg_loc path;
               path)))
      else
        (match Coll.find_opt cache package with
         | None ->
             let result = resolve_bs_package_aux ~cwd package in
             (Bsb_log.info "@{<info>Package@} %a -> %s@." Bsb_pkg_types.print
                package result;
              Coll.add cache package result;
              result)
         | Some x ->
             let result = resolve_bs_package_aux ~cwd package in
             (if not (Bsb_real_path.is_same_paths_via_io result x)
              then
                Bsb_log.warn
                  "@{<warning>Duplicated package:@} %a %s (chosen) vs %s in %s @."
                  Bsb_pkg_types.print package x result cwd;
              x))[@@ocaml.doc " TODO: collect all warnings and print later "]
    [@@@ocaml.text
      " The package does not need to be a bspackage\n    example:\n    {[\n      resolve_npm_package_file ~cwd \"reason/refmt\";;\n      resolve_npm_package_file ~cwd \"reason/refmt/xx/yy\"\n    ]}\n    It also returns the path name\n    Note the input [sub_path] is already converted to physical meaning path according to OS\n"]
  end 
module Ext_json_parse :
  sig
    type error
    val report_error : Format.formatter -> error -> unit
    exception Error of Lexing.position * Lexing.position * error 
    val parse_json_from_file : string -> Ext_json_types.t
  end =
  struct
    type error =
      | Illegal_character of char 
      | Unterminated_string 
      | Unterminated_comment 
      | Illegal_escape of string 
      | Unexpected_token 
      | Expect_comma_or_rbracket 
      | Expect_comma_or_rbrace 
      | Expect_colon 
      | Expect_string_or_rbrace 
      | Expect_eof 
    let fprintf = Format.fprintf
    let report_error ppf =
      function
      | Illegal_character c ->
          fprintf ppf "Illegal character (%s)" (Char.escaped c)
      | Illegal_escape s ->
          fprintf ppf "Illegal backslash escape in string or character (%s)"
            s
      | Unterminated_string -> fprintf ppf "Unterminated_string"
      | Expect_comma_or_rbracket -> fprintf ppf "Expect_comma_or_rbracket"
      | Expect_comma_or_rbrace -> fprintf ppf "Expect_comma_or_rbrace"
      | Expect_colon -> fprintf ppf "Expect_colon"
      | Expect_string_or_rbrace -> fprintf ppf "Expect_string_or_rbrace"
      | Expect_eof -> fprintf ppf "Expect_eof"
      | Unexpected_token -> fprintf ppf "Unexpected_token"
      | Unterminated_comment -> fprintf ppf "Unterminated_comment"
    exception Error of Lexing.position * Lexing.position * error 
    let () =
      Printexc.register_printer
        (function
         | x ->
             (match x with
              | Error (loc_start, loc_end, error) ->
                  Some
                    (Format.asprintf "@[%a:@ %a@ -@ %a)@]" report_error error
                       Ext_position.print loc_start Ext_position.print
                       loc_end)
              | _ -> None))
    type token =
      | Comma 
      | Eof 
      | False 
      | Lbrace 
      | Lbracket 
      | Null 
      | Colon 
      | Number of string 
      | Rbrace 
      | Rbracket 
      | String of string 
      | True 
    let error (lexbuf : Lexing.lexbuf) e =
      raise (Error ((lexbuf.lex_start_p), (lexbuf.lex_curr_p), e))
    let lexeme_len (x : Lexing.lexbuf) = x.lex_curr_pos - x.lex_start_pos
    let update_loc (({ lex_curr_p;_} as lexbuf) : Lexing.lexbuf) diff =
      lexbuf.lex_curr_p <-
        {
          lex_curr_p with
          pos_lnum = (lex_curr_p.pos_lnum + 1);
          pos_bol = (lex_curr_p.pos_cnum - diff)
        }
    let char_for_backslash =
      function
      | 'n' -> '\n'
      | 'r' -> '\r'
      | 'b' -> '\b'
      | 't' -> '\t'
      | c -> c
    let dec_code c1 c2 c3 =
      ((100 * ((Char.code c1) - 48)) + (10 * ((Char.code c2) - 48))) +
        ((Char.code c3) - 48)
    let hex_code c1 c2 =
      let d1 = Char.code c1 in
      let val1 =
        if d1 >= 97 then d1 - 87 else if d1 >= 65 then d1 - 55 else d1 - 48 in
      let d2 = Char.code c2 in
      let val2 =
        if d2 >= 97 then d2 - 87 else if d2 >= 65 then d2 - 55 else d2 - 48 in
      (val1 * 16) + val2
    let lf = '\n'
    let __ocaml_lex_tables =
      {
        Lexing.lex_base =
          "\000\000\239\255\240\255\241\255\000\000\025\000\011\000\244\255\245\255\246\255\247\255\248\255\249\255\000\000\000\000\000\000)\000\001\000\254\255\005\000\005\000\253\255\001\000\002\000\252\255\000\000\000\000\003\000\251\255\001\000\003\000\250\255O\000Y\000c\000y\000\131\000\141\000\153\000\163\000\001\000\253\255\254\255\023\000\255\255\006\000\246\255\189\000\248\255\215\000\255\255\249\255\249\000\181\000\252\255\t\000?\000K\000\234\000\251\255 \001\250\255";
        Lexing.lex_backtrk =
          "\255\255\255\255\255\255\255\255\r\000\r\000\016\000\255\255\255\255\255\255\255\255\255\255\255\255\016\000\016\000\016\000\016\000\016\000\255\255\000\000\012\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\r\000\255\255\r\000\255\255\r\000\255\255\255\255\255\255\255\255\001\000\255\255\255\255\255\255\b\000\255\255\255\255\255\255\255\255\006\000\006\000\255\255\006\000\001\000\002\000\255\255\255\255\255\255\255\255";
        Lexing.lex_default =
          "\001\000\000\000\000\000\000\000\255\255\255\255\255\255\000\000\000\000\000\000\000\000\000\000\000\000\255\255\255\255\255\255\255\255\255\255\000\000\255\255\020\000\000\000\255\255\255\255\000\000\255\255\255\255\255\255\000\000\255\255\255\255\000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255*\000\000\000\000\000\255\255\000\000/\000\000\000/\000\000\0003\000\000\000\000\000\255\255\255\255\000\000\255\255\255\255\255\255\255\255\000\000\255\255\000\000";
        Lexing.lex_trans =
          "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\019\000\018\000\018\000\019\000\017\000\019\000\255\2550\000\019\000\255\2559\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\019\000\000\000\003\000\000\000\000\000\019\000\000\000\000\0002\000\000\000\000\000+\000\b\000\006\000!\000\016\000\004\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\007\000\004\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000 \000,\000!\0008\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\021\0009\000\000\000\000\000\000\000\020\000\000\000\000\000\012\000\000\000\011\000 \0008\000\000\000\025\0001\000\000\000\000\000 \000\014\000\024\000\028\000\000\000\000\0009\000\026\000\030\000\r\000\031\000\000\000\000\000\022\000\027\000\015\000\029\000\023\000\000\000\000\000\000\000'\000\n\000'\000\t\000 \000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000%\000\000\000%\000\000\000#\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000\255\255#\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000\000\000\000\000\255\255\000\0008\000\000\000\000\0007\000:\000:\000:\000:\000:\000:\000:\000:\000:\000:\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0006\000\000\0006\000\000\000\000\000\000\000\000\0006\000\000\000\002\000)\000\000\000\000\000\000\000\255\255.\0005\0005\0005\0005\0005\0005\0005\0005\0005\0005\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255;\000;\000;\000;\000;\000;\000;\000;\000;\000;\000\000\000\000\000\000\000\000\000\000\000<\000<\000<\000<\000<\000<\000<\000<\000<\000<\0006\000\000\000\000\000\000\000\000\000\000\0006\000<\000<\000<\000<\000<\000<\000\000\000\000\000\000\000\000\000\000\0006\000\000\000\000\000\000\0006\000\000\0006\000\000\000\000\000\000\0004\000=\000=\000=\000=\000=\000=\000=\000=\000=\000=\000<\000<\000<\000<\000<\000<\000\000\000=\000=\000=\000=\000=\000=\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=\000=\000=\000=\000=\000=\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000";
        Lexing.lex_check =
          "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\000\000\000\017\000\000\000\000\000\019\000\020\000-\000\019\000\020\0007\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\000\000\255\255\255\255\019\000\255\255\255\255-\000\255\255\255\255(\000\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\004\000+\000\005\0008\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\016\0009\000\255\255\255\255\255\255\016\000\255\255\255\255\000\000\255\255\000\000\005\0008\000\255\255\014\000-\000\255\255\255\255\004\000\000\000\023\000\027\000\255\255\255\2559\000\025\000\029\000\000\000\030\000\255\255\255\255\015\000\026\000\000\000\r\000\022\000\255\255\255\255\255\255 \000\000\000 \000\000\000\005\000 \000 \000 \000 \000 \000 \000 \000 \000 \000 \000!\000!\000!\000!\000!\000!\000!\000!\000!\000!\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\"\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255#\000\255\255#\000\255\255\"\000#\000#\000#\000#\000#\000#\000#\000#\000#\000#\000$\000$\000$\000$\000$\000$\000$\000$\000$\000$\000%\000%\000%\000%\000%\000%\000%\000%\000%\000%\000/\000\"\000&\000&\000&\000&\000&\000&\000&\000&\000&\000&\000'\000'\000'\000'\000'\000'\000'\000'\000'\000'\000\255\255\255\255/\000\255\2551\000\255\255\255\2551\0005\0005\0005\0005\0005\0005\0005\0005\0005\0005\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\2551\000\255\2551\000\255\255\255\255\255\255\255\2551\000\255\255\000\000(\000\255\255\255\255\255\255\020\000-\0001\0001\0001\0001\0001\0001\0001\0001\0001\0001\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255/\000:\000:\000:\000:\000:\000:\000:\000:\000:\000:\000\255\255\255\255\255\255\255\255\255\2554\0004\0004\0004\0004\0004\0004\0004\0004\0004\0001\000\255\255\255\255\255\255\255\255\255\2551\0004\0004\0004\0004\0004\0004\000\255\255\255\255\255\255\255\255\255\2551\000\255\255\255\255\255\2551\000\255\2551\000\255\255\255\255\255\2551\000<\000<\000<\000<\000<\000<\000<\000<\000<\000<\0004\0004\0004\0004\0004\0004\000\255\255<\000<\000<\000<\000<\000<\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255<\000<\000<\000<\000<\000<\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255/\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\2551\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255";
        Lexing.lex_base_code = "";
        Lexing.lex_backtrk_code = "";
        Lexing.lex_default_code = "";
        Lexing.lex_trans_code = "";
        Lexing.lex_check_code = "";
        Lexing.lex_code = ""
      }
    let rec lex_json buf lexbuf = __ocaml_lex_lex_json_rec buf lexbuf 0
    and __ocaml_lex_lex_json_rec buf lexbuf __ocaml_lex_state =
      match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 -> lex_json buf lexbuf
      | 1 -> (update_loc lexbuf 0; lex_json buf lexbuf)
      | 2 -> comment buf lexbuf
      | 3 -> True
      | 4 -> False
      | 5 -> Null
      | 6 -> Lbracket
      | 7 -> Rbracket
      | 8 -> Lbrace
      | 9 -> Rbrace
      | 10 -> Comma
      | 11 -> Colon
      | 12 -> lex_json buf lexbuf
      | 13 -> Number (Lexing.lexeme lexbuf)
      | 14 ->
          let pos = Lexing.lexeme_start_p lexbuf in
          (scan_string buf pos lexbuf;
           (let content = Buffer.contents buf in
            Buffer.clear buf; String content))
      | 15 -> Eof
      | 16 ->
          let c = Lexing.sub_lexeme_char lexbuf lexbuf.Lexing.lex_start_pos in
          error lexbuf (Illegal_character c)
      | __ocaml_lex_state ->
          (lexbuf.Lexing.refill_buff lexbuf;
           __ocaml_lex_lex_json_rec buf lexbuf __ocaml_lex_state)
    and comment buf lexbuf = __ocaml_lex_comment_rec buf lexbuf 40
    and __ocaml_lex_comment_rec buf lexbuf __ocaml_lex_state =
      match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 -> lex_json buf lexbuf
      | 1 -> comment buf lexbuf
      | 2 -> error lexbuf Unterminated_comment
      | __ocaml_lex_state ->
          (lexbuf.Lexing.refill_buff lexbuf;
           __ocaml_lex_comment_rec buf lexbuf __ocaml_lex_state)
    and scan_string buf start lexbuf =
      __ocaml_lex_scan_string_rec buf start lexbuf 45
    and __ocaml_lex_scan_string_rec buf start lexbuf __ocaml_lex_state =
      match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 -> ()
      | 1 ->
          let len = (lexeme_len lexbuf) - 2 in
          (update_loc lexbuf len; scan_string buf start lexbuf)
      | 2 ->
          let len = (lexeme_len lexbuf) - 3 in
          (update_loc lexbuf len; scan_string buf start lexbuf)
      | 3 ->
          let c =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 1) in
          (Buffer.add_char buf (char_for_backslash c);
           scan_string buf start lexbuf)
      | 4 ->
          let c1 =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 1)
          and c2 =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 2)
          and c3 =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 3)
          and s =
            Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos
              (lexbuf.Lexing.lex_start_pos + 4) in
          let v = dec_code c1 c2 c3 in
          (if v > 255 then error lexbuf (Illegal_escape s);
           Buffer.add_char buf (Char.chr v);
           scan_string buf start lexbuf)
      | 5 ->
          let c1 =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 2)
          and c2 =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 3) in
          let v = hex_code c1 c2 in
          (Buffer.add_char buf (Char.chr v); scan_string buf start lexbuf)
      | 6 ->
          let c =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 1) in
          (Buffer.add_char buf '\\';
           Buffer.add_char buf c;
           scan_string buf start lexbuf)
      | 7 ->
          (update_loc lexbuf 0;
           Buffer.add_char buf lf;
           scan_string buf start lexbuf)
      | 8 ->
          let ofs = lexbuf.lex_start_pos in
          let len = lexbuf.lex_curr_pos - ofs in
          (Buffer.add_subbytes buf lexbuf.lex_buffer ofs len;
           scan_string buf start lexbuf)
      | 9 -> error lexbuf Unterminated_string
      | __ocaml_lex_state ->
          (lexbuf.Lexing.refill_buff lexbuf;
           __ocaml_lex_scan_string_rec buf start lexbuf __ocaml_lex_state)
    let parse_json lexbuf =
      let buf = Buffer.create 64 in
      let look_ahead = ref None in
      let token () =
        (match !look_ahead with
         | None -> lex_json buf lexbuf
         | Some x -> (look_ahead := None; x) : token) in
      let push e = look_ahead := (Some e) in
      let rec json (lexbuf : Lexing.lexbuf) =
        (match token () with
         | True -> True (lexbuf.lex_start_p)
         | False -> False (lexbuf.lex_start_p)
         | Null -> Null (lexbuf.lex_start_p)
         | Number s -> Flo { flo = s; loc = (lexbuf.lex_start_p) }
         | String s -> Str { str = s; loc = (lexbuf.lex_start_p) }
         | Lbracket ->
             parse_array lexbuf.lex_start_p lexbuf.lex_curr_p [] lexbuf
         | Lbrace -> parse_map lexbuf.lex_start_p Map_string.empty lexbuf
         | _ -> error lexbuf Unexpected_token : Ext_json_types.t)
      and parse_array loc_start loc_finish acc lexbuf =
        (match token () with
         | Rbracket ->
             Arr
               {
                 loc_start;
                 content = (Ext_array.reverse_of_list acc);
                 loc_end = (lexbuf.lex_curr_p)
               }
         | x ->
             (push x;
              (let new_one = json lexbuf in
               match token () with
               | Comma ->
                   parse_array loc_start loc_finish (new_one :: acc) lexbuf
               | Rbracket ->
                   Arr
                     {
                       content = (Ext_array.reverse_of_list (new_one :: acc));
                       loc_start;
                       loc_end = (lexbuf.lex_curr_p)
                     }
               | _ -> error lexbuf Expect_comma_or_rbracket)) : Ext_json_types.t)
      and parse_map loc_start acc lexbuf =
        (match token () with
         | Rbrace -> Obj { map = acc; loc = loc_start }
         | String key ->
             (match token () with
              | Colon ->
                  let value = json lexbuf in
                  (match token () with
                   | Rbrace ->
                       Obj
                         {
                           map = (Map_string.add acc key value);
                           loc = loc_start
                         }
                   | Comma ->
                       parse_map loc_start (Map_string.add acc key value)
                         lexbuf
                   | _ -> error lexbuf Expect_comma_or_rbrace)
              | _ -> error lexbuf Expect_colon)
         | _ -> error lexbuf Expect_string_or_rbrace : Ext_json_types.t) in
      let v = json lexbuf in
      match token () with | Eof -> v | _ -> error lexbuf Expect_eof
    let parse_json_from_file s =
      let in_chan = open_in s in
      let lexbuf = Ext_position.lexbuf_from_channel_with_fname in_chan s in
      match parse_json lexbuf with
      | exception e -> (close_in in_chan; raise e)
      | v -> (close_in in_chan; v)
  end 
module Hash_string : sig include (Hash_gen.S with type  key =  string) end =
  struct
    type key = string
    type 'a t = (key, 'a) Hash_gen.t
    let key_index (h : _ t) (key : key) =
      (Bs_hash_stubs.hash_string key) land ((Array.length h.data) - 1)
    let eq_key = Ext_string.equal
    type ('a, 'b) bucket = ('a, 'b) Hash_gen.bucket
    let create = Hash_gen.create
    let iter = Hash_gen.iter
    let to_list = Hash_gen.to_list
    let length = Hash_gen.length
    let add (h : _ t) key data =
      let i = key_index h key in
      let h_data = h.data in
      Array.unsafe_set h_data i
        (Cons { key; data; next = (Array.unsafe_get h_data i) });
      h.size <- (h.size + 1);
      if h.size > ((Array.length h_data) lsl 1)
      then Hash_gen.resize key_index h
    let rec find_rec key (bucketlist : _ bucket) =
      match bucketlist with
      | Empty -> raise Not_found
      | Cons rhs ->
          if eq_key key rhs.key then rhs.data else find_rec key rhs.next
    let find_exn (h : _ t) key =
      match Array.unsafe_get h.data (key_index h key) with
      | Empty -> raise Not_found
      | Cons rhs ->
          if eq_key key rhs.key
          then rhs.data
          else
            (match rhs.next with
             | Empty -> raise Not_found
             | Cons rhs ->
                 if eq_key key rhs.key
                 then rhs.data
                 else
                   (match rhs.next with
                    | Empty -> raise Not_found
                    | Cons rhs ->
                        if eq_key key rhs.key
                        then rhs.data
                        else find_rec key rhs.next))
    let find_opt (h : _ t) key =
      Hash_gen.small_bucket_opt eq_key key
        (Array.unsafe_get h.data (key_index h key))
    let mem (h : _ t) key =
      Hash_gen.small_bucket_mem (Array.unsafe_get h.data (key_index h key))
        eq_key key
  end 
module Bsb_build_util :
  sig
    val ppx_flags : Bsb_config_types.ppx list -> string[@@ocaml.doc
                                                         "\nBuild quoted commandline arguments for bsc.exe for the given ppx flags\n\nUse:\n{[\nppx_flags [ppxs]\n]}\n"]
    val pp_flag : string -> string
    val include_dirs : string list -> string[@@ocaml.doc
                                              "\nBuild unquoted command line arguments for bsc.exe for the given include dirs\n\nUse:\n{[\ninclude_dirs [dirs]\n]}\n"]
    val include_dirs_by : 'a list -> ('a -> string) -> string
    val mkp : string -> unit
    val get_list_string : Ext_json_types.t array -> string list
    type result =
      {
      path: string ;
      checked: bool [@dead "Bsb_build_util.result.+checked"]}
    val resolve_bsb_magic_file :
      cwd:string -> desc:string -> string -> result
    type package_context = {
      proj_dir: string ;
      top: bool }
    val walk_all_deps : string -> (package_context -> unit) -> unit
  end =
  struct
    let flag_concat flag xs =
      String.concat Ext_string.single_space
        (Ext_list.flat_map xs (fun x -> [flag; x]))
    let (//) = Ext_path.combine
    let ppx_flags (xs : Bsb_config_types.ppx list) =
      flag_concat "-ppx"
        (Ext_list.map xs
           (fun x ->
              if x.args = []
              then Ext_filename.maybe_quote x.name
              else
                (let fmt : _ format =
                   if Ext_sys.is_windows_or_cygwin
                   then "\"%s %s\""
                   else "'%s %s'" in
                 Printf.sprintf fmt x.name (String.concat " " x.args))))
    let pp_flag (xs : string) = "-pp " ^ (Ext_filename.maybe_quote xs)
    let include_dirs dirs =
      String.concat Ext_string.single_space
        (Ext_list.flat_map dirs (fun x -> ["-I"; Ext_filename.maybe_quote x]))
    let include_dirs_by dirs fn =
      String.concat Ext_string.single_space
        (Ext_list.flat_map dirs
           (fun x -> ["-I"; Ext_filename.maybe_quote (fn x)]))
    let convert_and_resolve_path : string -> string -> string =
      if Sys.unix
      then (//)
      else
        (fun cwd ->
           fun path ->
             if Ext_sys.is_windows_or_cygwin
             then let p = Ext_string.replace_slash_backward path in cwd // p
             else failwith ("Unknown OS :" ^ Sys.os_type))
    type result = {
      path: string ;
      checked: bool }
    let resolve_bsb_magic_file ~cwd  ~desc  p =
      (let no_slash = Ext_string.no_slash_idx p in
       if no_slash < 0
       then { path = p; checked = false }
       else
         (let first_char = String.unsafe_get p 0 in
          if (Filename.is_relative p) && (first_char <> '.')
          then
            let (package_name, rest) =
              Bsb_pkg_types.extract_pkg_name_and_file p in
            let relative_path =
              if Ext_sys.is_windows_or_cygwin
              then Ext_string.replace_slash_backward rest
              else rest in
            let package_dir = Bsb_pkg.resolve_bs_package ~cwd package_name in
            let path = package_dir // relative_path in
            (if Sys.file_exists path
             then { path; checked = true }
             else
               (Bsb_log.error "@{<error>Could not resolve @} %s in %s@." p
                  cwd;
                failwith (p ^ (" not found when resolving " ^ desc))))
          else { path = (convert_and_resolve_path cwd p); checked = true }) : 
      result)
    [@@@ocaml.text " converting a file from Linux path format to Windows "]
    let rec mkp dir =
      if not (Sys.file_exists dir)
      then
        let parent_dir = Filename.dirname dir in
        (if parent_dir = Filename.current_dir_name
         then Unix.mkdir dir 0o777
         else (mkp parent_dir; Unix.mkdir dir 0o777))
      else
        if not @@ (Sys.is_directory dir)
        then
          failwith
            (dir ^ " exists but it is not a directory, plz remove it first")
        else ()[@@ocaml.doc
                 " \n   {[\n     mkp \"a/b/c/d\";;\n     mkp \"/a/b/c/d\"\n   ]}\n"]
    let get_list_string_acc (s : Ext_json_types.t array) acc =
      Ext_array.to_list_map_acc s acc
        (fun x -> match x with | Str x -> Some (x.str) | _ -> None)
    let get_list_string s = get_list_string_acc s []
    let (|?) m (key, cb) = m |> (Ext_json.test key cb)
    type package_context = {
      proj_dir: string ;
      top: bool }
    [@@@ocaml.text
      "\n   TODO: check duplicate package name\n   ?use path as identity?\n\n   Basic requirements\n     1. cycle detection\n     2. avoid duplication\n     3. deterministic, since -make-world will also comes with -clean-world\n\n"]
    let pp_packages_rev ppf lst =
      Ext_list.rev_iter lst (fun s -> Format.fprintf ppf "%s " s)
    let rec walk_all_deps_aux (visited : string Hash_string.t)
      (paths : string list) (top : bool) (dir : string)
      (cb : package_context -> unit) =
      let bsconfig_json = dir // Literals.bsconfig_json in
      match Ext_json_parse.parse_json_from_file bsconfig_json with
      | Obj { map; loc } ->
          let cur_package_name =
            match Map_string.find_opt map Bsb_build_schemas.name with
            | Some (Str { str }) -> str
            | Some _|None ->
                Bsb_exception.errorf ~loc
                  "package name missing in %s/bsconfig.json" dir in
          let package_stacks = cur_package_name :: paths in
          (Bsb_log.info "@{<info>Package stack:@} %a @." pp_packages_rev
             package_stacks;
           if Ext_list.mem_string paths cur_package_name
           then
             (Bsb_log.error
                "@{<error>Cyclic dependencies in package stack@}@.";
              exit 2);
           if Hash_string.mem visited cur_package_name
           then Bsb_log.info "@{<info>Visited before@} %s@." cur_package_name
           else
             (let explore_deps (deps : string) =
                (map |?
                   (deps,
                     (`Arr
                        (fun (new_packages : Ext_json_types.t array) ->
                           Ext_array.iter new_packages
                             (fun js ->
                                match js with
                                | Str { str = new_package } ->
                                    let package_dir =
                                      Bsb_pkg.resolve_bs_package ~cwd:dir
                                        (Bsb_pkg_types.string_as_package
                                           new_package) in
                                    walk_all_deps_aux visited package_stacks
                                      false package_dir cb
                                | _ ->
                                    Bsb_exception.errorf ~loc
                                      "%s expect an array" deps)))))
                  |> ignore in
              explore_deps Bsb_build_schemas.bs_dependencies;
              if top then explore_deps Bsb_build_schemas.bs_dev_dependencies;
              cb { top; proj_dir = dir };
              Hash_string.add visited cur_package_name dir))
      | _ -> ()
      | exception _ -> Bsb_exception.invalid_json bsconfig_json
    let walk_all_deps dir cb =
      let visited = Hash_string.create 0 in
      walk_all_deps_aux visited [] true dir cb
  end 
module Bsb_global_backend :
  sig
    val lib_artifacts_dir : string ref
    val lib_ocaml_dir : string ref
    val backend_string : string ref
  end =
  struct
    let lib_artifacts_dir = ref Bsb_config.lib_bs
    let lib_ocaml_dir = ref Bsb_config.lib_ocaml
    let backend_string = ref Literals.js
  end 
module Bsb_global_paths :
  sig
    val cwd : string
    val vendor_bsc : string
    val vendor_ninja : string
    val vendor_bsdep : string
  end =
  struct
    let cwd = Sys.getcwd ()
    [@@@ocaml.text
      "\n   If [Sys.executable_name] gives an absolute path, \n   nothing needs to be done.\n   \n   If [Sys.executable_name] is not an absolute path, for example\n   (rlwrap ./ocaml)\n   it is a relative path, \n   it needs be adapted based on cwd\n\n   if [Sys.executable_name] gives an absolute path, \n   nothing needs to be done\n   if it is a relative path \n\n   there are two cases: \n   - bsb.exe\n   - ./bsb.exe \n   The first should also not be touched\n   Only the latter need be adapted based on project root  \n"]
    let bsc_dir =
      Filename.dirname
        (Ext_path.normalize_absolute_path
           (Ext_path.combine cwd Sys.executable_name))
    let vendor_bsc = Filename.concat bsc_dir "bsc.exe"
    let vendor_ninja = Filename.concat bsc_dir "ninja.exe"
    let vendor_bsdep = Filename.concat bsc_dir "bsb_helper.exe"
    ;;assert (Sys.file_exists bsc_dir)
  end 
module Bsb_db_util :
  sig
    val conflict_module_info :
      string -> Bsb_db.module_info -> Bsb_db.module_info -> 'a
    val merge : Bsb_db.t -> Bsb_db.t -> Bsb_db.t
    val sanity_check : Bsb_db.t -> unit
    [@@@ocaml.text
      " \n  Currently it is okay to have duplicated module, \n  In the future, we may emit a warning \n"]
    val add_basename :
      dir:string ->
        Bsb_db.t ->
          ?error_on_invalid_suffix:Ext_position.t -> string -> Bsb_db.t
  end =
  struct
    type module_info = Bsb_db.module_info
    type t = Bsb_db.t
    let conflict_module_info modname (a : module_info) (b : module_info) =
      Bsb_exception.conflict_module modname a.dir b.dir
    let merge (acc : t) (sources : t) =
      (Map_string.merge acc sources
         (fun modname ->
            fun k1 ->
              fun k2 ->
                match (k1, k2) with
                | (None, None) -> assert false
                | (Some a, Some b) -> conflict_module_info modname a b
                | (Some v, None) -> Some v
                | (None, Some v) -> Some v) : t)
    let sanity_check (map : t) =
      Map_string.iter map
        (fun m ->
           fun module_info ->
             if module_info.info = Mli then Bsb_exception.no_implementation m)
    let check (x : module_info) name_sans_extension case is_re
      (module_info : Bsb_db.info) =
      let x_ml_info = x.info in
      if
        (x.name_sans_extension <> name_sans_extension) ||
          ((x.case <> case) ||
             ((x.is_re <> is_re) ||
                ((x_ml_info = module_info) || (x_ml_info = Ml_mli))))
      then
        Bsb_exception.invalid_spec
          (Printf.sprintf
             "implementation and interface have different path names or different cases %s vs %s"
             x.name_sans_extension name_sans_extension);
      x.info <- Ml_mli;
      x
    let warning_unused_file : _ format =
      "@{<warning>IGNORED@}: file %s under %s is ignored because it can't be turned into a valid module name. The build system transforms a file name into a module name by upper-casing the first letter@."
    let add_basename ~dir:(dir : string)  (map : t) ?error_on_invalid_suffix 
      basename =
      (let info = ref Bsb_db.Ml in
       let is_re = ref false in
       let invalid_suffix = ref false in
       (match Ext_filename.get_extension_maybe basename with
        | ".ml" -> ()
        | ".re" -> is_re := true
        | ".mli" -> info := Mli
        | ".rei" -> (info := Mli; is_re := true)
        | _ -> invalid_suffix := true);
       (let info = !info in
        let is_re = !is_re in
        let invalid_suffix = !invalid_suffix in
        if invalid_suffix
        then
          match error_on_invalid_suffix with
          | None -> map
          | Some loc ->
              Bsb_exception.errorf ~loc "invalid suffix %s" basename
        else
          (match Ext_filename.as_module
                   ~basename:(Filename.basename basename)
           with
           | None -> (Bsb_log.warn warning_unused_file basename dir; map)
           | Some { module_name; case } ->
               let name_sans_extension =
                 Filename.concat dir
                   (Ext_filename.chop_extension_maybe basename) in
               let dir = Filename.dirname name_sans_extension in
               Map_string.adjust map module_name
                 (fun opt_module_info ->
                    match opt_module_info with
                    | None -> { dir; name_sans_extension; info; is_re; case }
                    | Some x -> check x name_sans_extension case is_re info))) : 
      t)
  end 
module Ext_option :
  sig
    [@@@ocaml.text " Utilities for [option] type "]
    val iter : 'a option -> ('a -> unit) -> unit
  end = struct let iter v f = match v with | None -> () | Some x -> f x end 
module Bsb_parse_sources :
  sig
    val scan :
      toplevel:bool ->
        root:string ->
          cut_generators:bool ->
            namespace:string option ->
              bs_suffix:bool ->
                ignored_dirs:Set_string.t ->
                  Ext_json_types.t -> (Bsb_file_groups.t * int)[@@ocaml.doc
                                                                 " [scan .. cxt json]\n    entry is to the [sources] in the schema    \n    given a root, return an object which is\n    all relative paths, this function will do the IO\n"]
    val clean_re_js : string -> unit[@@ocaml.doc
                                      " This function has some duplication \n  from [scan],\n  the parsing assuming the format is \n  already valid\n"]
  end =
  struct
    type build_generator = Bsb_file_groups.build_generator
    type t = Bsb_file_groups.t
    let is_input_or_output (xs : build_generator list) (x : string) =
      Ext_list.exists xs
        (fun { input; output } ->
           let it_is y = y = x in
           (Ext_list.exists input it_is) || (Ext_list.exists output it_is))
    let errorf x fmt = Bsb_exception.errorf ~loc:(Ext_json.loc_of x) fmt
    type cxt =
      {
      toplevel: bool ;
      dir_index: Bsb_dir_index.t ;
      cwd: string ;
      root: string ;
      cut_generators: bool ;
      traverse: bool ;
      namespace: string option ;
      bs_suffix: bool ;
      ignored_dirs: Set_string.t }
    let collect_pub_modules (xs : Ext_json_types.t array) (cache : Bsb_db.t)
      =
      (let set = ref Set_string.empty in
       for i = 0 to (Array.length xs) - 1 do
         (let v = Array.unsafe_get xs i in
          match v with
          | Str { str } ->
              if Map_string.mem cache str
              then set := (Set_string.add (!set) str)
              else
                Bsb_log.warn
                  "@{<warning>IGNORED@} %S in public is ignored since it is notan existing module@."
                  str
          | _ ->
              Bsb_exception.errorf ~loc:(Ext_json.loc_of v)
                "public excpect a list of strings")
       done;
       !set : Set_string.t)[@@ocaml.doc
                             " [public] has a list of modules, we do a sanity check to see if all the listed \n  modules are indeed valid module components\n"]
    let extract_pub (input : Ext_json_types.t Map_string.t)
      (cur_sources : Bsb_db.t) =
      (match Map_string.find_opt input Bsb_build_schemas.public with
       | Some (Str { str = s } as x) ->
           if s = Bsb_build_schemas.export_all
           then Export_all
           else
             if s = Bsb_build_schemas.export_none
             then Export_none
             else errorf x "invalid str for %s " s
       | Some (Arr { content = s }) ->
           Export_set (collect_pub_modules s cur_sources)
       | Some config ->
           Bsb_exception.config_error config "expect array or string"
       | None -> Export_all : Bsb_file_groups.public)
    let extract_resources (input : Ext_json_types.t Map_string.t) =
      (match Map_string.find_opt input Bsb_build_schemas.resources with
       | Some (Arr x) -> Bsb_build_util.get_list_string x.content
       | Some config -> Bsb_exception.config_error config "expect array "
       | None -> [] : string list)
    let extract_input_output (edge : Ext_json_types.t) =
      (let error () =
         errorf edge
           {| invalid edge format, expect  ["output" , ":", "input" ]|} in
       match edge with
       | Arr { content } ->
           (match Ext_array.find_and_split content
                    (fun x ->
                       fun () ->
                         match x with
                         | Str { str = ":" } -> true
                         | _ -> false) ()
            with
            | `No_split -> error ()
            | `Split (output, input) ->
                ((Ext_array.to_list_map
                    (fun (x : Ext_json_types.t) ->
                       match x with
                       | Str { str = ":" } -> error ()
                       | Str { str } -> Some str
                       | _ -> None) output),
                  (Ext_array.to_list_map
                     (fun (x : Ext_json_types.t) ->
                        match x with
                        | Str { str = ":" } -> error ()
                        | Str { str } -> Some str
                        | _ -> None) input)))
       | _ -> error () : (string list * string list))
    type json_map = Ext_json_types.t Map_string.t
    let extract_generators (input : json_map) =
      (match Map_string.find_opt input Bsb_build_schemas.generators with
       | Some (Arr { content; loc_start = _ }) ->
           Ext_array.fold_left content []
             (fun acc ->
                fun x ->
                  match x with
                  | Obj { map } ->
                      (match ((Map_string.find_opt map Bsb_build_schemas.name),
                               (Map_string.find_opt map
                                  Bsb_build_schemas.edge))
                       with
                       | (Some (Str command), Some edge) ->
                           let (output, input) = extract_input_output edge in
                           {
                             Bsb_file_groups.input = input;
                             output;
                             command = (command.str)
                           } :: acc
                       | _ -> errorf x "Invalid generator format")
                  | _ -> errorf x "Invalid generator format")
       | Some x -> errorf x "Invalid generator format"
       | None -> [] : build_generator list)
    let extract_predicate (m : json_map) =
      (let excludes =
         match Map_string.find_opt m Bsb_build_schemas.excludes with
         | None -> []
         | Some (Arr { content = arr }) -> Bsb_build_util.get_list_string arr
         | Some x -> Bsb_exception.config_error x "excludes expect array " in
       let slow_re = Map_string.find_opt m Bsb_build_schemas.slow_re in
       match (slow_re, excludes) with
       | (Some (Str { str = s }), []) ->
           let re = Str.regexp s in (fun name -> Str.string_match re name 0)
       | (Some (Str { str = s }), _::_) ->
           let re = Str.regexp s in
           (fun name ->
              (Str.string_match re name 0) &&
                (not (Ext_list.mem_string excludes name)))
       | (Some config, _) ->
           Bsb_exception.config_error config
             (Bsb_build_schemas.slow_re ^ " expect a string literal")
       | (None, _) -> (fun name -> not (Ext_list.mem_string excludes name)) : 
      string -> bool)
    let try_unlink s =
      try Unix.unlink s
      with | _ -> Bsb_log.info "@{<info>Failed to remove %s}@." s[@@ocaml.doc
                                                                   " [parsing_source_dir_map cxt input]\n    Major work done in this function, \n    assume [not toplevel && not (Bsb_dir_index.is_lib_dir dir_index)]      \n    is already checked, so we don't need check it again    \n"]
    let bs_cmt_post_process_cmd =
      lazy (try Sys.getenv "BS_CMT_POST_PROCESS_CMD" with | _ -> "")
    type suffix_kind =
      | Cmi of int 
      | Cmt of int 
      | Cmj of int 
      | Cmti of int 
      | Not_any 
    let classify_suffix (x : string) =
      (let i = Ext_string.ends_with_index x Literals.suffix_cmi in
       if i >= 0
       then Cmi i
       else
         (let i = Ext_string.ends_with_index x Literals.suffix_cmj in
          if i >= 0
          then Cmj i
          else
            (let i = Ext_string.ends_with_index x Literals.suffix_cmt in
             if i >= 0
             then Cmt i
             else
               (let i = Ext_string.ends_with_index x Literals.suffix_cmti in
                if i >= 0 then Cmti i else Not_any))) : suffix_kind)
    let prune_staled_bs_js_files (context : cxt)
      (cur_sources : _ Map_string.t) =
      (let lib_parent =
         Filename.concat (Filename.concat context.root Bsb_config.lib_bs)
           context.cwd in
       if Sys.file_exists lib_parent
       then
         let artifacts = Sys.readdir lib_parent in
         Ext_array.iter artifacts
           (fun x ->
              let kind = classify_suffix x in
              match kind with
              | Not_any -> ()
              | Cmi i|Cmt i|Cmj i|Cmti i ->
                  let j =
                    if context.namespace = None
                    then i
                    else Ext_string.rindex_neg x '-' in
                  if j >= 0
                  then
                    let cmp = Ext_string.capitalize_sub x j in
                    (if not (Map_string.mem cur_sources cmp)
                     then
                       let filepath = Filename.concat lib_parent x in
                       ((match kind with
                         | Cmt _ ->
                             let (lazy cmd) = bs_cmt_post_process_cmd in
                             if cmd <> ""
                             then
                               (try
                                  ignore
                                    (Sys.command
                                       (cmd ^ (" -cmt-rm " ^ filepath)) : 
                                    int)
                                with | _ -> ())
                         | Cmj _ ->
                             if context.bs_suffix
                             then
                               try_unlink
                                 (Filename.concat context.cwd
                                    ((String.sub x 0 j) ^
                                       Literals.suffix_bs_js))
                         | _ -> ());
                        try_unlink filepath)
                     else ())) : unit)[@@ocaml.doc
                                        " This is the only place where we do some removal during scanning,\n  configurabl\n"]
    let rec parsing_source_dir_map ({ cwd = dir } as cxt)
      (input : Ext_json_types.t Map_string.t) =
      (if Set_string.mem cxt.ignored_dirs dir
       then Bsb_file_groups.empty
       else
         (let cur_globbed_dirs = ref false in
          let has_generators = not (cxt.cut_generators || (not cxt.toplevel)) in
          let scanned_generators = extract_generators input in
          let sub_dirs_field =
            Map_string.find_opt input Bsb_build_schemas.subdirs in
          let base_name_array =
            lazy
              (cur_globbed_dirs := true;
               Sys.readdir (Filename.concat cxt.root dir)) in
          let output_sources =
            Ext_list.fold_left
              (Ext_list.flat_map scanned_generators (fun x -> x.output))
              Map_string.empty
              (fun acc -> fun o -> Bsb_db_util.add_basename ~dir acc o) in
          let sources =
            match Map_string.find_opt input Bsb_build_schemas.files with
            | None ->
                Ext_array.fold_left (Lazy.force base_name_array)
                  output_sources
                  (fun acc ->
                     fun basename ->
                       if is_input_or_output scanned_generators basename
                       then acc
                       else Bsb_db_util.add_basename ~dir acc basename)
            | Some (Arr basenames) ->
                Ext_array.fold_left basenames.content output_sources
                  (fun acc ->
                     fun basename ->
                       match basename with
                       | Str { str = basename; loc } ->
                           Bsb_db_util.add_basename ~dir acc basename
                             ~error_on_invalid_suffix:loc
                       | _ -> acc)
            | Some (Obj { map; loc = _ }) ->
                let predicate = extract_predicate map in
                Ext_array.fold_left (Lazy.force base_name_array)
                  output_sources
                  (fun acc ->
                     fun basename ->
                       if
                         (is_input_or_output scanned_generators basename) ||
                           (not (predicate basename))
                       then acc
                       else Bsb_db_util.add_basename ~dir acc basename)
            | Some x ->
                Bsb_exception.config_error x
                  "files field expect array or object " in
          let resources = extract_resources input in
          let public = extract_pub input sources in
          let children =
            match (sub_dirs_field, (cxt.traverse)) with
            | (None, true)|(Some (True _), _) ->
                let root = cxt.root in
                let parent = Filename.concat root dir in
                Ext_array.fold_left (Lazy.force base_name_array)
                  Bsb_file_groups.empty
                  (fun origin ->
                     fun x ->
                       if
                         (not (Set_string.mem cxt.ignored_dirs x)) &&
                           (Sys.is_directory (Filename.concat parent x))
                       then
                         Bsb_file_groups.merge
                           (parsing_source_dir_map
                              {
                                cxt with
                                cwd =
                                  (Ext_path.concat cxt.cwd
                                     (Ext_path.simple_convert_node_path_to_os_path
                                        x));
                                traverse = true
                              } Map_string.empty) origin
                       else origin)
            | (None, false)|(Some (False _), _) -> Bsb_file_groups.empty
            | (Some s, _) -> parse_sources cxt s in
          prune_staled_bs_js_files cxt sources;
          Bsb_file_groups.cons
            ~file_group:{
                          dir;
                          sources;
                          resources;
                          public;
                          dir_index = (cxt.dir_index);
                          generators =
                            (if has_generators
                             then scanned_generators
                             else [])
                        }
            ?globbed_dir:(if !cur_globbed_dirs then Some dir else None)
            children) : Bsb_file_groups.t)
    and parsing_single_source ({ toplevel; dir_index; cwd } as cxt)
      (x : Ext_json_types.t) =
      (match x with
       | Str { str = dir } ->
           if (not toplevel) && (not (Bsb_dir_index.is_lib_dir dir_index))
           then Bsb_file_groups.empty
           else
             parsing_source_dir_map
               {
                 cxt with
                 cwd =
                   (Ext_path.concat cwd
                      (Ext_path.simple_convert_node_path_to_os_path dir))
               } Map_string.empty
       | Obj { map } ->
           let current_dir_index =
             match Map_string.find_opt map Bsb_build_schemas.type_ with
             | Some (Str { str = "dev" }) -> Bsb_dir_index.get_dev_index ()
             | Some _ ->
                 Bsb_exception.config_error x
                   {|type field expect "dev" literal |}
             | None -> dir_index in
           if
             (not toplevel) &&
               (not (Bsb_dir_index.is_lib_dir current_dir_index))
           then Bsb_file_groups.empty
           else
             (let dir =
                match Map_string.find_opt map Bsb_build_schemas.dir with
                | Some (Str { str }) ->
                    Ext_path.simple_convert_node_path_to_os_path str
                | Some x ->
                    Bsb_exception.config_error x
                      "dir expected to be a string"
                | None ->
                    Bsb_exception.config_error x
                      ("required field :" ^
                         (Bsb_build_schemas.dir ^ " missing")) in
              parsing_source_dir_map
                {
                  cxt with
                  dir_index = current_dir_index;
                  cwd = (Ext_path.concat cwd dir)
                } map)
       | _ -> Bsb_file_groups.empty : t)
    and parsing_arr_sources cxt (file_groups : Ext_json_types.t array) =
      Ext_array.fold_left file_groups Bsb_file_groups.empty
        (fun origin ->
           fun x ->
             Bsb_file_groups.merge (parsing_single_source cxt x) origin)
    and parse_sources (cxt : cxt) (sources : Ext_json_types.t) =
      match sources with
      | Arr file_groups -> parsing_arr_sources cxt file_groups.content
      | _ -> parsing_single_source cxt sources
    let scan ~toplevel  ~root  ~cut_generators  ~namespace  ~bs_suffix 
      ~ignored_dirs  x =
      (Bsb_dir_index.reset ();
       (let output =
          parse_sources
            {
              ignored_dirs;
              toplevel;
              dir_index = Bsb_dir_index.lib_dir_index;
              cwd = Filename.current_dir_name;
              root;
              cut_generators;
              namespace;
              bs_suffix;
              traverse = false
            } x in
        (output, (Bsb_dir_index.get_current_number_of_dev_groups ()))) : 
      (t * int))
    type walk_cxt =
      {
      cwd: string ;
      root: string ;
      traverse: bool ;
      ignored_dirs: Set_string.t }
    let rec walk_sources (cxt : walk_cxt) (sources : Ext_json_types.t) =
      match sources with
      | Arr { content } ->
          Ext_array.iter content (fun x -> walk_single_source cxt x)
      | x -> walk_single_source cxt x
    and walk_single_source cxt (x : Ext_json_types.t) =
      match x with
      | Str { str = dir } ->
          let dir = Ext_path.simple_convert_node_path_to_os_path dir in
          walk_source_dir_map
            { cxt with cwd = (Ext_path.concat cxt.cwd dir) } None
      | Obj { map } ->
          (match Map_string.find_opt map Bsb_build_schemas.dir with
           | Some (Str { str }) ->
               let dir = Ext_path.simple_convert_node_path_to_os_path str in
               walk_source_dir_map
                 { cxt with cwd = (Ext_path.concat cxt.cwd dir) }
                 (Map_string.find_opt map Bsb_build_schemas.subdirs)
           | _ -> ())
      | _ -> ()
    and walk_source_dir_map (cxt : walk_cxt) sub_dirs_field =
      let working_dir = Filename.concat cxt.root cxt.cwd in
      if not (Set_string.mem cxt.ignored_dirs cxt.cwd)
      then
        let file_array = Sys.readdir working_dir in
        (Ext_array.iter file_array
           (fun file ->
              if
                (Ext_string.ends_with file Literals.suffix_gen_js) ||
                  (Ext_string.ends_with file Literals.suffix_gen_tsx)
              then Sys.remove (Filename.concat working_dir file));
         (let cxt_traverse = cxt.traverse in
          match (sub_dirs_field, cxt_traverse) with
          | (None, true)|(Some (True _), _) ->
              Ext_array.iter file_array
                (fun f ->
                   if
                     (not (Set_string.mem cxt.ignored_dirs f)) &&
                       (Sys.is_directory (Filename.concat working_dir f))
                   then
                     walk_source_dir_map
                       {
                         cxt with
                         cwd =
                           (Ext_path.concat cxt.cwd
                              (Ext_path.simple_convert_node_path_to_os_path f));
                         traverse = true
                       } None)
          | (None, _)|(Some (False _), _) -> ()
          | (Some s, _) -> walk_sources cxt s))
    let clean_re_js root =
      match Ext_json_parse.parse_json_from_file
              (Filename.concat root Literals.bsconfig_json)
      with
      | Obj { map } ->
          let ignored_dirs =
            match Map_string.find_opt map Bsb_build_schemas.ignored_dirs with
            | Some (Arr { content = x }) ->
                Set_string.of_list (Bsb_build_util.get_list_string x)
            | Some _|None -> Set_string.empty in
          Ext_option.iter (Map_string.find_opt map Bsb_build_schemas.sources)
            (fun config ->
               try
                 walk_sources
                   {
                     root;
                     traverse = true;
                     cwd = Filename.current_dir_name;
                     ignored_dirs
                   } config
               with | _ -> ())
      | _ -> ()
      | exception _ -> ()
  end 
module Bsb_unix :
  sig
    type command =
      {
      cmd: string [@dead "Bsb_unix.command.+cmd"];
      cwd: string [@dead "Bsb_unix.command.+cwd"];
      args: string array [@dead "Bsb_unix.command.+args"]}
    val command_fatal_error : command -> int -> unit
    val run_command_execv : command -> int
    val remove_dir_recursive : string -> unit
  end =
  struct
    type command = {
      cmd: string ;
      cwd: string ;
      args: string array }
    let log cmd =
      Bsb_log.info "@{<info>Entering@} %s @." cmd.cwd;
      Bsb_log.info "@{<info>Cmd:@} ";
      Bsb_log.info_args cmd.args
    let command_fatal_error cmd eid =
      Bsb_log.error "@{<error>Failure:@} %s \n Location: %s@." cmd.cmd
        cmd.cwd;
      exit eid
    let run_command_execv_unix cmd =
      (match Unix.fork () with
       | 0 -> (log cmd; Unix.chdir cmd.cwd; Unix.execv cmd.cmd cmd.args)
       | pid ->
           (match Unix.waitpid [] pid with
            | (_, process_status) ->
                (match process_status with
                 | Unix.WEXITED eid -> eid
                 | Unix.WSIGNALED _|Unix.WSTOPPED _ ->
                     (Bsb_log.error "@{<error>Interrupted:@} %s@." cmd.cmd; 2))) : 
      int)
    let run_command_execv_win (cmd : command) =
      let old_cwd = Unix.getcwd () in
      log cmd;
      Unix.chdir cmd.cwd;
      (let eid =
         Sys.command
           (String.concat Ext_string.single_space ((Filename.quote cmd.cmd)
              :: (List.tl @@ (Array.to_list cmd.args)))) in
       Bsb_log.info "@{<info>Leaving@} %s => %s  @." cmd.cwd old_cwd;
       Unix.chdir old_cwd;
       eid)[@@ocaml.doc
             " TODO: the args are not quoted, here \n    we are calling a very limited set of `bsb` commands, so that \n    we are safe\n"]
    let run_command_execv =
      if Ext_sys.is_windows_or_cygwin
      then run_command_execv_win
      else run_command_execv_unix[@@ocaml.doc
                                   " it assume you have permissions, so always catch it to fail \n    gracefully\n"]
    let rec remove_dir_recursive dir =
      if Sys.is_directory dir
      then
        let files = Sys.readdir dir in
        (for i = 0 to (Array.length files) - 1 do
           remove_dir_recursive
             (Filename.concat dir (Array.unsafe_get files i))
         done;
         Unix.rmdir dir)
      else Sys.remove dir
  end 
module Bsb_clean :
  sig
    [@@@ocaml.text
      " clean bsc generated artifacts.\n  TODO: clean staled in source js artifacts\n"]
    val clean_bs_deps : string -> unit
    val clean_self : string -> unit
  end =
  struct
    let (//) = Ext_path.combine
    let ninja_clean proj_dir =
      try
        let cmd = Bsb_global_paths.vendor_ninja in
        let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
        let cwd = proj_dir // lib_artifacts_dir in
        if Sys.file_exists cwd
        then
          let eid =
            Bsb_unix.run_command_execv
              { cmd; args = [|cmd;"-t";"clean"|]; cwd } in
          (if eid <> 0 then Bsb_log.warn "@{<warning>ninja clean failed@}@.")
      with
      | e ->
          Bsb_log.warn "@{<warning>ninja clean failed@} : %s @."
            (Printexc.to_string e)
    let clean_bs_garbage proj_dir =
      Bsb_log.info "@{<info>Cleaning:@} in %s@." proj_dir;
      (let try_remove x =
         let x = proj_dir // x in
         if Sys.file_exists x then Bsb_unix.remove_dir_recursive x in
       try
         Bsb_parse_sources.clean_re_js proj_dir;
         ninja_clean proj_dir;
         Ext_list.iter Bsb_config.all_lib_artifacts try_remove
       with
       | e ->
           Bsb_log.warn "@{<warning>Failed@} to clean due to %s"
             (Printexc.to_string e))
    let clean_bs_deps proj_dir =
      Bsb_build_util.walk_all_deps proj_dir
        (fun pkg_cxt -> clean_bs_garbage pkg_cxt.proj_dir)
    let clean_self proj_dir = clean_bs_garbage proj_dir
  end 
module Bsb_config_parse :
  sig
    val package_specs_from_bsconfig : unit -> Bsb_package_specs.t
    val interpret_json :
      toplevel_package_specs:Bsb_package_specs.t option ->
        per_proj_dir:string -> Bsb_config_types.t
  end =
  struct
    let (//) = Ext_path.combine
    let current_package : Bsb_pkg_types.t = Global Bs_version.package_name
    let resolve_package cwd package_name =
      let x = Bsb_pkg.resolve_bs_package ~cwd package_name in
      {
        Bsb_config_types.package_name = package_name;
        package_install_path = (x // (!Bsb_global_backend.lib_ocaml_dir))
      }
    type json_map = Ext_json_types.t Map_string.t
    let (|?) m (key, cb) = m |> (Ext_json.test key cb)
    let extract_main_entries (_ : json_map) = []
    let package_specs_from_bsconfig () =
      let json = Ext_json_parse.parse_json_from_file Literals.bsconfig_json in
      match json with
      | Obj { map } ->
          (match Map_string.find_opt map Bsb_build_schemas.package_specs with
           | Some x -> Bsb_package_specs.from_json x
           | None -> Bsb_package_specs.default_package_specs)
      | _ -> assert false
    let extract_package_name_and_namespace (map : json_map) =
      (let package_name =
         match Map_string.find_opt map Bsb_build_schemas.name with
         | Some (Str { str = "_" } as config) ->
             Bsb_exception.config_error config "_ is a reserved package name"
         | Some (Str { str = name }) -> name
         | Some config ->
             Bsb_exception.config_error config "name expect a string field"
         | None -> Bsb_exception.invalid_spec "field name is required" in
       let namespace =
         match Map_string.find_opt map Bsb_build_schemas.namespace with
         | None|Some (False _) -> None
         | Some (True _) ->
             Some (Ext_namespace.namespace_of_package_name package_name)
         | Some (Str { str }) ->
             Some (Ext_namespace.namespace_of_package_name str)
         | Some x ->
             Bsb_exception.config_error x
               "namespace field expects string or boolean" in
       (package_name, namespace) : (string * string option))
    let check_version_exit (map : json_map) stdlib_path =
      match Map_string.find_exn map Bsb_build_schemas.version with
      | Str { str } ->
          if str <> Bs_version.version
          then
            (Format.fprintf Format.err_formatter
               "@{<error>bs-platform version mismatch@} Running bsb @{<info>%s@} (%s) vs vendored @{<info>%s@} (%s)@."
               Bs_version.version
               (Filename.dirname (Filename.dirname Sys.executable_name)) str
               stdlib_path;
             exit 2)
      | _ -> assert false[@@ocaml.doc
                           "\n    There are two things to check:\n    - the running bsb and vendoring bsb is the same\n    - the running bsb need delete stale build artifacts\n      (kinda check npm upgrade)\n"]
    let check_stdlib (map : json_map) cwd =
      match Map_string.find_opt map Bsb_build_schemas.use_stdlib with
      | Some (False _) -> None
      | None|Some _ ->
          let stdlib_path = Bsb_pkg.resolve_bs_package ~cwd current_package in
          let json_spec =
            Ext_json_parse.parse_json_from_file
              (Filename.concat stdlib_path Literals.package_json) in
          (match json_spec with
           | Obj { map } ->
               (check_version_exit map stdlib_path;
                Some
                  {
                    Bsb_config_types.package_name = current_package;
                    package_install_path =
                      (stdlib_path // (!Bsb_global_backend.lib_ocaml_dir))
                  })
           | _ -> assert false)
    let extract_bs_suffix_exn (map : json_map) =
      match Map_string.find_opt map Bsb_build_schemas.suffix with
      | None -> false
      | Some (Str { str } as config) ->
          if str = Literals.suffix_js
          then false
          else
            if str = Literals.suffix_bs_js
            then true
            else
              Bsb_exception.config_error config
                "expect .bs.js or .js string here"
      | Some config ->
          Bsb_exception.config_error config
            "expect .bs.js or .js string here"
    let extract_gentype_config (map : json_map) cwd =
      (match Map_string.find_opt map Bsb_build_schemas.gentypeconfig with
       | None -> None
       | Some (Obj { map = obj }) ->
           Some
             {
               path =
                 ((match Map_string.find_opt obj Bsb_build_schemas.path with
                   | None ->
                       (Bsb_build_util.resolve_bsb_magic_file ~cwd
                          ~desc:"gentype.exe" "gentype/gentype.exe").path
                   | Some (Str { str }) ->
                       (Bsb_build_util.resolve_bsb_magic_file ~cwd
                          ~desc:"gentype.exe" str).path
                   | Some config ->
                       Bsb_exception.config_error config
                         "path expect to be a string"))
             }
       | Some config ->
           Bsb_exception.config_error config "gentypeconfig expect an object" : 
      Bsb_config_types.gentype_config option)
    let extract_refmt (map : json_map) cwd =
      (match Map_string.find_opt map Bsb_build_schemas.refmt with
       | Some (Flo { flo } as config) ->
           (match flo with
            | "3" -> None
            | _ -> Bsb_exception.config_error config "expect version 3 only")
       | Some (Str { str }) ->
           Some
             ((Bsb_build_util.resolve_bsb_magic_file ~cwd
                 ~desc:Bsb_build_schemas.refmt str).path)
       | Some config ->
           Bsb_exception.config_error config "expect version 2 or 3"
       | None -> None : Bsb_config_types.refmt)
    let extract_string (map : json_map) (field : string) cb =
      match Map_string.find_opt map field with
      | None -> None
      | Some (Str { str }) -> cb str
      | Some config ->
          Bsb_exception.config_error config (field ^ " expect a string")
    let extract_boolean (map : json_map) (field : string) (default : bool) =
      (match Map_string.find_opt map field with
       | None -> default
       | Some (True _) -> true
       | Some (False _) -> false
       | Some config ->
           Bsb_exception.config_error config (field ^ " expect a boolean") : 
      bool)
    let extract_reason_react_jsx (map : json_map) =
      let default : Bsb_config_types.reason_react_jsx option ref = ref None in
      (map |?
         (Bsb_build_schemas.reason,
           (`Obj
              (fun m ->
                 match Map_string.find_opt m Bsb_build_schemas.react_jsx with
                 | Some (Flo { loc; flo }) ->
                     (match flo with
                      | "2" -> default := (Some Jsx_v2)
                      | "3" -> default := (Some Jsx_v3)
                      | _ ->
                          Bsb_exception.errorf ~loc
                            "Unsupported jsx version %s" flo)
                 | Some x ->
                     Bsb_exception.config_error x
                       "Unexpected input (expect a version number) for jsx, note boolean is no longer allowed"
                 | None -> ()))))
        |> ignore;
      !default
    let extract_warning (map : json_map) =
      match Map_string.find_opt map Bsb_build_schemas.warnings with
      | None -> Bsb_warning.use_default
      | Some (Obj { map }) -> Bsb_warning.from_map map
      | Some config -> Bsb_exception.config_error config "expect an object"
    let extract_ignored_dirs (map : json_map) =
      match Map_string.find_opt map Bsb_build_schemas.ignored_dirs with
      | None -> Set_string.empty
      | Some (Arr { content }) ->
          Set_string.of_list (Bsb_build_util.get_list_string content)
      | Some config ->
          Bsb_exception.config_error config "expect an array of string"
    let extract_generators (map : json_map) =
      let generators = ref Map_string.empty in
      (match Map_string.find_opt map Bsb_build_schemas.generators with
       | None -> ()
       | Some (Arr { content = s }) ->
           generators :=
             (Ext_array.fold_left s Map_string.empty
                (fun acc ->
                   fun json ->
                     match json with
                     | Obj { map = m; loc } ->
                         (match ((Map_string.find_opt m
                                    Bsb_build_schemas.name),
                                  (Map_string.find_opt m
                                     Bsb_build_schemas.command))
                          with
                          | (Some (Str { str = name }), Some (Str
                             { str = command })) ->
                              Map_string.add acc name command
                          | (_, _) ->
                              Bsb_exception.errorf ~loc
                                {| generators exepect format like { "name" : "cppo",  "command"  : "cppo $in -o $out"} |})
                     | _ -> acc))
       | Some config ->
           Bsb_exception.config_error config
             (Bsb_build_schemas.generators ^ " expect an array field"));
      !generators
    let extract_dependencies (map : json_map) cwd (field : string) =
      (match Map_string.find_opt map field with
       | None -> []
       | Some (Arr { content = s }) ->
           Ext_list.map (Bsb_build_util.get_list_string s)
             (fun s ->
                resolve_package cwd (Bsb_pkg_types.string_as_package s))
       | Some config ->
           Bsb_exception.config_error config (field ^ " expect an array") : 
      Bsb_config_types.dependencies)
    let extract_string_list (map : json_map) (field : string) =
      (match Map_string.find_opt map field with
       | None -> []
       | Some (Arr { content = s }) -> Bsb_build_util.get_list_string s
       | Some config ->
           Bsb_exception.config_error config (field ^ " expect an array") : 
      string list)
    let extract_ppx (map : json_map) (field : string) ~cwd:(cwd : string)  =
      (match Map_string.find_opt map field with
       | None -> []
       | Some (Arr { content }) ->
           let resolve s =
             if s = ""
             then
               Bsb_exception.invalid_spec "invalid ppx, empty string found"
             else
               (Bsb_build_util.resolve_bsb_magic_file ~cwd
                  ~desc:Bsb_build_schemas.ppx_flags s).path in
           Ext_array.to_list_f content
             (fun x ->
                match x with
                | Str x ->
                    { Bsb_config_types.name = (resolve x.str); args = [] }
                | Arr { content } ->
                    let xs = Bsb_build_util.get_list_string content in
                    (match xs with
                     | [] ->
                         Bsb_exception.config_error x
                           " empty array is not allowed"
                     | name::args ->
                         { Bsb_config_types.name = (resolve name); args })
                | config ->
                    Bsb_exception.config_error config
                      (field ^
                         "expect each item to be either string or array"))
       | Some config ->
           Bsb_exception.config_error config (field ^ " expect an array") : 
      Bsb_config_types.ppx list)
    let extract_js_post_build (map : json_map) cwd =
      (let js_post_build_cmd = ref None in
       (map |?
          (Bsb_build_schemas.js_post_build,
            (`Obj
               (fun m ->
                  (m |?
                     (Bsb_build_schemas.cmd,
                       (`Str
                          (fun s ->
                             js_post_build_cmd :=
                               (Some
                                  ((Bsb_build_util.resolve_bsb_magic_file
                                      ~cwd
                                      ~desc:Bsb_build_schemas.js_post_build s).path))))))
                    |> ignore))))
         |> ignore;
       !js_post_build_cmd : string option)
    let interpret_json ~toplevel_package_specs 
      ~per_proj_dir:(per_proj_dir : string)  =
      (match Ext_json_parse.parse_json_from_file
               (per_proj_dir // Literals.bsconfig_json)
       with
       | Obj { map } ->
           let (package_name, namespace) =
             extract_package_name_and_namespace map in
           let refmt = extract_refmt map per_proj_dir in
           let gentype_config = extract_gentype_config map per_proj_dir in
           let bs_suffix = extract_bs_suffix_exn map in
           let entries = extract_main_entries map in
           let built_in_package = check_stdlib map per_proj_dir in
           let package_specs =
             match Map_string.find_opt map Bsb_build_schemas.package_specs
             with
             | Some x -> Bsb_package_specs.from_json x
             | None -> Bsb_package_specs.default_package_specs in
           let pp_flags : string option =
             extract_string map Bsb_build_schemas.pp_flags
               (fun p ->
                  if p = ""
                  then
                    Bsb_exception.invalid_spec
                      "invalid pp, empty string found"
                  else
                    Some
                      ((Bsb_build_util.resolve_bsb_magic_file
                          ~cwd:per_proj_dir ~desc:Bsb_build_schemas.pp_flags
                          p).path)) in
           let reason_react_jsx = extract_reason_react_jsx map in
           let bs_dependencies =
             extract_dependencies map per_proj_dir
               Bsb_build_schemas.bs_dependencies in
           let toplevel = toplevel_package_specs = None in
           let bs_dev_dependencies =
             if toplevel
             then
               extract_dependencies map per_proj_dir
                 Bsb_build_schemas.bs_dev_dependencies
             else [] in
           (match Map_string.find_opt map Bsb_build_schemas.sources with
            | Some sources ->
                let cut_generators =
                  extract_boolean map Bsb_build_schemas.cut_generators false in
                let (groups, number_of_dev_groups) =
                  Bsb_parse_sources.scan
                    ~ignored_dirs:(extract_ignored_dirs map) ~toplevel
                    ~root:per_proj_dir ~cut_generators ~bs_suffix ~namespace
                    sources in
                {
                  gentype_config;
                  bs_suffix;
                  package_name;
                  namespace;
                  warning = (extract_warning map);
                  external_includes =
                    (extract_string_list map
                       Bsb_build_schemas.bs_external_includes);
                  bsc_flags =
                    (extract_string_list map Bsb_build_schemas.bsc_flags);
                  ppx_files =
                    (extract_ppx map ~cwd:per_proj_dir
                       Bsb_build_schemas.ppx_flags);
                  pp_file = pp_flags;
                  bs_dependencies;
                  bs_dev_dependencies;
                  refmt;
                  js_post_build_cmd =
                    (extract_js_post_build map per_proj_dir);
                  package_specs =
                    ((match toplevel_package_specs with
                      | None -> package_specs
                      | Some x -> x));
                  file_groups = groups;
                  files_to_install = (Hash_set_string.create 96);
                  built_in_dependency = built_in_package;
                  generate_merlin =
                    (extract_boolean map Bsb_build_schemas.generate_merlin
                       true);
                  reason_react_jsx;
                  entries;
                  generators = (extract_generators map);
                  cut_generators;
                  number_of_dev_groups
                }
            | None ->
                Bsb_exception.invalid_spec
                  "no sources specified in bsconfig.json")
       | _ ->
           Bsb_exception.invalid_spec "bsconfig.json expect a json object {}" : 
      Bsb_config_types.t)[@@ocaml.doc
                           " ATT: make sure such function is re-entrant. \n    With a given [cwd] it works anywhere"]
  end 
module Ext_io :
  sig
    val load_file : string -> string
    val write_file : string -> string -> unit
  end =
  struct
    let load_file f =
      Ext_pervasives.finally (open_in_bin f) ~clean:close_in
        (fun ic ->
           let n = in_channel_length ic in
           let s = Bytes.create n in
           really_input ic s 0 n; Bytes.unsafe_to_string s)[@@ocaml.doc
                                                             " on 32 bit , there are 16M limitation "]
    let write_file f content =
      Ext_pervasives.finally ~clean:close_out (open_out_bin f)
        (fun oc -> output_string oc content)
  end 
module Bsb_merlin_gen :
  sig val merlin_file_gen : per_proj_dir:string -> Bsb_config_types.t -> unit
  end =
  struct
    let merlin = ".merlin"
    let merlin_header = "####{BSB GENERATED: NO EDIT"
    let merlin_trailer = "####BSB GENERATED: NO EDIT}"
    let merlin_trailer_length = String.length merlin_trailer
    let (//) = Ext_path.combine
    let revise_merlin merlin new_content =
      if Sys.file_exists merlin
      then
        let s = Ext_io.load_file merlin in
        let header = Ext_string.find s ~sub:merlin_header in
        let tail = Ext_string.find s ~sub:merlin_trailer in
        (if (header < 0) && (tail < 0)
         then
           let ochan = open_out_bin merlin in
           (output_string ochan s;
            output_string ochan "\n";
            output_string ochan merlin_header;
            Buffer.output_buffer ochan new_content;
            output_string ochan merlin_trailer;
            output_string ochan "\n";
            close_out ochan)
         else
           if (header >= 0) && (tail >= 0)
           then
             (let ochan = open_out_bin merlin in
              output_string ochan (String.sub s 0 header);
              output_string ochan merlin_header;
              Buffer.output_buffer ochan new_content;
              output_string ochan merlin_trailer;
              output_string ochan
                (Ext_string.tail_from s (tail + merlin_trailer_length));
              close_out ochan)
           else
             failwith
               "the .merlin is corrupted, locked region by bsb is not consistent ")
      else
        (let ochan = open_out_bin merlin in
         output_string ochan merlin_header;
         Buffer.output_buffer ochan new_content;
         output_string ochan merlin_trailer;
         output_string ochan "\n";
         close_out ochan)[@@ocaml.doc
                           " [new_content] should start end finish with newline "]
    let merlin_flg_ppx = "\nFLG -ppx "
    let merlin_flg_pp = "\nFLG -pp "
    let merlin_s = "\nS "
    let merlin_b = "\nB "
    let merlin_flg = "\nFLG "
    let bs_flg_prefix = "-bs-"
    let output_merlin_namespace buffer ns =
      match ns with
      | None -> ()
      | Some x ->
          let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
          (Buffer.add_string buffer merlin_b;
           Buffer.add_string buffer lib_artifacts_dir;
           Buffer.add_string buffer merlin_flg;
           Buffer.add_string buffer "-open ";
           Buffer.add_string buffer x)
    let bsc_flg_to_merlin_ocamlc_flg bsc_flags =
      let flags =
        List.filter (fun x -> not (Ext_string.starts_with x bs_flg_prefix))
          bsc_flags in
      if flags <> []
      then merlin_flg ^ (String.concat Ext_string.single_space flags)
      else ""
    let warning_to_merlin_flg (warning : Bsb_warning.t) =
      (merlin_flg ^ (Bsb_warning.to_merlin_string warning) : string)
    let merlin_file_gen ~per_proj_dir:(per_proj_dir : string) 
      ({ file_groups = res_files; generate_merlin; ppx_files; pp_file;
         bs_dependencies; bs_dev_dependencies; bsc_flags;
         built_in_dependency; external_includes; reason_react_jsx; namespace;
         package_name = _; warning }
        : Bsb_config_types.t)
      =
      if generate_merlin
      then
        let buffer = Buffer.create 1024 in
        (output_merlin_namespace buffer namespace;
         Ext_list.iter ppx_files
           (fun ppx ->
              Buffer.add_string buffer merlin_flg_ppx;
              if ppx.args = []
              then Buffer.add_string buffer ppx.name
              else
                (let fmt : _ format =
                   if Ext_sys.is_windows_or_cygwin
                   then "\"%s %s\""
                   else "'%s %s'" in
                 Buffer.add_string buffer
                   (Printf.sprintf fmt ppx.name (String.concat " " ppx.args))));
         Ext_option.iter pp_file
           (fun x -> Buffer.add_string buffer (merlin_flg_pp ^ x));
         Buffer.add_string buffer
           (merlin_flg_ppx ^
              (match reason_react_jsx with
               | None ->
                   let fmt : _ format =
                     if Ext_sys.is_windows_or_cygwin
                     then "\"%s -as-ppx \""
                     else "'%s -as-ppx '" in
                   Printf.sprintf fmt Bsb_global_paths.vendor_bsc
               | Some opt ->
                   let fmt : _ format =
                     if Ext_sys.is_windows_or_cygwin
                     then "\"%s -as-ppx -bs-jsx %d\""
                     else "'%s -as-ppx -bs-jsx %d'" in
                   Printf.sprintf fmt Bsb_global_paths.vendor_bsc
                     (match opt with | Jsx_v2 -> 2 | Jsx_v3 -> 3)));
         Ext_list.iter external_includes
           (fun path ->
              Buffer.add_string buffer merlin_s;
              Buffer.add_string buffer path;
              Buffer.add_string buffer merlin_b;
              Buffer.add_string buffer path);
         Ext_option.iter built_in_dependency
           (fun package ->
              let path = package.package_install_path in
              Buffer.add_string buffer (merlin_s ^ path);
              Buffer.add_string buffer (merlin_b ^ path));
         (let bsc_string_flag = bsc_flg_to_merlin_ocamlc_flg bsc_flags in
          Buffer.add_string buffer bsc_string_flag;
          Buffer.add_string buffer (warning_to_merlin_flg warning);
          Ext_list.iter bs_dependencies
            (fun package ->
               let path = package.package_install_path in
               Buffer.add_string buffer merlin_s;
               Buffer.add_string buffer path;
               Buffer.add_string buffer merlin_b;
               Buffer.add_string buffer path);
          Ext_list.iter bs_dev_dependencies
            (fun package ->
               let path = package.package_install_path in
               Buffer.add_string buffer merlin_s;
               Buffer.add_string buffer path;
               Buffer.add_string buffer merlin_b;
               Buffer.add_string buffer path);
          (let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
           Ext_list.iter res_files.files
             (fun x ->
                if not (Bsb_file_groups.is_empty x)
                then
                  (Buffer.add_string buffer merlin_s;
                   Buffer.add_string buffer x.dir;
                   Buffer.add_string buffer merlin_b;
                   Buffer.add_string buffer (lib_artifacts_dir // x.dir)));
           Buffer.add_string buffer "\n";
           revise_merlin (per_proj_dir // merlin) buffer)))
  end 
module Bsb_ninja_check :
  sig
    [@@@ocaml.text
      "\n   This module is used to check whether [build.ninja] needs\n   be regenerated. Everytime [bsb] run [regenerate_ninja], \n   bsb will try to [check] if it is needed, \n   if needed, bsb will regenerate ninja file and store the \n   metadata again\n"]
    type check_result =
      | Good [@dead "Bsb_ninja_check.check_result.+Good"]
      | Bsb_file_not_exist
      [@ocaml.doc " We assume that it is a clean repo "][@dead
                                                          "Bsb_ninja_check.check_result.+Bsb_file_not_exist"]
      | Bsb_source_directory_changed
      [@dead "Bsb_ninja_check.check_result.+Bsb_source_directory_changed"]
      | Bsb_bsc_version_mismatch 
      | Bsb_forced [@dead "Bsb_ninja_check.check_result.+Bsb_forced"]
      | Other of string [@dead "Bsb_ninja_check.check_result.+Other"]
    val pp_check_result : Format.formatter -> check_result -> unit
    val record : per_proj_dir:string -> file:string -> string list -> unit
    [@@ocaml.doc
      " [record cwd file relevant_file_or_dirs]\n    The data structure we decided to whether regenerate [build.ninja] \n    or not. \n    Note that if we don't record absolute path,  ninja will not notice  its build spec changed, \n    it will not trigger  rebuild behavior, \n    It may not be desired behavior, since there is some subtlies here (__FILE__ or __dirname)\n\n    We serialize such data structure and call {!check} to decide\n    [build.ninja] should be regenerated\n"]
    val check :
      per_proj_dir:string -> forced:bool -> file:string -> check_result
    [@@ocaml.doc " check if [build.ninja] should be regenerated "]
  end =
  struct
    type t =
      {
      dir_or_files: string array ;
      st_mtimes: float array ;
      source_directory: string }
    let magic_number = Bs_version.version
    let write (fname : string) (x : t) =
      let oc = open_out_bin fname in
      output_string oc magic_number; output_value oc x; close_out oc
    type check_result =
      | Good 
      | Bsb_file_not_exist
      [@ocaml.doc " We assume that it is a clean repo "]
      | Bsb_source_directory_changed 
      | Bsb_bsc_version_mismatch 
      | Bsb_forced 
      | Other of string 
    let pp_check_result fmt (check_resoult : check_result) =
      Format.pp_print_string fmt
        (match check_resoult with
         | Good -> "OK"
         | Bsb_file_not_exist -> "Dependencies information missing"
         | Bsb_source_directory_changed -> "Bsb source directory changed"
         | Bsb_bsc_version_mismatch -> "Bsc or bsb version mismatch"
         | Bsb_forced -> "Bsb forced rebuild"
         | Other s -> s)
    let rec check_aux cwd (xs : string array) (ys : float array) i finish =
      if i = finish
      then Good
      else
        (let current_file = Array.unsafe_get xs i in
         let stat = Unix.stat (Filename.concat cwd current_file) in
         if stat.st_mtime <= (Array.unsafe_get ys i)
         then check_aux cwd xs ys (i + 1) finish
         else Other current_file)
    let read (fname : string) (cont : t -> check_result) =
      match open_in_bin fname with
      | ic ->
          let buffer = really_input_string ic (String.length magic_number) in
          if buffer <> magic_number
          then Bsb_bsc_version_mismatch
          else (let res : t = input_value ic in close_in ic; cont res)
      | exception _ -> Bsb_file_not_exist
    let record ~per_proj_dir  ~file  (file_or_dirs : string list) =
      (let dir_or_files = Array.of_list file_or_dirs in
       let st_mtimes =
         Ext_array.map dir_or_files
           (fun x -> (Unix.stat (Filename.concat per_proj_dir x)).st_mtime) in
       write
         (Ext_string.concat3 file "_" (!Bsb_global_backend.backend_string))
         { st_mtimes; dir_or_files; source_directory = per_proj_dir } : 
      unit)
    let check ~per_proj_dir:(per_proj_dir : string)  ~forced  ~file  =
      (read
         (Ext_string.concat3 file "_" (!Bsb_global_backend.backend_string))
         (fun { dir_or_files; source_directory; st_mtimes } ->
            if per_proj_dir <> source_directory
            then Bsb_source_directory_changed
            else
              if forced
              then Bsb_forced
              else
                (try
                   check_aux per_proj_dir dir_or_files st_mtimes 0
                     (Array.length dir_or_files)
                 with
                 | e ->
                     (Bsb_log.info "@{<info>Stat miss %s@}@."
                        (Printexc.to_string e);
                      Bsb_file_not_exist))) : check_result)[@@ocaml.doc
                                                             " check time stamp for all files\n    TODO: those checks system call can be saved later\n    Return a reason\n    Even forced, we still need walk through a little\n    bit in case we found a different version of compiler\n"]
  end 
module Bsb_db_encode :
  sig val write_build_cache : dir:string -> Bsb_db.ts -> string end =
  struct
    let bsbuild_cache = Literals.bsbuild_cache
    let nl buf = Ext_buffer.add_char buf '\n'
    let make_encoding length buf =
      let max_range = (length lsl 1) + 1 in
      if max_range <= 0xff
      then (Ext_buffer.add_char buf '1'; Ext_buffer.add_int_1)
      else
        if max_range <= 0xff_ff
        then (Ext_buffer.add_char buf '2'; Ext_buffer.add_int_2)
        else
          if length <= 0x7f_ff_ff
          then (Ext_buffer.add_char buf '3'; Ext_buffer.add_int_3)
          else
            if length <= 0x7f_ff_ff_ff
            then (Ext_buffer.add_char buf '4'; Ext_buffer.add_int_4)
            else assert false
    let encode_single (db : Bsb_db.t) (buf : Ext_buffer.t) =
      nl buf;
      (let len = Map_string.cardinal db in
       Ext_buffer.add_string_char buf (string_of_int len) '\n';
       (let mapping = Hash_string.create 50 in
        Map_string.iter db
          (fun name ->
             fun { dir } ->
               Ext_buffer.add_string_char buf name '\n';
               if not (Hash_string.mem mapping dir)
               then Hash_string.add mapping dir (Hash_string.length mapping));
        (let length = Hash_string.length mapping in
         let rev_mapping = Array.make length "" in
         Hash_string.iter mapping
           (fun k -> fun i -> Array.unsafe_set rev_mapping i k);
         Ext_array.iter rev_mapping
           (fun s -> Ext_buffer.add_string_char buf s '\t');
         nl buf;
         (let len_encoding = make_encoding length buf in
          Map_string.iter db
            (fun _ ->
               fun module_info ->
                 len_encoding buf
                   (((Hash_string.find_exn mapping module_info.dir) lsl 1) +
                      (Obj.magic module_info.case)))))))
    let encode (dbs : Bsb_db.ts) buf =
      Ext_buffer.add_char_string buf '\n' (string_of_int (Array.length dbs));
      Ext_array.iter dbs (fun x -> encode_single x buf)
    let write_build_cache ~dir  (bs_files : Bsb_db.ts) =
      (let oc = open_out_bin (Filename.concat dir bsbuild_cache) in
       let buf = Ext_buffer.create 100_000 in
       encode bs_files buf;
       (let digest = Ext_buffer.digest buf in
        let hex_digest = Digest.to_hex digest in
        output_string oc digest;
        Ext_buffer.output_buffer oc buf;
        close_out oc;
        hex_digest) : string)
  end 
module Ext_digest : sig val length : int end = struct let length = 16 end 
module Bsb_namespace_map_gen :
  sig
    val output : dir:string -> string -> Bsb_file_groups.file_groups -> unit
    [@@ocaml.doc
      " [output dir namespace file_groups]\n    when [build.ninja] is generated, we output a module map [.mlmap] file \n    such [.mlmap] file will be consumed by [bsc.exe] to generate [.cmi] file\n "]
  end =
  struct
    let (//) = Ext_path.combine
    let write_file fname digest contents =
      let oc = open_out_bin fname in
      Digest.output oc digest;
      output_char oc '\n';
      Ext_buffer.output_buffer oc contents;
      close_out oc[@@ocaml.doc
                    " \n  TODO:\n  sort filegroupts to ensure deterministic behavior\n  \n  if [.bsbuild] is not changed\n  [.mlmap] does not need to be changed too\n  \n"]
    let output ~dir  (namespace : string)
      (file_groups : Bsb_file_groups.file_groups) =
      let fname = namespace ^ Literals.suffix_mlmap in
      let buf = Ext_buffer.create 10000 in
      Ext_list.iter file_groups
        (fun x ->
           Map_string.iter x.sources
             (fun k -> fun _ -> Ext_buffer.add_string_char buf k '\n'));
      (let digest = Ext_buffer.digest buf in
       let fname = dir // fname in
       if Sys.file_exists fname
       then
         let ic = open_in_bin fname in
         let old_digest = really_input_string ic Ext_digest.length in
         (close_in ic;
          if old_digest <> digest then write_file fname digest buf)
       else write_file fname digest buf)[@@ocaml.doc
                                          " \n  TODO:\n  sort filegroupts to ensure deterministic behavior\n  \n  if [.bsbuild] is not changed\n  [.mlmap] does not need to be changed too\n  \n"]
  end 
module Bsb_ninja_global_vars =
  struct
    let g_pkg_flg = "g_pkg_flg"
    let bsc = "bsc"
    let src_root_dir = "src_root_dir"
    let bsdep = "bsdep"
    let bsc_flags = "bsc_flags"
    let ppx_flags = "ppx_flags"
    let pp_flags = "pp_flags"
    let g_dpkg_incls = "g_dpkg_incls"
    let postbuild = "postbuild"
    let g_ns = "g_ns"
    let warnings = "warnings"
    let gentypeconfig = "gentypeconfig"
    let g_dev_incls = "g_dev_incls"
  end
module Bsb_ninja_rule :
  sig
    type t[@@ocaml.doc
            " The complexity comes from the fact that we allow custom rules which could\n  conflict with our custom built-in rules\n"]
    val get_name : t -> out_channel -> string
    type builtin =
      {
      build_ast: t ;
      build_ast_from_re: t ;
      copy_resources: t [@ocaml.doc " Rules below all need restat "];
      build_bin_deps: t ;
      ml_cmj_js: t ;
      ml_cmj_js_dev: t ;
      ml_cmj_cmi_js: t ;
      ml_cmj_cmi_js_dev: t ;
      ml_cmi: t ;
      ml_cmi_dev: t ;
      build_package: t ;
      customs: t Map_string.t }[@@ocaml.doc " A list of existing rules "]
    [@@@ocaml.text
      " rules are generally composed of built-in rules and customized rules, there are two design choices:\n    1. respect custom rules with the same name, then we need adjust our built-in \n    rules dynamically in case the conflict.\n    2. respect our built-in rules, then we only need re-load custom rules for each bsconfig.json\n"]
    type command = string[@@ocaml.doc
                           " Since now we generate ninja files per bsconfig.json in a single process, \n    we must make sure it is re-entrant\n"]
    val make_custom_rules :
      has_gentype:bool ->
        has_postbuild:bool ->
          has_ppx:bool ->
            has_pp:bool ->
              has_builtin:bool ->
                bs_suffix:bool ->
                  reason_react_jsx:Bsb_config_types.reason_react_jsx option
                    ->
                    digest:string ->
                      refmt:string option -> command Map_string.t -> builtin
    [@@ocaml.doc
      " Since now we generate ninja files per bsconfig.json in a single process, \n    we must make sure it is re-entrant\n"]
  end =
  struct
    type t =
      {
      mutable used: bool ;
      rule_name: string ;
      name: out_channel -> string }
    let get_name (x : t) oc = x.name oc
    let print_rule (oc : out_channel) ~description 
      ?restat:(restat : unit option)  ?dyndep  ~command  name =
      output_string oc "rule ";
      output_string oc name;
      output_string oc "\n";
      output_string oc "  command = ";
      output_string oc command;
      output_string oc "\n";
      Ext_option.iter dyndep
        (fun f ->
           output_string oc "  dyndep = ";
           output_string oc f;
           output_string oc "\n");
      if restat <> None then output_string oc "  restat = 1\n";
      output_string oc "  description = ";
      output_string oc description;
      output_string oc "\n"
    let define ~command  ?dyndep  ?restat  ?(description=
      "\027[34mBuilding\027[39m \027[2m${out}\027[22m")  rule_name =
      (let rec self =
         {
           used = false;
           rule_name;
           name =
             (fun oc ->
                if not self.used
                then
                  (print_rule oc ~description ?dyndep ?restat ~command
                     rule_name;
                   self.used <- true);
                rule_name)
         } in
       self : t)[@@ocaml.doc " allocate an unique name for such rule"]
    type command = string
    type builtin =
      {
      build_ast: t [@ocaml.doc " TODO: Implement it on top of pp_flags "];
      build_ast_from_re: t ;
      copy_resources: t [@ocaml.doc " Rules below all need restat "];
      build_bin_deps: t ;
      ml_cmj_js: t ;
      ml_cmj_js_dev: t ;
      ml_cmj_cmi_js: t ;
      ml_cmj_cmi_js_dev: t ;
      ml_cmi: t ;
      ml_cmi_dev: t ;
      build_package: t ;
      customs: t Map_string.t }
    let make_custom_rules ~has_gentype:(has_gentype : bool) 
      ~has_postbuild:(has_postbuild : bool)  ~has_ppx:(has_ppx : bool) 
      ~has_pp:(has_pp : bool)  ~has_builtin:(has_builtin : bool) 
      ~bs_suffix:(bs_suffix : bool) 
      ~reason_react_jsx:(reason_react_jsx :
                          Bsb_config_types.reason_react_jsx option)
       ~digest:(digest : string)  ~refmt:(refmt : string option) 
      (custom_rules : command Map_string.t) =
      (let buf = Buffer.create 100 in
       let mk_ml_cmj_cmd ~read_cmi  ~is_dev  ~postbuild  =
         (Buffer.clear buf;
          Buffer.add_string buf "$bsc $g_pkg_flg -color always";
          if bs_suffix then Buffer.add_string buf " -bs-suffix";
          if read_cmi then Buffer.add_string buf " -bs-read-cmi";
          if is_dev then Buffer.add_string buf " $g_dev_incls";
          Buffer.add_string buf " $g_lib_incls";
          if is_dev then Buffer.add_string buf " $g_dpkg_incls";
          if not has_builtin then Buffer.add_string buf " -nostdlib";
          Buffer.add_string buf " $warnings $bsc_flags";
          if has_gentype then Buffer.add_string buf " $gentypeconfig";
          Buffer.add_string buf " -o $out $in";
          if postbuild then Buffer.add_string buf " $postbuild";
          Buffer.contents buf : string) in
       let mk_ast ~has_pp:(has_pp : bool)  ~has_ppx  ~has_reason_react_jsx  =
         (Buffer.clear buf;
          Buffer.add_string buf "$bsc  $warnings -color always";
          (match refmt with
           | None -> ()
           | Some x ->
               (Buffer.add_string buf " -bs-refmt ";
                Buffer.add_string buf (Ext_filename.maybe_quote x)));
          if has_pp then Buffer.add_string buf " $pp_flags";
          (match (has_reason_react_jsx, reason_react_jsx) with
           | (false, _)|(_, None) -> ()
           | (_, Some (Jsx_v2)) -> Buffer.add_string buf " -bs-jsx 2"
           | (_, Some (Jsx_v3)) -> Buffer.add_string buf " -bs-jsx 3");
          if has_ppx then Buffer.add_string buf " $ppx_flags";
          Buffer.add_string buf
            " $bsc_flags -o $out -bs-syntax-only -bs-binary-ast $in";
          Buffer.contents buf : string) in
       let build_ast =
         define
           ~command:(mk_ast ~has_pp ~has_ppx ~has_reason_react_jsx:false)
           "build_ast" in
       let build_ast_from_re =
         define ~command:(mk_ast ~has_pp ~has_ppx ~has_reason_react_jsx:true)
           "build_ast_from_re" in
       let copy_resources =
         define
           ~command:(if Ext_sys.is_windows_or_cygwin
                     then "cmd.exe /C copy /Y $in $out > null"
                     else "cp $in $out") "copy_resource" in
       let build_bin_deps =
         define ~restat:()
           ~command:("$bsdep -hash " ^
                       (digest ^ " $g_ns -g $bsb_dir_group $in"))
           "build_deps" in
       let aux ~name  ~read_cmi  ~postbuild  =
         let postbuild = has_postbuild && postbuild in
         ((define ~command:(mk_ml_cmj_cmd ~read_cmi ~is_dev:false ~postbuild)
             ~dyndep:"$in_e.d" ~restat:() name),
           (define ~command:(mk_ml_cmj_cmd ~read_cmi ~is_dev:true ~postbuild)
              ~dyndep:"$in_e.d" ~restat:() (name ^ "_dev"))) in
       let (ml_cmj_js, ml_cmj_js_dev) =
         aux ~name:"ml_cmj_only" ~read_cmi:true ~postbuild:true in
       let (ml_cmj_cmi_js, ml_cmj_cmi_js_dev) =
         aux ~read_cmi:false ~name:"ml_cmj_cmi" ~postbuild:true in
       let (ml_cmi, ml_cmi_dev) =
         aux ~read_cmi:false ~postbuild:false ~name:"ml_cmi" in
       let build_package =
         define ~command:"$bsc -w -49 -color always -no-alias-deps  $in"
           ~restat:() "build_package" in
       {
         build_ast;
         build_ast_from_re;
         copy_resources;
         build_bin_deps;
         ml_cmj_js;
         ml_cmj_js_dev;
         ml_cmj_cmi_js;
         ml_cmi;
         ml_cmj_cmi_js_dev;
         ml_cmi_dev;
         build_package;
         customs =
           (Map_string.mapi custom_rules
              (fun name -> fun command -> define ~command ("custom_" ^ name)))
       } : builtin)
  end 
module Bsb_ninja_targets :
  sig
    type override =
      | Append of string 
      | AppendList of string list
      [@dead "Bsb_ninja_targets.override.+AppendList"]
      | AppendVar of string [@dead "Bsb_ninja_targets.override.+AppendVar"]
      | Overwrite of string 
      | OverwriteVar of string 
      | OverwriteVars of string list
      [@dead "Bsb_ninja_targets.override.+OverwriteVars"]
    type shadow =
      {
      key: string [@dead "Bsb_ninja_targets.shadow.+key"];
      op: override [@dead "Bsb_ninja_targets.shadow.+op"]}[@@ocaml.doc
                                                            " output should always be marked explicitly,\n   otherwise the build system can not figure out clearly\n   however, for the command we don't need pass `-o`\n"]
    val output_build :
      ?order_only_deps:string list ->
        ?implicit_deps:string list ->
          ?implicit_outputs:string list ->
            ?shadows:shadow list ->
              outputs:string list ->
                inputs:string list ->
                  rule:Bsb_ninja_rule.t -> out_channel -> unit[@@ocaml.doc
                                                                " output should always be marked explicitly,\n   otherwise the build system can not figure out clearly\n   however, for the command we don't need pass `-o`\n"]
    val phony :
      ?order_only_deps:string list ->
        inputs:string list -> output:string -> out_channel -> unit
    val output_kv : string -> string -> out_channel -> unit
    val output_kvs : (string * string) array -> out_channel -> unit
  end =
  struct
    type override =
      | Append of string 
      | AppendList of string list 
      | AppendVar of string 
      | Overwrite of string 
      | OverwriteVar of string 
      | OverwriteVars of string list 
    type shadow = {
      key: string ;
      op: override }
    let output_build ?(order_only_deps= [])  ?(implicit_deps= []) 
      ?(implicit_outputs= [])  ?(shadows= ([] : shadow list))  ~outputs 
      ~inputs  ~rule  oc =
      let rule = Bsb_ninja_rule.get_name rule oc in
      output_string oc "build ";
      Ext_list.iter outputs
        (fun s ->
           output_string oc Ext_string.single_space; output_string oc s);
      if implicit_outputs <> []
      then
        (output_string oc " | ";
         Ext_list.iter implicit_outputs
           (fun s ->
              output_string oc Ext_string.single_space; output_string oc s));
      output_string oc " : ";
      output_string oc rule;
      Ext_list.iter inputs
        (fun s ->
           output_string oc Ext_string.single_space; output_string oc s);
      if implicit_deps <> []
      then
        (output_string oc " | ";
         Ext_list.iter implicit_deps
           (fun s ->
              output_string oc Ext_string.single_space; output_string oc s));
      if order_only_deps <> []
      then
        (output_string oc " || ";
         Ext_list.iter order_only_deps
           (fun s ->
              output_string oc Ext_string.single_space; output_string oc s));
      output_string oc "\n";
      if shadows <> []
      then
        Ext_list.iter shadows
          (fun { key = k; op = v } ->
             output_string oc "  ";
             output_string oc k;
             output_string oc " = ";
             (match v with
              | Overwrite s -> (output_string oc s; output_string oc "\n")
              | OverwriteVar s ->
                  (output_string oc "$";
                   output_string oc s;
                   output_string oc "\n")
              | OverwriteVars s ->
                  (Ext_list.iter s
                     (fun s ->
                        output_string oc "$";
                        output_string oc s;
                        output_string oc Ext_string.single_space);
                   output_string oc "\n")
              | AppendList ls ->
                  (output_string oc "$";
                   output_string oc k;
                   Ext_list.iter ls
                     (fun s ->
                        output_string oc Ext_string.single_space;
                        output_string oc s);
                   output_string oc "\n")
              | Append s ->
                  (output_string oc "$";
                   output_string oc k;
                   output_string oc Ext_string.single_space;
                   output_string oc s;
                   output_string oc "\n")
              | AppendVar s ->
                  (output_string oc "$";
                   output_string oc k;
                   output_string oc Ext_string.single_space;
                   output_string oc "$";
                   output_string oc s;
                   output_string oc "\n")))
    let phony ?(order_only_deps= [])  ~inputs  ~output  oc =
      output_string oc "build ";
      output_string oc output;
      output_string oc " : ";
      output_string oc "phony";
      output_string oc Ext_string.single_space;
      Ext_list.iter inputs
        (fun s ->
           output_string oc Ext_string.single_space; output_string oc s);
      if order_only_deps <> []
      then
        (output_string oc " || ";
         Ext_list.iter order_only_deps
           (fun s ->
              output_string oc Ext_string.single_space; output_string oc s));
      output_string oc "\n"
    let output_kv key value oc =
      output_string oc key;
      output_string oc " = ";
      output_string oc value;
      output_string oc "\n"
    let output_kvs kvs oc =
      Ext_array.iter kvs (fun (k, v) -> output_kv k v oc)
  end 
module Ext_namespace_encode :
  sig
    val make : ?ns:string -> string -> string[@@ocaml.doc
                                               " [make ~ns:\"Ns\" \"a\" ]\n    A typical example would return \"a-Ns\"\n    Note the namespace comes from the output of [namespace_of_package_name]\n"]
  end =
  struct
    let make ?ns  cunit =
      match ns with
      | None -> cunit
      | Some ns -> cunit ^ (Literals.ns_sep ^ ns)
  end 
module Bsb_ninja_file_groups :
  sig
    val handle_files_per_dir :
      out_channel ->
        bs_suffix:bool ->
          rules:Bsb_ninja_rule.builtin ->
            package_specs:Bsb_package_specs.t ->
              js_post_build_cmd:string option ->
                files_to_install:Hash_set_string.t ->
                  namespace:string option ->
                    Bsb_file_groups.file_group -> unit
  end =
  struct
    let (//) = Ext_path.combine
    let handle_generators oc (group : Bsb_file_groups.file_group)
      custom_rules =
      let map_to_source_dir x = Bsb_config.proj_rel (group.dir // x) in
      Ext_list.iter group.generators
        (fun { output; input; command } ->
           match Map_string.find_opt custom_rules command with
           | None ->
               Ext_fmt.failwithf ~loc:__LOC__
                 "custom rule %s used but  not defined" command
           | Some rule ->
               Bsb_ninja_targets.output_build oc
                 ~outputs:(Ext_list.map output map_to_source_dir)
                 ~inputs:(Ext_list.map input map_to_source_dir) ~rule)
    let make_common_shadows package_specs dirname dir_index =
      ({
         key = Bsb_ninja_global_vars.g_pkg_flg;
         op =
           (Append
              (Bsb_package_specs.package_flag_of_package_specs package_specs
                 dirname))
       }
      ::
      (if Bsb_dir_index.is_lib_dir dir_index
       then []
       else
         [{
            key = Bsb_ninja_global_vars.g_dev_incls;
            op =
              (OverwriteVar
                 (Bsb_dir_index.string_of_bsb_dev_include dir_index))
          }]) : Bsb_ninja_targets.shadow list)
    let emit_module_build (rules : Bsb_ninja_rule.builtin)
      (package_specs : Bsb_package_specs.t)
      (group_dir_index : Bsb_dir_index.t) oc ~bs_suffix  js_post_build_cmd
      namespace (module_info : Bsb_db.module_info) =
      let has_intf_file = module_info.info = Ml_mli in
      let is_re = module_info.is_re in
      let filename_sans_extension = module_info.name_sans_extension in
      let is_dev = not (Bsb_dir_index.is_lib_dir group_dir_index) in
      let input_impl =
        Bsb_config.proj_rel
          (filename_sans_extension ^
             (if is_re then Literals.suffix_re else Literals.suffix_ml)) in
      let input_intf =
        Bsb_config.proj_rel
          (filename_sans_extension ^
             (if is_re then Literals.suffix_rei else Literals.suffix_mli)) in
      let output_mlast =
        filename_sans_extension ^
          (if is_re then Literals.suffix_reast else Literals.suffix_mlast) in
      let output_mliast =
        filename_sans_extension ^
          (if is_re then Literals.suffix_reiast else Literals.suffix_mliast) in
      let output_d = filename_sans_extension ^ Literals.suffix_d in
      let output_filename_sans_extension =
        Ext_namespace_encode.make ?ns:namespace filename_sans_extension in
      let output_cmi = output_filename_sans_extension ^ Literals.suffix_cmi in
      let output_cmj = output_filename_sans_extension ^ Literals.suffix_cmj in
      let output_js =
        Bsb_package_specs.get_list_of_output_js package_specs bs_suffix
          output_filename_sans_extension in
      let common_shadows =
        make_common_shadows package_specs (Filename.dirname output_cmi)
          group_dir_index in
      let ast_rule =
        if is_re then rules.build_ast_from_re else rules.build_ast in
      Bsb_ninja_targets.output_build oc ~outputs:[output_mlast]
        ~inputs:[input_impl] ~rule:ast_rule;
      Bsb_ninja_targets.output_build oc ~outputs:[output_d]
        ~inputs:(if has_intf_file
                 then [output_mlast; output_mliast]
                 else [output_mlast]) ~rule:(rules.build_bin_deps)
        ?shadows:(if is_dev
                  then
                    Some
                      [{
                         Bsb_ninja_targets.key =
                           Bsb_build_schemas.bsb_dir_group;
                         op =
                           (Overwrite
                              (string_of_int (group_dir_index :> int)))
                       }]
                  else None);
      if has_intf_file
      then
        (Bsb_ninja_targets.output_build oc ~outputs:[output_mliast]
           ~inputs:[input_intf] ~rule:ast_rule;
         Bsb_ninja_targets.output_build oc ~outputs:[output_cmi]
           ~shadows:common_shadows ~order_only_deps:[output_d]
           ~inputs:[output_mliast]
           ~rule:(if is_dev then rules.ml_cmi_dev else rules.ml_cmi));
      (let shadows =
         match js_post_build_cmd with
         | None -> common_shadows
         | Some cmd ->
             {
               key = Bsb_ninja_global_vars.postbuild;
               op =
                 (Overwrite
                    ("&& " ^
                       (cmd ^
                          (Ext_string.single_space ^
                             (String.concat Ext_string.single_space output_js)))))
             } :: common_shadows in
       let rule =
         if has_intf_file
         then (if is_dev then rules.ml_cmj_js_dev else rules.ml_cmj_js)
         else if is_dev then rules.ml_cmj_cmi_js_dev else rules.ml_cmj_cmi_js in
       Bsb_ninja_targets.output_build oc ~outputs:[output_cmj] ~shadows
         ~implicit_outputs:(if has_intf_file
                            then output_js
                            else output_cmi :: output_js)
         ~inputs:[output_mlast]
         ~implicit_deps:(if has_intf_file then [output_cmi] else [])
         ~order_only_deps:[output_d] ~rule)
    let handle_files_per_dir oc ~bs_suffix 
      ~rules:(rules : Bsb_ninja_rule.builtin)  ~package_specs 
      ~js_post_build_cmd 
      ~files_to_install:(files_to_install : Hash_set_string.t) 
      ~namespace:(namespace : string option) 
      (group : Bsb_file_groups.file_group) =
      (handle_generators oc group rules.customs;
       (let installable =
          match group.public with
          | Export_all -> (fun _ -> true)
          | Export_none -> (fun _ -> false)
          | Export_set set ->
              (fun module_name -> Set_string.mem set module_name) in
        Map_string.iter group.sources
          (fun module_name ->
             fun module_info ->
               if installable module_name
               then
                 Hash_set_string.add files_to_install
                   module_info.name_sans_extension;
               emit_module_build rules package_specs group.dir_index oc
                 ~bs_suffix js_post_build_cmd namespace module_info)) : 
      unit)
  end 
module Bsb_ninja_gen :
  sig
    val output_ninja_and_namespace_map :
      per_proj_dir:string -> toplevel:bool -> Bsb_config_types.t -> unit
    [@@ocaml.doc " \n  generate ninja file based on [cwd] \n"]
  end =
  struct
    let (//) = Ext_path.combine
    let get_bsc_flags (bsc_flags : string list) =
      (String.concat Ext_string.single_space bsc_flags : string)
    let emit_bsc_lib_includes
      (bs_dependencies : Bsb_config_types.dependencies)
      (source_dirs : string list) external_includes (namespace : _ option)
      (oc : out_channel) =
      (let all_includes source_dirs =
         source_dirs @
           ((Ext_list.map bs_dependencies (fun x -> x.package_install_path))
              @
              (Ext_list.map external_includes
                 (fun x ->
                    if Filename.is_relative x
                    then Bsb_config.rev_lib_bs_prefix x
                    else x))) in
       Bsb_ninja_targets.output_kv Bsb_build_schemas.g_lib_incls
         (Bsb_build_util.include_dirs
            (all_includes
               (if namespace = None
                then source_dirs
                else Filename.current_dir_name :: source_dirs))) oc : 
      unit)
    let output_static_resources (static_resources : string list) copy_rule oc
      =
      Ext_list.iter static_resources
        (fun output ->
           Bsb_ninja_targets.output_build oc ~outputs:[output]
             ~inputs:[Bsb_config.proj_rel output] ~rule:copy_rule);
      if static_resources <> []
      then
        Bsb_ninja_targets.phony oc ~order_only_deps:static_resources
          ~inputs:[] ~output:Literals.build_ninja
    let output_ninja_and_namespace_map ~per_proj_dir  ~toplevel 
      ({ bs_suffix; package_name; external_includes; bsc_flags; pp_file;
         ppx_files; bs_dependencies; bs_dev_dependencies; refmt;
         js_post_build_cmd; package_specs;
         file_groups = { files = bs_file_groups }; files_to_install;
         built_in_dependency; reason_react_jsx; generators; namespace;
         warning; gentype_config; number_of_dev_groups }
        : Bsb_config_types.t)
      =
      (let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
       let cwd_lib_bs = per_proj_dir // lib_artifacts_dir in
       let ppx_flags = Bsb_build_util.ppx_flags ppx_files in
       let oc = open_out_bin (cwd_lib_bs // Literals.build_ninja) in
       let (g_pkg_flg, g_ns_flg) =
         match namespace with
         | None ->
             ((Ext_string.inter2 "-bs-package-name" package_name),
               Ext_string.empty)
         | Some s ->
             ((Ext_string.inter4 "-bs-package-name" package_name "-bs-ns" s),
               (Ext_string.inter2 "-bs-ns" s)) in
       let () =
         Ext_option.iter pp_file
           (fun flag ->
              Bsb_ninja_targets.output_kv Bsb_ninja_global_vars.pp_flags
                (Bsb_build_util.pp_flag flag) oc);
         Ext_option.iter gentype_config
           (fun x ->
              Bsb_ninja_targets.output_kv Bsb_ninja_global_vars.gentypeconfig
                ("-bs-gentype " ^ x.path) oc);
         Bsb_ninja_targets.output_kvs
           [|(Bsb_ninja_global_vars.g_pkg_flg, g_pkg_flg);(Bsb_ninja_global_vars.src_root_dir,
                                                            per_proj_dir);
             (Bsb_ninja_global_vars.bsc,
               (Ext_filename.maybe_quote Bsb_global_paths.vendor_bsc));
             (Bsb_ninja_global_vars.bsdep,
               (Ext_filename.maybe_quote Bsb_global_paths.vendor_bsdep));
             (Bsb_ninja_global_vars.warnings,
               (Bsb_warning.to_bsb_string ~toplevel warning));(Bsb_ninja_global_vars.bsc_flags,
                                                                (get_bsc_flags
                                                                   bsc_flags));
             (Bsb_ninja_global_vars.ppx_flags, ppx_flags);(Bsb_ninja_global_vars.g_dpkg_incls,
                                                            (Bsb_build_util.include_dirs_by
                                                               bs_dev_dependencies
                                                               (fun x ->
                                                                  x.package_install_path)));
             (Bsb_ninja_global_vars.g_ns, g_ns_flg);(Bsb_build_schemas.bsb_dir_group,
                                                      "0")|] oc in
       let (bs_groups, bsc_lib_dirs, static_resources) =
         if number_of_dev_groups = 0
         then
           let (bs_group, source_dirs, static_resources) =
             Ext_list.fold_left bs_file_groups (Map_string.empty, [], [])
               (fun (acc, dirs, acc_resources) ->
                  fun ({ sources; dir; resources } as x) ->
                    ((Bsb_db_util.merge acc sources),
                      (if Bsb_file_groups.is_empty x
                       then dirs
                       else dir :: dirs),
                      (if resources = []
                       then acc_resources
                       else
                         Ext_list.map_append resources acc_resources
                           (fun x -> dir // x)))) in
           (Bsb_db_util.sanity_check bs_group;
            ([|bs_group|], source_dirs, static_resources))
         else
           (let bs_groups =
              Array.init (number_of_dev_groups + 1)
                (fun _ -> Map_string.empty) in
            let source_dirs =
              Array.init (number_of_dev_groups + 1) (fun _ -> []) in
            let static_resources =
              Ext_list.fold_left bs_file_groups []
                (fun (acc_resources : string list) ->
                   fun { sources; dir; resources; dir_index } ->
                     let dir_index = (dir_index :> int) in
                     bs_groups.(dir_index) <-
                       (Bsb_db_util.merge (bs_groups.(dir_index)) sources);
                     source_dirs.(dir_index) <- (dir ::
                     (source_dirs.(dir_index)));
                     Ext_list.map_append resources acc_resources
                       (fun x -> dir // x)) in
            let lib = bs_groups.((Bsb_dir_index.lib_dir_index :> int)) in
            Bsb_db_util.sanity_check lib;
            for i = 1 to number_of_dev_groups do
              (let c = bs_groups.(i) in
               Bsb_db_util.sanity_check c;
               Map_string.iter c
                 (fun k ->
                    fun a ->
                      if Map_string.mem lib k
                      then
                        Bsb_db_util.conflict_module_info k a
                          (Map_string.find_exn lib k));
               Bsb_ninja_targets.output_kv
                 (let open Bsb_dir_index in
                    string_of_bsb_dev_include (of_int i))
                 (Bsb_build_util.include_dirs (source_dirs.(i))) oc)
            done;
            (bs_groups, (source_dirs.((Bsb_dir_index.lib_dir_index :> int))),
              static_resources)) in
       let digest = Bsb_db_encode.write_build_cache ~dir:cwd_lib_bs bs_groups in
       let rules : Bsb_ninja_rule.builtin =
         Bsb_ninja_rule.make_custom_rules ~refmt
           ~has_gentype:(gentype_config <> None)
           ~has_postbuild:(js_post_build_cmd <> None)
           ~has_ppx:(ppx_files <> []) ~has_pp:(pp_file <> None)
           ~has_builtin:(built_in_dependency <> None) ~reason_react_jsx
           ~bs_suffix ~digest generators in
       emit_bsc_lib_includes bs_dependencies bsc_lib_dirs external_includes
         namespace oc;
       output_static_resources static_resources rules.copy_resources oc;
       Ext_list.iter bs_file_groups
         (fun files_per_dir ->
            Bsb_ninja_file_groups.handle_files_per_dir oc ~bs_suffix ~rules
              ~js_post_build_cmd ~package_specs ~files_to_install ~namespace
              files_per_dir);
       Ext_option.iter namespace
         (fun ns ->
            let namespace_dir = per_proj_dir // lib_artifacts_dir in
            Bsb_namespace_map_gen.output ~dir:namespace_dir ns bs_file_groups;
            Bsb_ninja_targets.output_build oc
              ~outputs:[ns ^ Literals.suffix_cmi]
              ~inputs:[ns ^ Literals.suffix_mlmap]
              ~rule:(rules.build_package));
       close_out oc : unit)
  end 
module Ext_json_noloc :
  sig
    type t
    val str : string -> t
    val arr : t array -> t
    val kvs : (string * t) list -> t
    val to_file : string -> t -> unit
  end =
  struct
    type t =
      | True 
      | False 
      | Null 
      | Flo of string 
      | Str of string 
      | Arr of t array 
      | Obj of t Map_string.t 
    let naive_escaped (unmodified_input : string) =
      (let n = ref 0 in
       let len = String.length unmodified_input in
       for i = 0 to len - 1 do
         n :=
           ((!n) +
              ((match String.unsafe_get unmodified_input i with
                | '"'|'\\'|'\n'|'\t'|'\r'|'\b' -> 2
                | _ -> 1)))
       done;
       if (!n) = len
       then unmodified_input
       else
         (let result = Bytes.create (!n) in
          n := 0;
          for i = 0 to len - 1 do
            (let open Bytes in
               (match String.unsafe_get unmodified_input i with
                | '"'|'\\' as c ->
                    (unsafe_set result (!n) '\\';
                     incr n;
                     unsafe_set result (!n) c)
                | '\n' ->
                    (unsafe_set result (!n) '\\';
                     incr n;
                     unsafe_set result (!n) 'n')
                | '\t' ->
                    (unsafe_set result (!n) '\\';
                     incr n;
                     unsafe_set result (!n) 't')
                | '\r' ->
                    (unsafe_set result (!n) '\\';
                     incr n;
                     unsafe_set result (!n) 'r')
                | '\b' ->
                    (unsafe_set result (!n) '\\';
                     incr n;
                     unsafe_set result (!n) 'b')
                | c -> unsafe_set result (!n) c);
               incr n)
          done;
          Bytes.unsafe_to_string result) : string)[@@ocaml.doc
                                                    " poor man's serialization "]
    let quot x = "\"" ^ ((naive_escaped x) ^ "\"")
    let str s = Str s
    let arr s = Arr s
    let kvs s = Obj (Map_string.of_list s)
    let rec encode_buf (x : t) (buf : Buffer.t) =
      (let a str = Buffer.add_string buf str in
       match x with
       | Null -> a "null"
       | Str s -> a (quot s)
       | Flo s -> a s
       | Arr content ->
           (match content with
            | [||] -> a "[]"
            | _ ->
                (a "[ ";
                 encode_buf (Array.unsafe_get content 0) buf;
                 for i = 1 to (Array.length content) - 1 do
                   (a " , "; encode_buf (Array.unsafe_get content i) buf)
                 done;
                 a " ]"))
       | True -> a "true"
       | False -> a "false"
       | Obj map ->
           if Map_string.is_empty map
           then a "{}"
           else
             (a "{ ";
              (let (_ : int) =
                 Map_string.fold map 0
                   (fun k ->
                      fun v ->
                        fun i ->
                          if i <> 0 then a " , ";
                          a (quot k);
                          a " : ";
                          encode_buf v buf;
                          i + 1) in
               a " }")) : unit)
    let to_channel (oc : out_channel) x =
      let buf = Buffer.create 1024 in
      encode_buf x buf; Buffer.output_buffer oc buf
    let to_file name v =
      let ochan = open_out_bin name in to_channel ochan v; close_out ochan
  end 
module Bsb_watcher_gen :
  sig
    val generate_sourcedirs_meta : name:string -> Bsb_file_groups.t -> unit
    [@@ocaml.doc
      " This module try to generate some meta data so that\n  everytime [bsconfig.json] is reload, we can re-read\n  such meta data changes in the watcher.\n  \n  Another way of doing it is processing [bsconfig.json] \n  directly in [watcher] but that would \n  mean the duplication of logic in [bsb] and [bsb_watcher]\n"]
  end =
  struct
    let kvs = Ext_json_noloc.kvs
    let arr = Ext_json_noloc.arr
    let str = Ext_json_noloc.str
    let generate_sourcedirs_meta ~name  (res : Bsb_file_groups.t) =
      let v =
        kvs
          [("dirs",
             (arr (Ext_array.of_list_map res.files (fun x -> str x.dir))));
          ("generated",
            (arr
               (Array.of_list @@
                  (Ext_list.fold_left res.files []
                     (fun acc ->
                        fun x ->
                          Ext_list.flat_map_append x.generators acc
                            (fun x -> Ext_list.map x.output str))))));
          ("pkgs",
            (arr
               (Array.of_list
                  (Bsb_pkg.to_list
                     (fun pkg ->
                        fun path ->
                          arr
                            [|(str (Bsb_pkg_types.to_string pkg));(str path)|])))))] in
      Ext_json_noloc.to_file name v
  end 
module Bsb_ninja_regen :
  sig
    val regenerate_ninja :
      toplevel_package_specs:Bsb_package_specs.t option ->
        forced:bool -> per_proj_dir:string -> Bsb_config_types.t option
    [@@ocaml.doc
      " Regenerate ninja file by need based on [.bsdeps]\n    return None if we dont need regenerate\n    otherwise return Some info\n"]
  end =
  struct
    let bsdeps = ".bsdeps"
    let (//) = Ext_path.combine
    let regenerate_ninja
      ~toplevel_package_specs:(toplevel_package_specs :
                                Bsb_package_specs.t option)
       ~forced  ~per_proj_dir  =
      (let toplevel = toplevel_package_specs = None in
       let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
       let lib_bs_dir = per_proj_dir // lib_artifacts_dir in
       let output_deps = lib_bs_dir // bsdeps in
       let check_result =
         Bsb_ninja_check.check ~per_proj_dir ~forced ~file:output_deps in
       Bsb_log.info "@{<info>BSB check@} build spec : %a @."
         Bsb_ninja_check.pp_check_result check_result;
       (match check_result with
        | Good -> None
        | Bsb_forced|Bsb_bsc_version_mismatch|Bsb_file_not_exist
          |Bsb_source_directory_changed|Other _ ->
            (if check_result = Bsb_bsc_version_mismatch
             then
               (Bsb_log.warn
                  "@{<info>Different compiler version@}: clean current repo@.";
                Bsb_clean.clean_self per_proj_dir);
             (let config =
                Bsb_config_parse.interpret_json ~toplevel_package_specs
                  ~per_proj_dir in
              Bsb_build_util.mkp lib_bs_dir;
              Bsb_package_specs.list_dirs_by config.package_specs
                (fun x ->
                   let dir = per_proj_dir // x in
                   if not (Sys.file_exists dir) then Unix.mkdir dir 0o777);
              if toplevel
              then
                Bsb_watcher_gen.generate_sourcedirs_meta
                  ~name:(lib_bs_dir // Literals.sourcedirs_meta)
                  config.file_groups;
              Bsb_merlin_gen.merlin_file_gen ~per_proj_dir config;
              Bsb_ninja_gen.output_ninja_and_namespace_map ~per_proj_dir
                ~toplevel config;
              Bsb_ninja_check.record ~per_proj_dir ~file:output_deps
                (Literals.bsconfig_json ::
                ((config.file_groups).globbed_dirs));
              Some config))) : Bsb_config_types.t option)[@@ocaml.doc
                                                           " Regenerate ninja file by need based on [.bsdeps]\n    return None if we dont need regenerate\n    otherwise return Some info\n"]
  end 
module Bsb_regex :
  sig
    val global_substitute :
      string -> reg:string -> (string -> string list -> string) -> string
    [@@ocaml.doc " Used in `bsb -init` command "]
  end =
  struct
    let string_after s n = String.sub s n ((String.length s) - n)
    let global_substitute text ~reg:expr  repl_fun =
      let text_len = String.length text in
      let expr = Str.regexp expr in
      let rec replace accu start last_was_empty =
        let startpos = if last_was_empty then start + 1 else start in
        if startpos > text_len
        then (string_after text start) :: accu
        else
          (match Str.search_forward expr text startpos with
           | exception Not_found -> (string_after text start) :: accu
           | pos ->
               let end_pos = Str.match_end () in
               let matched = Str.matched_string text in
               let groups =
                 let rec aux n acc =
                   match Str.matched_group n text with
                   | exception (Not_found|Invalid_argument _) -> acc
                   | v -> aux (succ n) (v :: acc) in
                 aux 1 [] in
               let repl_text = repl_fun matched groups in
               replace (repl_text :: (String.sub text start (pos - start)) ::
                 accu) end_pos (end_pos = pos)) in
      String.concat "" (List.rev (replace [] 0 false))
  end 
module OCamlRes =
  struct
    module Res =
      struct
        type node =
          | Dir of string * node list 
          | File of string * string 
      end
  end
module Bsb_templates : sig val root : OCamlRes.Res.node list end =
  struct
    let root =
      let open OCamlRes.Res in
        [Dir
           ("basic",
             [Dir
                ("src",
                  [File
                     ("demo.ml",
                       "\n\nlet () = Js.log \"Hello, BuckleScript\"")]);
             File
               ("bsconfig.json",
                 "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"sources\": {\n    \"dir\" : \"src\",\n    \"subdirs\" : true\n  },\n  \"package-specs\": {\n    \"module\": \"commonjs\",\n    \"in-source\": true\n  },\n  \"suffix\": \".bs.js\",\n  \"bs-dependencies\": [\n  ],\n  \"warnings\": {\n    \"error\" : \"+101\"\n  },\n  \"refmt\": 3\n}\n");
             File
               ("package.json",
                 "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"clean\": \"bsb -clean-world\",\n    \"build\": \"bsb -make-world\",\n    \"watch\": \"bsb -make-world -w\"\n  },\n  \"keywords\": [\n    \"BuckleScript\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\"\n  }\n}");
             File
               (".gitignore",
                 "*.exe\n*.obj\n*.out\n*.compile\n*.native\n*.byte\n*.cmo\n*.annot\n*.cmi\n*.cmx\n*.cmt\n*.cmti\n*.cma\n*.a\n*.cmxa\n*.obj\n*~\n*.annot\n*.cmj\n*.bak\nlib/bs\n*.mlast\n*.mliast\n.vscode\n.merlin\n.bsb.lock");
             File
               ("README.md",
                 "\n\n# Build\n```\nnpm run build\n```\n\n# Watch\n\n```\nnpm run watch\n```\n\n")]);
        Dir
          ("basic-reason",
            [Dir
               ("src",
                 [File
                    ("Demo.re",
                      "Js.log(\"Hello, BuckleScript and Reason!\");\n")]);
            File
              ("bsconfig.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"sources\": {\n    \"dir\" : \"src\",\n    \"subdirs\" : true\n  },\n  \"package-specs\": {\n    \"module\": \"commonjs\",\n    \"in-source\": true\n  },\n  \"suffix\": \".bs.js\",\n  \"bs-dependencies\": [\n\n  ],\n  \"warnings\": {\n    \"error\" : \"+101\"\n  },\n  \"namespace\": true,\n  \"refmt\": 3\n}\n");
            File
              ("package.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"build\": \"bsb -make-world\",\n    \"start\": \"bsb -make-world -w\",\n    \"clean\": \"bsb -clean-world\"\n  },\n  \"keywords\": [\n    \"BuckleScript\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\"\n  }\n}\n");
            File
              (".gitignore",
                ".DS_Store\n.merlin\n.bsb.lock\nnpm-debug.log\n/lib/bs/\n/node_modules/\n");
            File
              ("README.md",
                "# Basic Reason Template\n\nHello! This project allows you to quickly get started with Reason and BuckleScript. If you wanted a more sophisticated version, try the `react` template (`bsb -theme react -init .`).\n\n# Build\n\n```bash\n# for yarn\nyarn build\n\n# for npm\nnpm run build\n```\n\n# Build + Watch\n\n```bash\n# for yarn\nyarn start\n\n# for npm\nnpm run start\n```\n\n")]);
        Dir
          ("generator",
            [Dir
               ("src",
                 [File
                    ("test.cpp.ml",
                      "\n(* \n#define FS_VAL(name,ty) external name : ty = \"\" [@@bs.module \"fs\"]\n\n\nFS_VAL(readdirSync, string -> string array)\n *)\n\n\n let ocaml = OCAML");
                 File
                   ("demo.ml", "\n\nlet () = Js.log \"Hello, BuckleScript\"")]);
            File
              ("bsconfig.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"sources\": {\n    \"dir\": \"src\",\n    \"generators\": [{\n      \"name\": \"cpp\",\n      \"edge\": [\"test.ml\", \":\", \"test.cpp.ml\"]\n    }],\n    \"subdirs\": true  \n  },\n  \"generators\": [{\n    \"name\" : \"cpp\",\n    \"command\": \"sed 's/OCAML/3/' $in > $out\"\n  }],\n  \"bs-dependencies\" : [\n  ]\n}");
            File
              ("package.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"clean\": \"bsb -clean-world\",\n    \"build\": \"bsb -make-world\",\n    \"watch\": \"bsb -make-world -w\"\n  },\n  \"keywords\": [\n    \"BuckleScript\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\"\n  }\n}");
            File
              (".gitignore",
                "*.exe\n*.obj\n*.out\n*.compile\n*.native\n*.byte\n*.cmo\n*.annot\n*.cmi\n*.cmx\n*.cmt\n*.cmti\n*.cma\n*.a\n*.cmxa\n*.obj\n*~\n*.annot\n*.cmj\n*.bak\nlib/bs\n*.mlast\n*.mliast\n.vscode\n.merlin\n.bsb.lock");
            File
              ("README.md",
                "\n\n# Build\n```\nnpm run build\n```\n\n# Watch\n\n```\nnpm run watch\n```\n\n\n# Editor\nIf you use `vscode`, Press `Windows + Shift + B` it will build automatically")]);
        Dir
          ("minimal",
            [Dir ("src", [File ("main.ml", "")]);
            File
              ("bsconfig.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"sources\": {\n      \"dir\": \"src\",\n      \"subdirs\": true\n  }\n}");
            File
              ("package.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"clean\": \"bsb -clean-world\",\n    \"build\": \"bsb -make-world\",\n    \"start\": \"bsb -make-world -w\"\n  },\n  \"keywords\": [\n    \"BuckleScript\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\"\n  }\n}");
            File
              (".gitignore",
                ".DS_Store\n.merlin\n.bsb.lock\nnpm-debug.log\n/lib/bs/\n/node_modules/");
            File ("README.md", "\n  # ${bsb:name}")]);
        Dir
          ("node",
            [Dir
               ("src",
                 [File
                    ("demo.ml",
                      "\n\nlet () = Js.log \"Hello, BuckleScript\"")]);
            File
              ("bsconfig.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"sources\": {\n      \"dir\": \"src\",\n      \"subdirs\" : true\n  },\n  \"package-specs\": {\n    \"module\": \"commonjs\",\n    \"in-source\": true\n  },\n  \"suffix\": \".bs.js\",\n  \"bs-dependencies\": [\n   ]\n}");
            File
              ("package.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"clean\": \"bsb -clean-world\",\n    \"build\": \"bsb -make-world\",\n    \"watch\": \"bsb -make-world -w\"\n  },\n  \"keywords\": [\n    \"BuckleScript\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\"\n  }\n}");
            File
              (".gitignore",
                "*.exe\n*.obj\n*.out\n*.compile\n*.native\n*.byte\n*.cmo\n*.annot\n*.cmi\n*.cmx\n*.cmt\n*.cmti\n*.cma\n*.a\n*.cmxa\n*.obj\n*~\n*.annot\n*.cmj\n*.bak\nlib/bs\n*.mlast\n*.mliast\n.vscode\n.merlin\n.bsb.lock");
            File
              ("README.md",
                "\n\n# Build\n```\nnpm run build\n```\n\n# Watch\n\n```\nnpm run watch\n```\n\n\n# Editor\nIf you use `vscode`, Press `Windows + Shift + B` it will build automatically\n")]);
        Dir
          ("react-hooks",
            [Dir
               ("src",
                 [File
                    ("Index.re",
                      "// Entry point\n\n[@bs.val] external document: Js.t({..}) = \"document\";\n\n// We're using raw DOM manipulations here, to avoid making you read\n// ReasonReact when you might precisely be trying to learn it for the first\n// time through the examples later.\nlet style = document##createElement(\"style\");\ndocument##head##appendChild(style);\nstyle##innerHTML #= ExampleStyles.style;\n\nlet makeContainer = text => {\n  let container = document##createElement(\"div\");\n  container##className #= \"container\";\n\n  let title = document##createElement(\"div\");\n  title##className #= \"containerTitle\";\n  title##innerText #= text;\n\n  let content = document##createElement(\"div\");\n  content##className #= \"containerContent\";\n\n  let () = container##appendChild(title);\n  let () = container##appendChild(content);\n  let () = document##body##appendChild(container);\n\n  content;\n};\n\n// All 4 examples.\nReactDOMRe.render(\n  <BlinkingGreeting>\n    {React.string(\"Hello!\")}\n  </BlinkingGreeting>,\n  makeContainer(\"Blinking Greeting\"),\n);\n\nReactDOMRe.render(\n  <ReducerFromReactJSDocs />,\n  makeContainer(\"Reducer From ReactJS Docs\"),\n);\n\nReactDOMRe.render(\n  <FetchedDogPictures />,\n  makeContainer(\"Fetched Dog Pictures\"),\n);\n\nReactDOMRe.render(\n  <ReasonUsingJSUsingReason />,\n  makeContainer(\"Reason Using JS Using Reason\"),\n);\n");
                 File
                   ("ExampleStyles.re",
                     "let reasonReactBlue = \"#48a9dc\";\n\n// The {j|...|j} feature is just string interpolation, from\n// bucklescript.github.io/docs/en/interop-cheatsheet#string-unicode-interpolation\n// This allows us to conveniently write CSS, together with variables, by\n// constructing a string\nlet style = {j|\n  body {\n    background-color: rgb(224, 226, 229);\n    display: flex;\n    flex-direction: column;\n    align-items: center;\n  }\n  button {\n    background-color: white;\n    color: $reasonReactBlue;\n    box-shadow: 0 0 0 1px $reasonReactBlue;\n    border: none;\n    padding: 8px;\n    font-size: 16px;\n  }\n  button:active {\n    background-color: $reasonReactBlue;\n    color: white;\n  }\n  .container {\n    margin: 12px 0px;\n    box-shadow: 0px 4px 16px rgb(200, 200, 200);\n    width: 720px;\n    border-radius: 12px;\n    font-family: sans-serif;\n  }\n  .containerTitle {\n    background-color: rgb(242, 243, 245);\n    border-radius: 12px 12px 0px 0px;\n    padding: 12px;\n    font-weight: bold;\n  }\n  .containerContent {\n    background-color: white;\n    padding: 16px;\n    border-radius: 0px 0px 12px 12px;\n  }\n|j};\n");
                 Dir
                   ("FetchedDogPictures",
                     [File
                        ("FetchedDogPictures.re",
                          "[@bs.val] external fetch: string => Js.Promise.t('a) = \"fetch\";\n\ntype state =\n  | LoadingDogs\n  | ErrorFetchingDogs\n  | LoadedDogs(array(string));\n\n[@react.component]\nlet make = () => {\n  let (state, setState) = React.useState(() => LoadingDogs);\n\n  // Notice that instead of `useEffect`, we have `useEffect0`. See\n  // reasonml.github.io/reason-react/docs/en/components#hooks for more info\n  React.useEffect0(() => {\n    Js.Promise.(\n      fetch(\"https://dog.ceo/api/breeds/image/random/3\")\n      |> then_(response => response##json())\n      |> then_(jsonResponse => {\n           setState(_previousState => LoadedDogs(jsonResponse##message));\n           Js.Promise.resolve();\n         })\n      |> catch(_err => {\n           setState(_previousState => ErrorFetchingDogs);\n           Js.Promise.resolve();\n         })\n      |> ignore\n    );\n\n    // Returning None, instead of Some(() => ...), means we don't have any\n    // cleanup to do before unmounting. That's not 100% true. We should\n    // technically cancel the promise. Unofortunately, there's currently no\n    // way to cancel a promise. Promises in general should be way less used\n    // for React components; but since folks do use them, we provide such an\n    // example here. In reality, this fetch should just be a plain callback,\n    // with a cancellation API\n    None;\n  });\n\n  <div\n    style={ReactDOMRe.Style.make(\n      ~height=\"120px\",\n      ~display=\"flex\",\n      ~alignItems=\"center\",\n      ~justifyContent=\"center\",\n      (),\n    )}>\n    {switch (state) {\n     | ErrorFetchingDogs => React.string(\"An error occurred!\")\n     | LoadingDogs => React.string(\"Loading...\")\n     | LoadedDogs(dogs) =>\n       dogs\n       ->Belt.Array.mapWithIndex((i, dog) => {\n           let imageStyle =\n             ReactDOMRe.Style.make(\n               ~height=\"120px\",\n               ~width=\"100%\",\n               ~marginRight=i === Js.Array.length(dogs) - 1 ? \"0px\" : \"8px\",\n               ~borderRadius=\"8px\",\n               ~boxShadow=\"0px 4px 16px rgb(200, 200, 200)\",\n               ~backgroundSize=\"cover\",\n               ~backgroundImage={j|url($dog)|j},\n               ~backgroundPosition=\"center\",\n               (),\n             );\n           <div key=dog style=imageStyle />;\n         })\n       ->React.array\n     }}\n  </div>;\n};\n")]);
                 Dir
                   ("BlinkingGreeting",
                     [File
                        ("BlinkingGreeting.re",
                          "[@react.component]\nlet make = (~children) => {\n  let (show, setShow) = React.useState(() => true);\n\n  // Notice that instead of `useEffect`, we have `useEffect0`. See\n  // reasonml.github.io/reason-react/docs/en/components#hooks for more info\n  React.useEffect0(() => {\n    let id =\n      Js.Global.setInterval(\n        () => setShow(previousShow => !previousShow),\n        1000,\n      );\n\n    Some(() => Js.Global.clearInterval(id));\n  });\n\n  let style =\n    if (show) {\n      ReactDOMRe.Style.make(~opacity=\"1\", ~transition=\"opacity 1s\", ());\n    } else {\n      ReactDOMRe.Style.make(~opacity=\"0\", ~transition=\"opacity 1s\", ());\n    };\n\n  <div style> children </div>;\n};\n")]);
                 Dir
                   ("ReasonUsingJSUsingReason",
                     [File
                        ("ReasonUsingJSUsingReason.re",
                          "// In this Interop example folder, we have:\n// - A ReasonReact component, ReasonReactCard.re\n// - Used by a ReactJS component, ReactJSCard.js\n// - ReactJSCard.js can be used by ReasonReact, through bindings in ReasonUsingJSUsingReason.re (this file)\n// - ReasonUsingJSUsingReason.re is used by Index.re\n\n// All you need to do to use a ReactJS component in ReasonReact, is to write the lines below!\n// reasonml.github.io/reason-react/docs/en/components#import-from-js\n[@react.component] [@bs.module]\nexternal make: unit => React.element = \"./ReactJSCard\";\n");
                     File
                       ("ReasonReactCard.re",
                         "// In this Interop example folder, we have:\n// - A ReasonReact component, ReasonReactCard.re (this file)\n// - Used by a ReactJS component, ReactJSCard.js\n// - ReactJSCard.js can be used by ReasonReact, through bindings in ReasonUsingJSUsingReason.re\n// - ReasonUsingJSUsingReason.re is used by Index.re\n\n[@react.component]\nlet make = (~style) => {\n  <div style> {React.string(\"This is a ReasonReact card\")} </div>;\n};\n");
                     File
                       ("ReactJSCard.js",
                         "// In this Interop example folder, we have:\n// - A ReasonReact component, ReasonReactCard.re\n// - Used by a ReactJS component, ReactJSCard.js (this file)\n// - ReactJSCard.js can be used by ReasonReact, through bindings in ReasonUsingJSUsingReason.re\n// - ReasonUsingJSUsingReason.re is used by Index.re\n\nvar ReactDOM = require('react-dom');\nvar React = require('react');\n\nvar ReasonReactCard = require('./ReasonReactCard.bs').make;\n\nvar ReactJSComponent = function() {\n  let backgroundColor = \"rgba(0, 0, 0, 0.05)\";\n  let padding = \"12px\";\n\n  // We're not using JSX here, to avoid folks needing to install the related\n  // React toolchains just for this example.\n  // <div style={...}>\n  //   <div style={...}>This is a ReactJS card</div>\n  //   <ReasonReactCard style={...} />\n  // </div>\n  return React.createElement(\n    \"div\",\n    {style: {backgroundColor, padding, borderRadius: \"8px\"}},\n    React.createElement(\"div\", {style: {marginBottom: \"8px\"}}, \"This is a ReactJS card\"),\n    React.createElement(ReasonReactCard, {style: {backgroundColor, padding, borderRadius: \"4px\"}}),\n  )\n};\nReactJSComponent.displayName = \"MyBanner\";\n\nmodule.exports = ReactJSComponent;\n")]);
                 Dir
                   ("ReducerFromReactJSDocs",
                     [File
                        ("ReducerFromReactJSDocs.re",
                          "// This is the ReactJS documentation's useReducer example, directly ported over\n// https://reactjs.org/docs/hooks-reference.html#usereducer\n\n// A little extra we've put, because the ReactJS example has no styling\nlet leftButtonStyle = ReactDOMRe.Style.make(~borderRadius=\"4px 0px 0px 4px\", ~width=\"48px\", ());\nlet rightButtonStyle = ReactDOMRe.Style.make(~borderRadius=\"0px 4px 4px 0px\", ~width=\"48px\", ());\n\n// Record and variant need explicit declarations.\ntype state = {count: int};\n\ntype action =\n  | Increment\n  | Decrement;\n\nlet initialState = {count: 0};\n\nlet reducer = (state, action) => {\n  switch (action) {\n  | Increment => {count: state.count + 1}\n  | Decrement => {count: state.count - 1}\n  };\n};\n\n[@react.component]\nlet make = () => {\n  let (state, dispatch) = React.useReducer(reducer, initialState);\n\n  // We can use a fragment here, but we don't, because we want to style the counter\n  <div\n    style={ReactDOMRe.Style.make(~display=\"flex\", ~alignItems=\"center\", ~justifyContent=\"space-between\", ())}>\n    <div>\n      {React.string(\"Count: \")}\n      {React.string(string_of_int(state.count))}\n    </div>\n    <div>\n      <button style=leftButtonStyle onClick={_event => dispatch(Decrement)}>\n        {React.string(\"-\")}\n      </button>\n      <button style=rightButtonStyle onClick={_event => dispatch(Increment)}>\n        {React.string(\"+\")}\n      </button>\n    </div>\n  </div>;\n};\n")])]);
            File
              ("UNUSED_webpack.config.js",
                "const path = require('path');\n\nmodule.exports = {\n  entry: './src/Index.bs.js',\n  // If you ever want to use webpack during development, change 'production'\n  // to 'development' as per webpack documentation. Again, you don't have to\n  // use webpack or any other bundler during development! Recheck README if\n  // you didn't know this\n  mode: 'production',\n  output: {\n    path: path.join(__dirname, \"bundleOutput\"),\n    filename: 'index.js',\n  },\n};");
            File
              ("bsconfig.json",
                "{\n  \"name\": \"reason-react-examples\",\n  \"reason\": {\n    \"react-jsx\": 3\n  },\n  \"sources\": {\n    \"dir\" : \"src\",\n    \"subdirs\" : true\n  },\n  \"bsc-flags\": [\"-bs-super-errors\", \"-bs-no-version-header\"],\n  \"package-specs\": [{\n    \"module\": \"commonjs\",\n    \"in-source\": true\n  }],\n  \"suffix\": \".bs.js\",\n  \"namespace\": true,\n  \"bs-dependencies\": [\n    \"reason-react\"\n  ],\n  \"refmt\": 3\n}\n");
            File
              ("watcher.js",
                "// This is our simple, robust watcher. It hooks into the BuckleScript build\n// system to listen for build events.\n// See package.json's `start` script and `./node_modules/.bin/bsb --help`\n\n// Btw, if you change this file and reload the page, your browser cache\n// _might_ not pick up the new version. If you're in Chrome, do Force Reload.\n\nvar websocketReloader;\nvar LAST_SUCCESS_BUILD_STAMP = localStorage.getItem('LAST_SUCCESS_BUILD_STAMP') || 0;\n// package.json's `start` script's `bsb -ws _` means it'll pipe build events\n// through a websocket connection to a default port of 9999. This is\n// configurable, e.g. `-ws 5000`\nvar webSocketPort = 9999;\n\nfunction setUpWebSocket() {\n  if (websocketReloader == null || websocketReloader.readyState !== 1) {\n    try {\n      websocketReloader = new WebSocket(`ws://${window.location.hostname}:${webSocketPort}`);\n      websocketReloader.onmessage = (message) => {\n        var newData = JSON.parse(message.data).LAST_SUCCESS_BUILD_STAMP;\n        if (newData > LAST_SUCCESS_BUILD_STAMP) {\n          LAST_SUCCESS_BUILD_STAMP = newData;\n          localStorage.setItem('LAST_SUCCESS_BUILD_STAMP', LAST_SUCCESS_BUILD_STAMP);\n          // Refresh the page! This will naturally re-run everything,\n          // including our moduleserve which will re-resolve all the modules.\n          // No stable build!\n          location.reload(true);\n        }\n\n      }\n    } catch (exn) {\n      console.error(\"The watcher tried to connect to web socket, but failed. Here's the message:\");\n      console.error(exn);\n    }\n  }\n};\n\nsetUpWebSocket();\nsetInterval(setUpWebSocket, 2000);\n");
            File
              ("package.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"build\": \"bsb -make-world\",\n    \"start\": \"bsb -make-world -w -ws _ \",\n    \"clean\": \"bsb -clean-world\",\n    \"server\": \"moduleserve ./ --port 8000\",\n    \"test\": \"echo \\\"Error: no test specified\\\" && exit 1\"\n  },\n  \"keywords\": [\n    \"BuckleScript\",\n    \"ReasonReact\",\n    \"reason-react\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"dependencies\": {\n    \"react\": \"^16.8.1\",\n    \"react-dom\": \"^16.8.1\",\n    \"reason-react\": \">=0.7.0\"\n  },\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\",\n    \"moduleserve\": \"^0.9.0\"\n  }\n}\n");
            File
              (".gitignore",
                ".DS_Store\n.merlin\n.bsb.lock\nnpm-debug.log\n/lib/bs/\n/node_modules/\n/bundleOutput/");
            File
              ("README.md",
                "# ReasonReact Template & Examples\n\nThis is:\n- A template for your new ReasonReact project.\n- A collection of thin examples illustrating ReasonReact usage.\n- Extra helper documentation for ReasonReact (full ReasonReact docs [here](https://reasonml.github.io/reason-react/)).\n\n`src` contains 4 sub-folders, each an independent, self-contained ReasonReact example. Feel free to delete any of them and shape this into your project! This template's more malleable than you might be used to =).\n\nThe point of this template and examples is to let you understand and personally tweak the entirely of it. We **don't** give you an opaque, elaborate mega build setup just to put some boxes on the screen. It strikes to stay transparent, learnable, and simple. You're encouraged to read every file; it's a great feeling, having the full picture of what you're using and being able to touch any part.\n\n## Run\n\n```sh\nnpm install\nnpm run server\n# in a new tab\nnpm start\n```\n\nOpen a new web page to `http://localhost:8000/`. Change any `.re` file in `src` to see the page auto-reload. **You don't need any bundler when you're developing**!\n\n**How come we don't need any bundler during development**? We highly encourage you to open up `index.html` to check for yourself!\n\n# Features Used\n\n|                           | Blinking Greeting | Reducer from ReactJS Docs | Fetch Dog Pictures | Reason Using JS Using Reason |\n|---------------------------|-------------------|---------------------------|--------------------|------------------------------|\n| No props                  |                   | \226\156\147                         |                    |                              |\n| Has props                 |                   |                           |                    | \226\156\147                            |\n| Children props            | \226\156\147                 |                           |                    |                              |\n| No state                  |                   |                           |                    | \226\156\147                            |\n| Has state                 | \226\156\147                 |                           |  \226\156\147                 |                              |\n| Has state with useReducer |                   | \226\156\147                         |                    |                              |\n| ReasonReact using ReactJS |                   |                           |                    | \226\156\147                            |\n| ReactJS using ReasonReact |                   |                           |                    | \226\156\147                            |\n| useEffect                 | \226\156\147                 |                           |  \226\156\147                 |                              |\n| Dom attribute             | \226\156\147                 | \226\156\147                         |                    | \226\156\147                            |\n| Styling                   | \226\156\147                 | \226\156\147                         |  \226\156\147                 | \226\156\147                            |\n| React.array               |                   |                           |  \226\156\147                 |                              |\n\n# Bundle for Production\n\nWe've included a convenience `UNUSED_webpack.config.js`, in case you want to ship your project to production. You can rename and/or remove that in favor of other bundlers, e.g. Rollup.\n\nWe've also provided a barebone `indexProduction.html`, to serve your bundle.\n\n```sh\nnpm install webpack webpack-cli\n# rename file\nmv UNUSED_webpack.config.js webpack.config.js\n# call webpack to bundle for production\n./node_modules/.bin/webpack\nopen indexProduction.html\n```\n\n# Handle Routing Yourself\n\nTo serve the files, this template uses a minimal dependency called `moduleserve`. A URL such as `localhost:8000/scores/john` resolves to the file `scores/john.html`. If you'd like to override this and handle URL resolution yourself, change the `server` command in `package.json` from `moduleserve ./ --port 8000` to `moduleserve ./ --port 8000 --spa` (for \"single page application\"). This will make `moduleserve` serve the default `index.html` for any URL. Since `index.html` loads `Index.bs.js`, you can grab hold of the URL in the corresponding `Index.re` and do whatever you want.\n\nBy the way, ReasonReact comes with a small [router](https://reasonml.github.io/reason-react/docs/en/router) you might be interested in.\n");
            File
              ("indexProduction.html",
                "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"UTF-8\">\n  <title>ReasonReact Examples</title>\n</head>\n<body>\n  <script src=\"./bundleOutput/index.js\"></script>\n</body>\n</html>\n");
            File
              ("index.html",
                "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"UTF-8\">\n  <title>ReasonReact Examples</title>\n</head>\n<body>\n  <script>\n    // stub a variable ReactJS checks. ReactJS assumes you're using a bundler, NodeJS or similar system that provides it the `process.env.NODE_ENV` variable.\n    window.process = {\n      env: {\n        NODE_ENV: 'development'\n      }\n    };\n  </script>\n\n  <!-- This is https://github.com/marijnh/moduleserve, the secret sauce that allows us not need to bundle things during development, and have instantaneous iteration feedback, without any hot-reloading or extra build pipeline needed. -->\n  <script src=\"/moduleserve/load.js\" data-module=\"/src/Index.bs.js\"></script>\n  <!-- Our little watcher. Super clean. Check it out! -->\n  <script src=\"/watcher.js\"></script>\n</body>\n</html>\n")]);
        Dir
          ("react-starter",
            [Dir
               ("src",
                 [File
                    ("Index.re",
                      "[%bs.raw {|require(\"./index.css\")|}];\n\nReactDOMRe.renderToElementWithId(<App />, \"root\");\n");
                 File
                   ("index.css",
                     "body {\n  margin: 0;\n  font-family: -apple-system, system-ui, \"Segoe UI\", Helvetica, Arial,\n    sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\";\n}\n\nmain {\n  padding: 20px;\n}\n\n.counter {\n  padding: 20px;\n  display: inline-block;\n}\n");
                 File
                   ("App.re",
                     "type state = {count: int};\n\ntype action =\n  | Increment\n  | Decrement;\n\nlet initialState = {count: 0};\n\nlet reducer = (state, action) =>\n  switch (action) {\n  | Increment => {count: state.count + 1}\n  | Decrement => {count: state.count - 1}\n  };\n\n[@react.component]\nlet make = () => {\n  let (state, dispatch) = React.useReducer(reducer, initialState);\n\n  <main>\n    {React.string(\"Simple counter with reducer\")}\n    <div>\n      <button onClick={_ => dispatch(Decrement)}>\n        {React.string(\"Decrement\")}\n      </button>\n      <span className=\"counter\">\n        {state.count |> string_of_int |> React.string}\n      </span>\n      <button onClick={_ => dispatch(Increment)}>\n        {React.string(\"Increment\")}\n      </button>\n    </div>\n  </main>;\n};\n");
                 File
                   ("index.html",
                     "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"UTF-8\" />\n    <title>Reason react starter</title>\n  </head>\n  <body>\n    <div id=\"root\"></div>\n    <script src=\"/Index.js\"></script>\n  </body>\n</html>\n")]);
            File
              ("bsconfig.json",
                "{\n  \"name\": \"reason-react-starter\",\n  \"reason\": {\n    \"react-jsx\": 3\n  },\n  \"sources\": {\n    \"dir\": \"src\",\n    \"subdirs\": true\n  },\n  \"bsc-flags\": [\"-bs-super-errors\", \"-bs-no-version-header\"],\n  \"package-specs\": [\n    {\n      \"module\": \"commonjs\",\n      \"in-source\": true\n    }\n  ],\n  \"suffix\": \".bs.js\",\n  \"namespace\": true,\n  \"bs-dependencies\": [\"reason-react\"],\n  \"refmt\": 3\n}\n");
            File
              ("package.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"build\": \"bsb -make-world\",\n    \"start\": \"bsb -make-world -w -ws _ \",\n    \"clean\": \"bsb -clean-world\",\n    \"webpack\": \"webpack -w\",\n    \"webpack:production\": \"NODE_ENV=production webpack\",\n    \"server\": \"webpack-dev-server\",\n    \"test\": \"echo \\\"Error: no test specified\\\" && exit 1\"\n  },\n  \"keywords\": [\n    \"BuckleScript\",\n    \"ReasonReact\",\n    \"reason-react\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"dependencies\": {\n    \"react\": \"^16.8.1\",\n    \"react-dom\": \"^16.8.1\",\n    \"reason-react\": \">=0.7.0\"\n  },\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\",\n    \"webpack\": \"^4.0.1\",\n    \"webpack-cli\": \"^3.1.1\",\n    \"webpack-dev-server\": \"^3.1.8\",\n    \"html-webpack-plugin\": \"^3.2.0\",\n    \"style-loader\": \"^1.0.0\",\n    \"css-loader\": \"^3.2.0\"\n  }\n}\n");
            File
              (".gitignore",
                ".DS_Store\n.merlin\n.bsb.lock\nnpm-debug.log\n/lib/bs/\n/node_modules/\n*.bs.js\n");
            File
              ("README.md",
                "# Reason react starter\n\n## Run Project\n\n```sh\nnpm install\nnpm start\n# in another tab\nnpm run server\n```\n\nView the app in the browser at http://localhost:8000. Running in this environment provides hot reloading and support for routing; just edit and save the file and the browser will automatically refresh.\n\nTo use a port other than 8000 set the `PORT` environment variable (`PORT=8080 npm run server`).\n\n## Build for Production\n\n```sh\nnpm run clean\nnpm run build\nnpm run webpack:production\n```\n\nThis will replace the development artifact `build/Index.js` for an optimized version as well as copy `src/index.html` into `build/`. You can then deploy the contents of the `build` directory (`index.html` and `Index.js`).\n\n**To enable dead code elimination**, change `bsconfig.json`'s `package-specs` `module` from `\"commonjs\"` to `\"es6\"`. Then re-run the above 2 commands. This will allow Webpack to remove unused code.\n");
            File
              ("webpack.config.js",
                "const path = require(\"path\")\nconst HtmlWebpackPlugin = require(\"html-webpack-plugin\")\nconst outputDir = path.join(__dirname, \"build/\")\n\nconst isProd = process.env.NODE_ENV === \"production\"\n\nmodule.exports = {\n  entry: \"./src/Index.bs.js\",\n  mode: isProd ? \"production\" : \"development\",\n  devtool: \"source-map\",\n  output: {\n    path: outputDir,\n    filename: \"Index.js\"\n  },\n  plugins: [\n    new HtmlWebpackPlugin({\n      template: \"src/index.html\",\n      inject: false\n    })\n  ],\n  devServer: {\n    compress: true,\n    contentBase: outputDir,\n    port: process.env.PORT || 8000,\n    historyApiFallback: true\n  },\n  module: {\n    rules: [\n      {\n        test: /\\.css$/,\n        use: [\"style-loader\", \"css-loader\"]\n      }\n    ]\n  }\n}\n")]);
        Dir
          ("tea",
            [Dir
               ("src",
                 [File
                    ("main.ml",
                      "\n\n\nJs.Global.setTimeout\n  (fun _ -> \n  Demo.main (Web.Document.getElementById \"my-element\") () \n  |. ignore\n  )  \n0");
                 File
                   ("demo.ml",
                     "(* This line opens the Tea.App modules into the current scope for Program access functions and types *)\nopen Tea.App\n\n(* This opens the Elm-style virtual-dom functions and types into the current scope *)\nopen Tea.Html\n\n(* Let's create a new type here to be our main message type that is passed around *)\ntype msg =\n  | Increment  (* This will be our message to increment the counter *)\n  | Decrement  (* This will be our message to decrement the counter *)\n  | Reset      (* This will be our message to reset the counter to 0 *)\n  | Set of int (* This will be our message to set the counter to a specific value *)\n  [@@bs.deriving {accessors}] (* This is a nice quality-of-life addon from Bucklescript, it will generate function names for each constructor name, optional, but nice to cut down on code, this is unused in this example but good to have regardless *)\n\n(* This is optional for such a simple example, but it is good to have an `init` function to define your initial model default values, the model for Counter is just an integer *)\nlet init () = 4\n\n(* This is the central message handler, it takes the model as the first argument *)\nlet update model = function (* These should be simple enough to be self-explanatory, mutate the model based on the message, easy to read and follow *)\n  | Increment -> model + 1\n  | Decrement -> model - 1\n  | Reset -> 0\n  | Set v -> v\n\n(* This is just a helper function for the view, a simple function that returns a button based on some argument *)\nlet view_button title msg =\n  button\n    [ onClick msg\n    ]\n    [ text title\n    ]\n\n(* This is the main callback to generate the virtual-dom.\n  This returns a virtual-dom node that becomes the view, only changes from call-to-call are set on the real DOM for efficiency, this is also only called once per frame even with many messages sent in within that frame, otherwise does nothing *)\nlet view model =\n  div\n    []\n    [ span\n        [ style \"text-weight\" \"bold\" ]\n        [ text (string_of_int model) ]\n    ; br []\n    ; view_button \"Increment\" Increment\n    ; br []\n    ; view_button \"Decrement\" Decrement\n    ; br []\n    ; view_button \"Set to 2\" (Set 42)\n    ; br []\n    ; if model <> 0 then view_button \"Reset\" Reset else noNode\n    ]\n\n(* This is the main function, it can be named anything you want but `main` is traditional.\n  The Program returned here has a set of callbacks that can easily be called from\n  Bucklescript or from javascript for running this main attached to an element,\n  or even to pass a message into the event loop.  You can even expose the\n  constructors to the messages to javascript via the above [@@bs.deriving {accessors}]\n  attribute on the `msg` type or manually, that way even javascript can use it safely. *)\nlet main =\n  beginnerProgram { (* The beginnerProgram just takes a set model state and the update and view functions *)\n    model = init (); (* Since model is a set value here, we call our init function to generate that value *)\n    update;\n    view;\n  }")]);
            File
              ("loader.js",
                "/* Copyright (C) 2018 Authors of BuckleScript\n * \n * This program is free software: you can redistribute it and/or modify\n * it under the terms of the GNU Lesser General Public License as published by\n * the Free Software Foundation, either version 3 of the License, or\n * (at your option) any later version.\n *\n * In addition to the permissions granted to you by the LGPL, you may combine\n * or link a \"work that uses the Library\" with a publicly distributed version\n * of this file to produce a combined library or application, then distribute\n * that combined work under the terms of your choosing, with no requirement\n * to comply with the obligations normally placed on you by section 4 of the\n * LGPL version 3 (or the corresponding section of a later version of the LGPL\n * should you choose to use a later version).\n *\n * This program is distributed in the hope that it will be useful,\n * but WITHOUT ANY WARRANTY; without even the implied warranty of\n * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n * GNU Lesser General Public License for more details.\n * \n * You should have received a copy of the GNU Lesser General Public License\n * along with this program; if not, write to the Free Software\n * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. */\n\n\n\n//@ts-check\n\n// @ts-ignore\nwindow.process = { env: { NODE_ENV: 'dev' } }\n\n\n// local to getPath\nvar relativeElement = document.createElement(\"a\");\nvar baseElement = document.createElement(\"base\");\ndocument.head.appendChild(baseElement);\n\nexport function BsGetPath(id, parent) {\n    var oldPath = baseElement.href\n    baseElement.href = parent\n    relativeElement.href = id\n    var result = relativeElement.href\n    baseElement.href = oldPath\n    return result\n}\n/**\n * \n * Given current link and its parent, return the new link\n * @param {string} id \n * @param {string} parent \n * @return {string}\n */\nfunction getPathWithJsSuffix(id, parent) {\n    var oldPath = baseElement.href\n    baseElement.href = parent\n    relativeElement.href = id\n    var result = addSuffixJsIfNot(relativeElement.href)\n    baseElement.href = oldPath\n    return result\n}\n\n/**\n * \n * @param {string} x \n */\nfunction addSuffixJsIfNot(x) {\n    if (x.endsWith('.js')) {\n        return x\n    } else {\n        return x + '.js'\n    }\n}\n\n\nvar falsePromise = Promise.resolve(false)\nvar fetchConfig = {'cache' : 'no-cache'}\n// package.json semantics\n// a string to module object \n// from url -> module object \n// Modules : Map<string, Promise < boolean | string > \n// fetch the link:\n// - if it is already fetched before, return the stored promise\n//   otherwise create the promise which will be filled with the text if successful\n//   or filled with boolean false when failed\nvar MODULES = new Map()\nfunction cachedFetch(link) {\n    // console.info(link)\n    var linkResult = MODULES.get(link)\n    if (linkResult) {\n        return linkResult\n    } else {\n        var p = fetch(link, fetchConfig)\n            .then(resp => {\n                if (resp.ok) {\n                    return resp.text()\n                } else {\n                    return falsePromise\n                }\n            })\n\n        MODULES.set(link, p)\n        return p\n    }\n}\n\n// from location id -> url \n// There are two rounds of caching:\n// 1. if location and relative path is hit, no need to run \n// 2. if location and relative path is not hit, but the resolved link is hit, no need \n//     for network request\n/**\n * @type {Map<string, Map<string, Promise<any> > > }\n */\nvar IDLocations = new Map()\n\n/**\n * @type {Map<string, Map<string, any> > }\n */\nvar SyncedIDLocations = new Map()\n// Its value is an object \n// { link : String }\n// We will first mark it when visiting (to avoid duplicated computation)\n// and populate its link later\n\n/**\n * \n * @param {string} id \n * @param {string} location \n */\nfunction getIdLocation(id, location) {\n    var idMap = IDLocations.get(location)\n    if (idMap) {\n        return idMap.get(id)\n    }\n}\n\n/**\n * \n * @param {string} id \n * @param {string} location \n */\nfunction getIdLocationSync(id, location) {\n    var idMap = SyncedIDLocations.get(location)\n    if (idMap) {\n        return idMap.get(id)\n    }\n}\n\nfunction countIDLocations() {\n    var count = 0\n    for (let [k, vv] of IDLocations) {\n        for (let [kv, v] of vv) {\n            count += 1\n        }\n    }\n    console.log(count, 'modules loaded')\n}\n\n\n/**\n * \n * @param {string} id \n * @param {string} location \n * @param {Function} cb \n * @returns Promise<any>\n */\nfunction visitIdLocation(id, location, cb) {\n    var result;\n    var idMap = IDLocations.get(location)\n    if (idMap && (result = idMap.get(id))) {\n        return result\n    }\n    else {\n        result = new Promise(resolve => {\n            return (cb()).then(res => {\n                var idMap = SyncedIDLocations.get(location)\n                if (idMap) {\n                    idMap.set(id, res)\n                } else {\n                    SyncedIDLocations.set(location, new Map([[id, res]]))\n                }\n                return resolve(res)\n            })\n        })\n        if (idMap) {\n            idMap.set(id, result)\n        }\n        else {\n            IDLocations.set(location, new Map([[id, result]]))\n        }\n        return result\n    }\n}\n\n\n\n/**\n * \n * @param {string} text \n * @return {string[]}\n */\nfunction getDeps(text) {\n    var deps = []\n    text.replace(/(\\/\\*[\\w\\W]*?\\*\\/|\\/\\/[^\\n]*|[.$]r)|\\brequire\\s*\\(\\s*[\"']([^\"']*)[\"']\\s*\\)/g, function (_, ignore, id) {\n        if (!ignore) deps.push(id);\n    });\n    return deps;\n}\n\n\n\n// By using a named \"eval\" most browsers will execute in the global scope.\n// http://www.davidflanagan.com/2010/12/global-eval-in.html\nvar globalEval = eval;\n\n// function parentURL(url) {\n//     if (url.endsWith('/')) {\n//         return url + '../'\n//     } else {\n//         return url + '/../'\n//     }\n// }\n\n\n\n// loader.js:23 http://localhost:8080/node_modules/react-dom/cjs/react-dom.development.js/..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//../ fbjs/lib/containsNode Promise\194\160{<pending>}\n// 23:10:02.884 loader.js:23 http://localhost:8080/node_modules/react-dom/cjs/react-dom.development.js/..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//../ fbjs/lib/invariant Promise\194\160{<pending>}\n\n\n/**\n * \n * @param {string} id \n * @param {string} parent \n */\nfunction getParentModulePromise(id, parent) {\n    var parentLink = BsGetPath('..', parent)\n    if (parentLink === parent) {\n        return falsePromise\n    }\n    return getPackageJsPromise(id, parentLink)\n}\n// In the beginning\n// it is `resolveModule('./main.js', '')\n// return the promise of link and text \n\n/**\n * \n * @param {string} id \n */\nfunction getPackageName(id) {\n    var index = id.indexOf('/')\n    if (id[0] === '@') index = id.indexOf('/', index + 1)\n    if (index === -1) {\n        return id\n    }\n    return id.substring(0, index)\n}\n\n/**\n * \n * @param {string} s \n * @param {string} text \n * @returns {undefined | string }\n */\nfunction isJustAPackageAndHasMainField(s,text){\n    if(s.indexOf('/') >= 0){\n        return \n    } else {\n        var mainField; \n        try {\n            mainField = JSON.parse(text).main\n        }catch(_){\n        }\n        if(mainField === undefined){\n            return \n        } else {\n            return mainField\n        }\n    }\n}\nfunction getPackageJsPromise(id, parent) {\n    var idNodeModulesPrefix = './node_modules/' + id\n    var link = getPathWithJsSuffix(idNodeModulesPrefix, parent)\n    if (parent.endsWith('node_modules/')) {\n        // impossible that `node_modules/node_modules/xx/x\n        // return falsePromise\n        return getParentModulePromise(id, parent)\n    }\n\n    var packageJson = BsGetPath(`./node_modules/${getPackageName(id)}/package.json`, parent)\n\n    return cachedFetch(packageJson)\n        .then(\n            function (text) {\n                if (text !== false) {\n                    var mainField; \n                    if( (mainField = isJustAPackageAndHasMainField(id, text)) !== undefined){\n                        var packageLink = BsGetPath(addSuffixJsIfNot(`./node_modules/${id}/${mainField}`), parent)\n                        return cachedFetch(packageLink)\n                            .then(function(text){\n                                if(text !== false){\n                                    return {text, link : packageLink}\n                                } else {\n                                    return getParentModulePromise(id,parent)\n                                }\n                            })\n\n                    } else {\n                    // package indeed exist\n                    return cachedFetch(link).then(function (text) {\n                        if (text !== false) {\n                            return { text, link }\n                        } else if (!id.endsWith('.js')) {\n                            var linkNew = getPathWithJsSuffix(idNodeModulesPrefix + `/index.js`, parent)\n                            return cachedFetch(linkNew)\n                                .then(function (text) {\n                                    if (text !== false) {\n                                        return { text, link: linkNew }\n                                    } else {\n                                        return getParentModulePromise(id, parent)\n                                    }\n                                })\n\n                        } else {\n                            return getParentModulePromise(id, parent)\n                        }\n                    })\n                }\n                }\n                else {\n                    return getParentModulePromise(id, parent)\n                }\n            }\n        )\n\n\n}\n\n/**\n * \n * @param {string} id \n * @param {string} parent \n * can return Promise <boolean | object>, false means\n * this module can not be resolved\n */\nfunction getModulePromise(id, parent) {\n    var done = getIdLocation(id, parent)\n    if (!done) {\n        return visitIdLocation(id, parent, function () {\n            if (id[0] != '.') { // package path\n                return getPackageJsPromise(id, parent)\n            } else { // relative path, one shot resolve            \n                let link = getPathWithJsSuffix(id, parent)\n                return cachedFetch(link).then(\n                    function (text) {\n                        if (text !== false) {\n                            return { text, link }\n                        } else if (!id.endsWith('.js')){                            \n                            // could be \"./dir\"\n                            var newLink = getPathWithJsSuffix( id +\"/index.js\",parent)\n                            return cachedFetch(newLink)\n                            .then(function(text){\n                                if(text !== false){\n                                    return{text, link : newLink }\n                                } else {\n                                    throw new Error(` ${id} : ${parent} could not be resolved`)\n                                }\n                            })\n                        }\n                        else {\n                            throw new Error(` ${id} : ${parent} could not be resolved`)\n                        }\n                    }\n                )\n            }\n        })\n    } else {\n        return done\n    }\n}\n\n\n/**\n * \n * @param {string} id \n * @param {string} parent \n * @returns {Promise<any>}\n */\nfunction getAll(id, parent) {\n    return getModulePromise(id, parent)\n        .then(function (obj) {\n            if (obj) {\n                var deps = getDeps(obj.text)\n                return Promise.all(deps.map(x => getAll(x, obj.link)))\n            } else {\n                throw new Error(`${id}@${parent} was not resolved successfully`)\n            }\n        })\n};\n\n/**\n * \n * @param {string} text \n * @param {string} parent \n * @returns {Promise<any>}\n */\nfunction getAllFromText(text, parent) {\n    var deps = getDeps(text)\n    return Promise.all(deps.map(x => getAll(x, parent)))\n}\n\nvar evaluatedModules = new Map()\n\nfunction loadSync(id, parent) {\n    var baseOrModule = getIdLocationSync(id, parent)\n    if (baseOrModule && baseOrModule.link !== undefined) {\n        if(evaluatedModules.has(baseOrModule.link)){\n            return evaluatedModules.get(baseOrModule.link).exports\n        }\n        if (!baseOrModule.exports) {\n            baseOrModule.exports = {}\n            globalEval(`(function(require,exports,module){${baseOrModule.text}\\n})//# sourceURL=${baseOrModule.link}`)(\n                function require(id) {\n                    return loadSync(id, baseOrModule.link);\n                }, // require\n                baseOrModule.exports = {}, // exports\n                baseOrModule // module\n            );\n        }\n        if(!evaluatedModules.has(baseOrModule.link)){\n            evaluatedModules.set(baseOrModule.link,baseOrModule)\n        }\n        return baseOrModule.exports\n    } else {\n        throw new Error(`${id} : ${parent} could not be resolved`)\n    }\n}\n\n\nfunction genEvalName() {\n    return \"eval-\" + ((\"\" + Math.random()).substr(2, 5))\n}\n/**\n * \n * @param {string} text \n * @param {string} link\n * In this case [text] evaluated result will not be cached\n */\nfunction loadTextSync(text, link) {\n    var baseOrModule = { exports: {}, text, link }\n    globalEval(`(function(require,exports,module){${baseOrModule.text}\\n})//# sourceURL=${baseOrModule.link}/${genEvalName()}.js`)(\n        function require(id) {\n            return loadSync(id, baseOrModule.link);\n        }, // require\n        baseOrModule.exports, // exports\n        baseOrModule // module\n    );\n    return baseOrModule.exports\n}\n\n/**\n * \n * @param {string} text \n */\nfunction BSloadText(text) {\n    console.time(\"Loading\")\n    var parent = BsGetPath(\".\", document.baseURI)\n    return getAllFromText(text, parent).then(function () {\n        var result = loadTextSync(text, parent)\n        console.timeEnd(\"Loading\")\n        return result\n    })\n};\n\n\nfunction load(id, parent) {\n    return getAll(id, parent).then(function () {\n        return loadSync(id, parent)\n    })\n\n};\n\n\nexport function BSload(id) {\n    var parent = BsGetPath(\".\", document.baseURI)\n    return load(id, parent)\n}\n\nexport var BSLoader = {\n    loadText: BSloadText,\n    load: BSload,\n    SyncedIDLocations: SyncedIDLocations\n};\n\nwindow.BSLoader = BSLoader;\n\nvar main = document.querySelector('script[data-main]')\nif (main) {\n    BSload(main.dataset.main)\n}\n");
            File
              ("bsconfig.json",
                "{\n  \"name\": \"tea\",\n  \"version\": \"0.1.0\",\n  \"sources\": {\n    \"dir\" : \"src\",\n    \"subdirs\" : true\n  },\n  \"package-specs\": {\n    \"module\": \"commonjs\",\n    \"in-source\": true\n  },\n  \"suffix\": \".bs.js\",\n  \"bs-dependencies\": [\n      \"bucklescript-tea\"\n  ]\n}\n");
            File
              ("watcher.js",
                "\n\nvar wsReloader;\nvar LAST_SUCCESS_BUILD_STAMP = (localStorage.getItem('LAST_SUCCESS_BUILD_STAMP') || 0)\nvar WS_PORT = 9999; // configurable\n\nfunction setUpWebScoket() {\n    if (wsReloader == null || wsReloader.readyState !== 1) {\n        try {\n            wsReloader = new WebSocket(`ws://${window.location.hostname}:${WS_PORT}`)\n            wsReloader.onmessage = (msg) => {\n                var newData = JSON.parse(msg.data).LAST_SUCCESS_BUILD_STAMP\n                if (newData > LAST_SUCCESS_BUILD_STAMP) {\n                    LAST_SUCCESS_BUILD_STAMP = newData\n                    localStorage.setItem('LAST_SUCCESS_BUILD_STAMP', LAST_SUCCESS_BUILD_STAMP)\n                    location.reload(true)\n                }\n\n            }\n        } catch (exn) {\n            console.error(\"web socket failed connect\")\n        }\n    }\n};\n\nsetUpWebScoket();\nsetInterval(setUpWebScoket, 2000);");
            File
              ("package.json",
                "{\n  \"name\": \"${bsb:name}\",\n  \"version\": \"${bsb:proj-version}\",\n  \"scripts\": {\n    \"clean\": \"bsb -clean-world\",\n    \"build\": \"bsb -make-world\",\n    \"watch\": \"bsb -make-world -w -ws _\"\n  },\n  \"keywords\": [\n    \"BuckleScript\"\n  ],\n  \"author\": \"\",\n  \"license\": \"MIT\",\n  \"devDependencies\": {\n    \"bs-platform\": \"^${bsb:bs-version}\"\n  },\n  \"dependencies\": {\n    \"bucklescript-tea\": \"^0.7.4\"\n  }\n}\n");
            File
              ("README.md",
                "\n\n# Build\n```\nnpm run build\n```\n\n# Watch\n\n```\nnpm run watch\n```\n\ncreate a http-server\n\n```\nnpm install -g http-server\n```\n\nEdit the file and see the changes automatically reloaded in the browser\n");
            File
              ("index.html",
                "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"utf-8\">\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n    <meta name=\"description\" content=\"\">\n    <meta name=\"author\" content=\"\">\n    <title>Bucklescript TEA Starter Kit</title>\n  </head>\n  \n\n\n  <body>\n    <div id=\"my-element\"> </div>\n    <script src=\"./loader.js\" type=\"module\" data-main=\"./src/main.bs.js\"></script>\n    <script src=\"./watcher.js\" type=\"module\"></script>\n    \n  </body>\n</html>")])]
  end 
module Bsb_theme_init :
  sig
    val init_sample_project : cwd:string -> theme:string -> string -> unit
    val list_themes : unit -> unit
  end =
  struct
    type file_type =
      | Directory 
      | Non_directory_file 
      | Non_exists 
    let classify_file name =
      let exists = Sys.file_exists name in
      if exists
      then (if Sys.is_directory name then Directory else Non_directory_file)
      else Non_exists
    let replace s env =
      (Bsb_regex.global_substitute s ~reg:"\\${bsb:\\([-a-zA-Z0-9]+\\)}"
         (fun (_s : string) ->
            fun templates ->
              match templates with
              | key::_ -> Hash_string.find_exn env key
              | _ -> assert false) : string)
    let (//) = Filename.concat
    let get_bs_platform_version_if_exists dir =
      match Ext_json_parse.parse_json_from_file
              (Filename.concat dir Literals.package_json)
      with
      | Obj { map } ->
          (match Map_string.find_exn map Bsb_build_schemas.version with
           | Str { str } -> str
           | _ -> assert false)
      | _ -> assert false
    let run_npm_link cwd dirname =
      let bs_platform_dir =
        Filename.concat Literals.node_modules Bs_version.package_name in
      if Sys.file_exists bs_platform_dir
      then
        (if
           (get_bs_platform_version_if_exists bs_platform_dir) =
             Bs_version.version
         then
           Format.fprintf Format.std_formatter
             "bs-platform already exists(version match), no need symlink@."
         else
           (Format.fprintf Format.err_formatter
              "bs-platform already exists, but version mismatch with running bsb@.";
            exit 2))
      else
        (let npm_link = "npm link bs-platform" in
         let exit_code = Sys.command npm_link in
         if exit_code <> 0
         then (prerr_endline ("failed to run : " ^ npm_link); exit exit_code))
    let enter_dir cwd x action =
      Unix.chdir x;
      (match action () with
       | exception e -> (Unix.chdir cwd; raise e)
       | v -> v)
    let mkdir_or_not_if_exists dir =
      match classify_file dir with
      | Directory -> ()
      | Non_directory_file ->
          Format.fprintf Format.err_formatter
            "%s expected to be added as dir but exist file is not a dir" dir
      | Non_exists -> Unix.mkdir dir 0o777
    let rec process_theme_aux env cwd (x : OCamlRes.Res.node) =
      match x with
      | File (name, content) ->
          let new_file = cwd // name in
          if not @@ (Sys.file_exists new_file)
          then Ext_io.write_file new_file (replace content env)
      | Dir (current, nodes) ->
          let new_cwd = cwd // current in
          (mkdir_or_not_if_exists new_cwd;
           List.iter (fun x -> process_theme_aux env new_cwd x) nodes)
    let list_themes () =
      Format.fprintf Format.std_formatter "Available themes: @.";
      Bsb_templates.root |>
        (List.iter
           (fun (x : OCamlRes.Res.node) ->
              match x with
              | Dir (x, _) -> Format.fprintf Format.std_formatter "%s@." x
              | _ -> ()))
    let process_themes env theme proj_dir (themes : OCamlRes.Res.node list) =
      match Ext_list.find_first themes
              (fun x ->
                 match x with | Dir (dir, _) -> dir = theme | File _ -> false)
      with
      | None ->
          (list_themes ();
           raise (Arg.Bad ("theme " ^ (theme ^ " not found"))))
      | Some (Dir (_theme, nodes)) ->
          List.iter (fun node -> process_theme_aux env proj_dir node) nodes
      | Some _ -> assert false
    let init_sample_project ~cwd  ~theme  name =
      let env = Hash_string.create 0 in
      List.iter (fun (k, v) -> Hash_string.add env k v)
        [("proj-version", "0.1.0");
        ("bs-version", Bs_version.version);
        ("bsb",
          (((Filename.current_dir_name // "node_modules") // ".bin") // "bsb"))];
      (let action _ =
         process_themes env theme Filename.current_dir_name
           Bsb_templates.root;
         run_npm_link cwd name in
       match name with
       | "." ->
           let name = Filename.basename cwd in
           if Ext_namespace.is_valid_npm_package_name name
           then (Hash_string.add env "name" name; action ())
           else
             (Format.fprintf Format.err_formatter
                "@{<error>Invalid package name@} %S@}: the project name must be both a valid npm package name and a valid name as namespace@."
                name;
              exit 2)
       | _ ->
           if Ext_namespace.is_valid_npm_package_name name
           then
             (match classify_file name with
              | Non_directory_file ->
                  (Format.fprintf Format.err_formatter
                     "@{<error>%s already exists but it is not a directory@}@."
                     name;
                   exit 2)
              | Directory ->
                  (Format.fprintf Format.std_formatter
                     "Adding files into existing dir %s@." name;
                   Hash_string.add env "name" name;
                   enter_dir cwd name action)
              | Non_exists ->
                  (Format.fprintf Format.std_formatter
                     "Making directory %s@." name;
                   Unix.mkdir name 0o777;
                   Hash_string.add env "name" name;
                   enter_dir cwd name action))
           else
             (Format.fprintf Format.err_formatter
                "@{<error>Invalid package name@} %S.@} The project name must be a valid npm name, thus can't contain upper-case letters, for example."
                name;
              exit 2))[@@ocaml.doc " TODO: run npm link "]
  end 
module Bsb_file :
  sig
    val install_if_exists : destdir:string -> string -> bool[@@ocaml.doc
                                                              " return [true] if copied "]
  end =
  struct
    let set_infos filename (infos : Unix.stats) =
      Unix.utimes filename infos.st_atime infos.st_mtime;
      Unix.chmod filename infos.st_perm[@@ocaml.doc
                                         " it is not necessary to call [chown] since it is within the same user \n    and {!Unix.chown} is not implemented under Windows\n   "]
    let buffer_size = 8192
    let buffer = Bytes.create buffer_size
    let file_copy input_name output_name =
      let fd_in = Unix.openfile input_name [O_RDONLY] 0 in
      let fd_out =
        Unix.openfile output_name [O_WRONLY; O_CREAT; O_TRUNC] 0o666 in
      let rec copy_loop () =
        match Unix.read fd_in buffer 0 buffer_size with
        | 0 -> ()
        | r -> (ignore (Unix.write fd_out buffer 0 r); copy_loop ()) in
      copy_loop (); Unix.close fd_in; Unix.close fd_out
    let copy_with_permission input_name output_name =
      file_copy input_name output_name;
      set_infos output_name (Unix.lstat input_name)
    let install_if_exists ~destdir  input_name =
      if Sys.file_exists input_name
      then
        let output_name =
          Filename.concat destdir (Filename.basename input_name) in
        match ((Unix.stat output_name), (Unix.stat input_name)) with
        | ({ st_mtime = output_stamp;_}, { st_mtime = input_stamp;_}) when
            input_stamp <= output_stamp -> false
        | _ -> (copy_with_permission input_name output_name; true)
        | exception _ -> (copy_with_permission input_name output_name; true)
      else false
  end 
module Bsb_world :
  sig
    val install_targets : string -> Bsb_config_types.t -> unit
    val make_world_deps :
      string -> Bsb_config_types.t option -> string array -> unit
  end =
  struct
    let (//) = Ext_path.combine
    let install_targets cwd
      ({ files_to_install; namespace; package_name = _ } :
        Bsb_config_types.t)
      =
      let install ~destdir  file =
        (Bsb_file.install_if_exists ~destdir file) |> ignore in
      let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
      let install_filename_sans_extension destdir namespace x =
        let x = Ext_namespace_encode.make ?ns:namespace x in
        install ~destdir ((cwd // x) ^ Literals.suffix_ml);
        install ~destdir ((cwd // x) ^ Literals.suffix_re);
        install ~destdir ((cwd // x) ^ Literals.suffix_mli);
        install ~destdir ((cwd // x) ^ Literals.suffix_rei);
        install ~destdir
          (((cwd // lib_artifacts_dir) // x) ^ Literals.suffix_cmi);
        install ~destdir
          (((cwd // lib_artifacts_dir) // x) ^ Literals.suffix_cmj);
        install ~destdir
          (((cwd // lib_artifacts_dir) // x) ^ Literals.suffix_cmt);
        install ~destdir
          (((cwd // lib_artifacts_dir) // x) ^ Literals.suffix_cmti) in
      let destdir = cwd // (!Bsb_global_backend.lib_ocaml_dir) in
      if not @@ (Sys.file_exists destdir) then Unix.mkdir destdir 0o777;
      Bsb_log.info "@{<info>Installing started@}@.";
      (match namespace with
       | None -> ()
       | Some x -> install_filename_sans_extension destdir None x);
      Hash_set_string.iter files_to_install
        (install_filename_sans_extension destdir namespace);
      Bsb_log.info "@{<info>Installing finished@} @."[@@ocaml.doc
                                                       " TODO: create the animation effect \n    logging installed files\n"]
    let build_bs_deps cwd (deps : Bsb_package_specs.t)
      (ninja_args : string array) =
      let vendor_ninja = Bsb_global_paths.vendor_ninja in
      let args =
        if Ext_array.is_empty ninja_args
        then [|vendor_ninja|]
        else Array.append [|vendor_ninja|] ninja_args in
      let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
      Bsb_build_util.walk_all_deps cwd
        (fun { top; proj_dir } ->
           if not top
           then
             let config_opt =
               Bsb_ninja_regen.regenerate_ninja
                 ~toplevel_package_specs:(Some deps) ~forced:true
                 ~per_proj_dir:proj_dir in
             let command =
               {
                 Bsb_unix.cmd = vendor_ninja;
                 cwd = (proj_dir // lib_artifacts_dir);
                 args
               } in
             let eid = Bsb_unix.run_command_execv command in
             (if eid <> 0 then Bsb_unix.command_fatal_error command eid;
              Ext_option.iter config_opt (install_targets proj_dir)))
    let make_world_deps cwd (config : Bsb_config_types.t option)
      (ninja_args : string array) =
      Bsb_log.info "Making the dependency world!@.";
      (let deps =
         match config with
         | None -> Bsb_config_parse.package_specs_from_bsconfig ()
         | Some config -> config.package_specs in
       build_bs_deps cwd deps ninja_args)
  end 
module Bsb_main : sig  end =
  struct
    let () = Bsb_log.setup ()
    let force_regenerate = ref false
    let current_theme = ref "basic"
    let set_theme s = current_theme := s
    let generate_theme_with_path = ref None
    let regen = "-regen"
    let separator = "--"
    let watch_mode = ref false
    let make_world = ref false
    let do_install = ref false
    let set_make_world () = make_world := true
    let bs_version_string = Bs_version.version
    let print_version_string () =
      print_string bs_version_string; print_newline (); exit 0
    let bsb_main_flags : (string * Arg.spec * string) list =
      [("-v", (Arg.Unit print_version_string), " Print version and exit");
      ("-version", (Arg.Unit print_version_string),
        " Print version and exit");
      ("-verbose", (Arg.Unit Bsb_log.verbose),
        " Set the output(from bsb) to be verbose");
      ("-w", (Arg.Set watch_mode), " Watch mode");
      ("-clean-world",
        (Arg.Unit ((fun _ -> Bsb_clean.clean_bs_deps Bsb_global_paths.cwd))),
        " Clean all bs dependencies");
      ("-clean",
        (Arg.Unit ((fun _ -> Bsb_clean.clean_self Bsb_global_paths.cwd))),
        " Clean only current project");
      ("-make-world", (Arg.Unit set_make_world),
        " Build all dependencies and itself ");
      ("-install", (Arg.Set do_install),
        " Install public interface files into lib/ocaml");
      ("-init",
        (Arg.String ((fun path -> generate_theme_with_path := (Some path)))),
        " Init sample project to get started. Note (`bsb -init sample` will create a sample project while `bsb -init .` will reuse current directory)");
      ("-theme", (Arg.String set_theme),
        " The theme for project initialization, default is basic(https://github.com/bucklescript/bucklescript/tree/master/jscomp/bsb/templates)");
      (regen, (Arg.Set force_regenerate),
        " (internal) Always regenerate build.ninja no matter bsconfig.json is changed or not (for debugging purpose)");
      ("-themes", (Arg.Unit Bsb_theme_init.list_themes),
        " List all available themes");
      ("-where",
        (Arg.Unit
           ((fun _ -> print_endline (Filename.dirname Sys.executable_name)))),
        " Show where bsb.exe is located");
      ("-ws", (Arg.Bool ignore),
        " [host:]port specify a websocket number (and optionally, a host). When a build finishes, we send a message to that port. For tools that listen on build completion.")]
    let exec_command_then_exit command =
      Bsb_log.info "@{<info>CMD:@} %s@." command; exit (Sys.command command)
      [@@ocaml.doc "  Invariant: it has to be the last command of [bsb] "]
    let ninja_command_exit ninja_args =
      let ninja_args_len = Array.length ninja_args in
      let lib_artifacts_dir = !Bsb_global_backend.lib_artifacts_dir in
      if Ext_sys.is_windows_or_cygwin
      then
        let path_ninja = Filename.quote Bsb_global_paths.vendor_ninja in
        exec_command_then_exit
          (if ninja_args_len = 0
           then Ext_string.inter3 path_ninja "-C" lib_artifacts_dir
           else
             (let args =
                Array.append [|path_ninja;"-C";lib_artifacts_dir|] ninja_args in
              Ext_string.concat_array Ext_string.single_space args))
      else
        (let ninja_common_args = [|"ninja.exe";"-C";lib_artifacts_dir|] in
         let args =
           if ninja_args_len = 0
           then ninja_common_args
           else Array.append ninja_common_args ninja_args in
         Bsb_log.info_args args;
         Unix.execvp Bsb_global_paths.vendor_ninja args)
    let usage =
      "Usage : bsb.exe <bsb-options> -- <ninja_options>\nFor ninja options, try ninja -h \nninja will be loaded either by just running `bsb.exe' or `bsb.exe .. -- ..`\nIt is always recommended to run ninja via bsb.exe \nBsb options are:"
      [@@ocaml.doc
        "\n   Cache files generated:\n   - .bsdircache in project root dir\n   - .bsdeps in builddir\n\n   What will happen, some flags are really not good\n   ninja -C _build\n"]
    let handle_anonymous_arg arg =
      raise (Arg.Bad ("Unknown arg \"" ^ (arg ^ "\"")))
    let program_exit () = exit 0
    let install_target config_opt =
      let config =
        match config_opt with
        | None ->
            let config =
              Bsb_config_parse.interpret_json ~toplevel_package_specs:None
                ~per_proj_dir:Bsb_global_paths.cwd in
            let _ =
              Ext_list.iter (config.file_groups).files
                (fun group ->
                   let check_file =
                     match group.public with
                     | Export_all -> (fun _ -> true)
                     | Export_none -> (fun _ -> false)
                     | Export_set set ->
                         (fun module_name -> Set_string.mem set module_name) in
                   Map_string.iter group.sources
                     (fun module_name ->
                        fun module_info ->
                          if check_file module_name
                          then
                            Hash_set_string.add config.files_to_install
                              module_info.name_sans_extension)) in
            config
        | Some config -> config in
      Bsb_world.install_targets Bsb_global_paths.cwd config
    let () =
      try
        match Sys.argv with
        | [|_|] ->
            ((Bsb_ninja_regen.regenerate_ninja ~toplevel_package_specs:None
                ~forced:false ~per_proj_dir:Bsb_global_paths.cwd)
               |> ignore;
             ninja_command_exit [||])
        | argv ->
            (match Ext_array.find_and_split argv Ext_string.equal separator
             with
             | `No_split ->
                 (Arg.parse bsb_main_flags handle_anonymous_arg usage;
                  (match !generate_theme_with_path with
                   | Some path ->
                       Bsb_theme_init.init_sample_project
                         ~cwd:Bsb_global_paths.cwd ~theme:(!current_theme)
                         path
                   | None ->
                       let make_world = !make_world in
                       let force_regenerate = !force_regenerate in
                       let do_install = !do_install in
                       if
                         (not make_world) &&
                           ((not force_regenerate) && (not do_install))
                       then (if !watch_mode then program_exit ())
                       else
                         (let config_opt =
                            Bsb_ninja_regen.regenerate_ninja
                              ~toplevel_package_specs:None
                              ~forced:force_regenerate
                              ~per_proj_dir:Bsb_global_paths.cwd in
                          if make_world
                          then
                            Bsb_world.make_world_deps Bsb_global_paths.cwd
                              config_opt [||];
                          if !watch_mode
                          then program_exit ()
                          else
                            if make_world
                            then ninja_command_exit [||]
                            else if do_install then install_target config_opt)))
             | `Split (bsb_args, ninja_args) ->
                 (Arg.parse_argv bsb_args bsb_main_flags handle_anonymous_arg
                    usage;
                  (let config_opt =
                     Bsb_ninja_regen.regenerate_ninja
                       ~toplevel_package_specs:None
                       ~per_proj_dir:Bsb_global_paths.cwd
                       ~forced:(!force_regenerate) in
                   if !make_world
                   then
                     Bsb_world.make_world_deps Bsb_global_paths.cwd
                       config_opt ninja_args;
                   if !do_install then install_target config_opt;
                   if !watch_mode
                   then program_exit ()
                   else ninja_command_exit ninja_args)))
      with
      | Bsb_exception.Error e ->
          (Bsb_exception.print Format.err_formatter e;
           Format.pp_print_newline Format.err_formatter ();
           exit 2)
      | Ext_json_parse.Error (start, _, e) ->
          (Format.fprintf Format.err_formatter
             "File %S, line %d\n@{<error>Error:@} %a@." start.pos_fname
             start.pos_lnum Ext_json_parse.report_error e;
           exit 2)
      | Arg.Bad s|Sys_error s ->
          (Format.fprintf Format.err_formatter "@{<error>Error:@} %s@." s;
           exit 2)
      | e -> Ext_pervasives.reraise e
  end 
