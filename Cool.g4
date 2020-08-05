grammar Cool;

program : class_* ;

class_ : CLASS TYPEID (INHERITS TYPEID)? '{' feature* '}' ';' ;

feature : OBJECTID ':' TYPEID ('<-' expr)? ';'                  # attr
        | OBJECTID '(' formals ')' ':' TYPEID '{' expr '}' ';'  # method
        ;

formals: ( formal (',' formal)* )? ;

formal : OBJECTID ':' TYPEID ;

expr : INT                                        # int_const
     | (TRUE | FALSE)                             # bool_const
     | STRING                                     # str_const
     | '(' expr ')'                               # parens
     | expr '/' expr                              # divide
     | expr '*' expr                              # multiply
     | expr '+' expr                              # add
     | expr '-' expr                              # minus
     | '~' expr                                   # negate
     | expr '<' expr                              # lt
     | expr '<=' expr                             # leq
     | expr '=' expr                              # eq
     | NOT expr                                   # not
     | OBJECTID                                   # object
     | ISVOID expr                                # isvoid
     | NEW TYPEID                                 # new
     | IF expr THEN expr ELSE expr FI             # conditional
     | WHILE expr LOOP expr POOL                  # loop
     | OBJECTID '<-' expr                         # assign
     | CASE expr OF branch+ ESAC                  # case
     | '{' (expr ';')+ '}' .                      # block
     | expr '@' TYPEID '.' OBJECTID '(' args? ')' # static_dispatch
     | expr '.' OBJECTID '(' args? ')'            # self_dispatch
     | OBJECTID '(' args? ')'                     # dispatch
     | LET letvar (',' letvar)* IN expr           # let
     ;

branch : OBJECTID ':' TYPEID '=>' expr ';' ;

args: expr (',' expr)* ;

letvar : OBJECTID ':' TYPEID ('<-' expr)? ;

INT : [0-9]+ ;

// TODO: this doesn't match Cool's definition of a string
STRING : '"' ( ESC | . )*? '"' ;
fragment ESC : '\\' [btnr"\\] ;

// keywords
CLASS : C L A S S ;
ELSE : E L S E ;
FI : F I ;
IF : I F ;
IN : I N ;
INHERITS : I N H E R I T S ;
LET : L E T ;
LOOP : L O O P ;
POOL : P O O L ;
THEN : T H E N ;
WHILE : W H I L E ;
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
WS : [ \t\n]+ -> skip ;

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