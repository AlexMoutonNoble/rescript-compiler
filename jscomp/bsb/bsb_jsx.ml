type version = Jsx_v3 | Jsx_v4
type module_ = React
type mode = Classic | Automatic

type t = {
  version : version option;
  module_ : module_ option;
  mode : mode option;
}

let ( .?() ) = Map_string.find_opt
let ( |? ) m (key, cb) = m |> Ext_json.test key cb

let from_map map =
  let version : version option ref = ref None in
  let module_ : module_ option ref = ref None in
  let mode : mode option ref = ref None in
  map
  |? ( Bsb_build_schemas.jsx,
       `Obj
         (fun m ->
           match m.?(Bsb_build_schemas.jsx_version) with
           | Some (Flo { loc; flo }) -> (
               match flo with
               | "3" -> version := Some Jsx_v3
               | "4" -> version := Some Jsx_v4
               | _ -> Bsb_exception.errorf ~loc "Unsupported jsx-version %s" flo
               )
           | Some x ->
               Bsb_exception.config_error x
                 "Unexpected input (expect a version number) for jsx-version"
           | None -> ()) )
  |? ( Bsb_build_schemas.jsx,
       `Obj
         (fun m ->
           match m.?(Bsb_build_schemas.jsx_module) with
           | Some (Str { loc; str }) -> (
               match str with
               | "react" -> module_ := Some React
               | _ -> Bsb_exception.errorf ~loc "Unsupported jsx-module %s" str)
           | Some x ->
               Bsb_exception.config_error x
                 "Unexpected input (jsx module name) for jsx-mode"
           | None -> ()) )
  |? ( Bsb_build_schemas.jsx,
       `Obj
         (fun m ->
           match m.?(Bsb_build_schemas.jsx_mode) with
           | Some (Str { loc; str }) -> (
               match str with
               | "classic" -> mode := Some Classic
               | "automatic" -> mode := Some Automatic
               | _ -> Bsb_exception.errorf ~loc "Unsupported jsx-mode %s" str)
           | Some x ->
               Bsb_exception.config_error x
                 "Unexpected input (expect classic or automatic) for jsx-mode"
           | None -> ()) )
  |> ignore;
  { version = !version; module_ = !module_; mode = !mode }
