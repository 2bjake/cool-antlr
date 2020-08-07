grammar Cool;

program : classDecl* ;

classDecl : CLASS TYPEID (INHERITS TYPEID)? '{' feature* '}' ';' ;

feature : OBJECTID ':' TYPEID ('<-' expr)? ';'                  # attr
        | OBJECTID '(' formals ')' ':' TYPEID '{' expr '}' ';'  # method
        ;

formals: ( formal (',' formal)* )? ;

formal : OBJECTID ':' TYPEID ;

expr : INT                                        # intConst
     | (TRUE | FALSE)                             # boolConst
     | STRING                                     # stringConst
     | '(' expr ')'                               # parens
     | '~' expr                                   # negate
     | ISVOID expr                                # isvoid
     | expr (MUL | DIV) expr                      # mulDiv
     | expr (ADD | SUB) expr                      # addSub
     | expr (LE | LT | EQ) expr                   # compare
     | NOT expr                                   # not
     | OBJECTID '<-' expr                         # assign
     | OBJECTID                                   # object
     | NEW TYPEID                                 # new
     | IF expr THEN expr ELSE expr FI             # conditional
     | WHILE expr LOOP expr POOL                  # loop
     | CASE expr OF branch+ ESAC                  # case
     | '{' (expr ';')+ '}'                        # block
     | expr '@' TYPEID '.' OBJECTID '(' args? ')' # staticDispatch
     | expr '.' OBJECTID '(' args? ')'            # selfDispatch
     | OBJECTID '(' args? ')'                     # dispatch
     | LET letvar (',' letvar)* IN expr           # let
     ;

branch : OBJECTID ':' TYPEID '=>' expr ';' ;

args: expr (',' expr)* ;

letvar : OBJECTID ':' TYPEID ('<-' expr)? ;

allTokens: token* ;

token: INT # int
     | STRING # string
     | (TRUE | FALSE) # bool
     | (CLASS | IF | THEN | ELSE | FI | IN | INHERITS | LET | WHILE | LOOP | POOL | CASE | ESAC | OF | NEW | ISVOID | NOT) #keyword
     | TYPEID # typeid
     | OBJECTID #objectid
     | '<-' # assignToken
     | '=>' # darrow
     | LE  # le
     | (LT | EQ | MUL | DIV | ADD | SUB | ':' | ';' | '(' | ')' | '{' | '}' | '@' | '~'  | ';' | ',' | '.') # singleChar
     | UNTERMINATED_STRING # unterminatedString
     | ERROR # error
     | INVALID # invalid
     ;

INVALID: '\u0001' | '\u0002' | '\u0003' | '\u0004' ;

INT : [0-9]+ ;

MUL : '*' ;
DIV : '/' ;
ADD : '+' ;
SUB : '-' ;
LE : '<=' ;
LT : '<' ;
EQ : '=' ;

STRING : '"' CHARS? '"' ;

UNTERMINATED_STRING : '"' CHARS? '\n'
                    | '"' CHARS? EOF
                    ;

fragment
CHARS : CHAR+ ;

fragment
CHAR
    :   ~["\\\n]
    |   '\\' .
    ;

// keywords
CLASS : C L A S S ;
IF : I F ;
THEN : T H E N ;
ELSE : E L S E ;
FI : F I ;
IN : I N ;
INHERITS : I N H E R I T S ;
LET : L E T ;
WHILE : W H I L E ;
LOOP : L O O P ;
POOL : P O O L ;
CASE: C A S E ;
ESAC: E S A C ;
OF: O F ;
NEW : N E W ;
ISVOID : I S V O I D ;
NOT : N O T ;
TRUE : 't' R U E ; // must start with lowercase t
FALSE : 'f' A L S E ; // must start with lowercase f

// identifiers

TYPEID: [A-Z][A-Za-z0-9_]* ;
OBJECTID: [a-z][A-Za-z0-9_]* ;

BLOCK_COMMENT: '(*' .*? '*)' -> skip ; // TODO: handle nested
LINE_COMMENT : '--' .*? '\n' -> skip ;
WS : [ \n\f\r\t]+ -> skip ;
VT : '\u000B' -> skip ;

ERROR: . ;

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
