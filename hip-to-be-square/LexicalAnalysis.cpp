/* LexicalAnalysis.cpp
 * JML190001 - John Lawler
 * CS4386.501 Assignment One
 * 02/19/23
 * Program receives input as a string through either a
 * text file, typed directly into the terminal, or uses one of its default programs
 * (see main for more details). Program then uses a DFA to determine whether or not to 
 * accept characters as tokens and adds it to a vector of Tokens (a struct containing
 * the enumerated type TokenType and a string). It then spits back out the associated
 * tokens and lexemes, and whether or not the analysis was successful. 
 */


#include <iostream>
#include <string>
#include <cctype>
#include <vector>
#include <fstream>
using namespace std;

// Token type that encompasses all tokens in language, 
// including invalid for any invalid tokens
enum TokenType {
    TAGS,
    BEGIN,
    SEQUENCE,
    INTEGER,
    DATE,
    END,
    RANGE_SEPARATOR,
    ASSIGN, 
    LCURLY,
    RCURLY,
    COMMA,
    LPAREN,
    RPAREN,
    TYPEREF,
    IDENTIFIER,
    NUMBER,
    INVALID,
    HORIZONTAL_TABULATION,
    LINE_FEED,
    VERTICAL_TABULATION,
    FORM_FEED,
    CARRIAGE_RETURN,
    SPACE,
    VERTICAL_LINE
};

// Token struct of TokenType token, string lexeme
// Includes constructor for the struct
struct Token {
    TokenType token;
    string lexeme;

    Token(TokenType type, std::string value) : token(type), lexeme(value) {}
};

// function prototypes
vector<Token> lex(string);
string getTokenName(TokenType);


