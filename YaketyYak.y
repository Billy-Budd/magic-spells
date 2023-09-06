%{
/* yakety-yak.y
 * JML190001 - John Lawler
 * CS4386.501 Project Final
 * Program takes in a file and recognizes tokens in that file. It then uses bison to parse the grammar 
 * described in this file and changes the original file into an output file that you specify in the C
 * language. More details about this process occur throughout the program in the notes. 
 * I recently added the variable 'line' to the code using yylineno to show the lines of errors at the 
 * suggestion of a classmate, but it's not quite working in it's current form, and removing them creates 
 * a segmentation fault, so they will have to remain until a later date.
 *
 * Usage: ./jsgc <yourFile.txt> <outputFile.c>
 * Note: jsgc stands for 'John's Super Good Compiler' as more parts get added to this, I decided
 * to pick on a fairly easy name to type for testing. 
 * Note: some of the minor and major changes to this program are included in the header comment of 
 * FlexicalAnalysis.l
 * Note: VSCode lost my tab spacing preferences, so there may be some inconsistenting tabbing. I did my best
 * to fix this, but I'm sure there are still instances of it happening. 
 */
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "HandItOver.h"

extern FILE *yyin;      // in file
extern FILE *yyout;     // out file
extern int yylineno;
extern int errCount;

#define HASH_SIZE 255

// general error message
void yyerror(char *msg) {
        printf("Error: %s\n", msg);
}

int yylex(void);

struct ProgramStruct *programGlobal;    // needed for transition into tree

/* This next section is all about taking the tokens and fitting them into the parse tree
 * Once they are in the parse tree, we can allocate the way the tokens are structured into various
 * structures that best pertain to that token. Most, if not all, of the tokens can be broken up into 
 * smaller parts until we are only adding one 'leaf' of the tree at a time where only one part of the c 
 * code is actually being generated. This way, we can incrementally develop the output file in a straight-
 * forward and maintainable way. For more information about this parse tree, please look at the supplementary 
 * documents (particularly the specs of the project). 
 */
%}


%union {
        int num;
        char *sval;

        enum TypesEnum types_union;
        struct ProgramStruct *program_union;
        struct VarDecStruct *varDec_union;
        struct StatementsStruct *statements_union;
        struct StmtStruct *stmt_union;
        struct AssignmentStruct *assignment_union;
        struct IfStruct *if_union;
        struct ElseStruct *else_union;
        struct WhileStruct *while_union;
        struct WriteIntStruct *writeInt_union;
        struct ExpressionsStruct *expressions_union;
        struct ExpresStruct *expres_union;
        struct TermStruct *term_union;
        struct FactorStruct *factor_union;
}

%token<num> NUM;
%token<sval> ident BOOLVAR;
%token<sval> LP RP ASGN SC OP2 OP3 OP4 IF THEN ELSE BEGN END WHILE DO PROGRAM VAR AS INT BOOL WRITEINT READINT;

%type <types_union> Type;
%type <assignment_union> Assignment;
%type <if_union> IfStatement;
%type <statements_union> Statements;
%type <stmt_union> Statement;
%type <program_union> Program;
%type <varDec_union> Var_Declarations;
%type <else_union> ElseStatement;
%type <while_union> WhileStatement;
%type <expressions_union> Expressions;
%type <term_union> Term;
%type <factor_union> Factor;
%type <writeInt_union> WriteIntStatement;
%type <expres_union> Expression;


%start Program;
%%
Program:
        PROGRAM Var_Declarations BEGN Statements END { 
                struct ProgramStruct *ptr = malloc(sizeof(struct ProgramStruct));
                ptr->varDecVar = $2;
                ptr->statementsVar = $4;
                ptr->line = yylineno;
                programGlobal = ptr;
                //printf("PROGRAM Var_Declarations BEGN Statements END | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Program error on line %d\n", yylineno); }
        }

Var_Declarations:
        VAR ident AS Type SC Var_Declarations { 
                struct VarDecStruct *ptr = malloc(sizeof(struct VarDecStruct));
                ptr->identifier = strdup($2);
                ptr->type = $4;
                ptr->varDecVar = $6;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("VAR ident AS Type SC Var_Declarations | COMPLETE\n"); 
        }
        | /* empty */ { 
                $$ = NULL;
                //printf("Var_Declarations: EMPTY | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Var_Declarations error on line %d\n", yylineno); }
        }

