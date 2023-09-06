#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifndef HANDITOVER_H
#define HANDITOVER_H

// Type:
enum TypesEnum {
    INT_ENUM,
    BOOL_ENUM
};

// Factor:
struct FactorStruct {
    int factorType;
    int line;
    union {
        char *identifier;
        int num;
        char *boolvar;
        struct ExpressionsStruct *expressionsVar;
    }; // union
};

// Term:
struct TermStruct {
    int termType;
    int line;
    union {
        struct FactorStruct *factorVar;
        struct{
            char *OP2;
            struct FactorStruct *factorLeftOP2;
            struct FactorStruct *factorRightOP2;
        }; // mini struct
    }; // union
};

// Expression: shortened to expresStruct for readability
struct ExpresStruct {
    int expresType;
    int line;
    union {
        struct TermStruct *termVar;
        struct {
            char *OP3;
            struct TermStruct *termLeftOP3;
            struct TermStruct *termRightOP3;
        }; // mini struct
    }; // union
};

// Expressions:
struct ExpressionsStruct {
    int expressionsType;
    int line;
    union {
        struct ExpresStruct *expresVar;
        struct {
            char *OP4;
            struct ExpresStruct *expresLeftOP4;
            struct ExpresStruct *expresRightOP4;
        }; // mini struct
    }; // union
};

// WriteIntStatement:
struct WriteIntStruct {
    int line;
    struct ExpressionsStruct *expressionsVar;
};

// WhileStatement:
struct WhileStruct {
    int line;
    struct ExpressionsStruct *expressionsVar;
    struct StatementsStruct *statementsVar;
};

// ElseStatement:
struct ElseStruct {
    int line;
    struct StatementsStruct *statementsVar;
};

// IfStatement:
struct IfStruct {
    int line;
    struct ExpressionsStruct *expressionsVar;
    struct StatementsStruct *statementsVar;
    struct ElseStruct *elseVar;
};

// Assignment:
struct AssignmentStruct {
    int line;
    int assignmentType;
    char *identifier;
    union {
        int intRead;
        struct ExpressionsStruct *expressionsVar;
    }; // union
};

// Statement: shortened to StmtStruct for readability
struct StmtStruct {
    int line;
    int stmtType;
    union {
        struct AssignmentStruct *assignmentVar;
        struct IfStruct *ifVar;
        struct WhileStruct *whileVar;
        struct WriteIntStruct *writeIntVar;
    }; // union
};

// Statements: 
struct StatementsStruct {
    int line;
    struct StmtStruct *stmtVar;
    struct StatementsStruct *statementsVar;
};

// VarDeclaration:
struct VarDecStruct {
    int line;
    char *identifier;
    enum TypesEnum type;
    struct VarDecStruct *varDecVar;
};

// Program:
struct ProgramStruct {
    int line;
    struct VarDecStruct *varDecVar;
    struct StatementsStruct *statementsVar;
};

#endif /* HANDITOVER_H */