int main() {

    string fileName;

    // options for user, allows testing default, default with errors, a prewritten file, or typing in terminal
    cout << "Options: \n\tPress Enter to test the default success case";
    cout << "\n\tEnter the name of a file to read in. Example: MyProgram.txt";
    cout << "\n\tType \'failure\' to see an example of a failed string";
    cout << "\n\tType \'type\' to write the program in the terminal. Typing \'END\' will begin lexical analysis";
    cout << "\n\nNote: If there is a file in the same folder as this program with the name of an option,";
    cout << "\nthe option will take precedence over that file. Additionally, your file to read in must be";
    cout << "\nfour or more letters.\n";
    getline(cin, fileName);

    string input;

    // no file chosen, use default
    if (fileName == "") {
        input = "MyShopPurchaseOrders   TAGS   ::=   BEGIN\n"
            "\n"
            "PurchaseOrder ::= SEQUENCE {\n"
            "dateOfOrder DATE,\n"
            "customer    CustomerInfo,\n"
            "items       ListOfItems\n"
            "}\n"
            "\n"
            "Item ::= SEQUENCE {\n"
            "itemCode        INTEGER ( 1 .. 99999 ) ,\n"
            "power           INTEGER ( 110 | 220 ) ,\n"
            "deliveryTime    INTEGER ( 8 .. 12 | 14 .. 19 ) ,\n"
            "quantity        INTEGER ( 1 .. 1000 ) ,\n"
            "unitPrice       INTEGER ( 1 .. 9999 ) ,\n"
            "}\n"
            "END";
    }

    // failing lexical analysis
    else if (fileName == "failure") {
        input = "MyShopPurchaseOrders   TAGS   ::=   BEGIN\n"
            "\n"
            "%PurchaseOrder ::= SEQUENCE {\n"
            "dateOfOrder DATE,\n"
            "customer    CustomerInfo,\n"
            "items       ListOfItems\n"
            "}\n"
            "\n"
            "Item ::= SEQUENCE {\n"
            "itemCode     %  INTEGER ( 1 .. 99999 ) ,\n"
            "power           INTEGER ( 110 | 220 ) ,\n"
            "deliveryTime    INTEFER ( 8 .. 12 | 14 .. 19 ) ,\n"
            "quantity        INTEGER ( 1 ... 1000 ) ,\n"
            "unitPrice   :   INTEGER ( 1 .. 9999 ) ,\n"
            "}\n%\n"
            "END";
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
        ofstream outFS(fileName);
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
        inFS.open(fileName);

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
    

    // perform lexical analysis
    vector<Token> tokens = lex(input);

    // number of invalid tokens
    int invalid = 0;

    // print the tokens
    for (Token token : tokens) {

        // get token name instead of enumerated number
        string tokenName = getTokenName(token.token);
        
        // invalid token enumeration
        if (token.token == 16) { invalid++; }

        // print out the lexeme and token name 
        cout << token.lexeme << " (" << tokenName << ")" << endl;
    }
    
    // errors found
    if (invalid > 0) { cout << "\nThere were " << invalid << " errors.\n"; }
    
    // no errors found, lexical analysis success
    else { cout << "\nLexical analysis successful. No errors found.\n\nSUCCESS\n"; }

    cout << "Press enter to end program...";
    cin.get();

    return 0;
}

/* Function takes in the string input and returns a vector of tokens with their token types
 * and their lexemes. Since there are not an inordinate amount of token types, the function
 * uses a DFA to determine the token type and whether or not it is invalid. This is accomplished
 * by using a vector and looping through the vector and accounting for tokens accordingly. 
 */
vector<Token> lex(string input) {

    // prepare to analyze vector
    vector<Token> tokens;
    int i = 0;

    // loop while there are more characters to analyze
    while (i < input.length()) {

        // handle alphabetical lexemes 
        if (isalpha(input[i])) {

            // collect entire word from input, accounting for hyphens as well
            string word = "";
            while (isalnum(input[i]) || input[i] == '-') { word += input[i]; i++; }

            // reserved words, and add them to vector
            if      (word == "TAGS") {     tokens.push_back(Token(TokenType::TAGS,     word)); }
            else if (word == "BEGIN") {    tokens.push_back(Token(TokenType::BEGIN,    word)); }
            else if (word == "SEQUENCE") { tokens.push_back(Token(TokenType::SEQUENCE, word)); }
            else if (word == "INTEGER") {  tokens.push_back(Token(TokenType::INTEGER,  word)); }
            else if (word == "DATE") {     tokens.push_back(Token(TokenType::DATE,     word)); }
            else if (word == "END") {      tokens.push_back(Token(TokenType::END,      word)); }

            // determine if the word is an identifier or a typeref, and add to vector
            else {
                if (isupper(word[0])) { tokens.push_back(Token(TokenType::TYPEREF,    word)); }
                else                  { tokens.push_back(Token(TokenType::IDENTIFIER, word)); }
            }
        }

        // handle numbers
        else if (isdigit(input[i])) {

            // collect entire number from input
            string number = "";
            while (isdigit(input[i])) { number += input[i]; i++; }

            // add number to vector
            tokens.push_back(Token(TokenType::NUMBER, number));
        }

        // all other special characters are handled here
        else {
            switch (input[i]) {

            // handle :, must be ::= or else it is an invalid token, add to vector
            case ':':
                if (input.substr(i, 3) == "::=") { tokens.push_back(Token(TokenType::ASSIGN,  "::=")); i += 2; } // only 2 because there is a +1 after break
                else                             { tokens.push_back(Token(TokenType::INVALID, "")); }
                break;

            // handle ., must be .. or else it is an invalid token, add to vector
            case '.':
                if (input.substr(i, 2) == "..") { tokens.push_back(Token(TokenType::RANGE_SEPARATOR, "..")); i++; }
                else                            { tokens.push_back(Token(TokenType::INVALID,         "")); }
                break;

            // add whitespace to vector
            case ' ':  tokens.push_back(Token(TokenType::SPACE,                 " "));         break;
            case '\t': tokens.push_back(Token(TokenType::HORIZONTAL_TABULATION, "ASCII: 9"));  break;
            case '\n': tokens.push_back(Token(TokenType::LINE_FEED,             "ASCII: 10")); break;
            case '\v': tokens.push_back(Token(TokenType::VERTICAL_TABULATION,   "ASCII: 11")); break;
            case '\f': tokens.push_back(Token(TokenType::FORM_FEED,             "ASCII: 12")); break;
            case '\r': tokens.push_back(Token(TokenType::CARRIAGE_RETURN,       "ASCII: 13")); break;
            

            // add { } , ( ) | to vector
            case '{': tokens.push_back(Token(TokenType::LCURLY,        "{")); break;
            case '}': tokens.push_back(Token(TokenType::RCURLY,        "}")); break;
            case ',': tokens.push_back(Token(TokenType::COMMA,         ",")); break;
            case '(': tokens.push_back(Token(TokenType::LPAREN,        "(")); break;
            case ')': tokens.push_back(Token(TokenType::RPAREN,        ")")); break;
            case '|': tokens.push_back(Token(TokenType::VERTICAL_LINE, "|")); break;

            // character is invalid, add that token to vector and attempt to add that character 
            default:
                string invalid; invalid += input[i];
                tokens.push_back(Token(TokenType::INVALID, invalid));
                break;
            }
            i++;
        }
    }

    // return vector when done
    return tokens;
}

/* Function receives a token and changes it from an integer to 
 * a string so that output is more understandable 
 */
string getTokenName(TokenType token) {
    string tokenName;

    switch (token) {
    case 0:  tokenName = "TAGS";                  break;
    case 1:  tokenName = "BEGIN";                 break;
    case 2:  tokenName = "SEQUENCE";              break;
    case 3:  tokenName = "INTEGER";               break;
    case 4:  tokenName = "DATE";                  break;
    case 5:  tokenName = "END";                   break;
    case 6:  tokenName = "RANGE_SEPARATOR";       break;
    case 7:  tokenName = "ASSIGN";                break;
    case 8:  tokenName = "LCURLY";                break;
    case 9:  tokenName = "RCURLY";                break;
    case 10: tokenName = "COMMA";                 break;
    case 11: tokenName = "LPAREN";                break;
    case 12: tokenName = "RPAREN";                break;
    case 13: tokenName = "TYPEREF";               break;
    case 14: tokenName = "IDENTIFIER";            break;
    case 15: tokenName = "NUMBER";                break;
    case 16: tokenName = "INVALID";               break;
    case 17: tokenName = "HORIZONTAL_TABULATION"; break;
    case 18: tokenName = "LINE_FEED";             break;
    case 19: tokenName = "VERTICAL_TABULATION";   break;
    case 20: tokenName = "FORM_FEED";             break;
    case 21: tokenName = "CARRIAGE_RETURN";       break;
    case 22: tokenName = "SPACE";                 break;
    case 23: tokenName = "VERTICAL_LINE";         break;
    }

    return tokenName;
}