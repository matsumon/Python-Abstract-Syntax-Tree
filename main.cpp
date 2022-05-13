#include <iostream>
#include <set>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <sstream>
#include "parser.hpp"

extern int yylex();
extern Tree * root;

/*
 * These values are globals defined in the parsing function.
 */
extern std::string* target_program;
extern std::set<std::string> symbols;
int a = 0;
void print_node(std::string variable_name, std::string node_value){
  std::cout<<variable_name<<" "<<"[label=\""<<node_value<<"\"];\n"<<std::endl;

}
void print_connection(std::string child, std::string parent){
  std::cout<<parent<<" -> "<<child<<";\n"<<std::endl;
}
void print_tree(Tree *node,std::string parent){
  std::string current_node;
  if(node == NULL){
    return;
  }
    std::ostringstream stm ;
    stm << a ;
    current_node = node->node_type + stm.str();
    a++;
    if(node->node_type != "STATEMENT"){
      print_node(current_node, node->node_type);
      print_connection(current_node,parent);
    }
    if(node->value.size() > 0 && node->node_type != "STATEMENT"){
        std::ostringstream stm ;
        stm << a;
        std::string node_value = "var" + stm.str();
        a++;
      print_node(node_value, node->value);
      print_connection(node_value,current_node);
    }
    for (std::vector<Tree *>::iterator it = node->block.begin() ; it != node->block.end(); it++){
      print_tree(*it,parent);
    }
    for (std::vector<Tree *>::iterator it = node->child.begin() ; it != node->child.end(); it++){
      print_tree(*it,current_node);
    }
    // print_tree(node->left_node,current_node);
    // print_tree(node->right_node,current_node);
  // else{
  //     std::ostringstream stm ;
  //     stm << a ;
  //     current_node = node->node_type + stm.str();
  //     a++;
  //     print_node(current_node, node->node_type);
  //     print_connection(current_node,parent);
  // }
  // if(node->value.size() > 0){
  //     std::ostringstream stm ;
  //     stm << a;
  //     std::string node_value = "var" + stm.str();
  //     a++;
  //   print_node(node_value, node->value);
  //   print_connection(node_value,current_node);
  // }
  // print_tree(node->left_node,current_node);
  // print_tree(node->right_node,current_node);
  // if(node->block.size() == 0){
  //    return;
  // }
  // for (std::vector<Tree *>::iterator it = node->block.begin() ; it != node->block.end(); it++){
  //   print_tree(*it,parent);
  // }
}

int main() {
  if (!yylex()) {
    /*
     * Write initial C++ boilerplate stuff.
     */
    // std::cout << "#include <iostream>" << std::endl;
    // std::cout << "int main() {" << std::endl;

    /*
     * Write a declaraction for each variable in the symbol table.  Treat all
     * variables as `double`.
     */
    // std::set<std::string>::iterator it;
    // for (it = symbols.begin(); it != symbols.end(); it++) {
    //   std::cout << "double " << *it << ";" << std::endl;
    // }

    /*
     * Write the translated program statements.
     */
    // std::cout << std::endl << "/* Begin program */" << std::endl << std::endl;
    // std::cout << *target_program << std::endl;
       std::cout << "digraph G {" << std::endl;
    print_tree(root,"block");
 //     std::cout << "HERE" << root->node_type << std::endl;
    // std::cout << "/* End program */" << std::endl << std::endl;

    /*
     * Write a print statement for each symbol in the symbol table.
     */
    // for (it = symbols.begin(); it != symbols.end(); it++) {
    //   std::cout << "std::cout << \"" << *it << ": \" << " << *it << " << std::endl;" << std::endl;
    // }

    /*
     * Write the terminating brace for main().
     */
    std::cout << "}" << std::endl;

    // delete target_program;
    // target_program = NULL;

  }
}
