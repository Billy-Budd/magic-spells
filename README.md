# [magic-spells](https://github.com/Billy-Budd/magic-spells/)
The super-repository for all of the parts and the final product of Compiler Design.
Please note that the README.md in the folders [flexicution](/flexicution) and [hip-to-be-square](/hip-to-be-square) are deprecated and the links are now broken that this is a super-repository including all versions of this project. Name here is a reference to [Crystal Castles](https://en.wikipedia.org/wiki/Crystal_Castles)' song [Magic Spells](https://genius.com/Crystal-castles-magic-spells-lyrics) which can be heard [here](https://youtu.be/fUTJa00puDU). Definitely one of my favorite electronic albums of all time, but programming and compilation are by no means 'magic.' 
As of [yakety-yak](/yakety-yak), the compiler has a makefile (please see each sub-header for more details) that creates the output jsgc which stands for John's Super Good Compiler. 
=========================================================================================
## [hip-to-be-square](/hip-to-be-square)
[Hip to be Square](https://en.wikipedia.org/wiki/Hip_to_Be_Square) is a [song](https://youtu.be/LB5YkmjalDg) by [Huey Lewis and the News](https://en.wikipedia.org/wiki/Huey_Lewis_and_the_News) and I had absolutely no reason to name it this as I cannot think of any connection that it has to the song. The only connection is that a compiler (that is being designed in this class) is taking code and making it 'square' by compiling it, but that is such a stretch that you might as well completely disregard this. 
==========================================Files==========================================
- [sample-input](/hip-to-be-square/input.txt): sample input
- [source](/hip-to-be-square/LexicalAnalysis.cpp): source code
- [executable](/hip-to-be-square/LexicalAnalysis.exe): if you are using an input file, make sure the file is in the same folder as the executable
- [requirements](/hip-to-be-square/assign1(1).docx): requirements for assignment
- [response](/hip-to-be-square/CS4386.501a01_JML190001.pdf): response to questions at the bottom of the requirements document
=========================================================================================
## [flexicution](/flexicution)
Project part 1A where we modify the earlier code (in this case, [hip-to-be-square](/hip-to-be-square)) to use flex to find tokens. The temporary name this had was [FlexicalAnalysis](/flexicution/FlexicaAnalysis.l) since the first part of the project was [LexicalAnalysis](/hip-to-be-square/LexicalAnalysis.cpp) and it felt very fitting. The only song that I knew had 'flex' in the tile is [Logic](https://en.wikipedia.org/wiki/Logic_(rapper))'s [Flexicution](https://en.wikipedia.org/wiki/Flexicution) which you can listen to [here](https://youtu.be/M2NIMHVmGwk). 
Program contains a menu that details its uses (but not the language that it compiles, please see [instructions](/flexicution/proj1a-instructions.docx) or [input.txt](/flexicution/input.txt)). It does not accept a parameter via the command line but I plan to add that in the next iteration of the project. 
==========================================Files==========================================
- [sample-input](/flexicution/1a-sample-input.docx): this is the raw sample input given from professor. This can be accessed directly in the program by executing the program, and pressing enter to use the base case text. 
- [response-doc](/flexicution/CS4386.501p01a_JML190001.pdf): this is a response doc answering some of the questions in the outline given by the professor.
- [FlexicalAnalysis.l](/flexicution/FlexicaAnalysis.l): I misnamed the file name and I am not keen on changing it now, but this is the source code of mixed lex and c/c++ code. 
- [README.md](/flexicution/README.md): deprecated. Please disregard.
- [input.txt](/flexicution/input.txt): this is [sample-input](/flexicution/1a-sample-input.docx) in file format that is easy to use for c/c++.
- [lex.yy.c](/flexicution/lex.yy.c): this is the compiled lex code (non-compiled c).
- [instructions](/flexicution/proj1a-instructions.docx): instructions given by professor.
=========================================================================================
## [yakety-yak](/yakety-yak)
[Yakety Yak](https://en.wikipedia.org/wiki/Yakety_Yak) is a [song](https://youtu.be/HRA3majpFXI) by [The Coasters](https://en.wikipedia.org/wiki/The_Coasters). The reason that I named it this is because (very logical reasoning incoming) bison which is like yak which is said the same as yacc. Personally, I really hate this song, and it frustrated me beyond belief while coding this because it was stuck in my head for almost six hours. 
Some important things to note about this are: 
- Usage: ./jsgc <file.txt>
- There is a makefile for convenience, compiles both files (creating a header file for the bison) and outputs the compiled code jsgc.
- The code is no longer in C++. The code is now entirely in C and uses gcc for compilation.
- The code no longer has the basic "user interface" that it had in [flexicution](/flexicution).
- There is no 'graceful' exit from typing directly into parser.
- Things typed directly into the parser are not saved.
- It does not create output files (as of 3/23/23, may be changed soon).
- The main function is now in the [bison file](/yakety-yak/yakety-yak.y).
- Program no longer outputs tokens like it did in [flexicution](/flexicution), outputs parse messages.
- Please note that the parse messages are displayed from depth first, following the bottom-most rule it can before showing the more general rules.
==========================================Files==========================================
- [response](/yakety-yak/CS4386.501p02a_JML190001.pdf) : has pictures of failing output and successful output
- [failure](/yakety-yak/failure.txt) : .txt file that will fail parsing
- [flexical-analysis](/yakety-yak/flexical-analysis.l) : lex file with tokens (mostly unmodified, other than main being moved)
- [lex-file](/yakety-yak/lex.yy.c) : compiled lex with flex
- [Makefile](/yakety-yak/Makefile) : Makefile with make clean functionality
- [sample](/yakety-yak/sample.txt) : .txt file that will successfully parse
- [yakety-yak-c](/yakety-yak/yakety-yak.tab.c) : [yakety-yak.y](/yakety-yak/yakety-yak.y) compiled file in c (compiled with bison)
- [yakety-yak-h](/yakety-yak/yakety-yak.tab.h) : [yakety-yak.y](/yakety-yak/yakety-yak.y) compiled file in c, header file (compiled with bison)
- [yakety-yak](/yakety-yak/yakety-yak.y) : source .y bison file for parsing
- [CFG](/flexicution/proj1a-instructions.docx) : document with the grammar