Type:
        INT { 
                $$ = INT_ENUM;
                //printf("Type: INT | COMPLETE\n"); 
        }
        | BOOL { 
                $$ = BOOL_ENUM;
                //printf("Type: BOOL | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Type error on line %d\n", yylineno); }
        }

Statements:
        Statement SC Statements { 
                struct StatementsStruct *ptr = malloc(sizeof(struct StatementsStruct));
                ptr->stmtVar = $1;
                ptr->statementsVar = $3;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Statement SC Statements | COMPLETE\n"); 
        }
        | /* empty */ { 
                $$ = NULL;
                //printf("Statements: EMPTY | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Statements error on line %d\n", yylineno); }
        }

Statement: 
        Assignment { 
                struct StmtStruct *ptr = malloc(sizeof(struct StmtStruct));
                ptr->stmtType = 0;
                ptr->assignmentVar = $1;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Assignment | COMPLETE\n"); 
        }
        | IfStatement {
                struct StmtStruct *ptr = malloc(sizeof(struct StmtStruct));
                ptr->stmtType = 1;
                ptr->ifVar = $1;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("IfStatement | COMPLETE\n", $$); 
        }
        | WhileStatement {
                struct StmtStruct *ptr = malloc(sizeof(struct StmtStruct));
                ptr->stmtType = 2;
                ptr->whileVar = $1;
                ptr->line = yylineno; 
                $$ = ptr;
                //printf("WhileStatement | COMPLETE\n", $$); 
        }
        | WriteIntStatement {
                struct StmtStruct *ptr = malloc(sizeof(struct StmtStruct));
                ptr->stmtType = 3;
                ptr->writeIntVar = $1;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("WriteIntStatement | COMPLETE\n", $$); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Statement error on line %d\n", yylineno); }
        }

Assignment: 
        ident ASGN Expressions { 
                struct AssignmentStruct *ptr = malloc(sizeof(struct AssignmentStruct));
                ptr->assignmentType = 0;
                ptr->identifier = strdup($1);
                ptr->expressionsVar = $3;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("ident ASNG Expressions | COMPLETE\n"); 
        }
        | ident ASGN READINT { 
                struct AssignmentStruct *ptr = malloc(sizeof(struct AssignmentStruct));
                ptr->assignmentType = 1;
                ptr->identifier = strdup($1);
                ptr->intRead = 1;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("ident ASGN READINT | COMPLETE\n"); 
        }

IfStatement:
        IF Expressions THEN Statements ElseStatement END { 
                struct IfStruct *ptr = malloc(sizeof(struct IfStruct));
                ptr->expressionsVar = $2;
                ptr->statementsVar = $4;
                ptr->elseVar = $5;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("IF Expressions THEN Statements Else | COMPLETE\n"); 
        }

ElseStatement:
        ELSE Statements { 
                struct ElseStruct *ptr = malloc(sizeof(struct ElseStruct));
                ptr->statementsVar = $2;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("ELSE Statements | COMPLETE\n"); 
        }
        | /* empty */ { 
                $$ = NULL;
                //printf("ElseStatement: EMPTY | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Else error on line %d\n", yylineno); }
        }

WhileStatement:
        WHILE Expressions DO Statements END { 
                struct WhileStruct *ptr = malloc(sizeof(struct WhileStruct));
                ptr->expressionsVar = $2;
                ptr->statementsVar = $4;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("WHILE Expressions DO Statements END | COMPLETE\n"); 
        }

WriteIntStatement:
        WRITEINT Expressions { 
                struct WriteIntStruct *ptr = malloc(sizeof(struct WriteIntStruct));
                ptr->expressionsVar = $2;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("WRITEINT Expressions | COMPLETE\n"); 
        }

Expressions:
        Expression { 
                struct ExpressionsStruct *ptr = malloc(sizeof(struct ExpressionsStruct));
                ptr->expressionsType = 0;
                ptr->expresVar = $1;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Expression | COMPLETE\n"); 
        }
        | Expression OP4 Expression { 
                struct ExpressionsStruct *ptr = malloc(sizeof(struct ExpressionsStruct));
                ptr->expressionsType = 1;
                ptr->expresLeftOP4 = $1;
                ptr->OP4 = strdup($2);
                ptr->expresRightOP4 = $3;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Expression OP4 Expression | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Expressions error on line %d\n", yylineno); }
        }

