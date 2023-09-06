%{

/* FlexicalAnalysis.l
 * JML190001 - John Lawler
 * CS4386.501 Project One A
 * 02/26/23
 * Program receives input as a string through either a text file, typed directly into
 * the terminal, or uses one of the default programs (see main for more details). 
 * Program then uses flex to convert lexemes into acceptable tokens (with one of the
 * tokens being invalid). The program can show whitespace as a lexeme where you would 
 * change the {WHITESPACE} command from {} to {printToken("WHITESPACE", yytext);}.
 * I excluded it because it ends up that most of the program is WHITESPACE and it 
 * cluttered the output. Program exports the associated tokens with their lexemes and
 * returns whether flexical analysis was successful or if it found invalid tokens, 
 * creating errors. 
 */
#include <iostream>
#include <string>
#include <fstream>

using namespace std;

int invalid = 0;
string outputString;

// print token information from token and lexeme
void printToken(const char* token, const char* lexeme) {
    string outputStringTemp = "Token: " + string(token) + ", Value" + string(lexeme) + "\n";
    cout << outputStringTemp;
    outputString += outputStringTemp;
}



%}

num [1-9][0-9]*|0
boollit false|true
ident [A-Z][A-Z0-9]*
LP "("
RP ")"
ASGN ":="
SC ";"
OP2 "*"|"div"|"mod"
OP3 "+"|"-"
OP4 "="|"!="|"<"|">"|"<="|">="
IF "if"
THEN "then"
ELSE "else"
BEGIN "begin"
END "end"
WHILE "while"
DO "do"
PROGRAM "program"
VAR "var"
AS "as"
INT "int"
BOOL "bool"
WRITEINT "writeInt"
READINT "readInt"
WHITESPACE [ \t\r\n]|%.*

%%
{num}               { printToken("num", yytext); }
{boollit}           { printToken("boollit", yytext); }
{ident}             { printToken("ident", yytext); }
{LP}                { printToken("LP", yytext); }
{RP}                { printToken("RP", yytext); }
{ASGN}              { printToken("ASGN", yytext); }
{SC}                { printToken("SC", yytext); }
{OP2}               { printToken("OP2", yytext); }
{OP3}               { printToken("OP3", yytext); }
{OP4}               { printToken("OP4", yytext); }
{IF}                { printToken("IF", yytext); }
{THEN}              { printToken("THEN", yytext); }
{ELSE}              { printToken("ELSE", yytext); }
{BEGIN}             { printToken("BEGIN", yytext); }
{END}               { printToken("END", yytext); }
{WHILE}             { printToken("WHILE", yytext); }
{DO}                { printToken("DO", yytext); }
{PROGRAM}           { printToken("PROGRAM", yytext); }
{VAR}               { printToken("VAR", yytext); }
{AS}                { printToken("AS", yytext); }
{INT}               { printToken("INT", yytext); }
{BOOL}              { printToken("BOOL", yytext); }
{WRITEINT}          { printToken("WRITEINT", yytext); }
{READINT}           { printToken("READINT", yytext); }
{WHITESPACE}        {}
.                   { cerr << "Invalid token: " << yytext << endl; invalid++; }

%%

