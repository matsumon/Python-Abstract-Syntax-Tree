#include <iostream>
#include <set>
#include "parser.hpp"

extern int yylex();

/*
 * These values are globals defined in the parsing function.
 */
extern std::string* target_program;
extern std::set<std::string> symbols;

int main() {
  if (!yylex()) {
    /*
     * Write initial C++ boilerplate stuff.
     */
    std::cout << "#include <iostream>" << std::endl;
    std::cout << "int main() {" << std::endl;

    /*
     * Write a declaraction for each variable in the symbol table.  Treat all
     * variables as `double`.
     */
    std::set<std::string>::iterator it;
    for (it = symbols.begin(); it != symbols.end(); it++) {
      std::cout << "double " << *it << ";" << std::endl;
    }

    /*
     * Write the translated program statements.
     */
    std::cout << std::endl << "/* Begin program */" << std::endl << std::endl;
    std::cout << *target_program << std::endl;
    std::cout << "/* End program */" << std::endl << std::endl;

    /*
     * Write a print statement for each symbol in the symbol table.
     */
    for (it = symbols.begin(); it != symbols.end(); it++) {
      std::cout << "std::cout << \"" << *it << ": \" << " << *it << " << std::endl;" << std::endl;
    }

    /*
     * Write the terminating brace for main().
     */
    std::cout << "}" << std::endl;

    delete target_program;
    target_program = NULL;

  }
}
