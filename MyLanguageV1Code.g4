// A simple syntax-directed translator for a simple language
// ICS 312 - HW9 - Spring 2019
// Christian Cheshire, expanding on work by Henri Casanova

grammar MyLanguageV1Code;

// Root non-terminal symbol
// A program is a bunch of declarations followed by a bunch of statements
// The Java code outputs the necessary NASM code around these declarations

program       : 
              {System.out.println("%include \"asm_io.inc\"");
               System.out.println("segment .bss"); }
              declaration*
              {System.out.println("segment .text"); 
               System.out.println("\tglobal asm_main"); 
               System.out.println("asm_main:"); 
               System.out.println("\tenter 0,0"); 
               System.out.println("\tpusha"); }
              statement*
              {System.out.println("\tpopa"); 
               System.out.println("\tmov eax,0"); 
               System.out.println("\tleave"); 
               System.out.println("\tret"); } 
	      function* // ***********ADDED***********
              ;

// Parse rule for variable declarations

declaration   : 
              {int a; }
              INT a=NAME SEMICOLON
              {System.out.println("\t"+$a.text + "  resd 1");}
              ;

// Parse rule for statements

statement      : 
               ifstmt 
             | printstmt 
             | assignstmt 
             | dowhilestmt // ***********ADDED***********
             | callfunction // ***********ADDED***********
	     | retfunction // ***********ADDED***********
               ;

// Parse rule for callfunction
// ***********ADDED THIS SECTION**************

callfunction:
            {int a,b;}
            a=identifier ASSIGN b=NAME LPAREN RPAREN SEMICOLON
            {System.out.println("\tcall "+$b.text);}
            {System.out.println("\tmov "+$a.toString+", eax");}
            ;

// Parse rule for function statement
// ***********ADDED THIS SECTION**************

function    :
            {int a,b;}
            INT b=NAME LPAREN RPAREN LBRACK
            {System.out.println($b.text+":");}
            {System.out.println("\tpush ebp");}
            {System.out.println("\tmov ebp, esp");}
            {System.out.println("\tmov eax, 0");}
            statement*
            retfunction
            RBRACK
            ;

// Parse rule for retfunction
// ***********ADDED THIS SECTION**************

retfunction :
            {int a,b;}
            RETURN a=term SEMICOLON
            {System.out.println("\tmov eax, "+$a.toString);}
            {System.out.println("\tpop ebp");}
            {System.out.println("\tret");}
            |
            RETURN expression SEMICOLON
            {System.out.println("\tpop ebp");}
            {System.out.println("\tret");}
            |
            RETURN b=integer SEMICOLON
            {System.out.println("\tmov eax, "+$b.toString);}
            {System.out.println("\tpop ebp");}
            {System.out.println("\tret");}
            ;

// Parse rule for do-while statements 
// ***********ADDED THIS SECTION**************

dowhilestmt :  
	    {int a,b;}
	    {String label;}
            DO
	    {label = "label_"+Integer.toString($DO.index);}
	    {System.out.println(label+":");}
            statement*
            WHILE LPAREN a=identifier NOTEQUAL b=integer RPAREN
            {System.out.println("\tcmp dword "+$a.toString+","+$b.toString);
            System.out.println("\tjne "+label); }
            ;

// Parse rule for if statements

ifstmt      : 
            {int a,b;} 
            {String label;}
            IF LPAREN a=identifier EQUAL b=integer RPAREN
            {System.out.println("\tcmp dword "+$a.toString+","+$b.toString);
            label = "label_"+Integer.toString($IF.index);
            System.out.println("\tjnz "+label); }
            statement*
            { System.out.println(label+":"); }
            ENDIF
            ;

// Parse rule for print statements

printstmt      : 
               PRINT term SEMICOLON
               {System.out.println("\tmov eax, "+$term.toString);
                System.out.println("\tcall print_int");
                System.out.println("\tcall print_nl");} 
	      |
	       PRINT augprintstmt* SEMICOLON	
               ;

// Parse rule for augmented print statements
// ***********ADDED THIS SECTION**************

augprintstmt   :
	       term COMMA*
               {System.out.println("\tmov eax, "+$term.toString);
               System.out.println("\tcall print_int");
               System.out.println("\tcall print_nl");}
               ;

// Parse rule for assignment statements

assignstmt      : 
                {int a; }
                a=NAME ASSIGN expression SEMICOLON 
                {System.out.println("\tmov ["+$a.text+"], eax");} 
                ;

// Parse rule for expressions

expression      : 
                {int a,b; }
                a=term 
                {System.out.println("\tmov eax,"+$a.toString);}
              | 
                a=term PLUS b=term 
                {System.out.println("\tmov eax,"+$a.toString);}
                {System.out.println("\tadd eax,"+$b.toString);}
	      |	// ************ADDED MINUS SECTION****************
		a=term MINUS b=term 
                {System.out.println("\tmov eax,"+$a.toString);}
                {System.out.println("\tsub eax,"+$b.toString);}
                ;

// Parse rule for terms

term returns [String toString]  : 
                                identifier {$toString = $identifier.toString;} 
                              | integer {$toString = $integer.toString;} 
                                ;

// Parse rule for identifiers

identifier returns [String toString]: NAME {$toString = "["+$NAME.text+"]";} ;

// Parse rule for numbers 

integer returns [String toString]: INTEGER {$toString = $INTEGER.text;} ;


// Reserved Keywords
////////////////////////////////

IF: 'if';
ENDIF: 'endif';
PRINT: 'print';
INT: 'int';
DO: 'do';
WHILE: 'while';
RETURN: 'return';

// Operators
PLUS: '+';
MINUS: '-'; // ***********ADDED*************
EQUAL: '==';
ASSIGN: '=';
NOTEQUAL: '!=';

// Semicolon and parentheses
SEMICOLON: ';';
LPAREN: '(';
RPAREN: ')';
COMMA: ','; // ***********ADDED***********
LBRACK: '{';  // ***********ADDED***********
RBRACK: '}';  // ***********ADDED***********

// Integers
INTEGER: [0-9][0-9]*;

// Variable names
NAME: [a-z]+;   

// Ignore all white spaces 
WS: [ \t\r\n]+ -> skip ; 