int main() {
    
    // fileName
    string fileName;

    // options for user, allows testing default, default with errors, a prewritten file, or typing in terminal
    cout << "Options: \n\tPress Enter to test the default success case";
    cout << "\n\tEnter the name of a file to read in. Example: MyProgram.txt";
    cout << "\n\tType \'type\' to write the program in the terminal. Typing \'END\' will begin lexical analysis";
    cout << "\n\nNote: If there is a file in the same folder as this program with the name of an option,";
    cout << "\nthe option will take precedence over that file. Additionally, your file to read in must be";
    cout << "\nfour or more letters. Choosing \'type\' needs to end with END. The file may then not compile";
    cout << "\ncorrectly, so go ahead and close out of the program and open up the .txt file you made and make";
    cout << "\nedits as needed.\n";
    getline(cin, fileName);

    string input;

    // no file chosen, use default, produces no errors
    if (fileName == "") {
        input = "program\n"
            "var SMALLER as int ;\n"
            "var BIGGER as int ;\n"
            "var TEMP as int ;\n"
            "\n"
            "begin\n"
            "BIGGER := readInt ;\n"
            "SMALLER := readInt ;\n"

            "if SMALLER > BIGGER then \n"
                "TEMP := SMALLER ;\n"
                "TEMP1 := 2147483648 ;\n"
                "SMALLER := BIGGER ;\n"
                "BIGGER := TEMP ;\n"
            "end ;\n"

            "while SMALLER > 0 do\n"
                "BIGGER := BIGGER - SMALLER ;\n"
                "if SMALLER > BIGGER then\n"
                    "TEMP := SMALLER ;\n"
                    "SMALLER := BIGGER ;\n"
                    "BIGGER := TEMP ;\n"
                "end ;\n"
            "end ;\n"
            "writeInt BIGGER ;\n"
        "end\n";
    }

    // failing lexical analysis, produces two errors, has ::= and $ to cause errors
    // could be elaborated upon in the future, 
    else if (fileName == "failure") {
        input = "program\n"
            "var SMALLER as $int ;\n"
            "var BIGGER as int ;\n"
            "var TEMP as int ;\n"
            "\n"
            "begin\n"
            "BIGGER ::= readInt ;\n"
            "SMALLER := readInt ;\n"

            "if SMALLER > BIGGER then \n"
                "TEMP := SMALLER ;\n"
                "TEMP1 := 2147483648 ;\n"
                "SMALLER := BIGGER ;\n"
                "BIGGER := TEMP ;\n"
            "end ;\n"

            "while SMALLER > 0 do\n"
                "BIGGER := BIGGER - SMALLER ;\n"
                "if SMALLER > BIGGER then\n"
                    "TEMP := SMALLER ;\n"
                    "SMALLER := BIGGER ;\n"
                    "BIGGER := TEMP ;\n"
                "end ;\n"
            "end ;\n"
            "writeInt BIGGER ;\n"
        "end\n";
    }

    // typing in terminal
    else if (fileName == "type") {

        while (fileName == "type" || fileName.length() < 4) {
            cout << "Enter title of program (must be four or more letters): ";
            getline(cin, fileName);
        }

        // add file extension if user did not
        if (fileName.substr(fileName.length() - 4, fileName.length()) != ".txt" || fileName.length() < 4) {
            fileName += ".txt";
        }
        
        // prepare for file input
        ofstream outFS(fileName.c_str());
        string line;
        int lineNum = 1;

        // file successfully opened/created begin writing
        if (outFS.is_open()) {

            // while END has not been submitted, keep writing
            while (line.substr(0, 3) != "END") {
                cout << lineNum << ": ";    // display line number
                getline(cin, line);         // get line
                outFS << line + "\n";       // write line to output file
                input += line + "\n";       // add line to be analyzed
                lineNum++;                  // increase line number
            }      
        }

        // file could not be opened, return with error
        else {
            cout << endl << fileName << " could not be opened.\n";
            cout << "Press enter to end program...";
            cin.get();
            return 1;
        }

        // close file
        outFS.close();

    }
    
    // file name was chosen
    else {

        // file has less than four letters
        if (fileName.length() < 4) {
            cout << fileName << " is less than four characters.\n";
            cout << "Press enter to end program...";
            cin.get();
            return 1;
        }

        // prepare to write in file
        ifstream inFS;
        string line;

        // add file extension if user did not
        if (fileName.substr(fileName.length() - 4, fileName.length()) != ".txt") {
            fileName += ".txt";
        }

        // open file
        inFS.open(fileName.c_str());

        // failure to open
        if (!inFS.is_open()) {
            cout << "Could not open " << fileName << endl;
            cout << "Press enter to end program...";
            cin.get();
            return 1;
        }

        // while there is more to write, keep writing
        while (inFS.good()) {
            getline(inFS, line);
            input += line + "\n";
        }

        // close file
        inFS.close();
    }

    // create buffer to read from input string
    YY_BUFFER_STATE buffer = yy_scan_string(input.c_str());

    // create an output file 
    string outputFileName = "output-" + fileName + ".txt";
    ofstream outputFile(outputFileName.c_str());

    // tokenize the input string
    yylex();

    // free buffer to move on
    yy_delete_buffer(buffer);

    // put the output in the output file
    outputFile << outputString;

    // count invalid tokens
    if (invalid > 0) { cout << "\nThere were " << invalid << " errors.\n"; }
    
    // no errors found, lexical analysis success
    else { cout << "\nLexical analysis successful. No errors found.\n\nSUCCESS\n"; }

    // stop for the executable
    cout << "Press enter to end program...";
    cin.get();

    outputFile.close();

    return 0;
}