Expression:
        Term { 
                struct ExpresStruct *ptr = malloc(sizeof(struct ExpresStruct));
                ptr->expresType = 0;
                ptr->termVar = $1;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Term | COMPLETE\n"); 
        }
        | Term OP3 Term { 
                struct ExpresStruct *ptr = malloc(sizeof(struct ExpresStruct));
                ptr->expresType = 1;
                ptr->termLeftOP3 = $1;
                ptr->OP3 = strdup($2);
                ptr->termRightOP3 = $3;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Term OP3 TERM | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Expression error on line %d\n", yylineno); }
        }

Term: 
        Factor { 
                struct TermStruct *ptr = malloc(sizeof(struct TermStruct));
                ptr->termType = 0;
                ptr->factorVar = $1;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Factor | COMPLETE\n"); 
        }
        | Factor OP2 Factor { 
                struct TermStruct *ptr = malloc(sizeof(struct TermStruct));
                ptr->termType = 1;
                ptr->factorLeftOP2 = $1;
                ptr->OP2 = strdup($2);
                ptr->factorRightOP2 = $3;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("Factor OP2 Factor | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Factor error on line %d\n", yylineno); }
        }

Factor: 
        ident { 
                struct FactorStruct *ptr = malloc(sizeof(struct FactorStruct));
                ptr->factorType = 0;
                ptr->identifier = strdup($1);
                ptr->line = yylineno;
                $$ = ptr;
                //printf("ident | COMPLETE | %s\n", ptr->identifier); 
        }
        | NUM { 
                struct FactorStruct *ptr = malloc(sizeof(struct FactorStruct));
                ptr->factorType = 1;
                ptr->num = atoi($1);
                ptr->line = yylineno;
                $$ = ptr;
                //printf("NUM | COMPLETE | %d\n", ptr->num); 
        }
        | BOOLVAR { 
                struct FactorStruct *ptr = malloc(sizeof(struct FactorStruct));
                ptr->factorType = 2;
                ptr->boolvar = strdup($1);
                ptr->line = yylineno;
                $$ = ptr;
                //printf("BOOLVAR | COMPLETE\n"); 
        }
        | LP Expressions RP { 
                struct FactorStruct *ptr = malloc(sizeof(struct FactorStruct));
                ptr->factorType = 3;
                ptr->expressionsVar = $2;
                ptr->line = yylineno;
                $$ = ptr;
                //printf("LP Expressions RP | COMPLETE\n"); 
        }
        | error {
                { fprintf(stderr, "Error: Syntax: Syntax error on line %d\n", yylineno); }
        }
%%

/*ERRORS*/
// this struct will allow us to find: 
// undeclared vars
// double declaration
// type mismatch
// detect overflow
struct Bucket {
        char *name;
        bool nodeType;
        struct Bucket* nextBucket;
        int val;
};

struct Bucket* hashTable[HASH_SIZE];

// create semi-unique hash for each variable name (pick the correct bucket to put it in)
int hash (char *name) {
        int x = 0;
        int i = 0;

        for (i = 0; name[i] != '\0'; i++) {
                x += name[i];
        }
        
        return x % HASH_SIZE;
}

// insert a new node to our buckets in our hash table
void insert(char *name, bool nodeType, int val) {

        // get proper hash
        int index = hash(name);

        // create space
        struct Bucket* bucket = (struct Bucket*) malloc(sizeof(struct Bucket));

        // store needed values
        bucket->name = name;
        bucket->nodeType = nodeType;
        bucket->val = val;
        bucket->nextBucket = hashTable[index];

        hashTable[index] = bucket;
}

// look for our variable, used in undeclared error and double declaration error
bool search(char *name) {

        // get proper hash
        int index = hash(name);

        // go to bucket
        struct Bucket* bucket = hashTable[index];

        // look through the buckets, if we find a matching one, return true
        while (bucket != NULL) {
                if (strcmp(bucket->name, name) == 0)
                        return true;
        }

        // otherwise we did not find our node, return false
        return false;
}

/* PRINT TOKENS AS C CODE */
/* FUNCTIONS ARE CREATED IN A "DEPTH FIRST" FASHION, EXCEPT FOR THE NEED OF PROTOTYPE IN printFactor */
void printExpressions(FILE *yyout, struct ExpressionsStruct *expressions); // specifically need this for (Expressions)

