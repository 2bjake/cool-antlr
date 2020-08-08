grammar Cool;

program : classDecl* ;

classDecl : Class TypeId (Inherits TypeId)? '{' feature* '}' ';' ;

feature : ObjectId ':' TypeId ('<-' expr)? ';'                  # attr
        | ObjectId '(' formals ')' ':' TypeId '{' expr '}' ';'  # method
        ;

formals: ( formal (',' formal)* )? ;

formal : ObjectId ':' TypeId ;

expr : Int                                        # intConst
     | (True | False)                             # boolConst
     | String                                     # stringConst
     | '(' expr ')'                               # parens
     | '~' expr                                   # negate
     | Isvoid expr                                # isvoid
     | expr (Star | Divide) expr                  # arith
     | expr (Plus | Minus) expr                   # arith
     | expr (LessEqual | Less | Equal) expr       # compare
     | Not expr                                   # not
     | ObjectId '<-' expr                         # assign
     | ObjectId                                   # object
     | New TypeId                                 # new
     | If expr Then expr Else expr Fi             # conditional
     | While expr Loop expr Pool                  # loop
     | Case expr Of branch+ Esac                  # case
     | '{' (expr ';')+ '}'                        # block
     | expr '@' TypeId '.' ObjectId '(' args? ')' # staticDispatch
     | expr '.' ObjectId '(' args? ')'            # dispatch
     | ObjectId '(' args? ')'                     # selfDispatch
     | Let letvar (',' letvar)* In expr           # let
     ;

branch : ObjectId ':' TypeId '=>' expr ';' ;

args: expr (',' expr)* ;

letvar : ObjectId ':' TypeId ('<-' expr)? ;

allTokens: token* ;

token: Int # int
     | String # string
     | (True | False) # bool
     | (Class | If | Then | Else | Fi | In | Inherits | Let | While | Loop | Pool | Case | Esac | Of | New | Isvoid | Not) # keyword
     | TypeId # typeId
     | ObjectId # objectId
     | '<-' # assignToken
     | '=>' # darrow
     | LessEqual  # le
     | (Less | Equal | Star | Divide | Plus | Minus | ':' | ';' | '(' | ')' | '{' | '}' | '@' | '~'  | ';' | ',' | '.') # singleChar
     | UnterminatedString # unterminatedString
     | UnmatchedComment # unmatchedComment
     | Error # error
     | Invalid # invalid
     ;

Invalid: '\u0001' | '\u0002' | '\u0003' | '\u0004' ;

UnmatchedComment : '*)' ;

Int : [0-9]+ ;

Star : '*' ;
Divide : '/' ;
Plus : '+' ;
Minus : '-' ;
LessEqual : '<=' ;
Less : '<' ;
Equal : '=' ;

String : '"' Chars? '"' ;

UnterminatedString : '"' Chars? '\n'
                   | '"' Chars? EOF
                   ;

fragment
Chars : Char+ ;

fragment
Char : ~["\\\n]
     | '\\' .
     ;

// keywords

Class : C L A S S ;
If : I F ;
Then : T H E N ;
Else : E L S E ;
Fi : F I ;
In : I N ;
Inherits : I N H E R I T S ;
Let : L E T ;
While : W H I L E ;
Loop : L O O P ;
Pool : P O O L ;
Case: C A S E ;
Esac: E S A C ;
Of: O F ;
New : N E W ;
Isvoid : I S V O I D ;
Not : N O T ;
True : 't' R U E ; // must start with lowercase t
False : 'f' A L S E ; // must start with lowercase f

// identifiers

TypeId: [A-Z][A-Za-z0-9_]* ;
ObjectId: [a-z][A-Za-z0-9_]* ;

// skip tokens

BlockComment : '(*' (BlockComment | . )*? '*)' -> skip ; // TODO: this isn't quite right, but good enough for now...
LineComment : '--' .*? ('\n' | EOF) -> skip ;
WS : [ \n\f\r\t]+ -> skip ;
VT : '\u000B' -> skip ;

Error: . ;

// case insensitive letters for keywords

fragment A : [aA];
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];
