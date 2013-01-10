(* Ocsimore
 * Copyright (C) 2009
 * Laboratoire PPS - Université Paris Diderot - CNRS
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

(** @author Granarolo Jean-Henri *)

open Eliom_content
open Html5.F

let sources_css_header =
  Page_site.Header.create_header
    (fun () -> [Html5.D.css_link
		(Page_site.static_file_uri ["ocsforge_sources.css"]) ()])

let code_content args c =
  lwt () = Page_site.Header.require_header sources_css_header in
  match c with
  | None -> Lwt.return []
  | Some s ->
      let s = Ocsimore_lib.remove_spaces s in
      let lang =
        try List.assoc "language" args
        with _ -> ""
      in
      let lexbuf = Lexing.from_string s in
      lwt (_, r) = Ocsforge_color.color_by_lang lexbuf lang in Lwt.return r

let f_code _ args c =
  `Flow5 (
    lwt c = code_content args c in
    Lwt.return [ pre ~a:[ a_class ["ocsforge_color"] ] c ] )

let f_code_inline _ args c =
  `Phrasing_without_interactive (
    lwt c = code_content args c in
    Lwt.return [ span ~a:[ a_class ["ocsforge_color"] ] c ] )

let _ =
  Wiki_syntax.register_simple_flow_extension ~name:"code" f_code;
  Wiki_syntax.register_simple_phrasing_extension ~name:"code-inline" f_code_inline