// print out factors as they are parsed, uses factorType to determine what kind of factor it is
// I used to try and just let it run, but this solution is much more elegant and easier to implement
void printFactor(FILE *yyout, struct FactorStruct *factor) {
        // factor is an identifier
        if (factor->factorType == 0) { 

                // identifier is declared, print as usual
                if (search(factor->identifier) == true) {
                        fprintf(yyout, "%s", factor->identifier);
                }

                // identifier not declared, error
                else {
                        printf("Error: Undeclared Variable: Undeclared variable \"%s\" encountered on line %d\n", factor->identifier, factor->line);
                }
                
        }
        
        // factor is a number
        else if (factor->factorType == 1) { 

                // any negative number is outside the accepted range, so if we find one, error and output relevant info
                // also checks for overflow since overflow will wrap around to a negative number (assuming the number isn't in the 4 billions area where it would be positive again)
                if (factor->num < 0 || factor->num == 2147483648) {
                        printf("Error: Invalid Number: Please ensure your value (%d) on line %d is within [0, 2147483647]\n", factor->num, factor->line);
                }

                // print the number if it is non-negative
                else {
                        fprintf(yyout, "%d", factor->num); 
                }
                
        }

        // factor is a boolean
        else if (factor->factorType == 2) { fprintf(yyout, "%s", factor->boolvar); }

        // factor is ( Expressions ), which needs call to printExpressions
        else if (factor->factorType == 3) { 
                fprintf(yyout, "(");                                    // left parentheses
                printExpressions(yyout, factor->expressionsVar);        // expressions term inside parentheses
                fprintf(yyout, ")");                                    // right parentheses
        }
        
        // if the number is something other than 0-3, then something terrible has gone wrong
        else { fprintf(yyout, "Error: Parse Error: factorType not recognized\n"); }
}

// print out terms as they are parsed, uses termType to determine how to parse
void printTerm(FILE *yyout, struct TermStruct *term) {
        // termType == 0, term is just a factor. call printFactor
        if (term->termType == 0) { printFactor(yyout, term->factorVar); }

        // termType == 1, there is an operator and two factors, call printFactor accordingly
        else if (term->termType == 1) {
                printFactor(yyout, term->factorLeftOP2);        // left term

                // check for mod, change to % for c
                if (strcmp(term->OP2,"mod") == 0) {
                        fprintf(yyout, "%%");
                }

                // check for div, change to / for c
                else if (strcmp(term->OP2,"div") == 0) {
                        fprintf(yyout, "/");
                }

                // this should always be *, in case it isn't, there is something wrong, but we want to print it to file anyways
                else {
                        fprintf(yyout, "%s", term->OP2);
                }
                
                printFactor(yyout, term->factorRightOP2);       // right term
        }

        // if the number is something other than 0-1, then something terrible has gone wrong
        else { fprintf(yyout, "Error: Parse Error: termType not recognized\n"); }
}

// print out expression as they are parsed, note that this is the expression NOT expressions
void printExpr(FILE *yyout, struct ExpresStruct *expr) {
        // expresType == 0, expression is just a term, call printTerm
        if (expr->expresType == 0) { printTerm(yyout, expr->termVar); }

        // expresType == 1, there is an operator and two terms, call printTerm accordingly
        else if (expr->expresType == 1) {
                printTerm(yyout, expr->termLeftOP3);    // left term
                fprintf(yyout, "%s", expr->OP3);        // operator term
                printTerm(yyout, expr->termRightOP3);   // right term
        }

        // if the number is something other than 0-1, then something terrible has gone wrong
        else { fprintf(yyout, "Error: Parse Error: expresType not recognized\n"); }
}

// print out expressions as they are parsed, this is expressions plural, so the more general version
void printExpressions(FILE *yyout, struct ExpressionsStruct *expressions) {
        // expressionsType == 0, expressions is just an expression, call printExpr
        if (expressions->expressionsType == 0) { printExpr(yyout, expressions->expresVar); }

        // expressionsType == 1, there is an operator between two expression, call printExpr accordingly
        else if (expressions->expressionsType == 1) { 
                printExpr(yyout, expressions->expresLeftOP4);   // left term

                // possibly the most ungraceful check to turn a = into an ==, but it needs to be done for while and if statements
                if ((strcmp(expressions->OP4, "=") == 0 && 
                        ((strcmp(expressions->OP4, "<=")) != 0 && 
                         (strcmp(expressions->OP4, ">=")) != 0 &&
                         (strcmp(expressions->OP4, ":=")) != 0 &&
                         (strcmp(expressions->OP4, "!=")) != 0))) {
                        
                        fprintf(yyout, "==", expressions->OP4);
                }

                // otherwise, the original token is right and can just be printed
                else  {
                        fprintf(yyout, "%s", expressions->OP4);        // operator term
                }

                printExpr(yyout, expressions->expresRightOP4);  // right term
        }

        // if the numbher is something other than 0-1, then something terrible has gone wrong
        else { fprintf(yyout, "Error: Parse error: expresType not recognized\n"); }
}

