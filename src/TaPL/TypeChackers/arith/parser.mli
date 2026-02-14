type token =
  | IMPORT of (
# 25 "parser.mly"
        Support.Error.info
# 6 "parser.mli"
)
  | IF of (
# 26 "parser.mly"
        Support.Error.info
# 11 "parser.mli"
)
  | THEN of (
# 27 "parser.mly"
        Support.Error.info
# 16 "parser.mli"
)
  | ELSE of (
# 28 "parser.mly"
        Support.Error.info
# 21 "parser.mli"
)
  | TRUE of (
# 29 "parser.mly"
        Support.Error.info
# 26 "parser.mli"
)
  | FALSE of (
# 30 "parser.mly"
        Support.Error.info
# 31 "parser.mli"
)
  | SUCC of (
# 31 "parser.mly"
        Support.Error.info
# 36 "parser.mli"
)
  | PRED of (
# 32 "parser.mly"
        Support.Error.info
# 41 "parser.mli"
)
  | ISZERO of (
# 33 "parser.mly"
        Support.Error.info
# 46 "parser.mli"
)
  | UCID of (
# 36 "parser.mly"
        string Support.Error.withinfo
# 51 "parser.mli"
)
  | LCID of (
# 37 "parser.mly"
        string Support.Error.withinfo
# 56 "parser.mli"
)
  | INTV of (
# 38 "parser.mly"
        int Support.Error.withinfo
# 61 "parser.mli"
)
  | FLOATV of (
# 39 "parser.mly"
        float Support.Error.withinfo
# 66 "parser.mli"
)
  | STRINGV of (
# 40 "parser.mly"
        string Support.Error.withinfo
# 71 "parser.mli"
)
  | APOSTROPHE of (
# 43 "parser.mly"
        Support.Error.info
# 76 "parser.mli"
)
  | DQUOTE of (
# 44 "parser.mly"
        Support.Error.info
# 81 "parser.mli"
)
  | ARROW of (
# 45 "parser.mly"
        Support.Error.info
# 86 "parser.mli"
)
  | BANG of (
# 46 "parser.mly"
        Support.Error.info
# 91 "parser.mli"
)
  | BARGT of (
# 47 "parser.mly"
        Support.Error.info
# 96 "parser.mli"
)
  | BARRCURLY of (
# 48 "parser.mly"
        Support.Error.info
# 101 "parser.mli"
)
  | BARRSQUARE of (
# 49 "parser.mly"
        Support.Error.info
# 106 "parser.mli"
)
  | COLON of (
# 50 "parser.mly"
        Support.Error.info
# 111 "parser.mli"
)
  | COLONCOLON of (
# 51 "parser.mly"
        Support.Error.info
# 116 "parser.mli"
)
  | COLONEQ of (
# 52 "parser.mly"
        Support.Error.info
# 121 "parser.mli"
)
  | COLONHASH of (
# 53 "parser.mly"
        Support.Error.info
# 126 "parser.mli"
)
  | COMMA of (
# 54 "parser.mly"
        Support.Error.info
# 131 "parser.mli"
)
  | DARROW of (
# 55 "parser.mly"
        Support.Error.info
# 136 "parser.mli"
)
  | DDARROW of (
# 56 "parser.mly"
        Support.Error.info
# 141 "parser.mli"
)
  | DOT of (
# 57 "parser.mly"
        Support.Error.info
# 146 "parser.mli"
)
  | EOF of (
# 58 "parser.mly"
        Support.Error.info
# 151 "parser.mli"
)
  | EQ of (
# 59 "parser.mly"
        Support.Error.info
# 156 "parser.mli"
)
  | EQEQ of (
# 60 "parser.mly"
        Support.Error.info
# 161 "parser.mli"
)
  | EXISTS of (
# 61 "parser.mly"
        Support.Error.info
# 166 "parser.mli"
)
  | GT of (
# 62 "parser.mly"
        Support.Error.info
# 171 "parser.mli"
)
  | HASH of (
# 63 "parser.mly"
        Support.Error.info
# 176 "parser.mli"
)
  | LCURLY of (
# 64 "parser.mly"
        Support.Error.info
# 181 "parser.mli"
)
  | LCURLYBAR of (
# 65 "parser.mly"
        Support.Error.info
# 186 "parser.mli"
)
  | LEFTARROW of (
# 66 "parser.mly"
        Support.Error.info
# 191 "parser.mli"
)
  | LPAREN of (
# 67 "parser.mly"
        Support.Error.info
# 196 "parser.mli"
)
  | LSQUARE of (
# 68 "parser.mly"
        Support.Error.info
# 201 "parser.mli"
)
  | LSQUAREBAR of (
# 69 "parser.mly"
        Support.Error.info
# 206 "parser.mli"
)
  | LT of (
# 70 "parser.mly"
        Support.Error.info
# 211 "parser.mli"
)
  | RCURLY of (
# 71 "parser.mly"
        Support.Error.info
# 216 "parser.mli"
)
  | RPAREN of (
# 72 "parser.mly"
        Support.Error.info
# 221 "parser.mli"
)
  | RSQUARE of (
# 73 "parser.mly"
        Support.Error.info
# 226 "parser.mli"
)
  | SEMI of (
# 74 "parser.mly"
        Support.Error.info
# 231 "parser.mli"
)
  | SLASH of (
# 75 "parser.mly"
        Support.Error.info
# 236 "parser.mli"
)
  | STAR of (
# 76 "parser.mly"
        Support.Error.info
# 241 "parser.mli"
)
  | TRIANGLE of (
# 77 "parser.mly"
        Support.Error.info
# 246 "parser.mli"
)
  | USCORE of (
# 78 "parser.mly"
        Support.Error.info
# 251 "parser.mli"
)
  | VBAR of (
# 79 "parser.mly"
        Support.Error.info
# 256 "parser.mli"
)

val toplevel :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf ->  Syntax.command list 
