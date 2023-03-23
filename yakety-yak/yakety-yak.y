%{
/* yakety-yak.y
 * JML190001 - John Lawler
 * CS4386.501 Project Two A
 * Program provides context free grammar using tokens from FlexicalAnalysis.l
 * and uses yyin as its main source of file input. 
 * Currently, everything is in string form because it was easier to do it this way, 
 * but it will be changed as needed to accomodate for a more accurate compiler. 
 * You can 'freehand' the code by not giving a .txt file in its command line argument
 * but I do not recommend this as it can be tedious and your work is not saved. 
 * Usage: ./jsgc <yourFile.txt>
 * Note: jsgc stands for 'John's Super Good Compiler' as more parts get added to this, I decided
 * to pick on a fairly easy name to type for testing. 
 * Note: some of the minor and major changes to this program are included in the header comment of 
 * FlexicalAnalysis.l
 */
#include <stdio.h>

extern FILE *yyin;

void yyerror(char *msg) {
    printf("Error: %s\n", msg);
}

int yylex(void);
%}

%union {
  int num;
  char *sval;
}

%token<sval> ident;
%token<num> NUM;
%token<sval> BOOLLIT LP RP ASGN SC OP2 OP3 OP4 IF THEN ELSE BEGN END WHILE DO PROGRAM VAR AS INT BOOL WRITEINT READINT;

%type<sval> Type Assignment IfStatement Statements Statement Program Var_Declarations ElseStatement WhileStatement Expressions Term Factor WriteIntStatement Expression
%start Program;
%%
Program:
        PROGRAM Var_Declarations BEGN Statements END { printf("%s\n", $$); }

Var_Declarations:
        VAR ident AS Type SC Var_Declarations { printf("Declaration: %s as %s\n", $2, $4); }
        | /* empty */ { printf("Var_Declarations: empty\n"); }

Type:
        INT { printf("Type: %s\n", $$); }
        | BOOL { printf("Type: %s\n", $$); }

Statements:
        Statement SC Statements { printf("Statements: %s SC Statements\n", $1); }
        | /* empty */ { printf("Statements: empty\n"); }

Statement: 
        Assignment { printf("Assignment: %s COMPLETE\n", $$); }
        | IfStatement { printf("IfStatement: %s COMPLETE\n", $$); }
        | WhileStatement { printf("WhileStatement: %s COMPLETE\n", $$); }
        | WriteIntStatement { printf("WriteIntStatement: %s COMPLETE\n", $$); }

Assignment: 
        ident ASGN Expressions { printf("Assignment(Expressions): %s := %s\n", $1, $3); }
        | ident ASGN READINT { printf("Assignment(READINT): %s := %s\n", $1, $3); }

IfStatement:
        IF Expressions THEN Statements ElseStatement END { printf("IfStatement: %s THEN Statements ElseStatement\n", $2); }

ElseStatement:
        ELSE Statements { printf("Else: %s\n", $2); }
        | /* empty */ { printf("ElseStatement: empty\n"); }

WhileStatement:
        WHILE Expressions DO Statements END { printf("WhileStatement: while %s DO %s END\n", $2, $4); }

WriteIntStatement:
        WRITEINT Expressions { printf("WriteIntStatement: %s\n", $2); }

Expressions:
        Expression { printf("Expressions: %s\n", $1); }
        | Expression OP4 Expression { printf("Expression(OP4): %s %s %s\n", $1, $2, $3); }

Expression:
        Term { printf("Expression: %s\n", $1); }
        | Term OP3 Term { printf("Expression(OP3): %s %s %s\n", $1, $2, $3); }

Term: 
        Factor { printf("Term: %s\n", $1); }
        | Factor OP2 Factor { printf("Term(OP2): %s %s %s\n", $1, $2, $3); }

Factor: 
        ident { printf("Factor(ident): %s\n", $1); }
        | NUM { printf("Factor(NUM): %s\n", $1); }
        | BOOLLIT { printf("Factor(BOOLLIT): %s\n", $1); }
        | LP Expressions RP { printf("Factor: LP Expressions RP\n"); }
%%

int main(int argc, char** argv) {
    if (argc == 2){

        // open a file to be read
        FILE *inFile = fopen(argv[1], "r");

        // file could not be opened
        if (!inFile){
            printf("Error: Cannot open input file %s\n", argv[1]);
            return 1;
        }

        // put the file in yyin for yyparse
        yyin = inFile;
        int errCount = yyparse();
        fclose(inFile);

        // display success or errors
        if (errCount == 0){
                printf("\n\nSUCCESS\n\n");
        }
        else {
                printf("\n\nThere were errors found.\n\n");
        }
    }

    else {
        yyparse();
    }

    return 0;
}