// main function for printing out program, contains assignment, if/else, while, and writeInt
// i know the pointers here are a bit goofy; however, this saves other confusing steps
// the main point here is that we start with the super category statements
// and narrow it down into the 4 things that a statment (non plural) can be
void printStatements(FILE *yyout, struct StatementsStruct *statements) {
        // while there are more statements, continue parsing them into the correct print statements
        while (statements != NULL) {

                // assignment 
                if (statements->stmtVar->stmtType == 0) {
                        // access the struct for the assignment
                        struct AssignmentStruct *assignment = statements->stmtVar->assignmentVar;

                        // if true, variable is declared and we can assign
                        if (search(assignment->identifier) == true) {

                        // assignment type 0, expressions type
                                if (assignment->assignmentType == 0) { 
                                        // need to check for initialized variables
                                        fprintf(yyout, "%s = ", assignment->identifier);        // variable name
                                        printExpressions(yyout, assignment->expressionsVar);    // value for variable
                                        fprintf(yyout, ";\n");                                  // ;
                                }

                                // assignment type 1, read int type
                                // create temp var i, scanf %d using dereferenced i, put int in proper variable 
                                // %% turns into just % because %% is an escape for %
                                else if (assignment->assignmentType == 1) {
                                        fprintf(yyout, "scanf(\"%%d\", &i);\n");                // scan the variable from input
                                        fprintf(yyout, "%s = i;\n", assignment->identifier);    // assign the temp variable to our real variable
                                }

                                // if the number is something other than 0-1, then somthing terrible has gone wrong
                                else { fprintf(yyout, "Error: Parse Error: assignmentType not recognized\n"); }
                        }

                        else {
                                printf("Error: Undeclared Variable: Undeclared variable \"%s\" encountered on line %d\n", assignment->identifier, assignment->line);
                        }

                        
                }

                // if, print out a c if statement into yyout
                else if (statements->stmtVar->stmtType == 1) {
                        // access the struct for the if statement
                        struct IfStruct *ifStmt = statements->stmtVar->ifVar;

                        // begin if statement
                        fprintf(yyout, "if(");

                        // conditionals of if
                        printExpressions(yyout, ifStmt->expressionsVar);
                        fprintf(yyout, ") {\n");

                        // statements of if
                        printStatements(yyout, ifStmt->statementsVar);

                        // add an else (if there is no else, then it will be blank and it will still run as normal)
                        // yes, this outputs a little weird into the output file, but it's easier to visualize this rather than on three lines
                        fprintf(yyout, "} else {\n");

                        // add else clause if it exists
                        if (ifStmt->elseVar) {
                                printStatements(yyout, ifStmt->elseVar->statementsVar);
                        }

                        // close out the if/else statement
                        fprintf(yyout, "}\n");
                }

                // while, print out a c while statement int yyout
                else if (statements->stmtVar->stmtType == 2) {
                        // access the struct for the while statement
                        struct WhileStruct *whileStmt = statements->stmtVar->whileVar;

                        // begin statement
                        fprintf(yyout, "while(");

                        // conditionals of while
                        printExpressions(yyout, whileStmt->expressionsVar);
                        fprintf(yyout, ") {\n");

                        // statments of while
                        printStatements(yyout, whileStmt->statementsVar);

                        // end statement
                        fprintf(yyout, "}\n");
                }

                // writeInt, uses similar logic as assignment
                else if (statements->stmtVar->stmtType == 3) {
                        // accesss the struct for the writeInt statement
                        struct WriteIntStruct *writeInt = statements->stmtVar->writeIntVar;

                        // similar logic to assignment, just need to write it into console
                        fprintf(yyout, "printf(\"%%d\\n\", ");

                        // this can be an Expressions, so we move out of this and back into the main tree
                        printExpressions(yyout, writeInt->expressionsVar);

                        // close out statement
                        fprintf(yyout, ");\n");
                }

                // move onto the next statement, eventually will be NULL and loop will end
                statements = statements->statementsVar;
        }
}


