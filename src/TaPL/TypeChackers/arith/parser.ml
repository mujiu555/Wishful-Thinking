type token =
  | IMPORT of (
# 25 "parser.mly"
        Support.Error.info
# 6 "parser.ml"
)
  | IF of (
# 26 "parser.mly"
        Support.Error.info
# 11 "parser.ml"
)
  | THEN of (
# 27 "parser.mly"
        Support.Error.info
# 16 "parser.ml"
)
  | ELSE of (
# 28 "parser.mly"
        Support.Error.info
# 21 "parser.ml"
)
  | TRUE of (
# 29 "parser.mly"
        Support.Error.info
# 26 "parser.ml"
)
  | FALSE of (
# 30 "parser.mly"
        Support.Error.info
# 31 "parser.ml"
)
  | SUCC of (
# 31 "parser.mly"
        Support.Error.info
# 36 "parser.ml"
)
  | PRED of (
# 32 "parser.mly"
        Support.Error.info
# 41 "parser.ml"
)
  | ISZERO of (
# 33 "parser.mly"
        Support.Error.info
# 46 "parser.ml"
)
  | UCID of (
# 36 "parser.mly"
        string Support.Error.withinfo
# 51 "parser.ml"
)
  | LCID of (
# 37 "parser.mly"
        string Support.Error.withinfo
# 56 "parser.ml"
)
  | INTV of (
# 38 "parser.mly"
        int Support.Error.withinfo
# 61 "parser.ml"
)
  | FLOATV of (
# 39 "parser.mly"
        float Support.Error.withinfo
# 66 "parser.ml"
)
  | STRINGV of (
# 40 "parser.mly"
        string Support.Error.withinfo
# 71 "parser.ml"
)
  | APOSTROPHE of (
# 43 "parser.mly"
        Support.Error.info
# 76 "parser.ml"
)
  | DQUOTE of (
# 44 "parser.mly"
        Support.Error.info
# 81 "parser.ml"
)
  | ARROW of (
# 45 "parser.mly"
        Support.Error.info
# 86 "parser.ml"
)
  | BANG of (
# 46 "parser.mly"
        Support.Error.info
# 91 "parser.ml"
)
  | BARGT of (
# 47 "parser.mly"
        Support.Error.info
# 96 "parser.ml"
)
  | BARRCURLY of (
# 48 "parser.mly"
        Support.Error.info
# 101 "parser.ml"
)
  | BARRSQUARE of (
# 49 "parser.mly"
        Support.Error.info
# 106 "parser.ml"
)
  | COLON of (
# 50 "parser.mly"
        Support.Error.info
# 111 "parser.ml"
)
  | COLONCOLON of (
# 51 "parser.mly"
        Support.Error.info
# 116 "parser.ml"
)
  | COLONEQ of (
# 52 "parser.mly"
        Support.Error.info
# 121 "parser.ml"
)
  | COLONHASH of (
# 53 "parser.mly"
        Support.Error.info
# 126 "parser.ml"
)
  | COMMA of (
# 54 "parser.mly"
        Support.Error.info
# 131 "parser.ml"
)
  | DARROW of (
# 55 "parser.mly"
        Support.Error.info
# 136 "parser.ml"
)
  | DDARROW of (
# 56 "parser.mly"
        Support.Error.info
# 141 "parser.ml"
)
  | DOT of (
# 57 "parser.mly"
        Support.Error.info
# 146 "parser.ml"
)
  | EOF of (
# 58 "parser.mly"
        Support.Error.info
# 151 "parser.ml"
)
  | EQ of (
# 59 "parser.mly"
        Support.Error.info
# 156 "parser.ml"
)
  | EQEQ of (
# 60 "parser.mly"
        Support.Error.info
# 161 "parser.ml"
)
  | EXISTS of (
# 61 "parser.mly"
        Support.Error.info
# 166 "parser.ml"
)
  | GT of (
# 62 "parser.mly"
        Support.Error.info
# 171 "parser.ml"
)
  | HASH of (
# 63 "parser.mly"
        Support.Error.info
# 176 "parser.ml"
)
  | LCURLY of (
# 64 "parser.mly"
        Support.Error.info
# 181 "parser.ml"
)
  | LCURLYBAR of (
# 65 "parser.mly"
        Support.Error.info
# 186 "parser.ml"
)
  | LEFTARROW of (
# 66 "parser.mly"
        Support.Error.info
# 191 "parser.ml"
)
  | LPAREN of (
# 67 "parser.mly"
        Support.Error.info
# 196 "parser.ml"
)
  | LSQUARE of (
# 68 "parser.mly"
        Support.Error.info
# 201 "parser.ml"
)
  | LSQUAREBAR of (
# 69 "parser.mly"
        Support.Error.info
# 206 "parser.ml"
)
  | LT of (
# 70 "parser.mly"
        Support.Error.info
# 211 "parser.ml"
)
  | RCURLY of (
# 71 "parser.mly"
        Support.Error.info
# 216 "parser.ml"
)
  | RPAREN of (
# 72 "parser.mly"
        Support.Error.info
# 221 "parser.ml"
)
  | RSQUARE of (
# 73 "parser.mly"
        Support.Error.info
# 226 "parser.ml"
)
  | SEMI of (
# 74 "parser.mly"
        Support.Error.info
# 231 "parser.ml"
)
  | SLASH of (
# 75 "parser.mly"
        Support.Error.info
# 236 "parser.ml"
)
  | STAR of (
# 76 "parser.mly"
        Support.Error.info
# 241 "parser.ml"
)
  | TRIANGLE of (
# 77 "parser.mly"
        Support.Error.info
# 246 "parser.ml"
)
  | USCORE of (
# 78 "parser.mly"
        Support.Error.info
# 251 "parser.ml"
)
  | VBAR of (
# 79 "parser.mly"
        Support.Error.info
# 256 "parser.ml"
)

