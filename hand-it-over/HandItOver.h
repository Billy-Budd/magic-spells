#ifndef MYHEADER_H_
#define MYHEADER_H_

// Factor:
struct {
    int type;
    char *identifier;
    int num;
    int boollit;
    struct ExpressionsStruct *expressionsVar;
} FactorStruct;

// Term:
struct {
    struct FactorStruct *factorVar;
    struct FactorStruct *factorLeftOP2;
    struct FactorStruct *factorRightOP2;
} TermStruct;

// Expression: shortened to expresStruct for readability
struct {
    struct TermStruct *termVar;
    struct TermStruct *termLeftOP3;
    struct TermStruct *termRightOP3;
} ExpresStruct;

// Expressions:
struct {
    struct ExpresStruct *expresVar;
    struct ExpresStruct *expresLeftOP4;
    struct ExpresStruct *expresRightOP4;
} ExpressionsStruct;

// WriteIntStatement:
struct {
    struct ExpressionsStruct *expressionsVar;
} WriteIntStruct;

// WhileStatement:
struct {
    struct ExprsssionsStruct *expressionsVar;
    struct StatementsStruct *statementsVar;
} WhileStruct;

// ElseStatement:
struct {
    struct StatementsStruct *statementsVar;
} ElseStruct;

// IfStatement:
struct {
    struct ExpressionsStruct *expressionsVar;
    struct StatementsStruct *statementsVar;
    struct ElseStruct *elseVar;
} IfStruct;

// Assignment:
struct {
    char *identifier;
    int intRead;
    struct ExpressionsStruct *expressionsVar;
} AssignmentStruct;

// Statement: shortened to StmtStruct for readability
struct {
    struct AssignmentStruct *assignmentVar;
    struct IfStruct *ifVar;
    struct WhileStruct *whileVar;
    struct WriteIntStruct *writeIntVar;
} StmtStruct;

// Statements: 
struct {
    struct StmtStruct *stmtVar;
    struct StatementsStruct *statementsVar;
} StatementsStruct;

// Type:
enum TypesEnum {
    INT_ENUM,
    BOOL_ENUM
};

// VarDeclaration:
struct {
    char *identifier;
    enum TypesEnum type;
    struct VarDecStruct *varDecVar;
} VarDecStruct;

// Program:
struct {
    struct VarDecStruct *varDecVar;
    struct StatementsStruct *statementsVar;
} ProgramStruct;

#endif /* MYHEADER_H_ */