// Main function, open proper files, close proper files, run yyparse, all that kind of stuff. More details within main
int main(int argc, char** argv) {
    if (argc == 3) {

        // open a file to be read
        FILE *inFile = fopen(argv[1], "r");

        // open out file to write to
        FILE *outFile = fopen(argv[2], "w");
        
        // file could not be opened
        if (!inFile){
                printf("Error: Cannot open input file %s\n", argv[1]);
                return 1;
        }

        // file could not be opened
        if (!outFile) {
                printf("Error: Cannot open output file %s\n", argv[2]);
                return 1;
        }

        // notice message
        printf("\nChecking tokens and parsing...\n");

        // put the file in yyin for yyparse
        yyin = inFile;
        yyout = outFile;
        yyparse();

        // notice message
        printf("\nWriting to outfile...\n");

        // segmentation fault message, if it happens, please follow the provided steps
        printf("\nIf your program does not compile and you get a \"Segmentation fault\" error, the most likely cause is an incomplete declaration or statement.\n");
        printf("This typically happens when a comment, denoted by %%, is used and comments out a portion of the tokens in a line.\n");
        printf("Please check your input file for misplaced comments and try again if this error occurs.\n\n");
        printf("Some errors may appear on the wrong line. Please backtrack whitespace lines to encounter error.\n\n");
        
        // required stuff for c, headers and main
        fprintf(yyout, "#include<stdio.h>\n#include<stdbool.h>\n#include<stdlib.h>\nint main(int argc, char** argv) {\n");

        // initialize a temp variable for READINT because it will initialize twice if there are two READINT statements if it is in function
        fprintf(yyout, "int i;\n");                             

        // notice message
        printf("Writing variable declarations...\n\n");

        // create a pointer for our current position in the programGlobal
        struct VarDecStruct *declarations = programGlobal->varDecVar;

        // go through all of our varDecVar in programGlobal and get all of our declarations initialized
        while (declarations != NULL) {

                // integer type
                if (declarations->type == INT_ENUM) {
                        bool thisType = false;

                        // if this is true, we already have it declared and should not declare again
                        // program will not break, just output error, and skip this declaration
                        if (search(declarations->identifier) == true) {
                                printf("Error: Duplicate Declaration: Duplicate variable \"%s\" encountered on line %d\n", declarations->identifier, declarations->line);
                        }

                        // was not already found in hash table, we can now add and print to outfile
                        else {
                                insert(declarations->identifier, thisType, 0);
                                fprintf(yyout, "int %s;\n", declarations->identifier);
                        }                        
                }

                // boolean type
                else if (declarations->type == BOOL_ENUM) {
                        bool thisType = true;

                        // if this is true, we already have it declared and should not declare again
                        // program will not break, just output error, and skip this declaration
                        if (search(declarations->identifier) == true) {
                                printf("Error: Duplicate Declaration: Duplicate variable \"%s\" encountered on line %d\n", declarations->identifier, declarations->line);
                        }

                        // was not already found in hash table, we can now add and print to outfile
                        else {
                                insert(declarations->identifier, thisType, 0);
                                fprintf(yyout, "bool %s;\n", declarations->identifier);
                        } 
                }

                // unrecognized type
                else {
                        printf("\n\nError: Type Error: unrecognized type\n");
                        printf("Please change the type to integer or boolean and retry.\n");
                }
                

                // move on to the next node to check if we were successfully able to add the identifier
                declarations = declarations->varDecVar;
        }

        // notice message
        printf("\nFinished variable declarations...\n\n");

        // create a pointer for our statements with our programGlobal marker
        struct StatementsStruct *stmts = programGlobal->statementsVar;

        printf("Writing statements...\n\n");
        // call function for our statements (part 2 of 2 of our major steps)
        printStatements(yyout, stmts);

        // changing end to return 0; because c
        fprintf(yyout, "return 0;\n");
        fprintf(yyout, "}\n");

        // notice message
        printf("\nFinished statements...\n\n");
        

        // display success or errors
        if (errCount == 0){
                printf("\n\nSUCCESS\n\n");
        }
        else {
                printf("%d", errCount);
                printf(" syntax error(s) found. Please check the console for additional information.\n\n");
        }

        // close the files
        fclose(inFile);
        fclose(outFile);
    }

    else {
        printf("Usage: ./jsgc <input.txt> <output.c>\n");
        printf("You can manually type into this console and it will parse, but please be aware that nothing you type will be saved.\n");
        yyparse();
    }

    return 0;
}