open Parsing
let _ = parse_error;;
# 7 "parser.mly"
open Support.Error
open Support.Pervasive
open Syntax
# 265 "parser.ml"
let yytransl_const = [|
    0|]

let yytransl_block = [|
  257 (* IMPORT *);
  258 (* IF *);
  259 (* THEN *);
  260 (* ELSE *);
  261 (* TRUE *);
  262 (* FALSE *);
  263 (* SUCC *);
  264 (* PRED *);
  265 (* ISZERO *);
  266 (* UCID *);
  267 (* LCID *);
  268 (* INTV *);
  269 (* FLOATV *);
  270 (* STRINGV *);
  271 (* APOSTROPHE *);
  272 (* DQUOTE *);
  273 (* ARROW *);
  274 (* BANG *);
  275 (* BARGT *);
  276 (* BARRCURLY *);
  277 (* BARRSQUARE *);
  278 (* COLON *);
  279 (* COLONCOLON *);
  280 (* COLONEQ *);
  281 (* COLONHASH *);
  282 (* COMMA *);
  283 (* DARROW *);
  284 (* DDARROW *);
  285 (* DOT *);
    0 (* EOF *);
  286 (* EQ *);
  287 (* EQEQ *);
  288 (* EXISTS *);
  289 (* GT *);
  290 (* HASH *);
  291 (* LCURLY *);
  292 (* LCURLYBAR *);
  293 (* LEFTARROW *);
  294 (* LPAREN *);
  295 (* LSQUARE *);
  296 (* LSQUAREBAR *);
  297 (* LT *);
  298 (* RCURLY *);
  299 (* RPAREN *);
  300 (* RSQUARE *);
  301 (* SEMI *);
  302 (* SLASH *);
  303 (* STAR *);
  304 (* TRIANGLE *);
  305 (* USCORE *);
  306 (* VBAR *);
    0|]

let yylhs = "\255\255\
\001\000\001\000\002\000\002\000\003\000\003\000\004\000\004\000\
\004\000\004\000\005\000\005\000\005\000\005\000\000\000"

let yylen = "\002\000\
\001\000\003\000\002\000\001\000\001\000\006\000\001\000\002\000\
\002\000\002\000\003\000\001\000\001\000\001\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\012\000\013\000\000\000\000\000\
\000\000\014\000\001\000\000\000\015\000\000\000\004\000\005\000\
\007\000\003\000\000\000\008\000\009\000\010\000\000\000\000\000\
\000\000\011\000\002\000\000\000\000\000\006\000"

let yydgoto = "\002\000\
\013\000\014\000\015\000\016\000\017\000"

let yysindex = "\010\000\
\001\000\000\000\244\254\254\254\000\000\000\000\003\255\003\255\
\003\255\000\000\000\000\254\254\000\000\224\254\000\000\000\000\
\000\000\000\000\011\255\000\000\000\000\000\000\232\254\001\000\
\254\254\000\000\000\000\017\255\254\254\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\254\255\000\000\008\000\000\000\009\000"

let yytablesize = 295
let yytable = "\004\000\
\011\000\018\000\005\000\006\000\007\000\008\000\009\000\005\000\
\006\000\010\000\001\000\019\000\024\000\025\000\010\000\020\000\
\021\000\022\000\026\000\023\000\029\000\027\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\028\000\000\000\000\000\012\000\030\000\000\000\000\000\000\000\
\012\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\003\000\004\000\000\000\000\000\005\000\006\000\007\000\
\008\000\009\000\000\000\000\000\010\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\012\000"

let yycheck = "\002\001\
\000\000\014\001\005\001\006\001\007\001\008\001\009\001\005\001\
\006\001\012\001\001\000\004\000\045\001\003\001\012\001\007\000\
\008\000\009\000\043\001\012\000\004\001\024\000\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\025\000\255\255\255\255\038\001\029\000\255\255\255\255\255\255\
\038\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\001\001\002\001\255\255\255\255\005\001\006\001\007\001\
\008\001\009\001\255\255\255\255\012\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\038\001"

let yynames_const = "\
  "

let yynames_block = "\
  IMPORT\000\
  IF\000\
  THEN\000\
  ELSE\000\
  TRUE\000\
  FALSE\000\
  SUCC\000\
  PRED\000\
  ISZERO\000\
  UCID\000\
  LCID\000\
  INTV\000\
  FLOATV\000\
  STRINGV\000\
  APOSTROPHE\000\
  DQUOTE\000\
  ARROW\000\
  BANG\000\
  BARGT\000\
  BARRCURLY\000\
  BARRSQUARE\000\
  COLON\000\
  COLONCOLON\000\
  COLONEQ\000\
  COLONHASH\000\
  COMMA\000\
  DARROW\000\
  DDARROW\000\
  DOT\000\
  EOF\000\
  EQ\000\
  EQEQ\000\
  EXISTS\000\
  GT\000\
  HASH\000\
  LCURLY\000\
  LCURLYBAR\000\
  LEFTARROW\000\
  LPAREN\000\
  LSQUARE\000\
  LSQUAREBAR\000\
  LT\000\
  RCURLY\000\
  RPAREN\000\
  RSQUARE\000\
  SEMI\000\
  SLASH\000\
  STAR\000\
  TRIANGLE\000\
  USCORE\000\
  VBAR\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Support.Error.info) in
    Obj.repr(
# 98 "parser.mly"
      ( [] )
# 498 "parser.ml"
               :  Syntax.command list ))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'Command) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Support.Error.info) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 :  Syntax.command list ) in
    Obj.repr(
# 100 "parser.mly"
      ( let cmd = _1 in
          let cmds = _3 in
          cmd::cmds )
# 509 "parser.ml"
               :  Syntax.command list ))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Support.Error.info) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string Support.Error.withinfo) in
    Obj.repr(
# 106 "parser.mly"
                   ( (Import(_2.v)) )
# 517 "parser.ml"
               : 'Command))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'Term) in
    Obj.repr(
# 108 "parser.mly"
      ( (let t = _1 in Eval(tmInfo t,t)) )
# 524 "parser.ml"
               : 'Command))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'AppTerm) in
    Obj.repr(
# 112 "parser.mly"
      ( _1 )
# 531 "parser.ml"
               : 'Term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : Support.Error.info) in
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'Term) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : Support.Error.info) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'Term) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : Support.Error.info) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'Term) in
    Obj.repr(
# 114 "parser.mly"
      ( TmIf(_1, _2, _4, _6) )
# 543 "parser.ml"
               : 'Term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'ATerm) in
    Obj.repr(
# 118 "parser.mly"
      ( _1 )
# 550 "parser.ml"
               : 'AppTerm))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Support.Error.info) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ATerm) in
    Obj.repr(
# 120 "parser.mly"
      ( TmSucc(_1, _2) )
# 558 "parser.ml"
               : 'AppTerm))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Support.Error.info) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ATerm) in
    Obj.repr(
# 122 "parser.mly"
      ( TmPred(_1, _2) )
# 566 "parser.ml"
               : 'AppTerm))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Support.Error.info) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ATerm) in
    Obj.repr(
# 124 "parser.mly"
      ( TmIsZero(_1, _2) )
# 574 "parser.ml"
               : 'AppTerm))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Support.Error.info) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'Term) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Support.Error.info) in
    Obj.repr(
# 129 "parser.mly"
      ( _2 )
# 583 "parser.ml"
               : 'ATerm))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Support.Error.info) in
    Obj.repr(
# 131 "parser.mly"
      ( TmTrue(_1) )
# 590 "parser.ml"
               : 'ATerm))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Support.Error.info) in
    Obj.repr(
# 133 "parser.mly"
      ( TmFalse(_1) )
# 597 "parser.ml"
               : 'ATerm))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int Support.Error.withinfo) in
    Obj.repr(
# 135 "parser.mly"
      ( let rec f n = match n with
              0 -> TmZero(_1.i)
            | n -> TmSucc(_1.i, f (n-1))
          in f _1.v )
# 607 "parser.ml"
               : 'ATerm))
(* Entry toplevel *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let toplevel (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf :  Syntax.command list )
