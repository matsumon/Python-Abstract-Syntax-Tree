%{
  #include <iostream>
  #include <set>

  #include "parser.hpp"


  extern int yylex();
  void yyerror(YYLTYPE* loc, const char* err);
  std::string* translate_boolean_str(std::string* boolean_str);

  /*
   * Here, target_program is a string that will hold the target program being
   * generated, and symbols is a simple symbol table.
   */
  std::string* target_program;
  std::set<std::string> symbols;
  Tree * root;
%}

%code requires{
  #include "tree.hpp"
}
/* Enable location tracking. */
%locations

/*
 * All program constructs will be represented as strings, specifically as
 * their corresponding C/C++ translation.
 */
// %define api.value.type { std::string* }
%union{
  std::string* str;
  Tree * node;
}
/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */
%define api.pure full
%define api.push-pull push

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */
%token <str> IDENTIFIER FLOAT  INTEGER  BOOLEAN INDENT  DEDENT  NEWLINE
%token <node> DEF  ELIF  ELSE  FOR  IF  NOT  OR  ETURN  WHILE ASSIGN AND  BREAK
%token <node> PLUS  MINUS  TIMES  DIVIDEDBY EQ  NEQ  GT  GTE  LT  LTE LPAREN  RPAREN  COMMA  COLON RETURN

%type <node> program statements statement while_statement if_statement elif_blocks else_block
%type <node>  break_statement condition assign_statement expression block negated_expression primary_expression
/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */
%left OR
%left AND
%right NOT
%left EQ NEQ GT GTE LT LTE
%left PLUS MINUS
%left TIMES DIVIDEDBY

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */

/*
 * This is the goal/start symbol.  Once all of the statements in the entire
 * source program are translated, this symbol receives the string containing
 * all of the translations and assigns it to the global target_program, so it
 * can be used outside the parser.
 */
program
  : statements {
      root = $1;
    }
  ;

/*
 * The `statements` symbol represents a set of contiguous statements.  It is
 * used to represent the entire program in the rule above and to represent a
 * block of statements in the `block` rule below.  The second production here
 * simply concatenates each new statement's translation into a running
 * translation for the current set of statements.
 */
statements
  : statement { $$ = $1;
      Tree * temp = new Tree("STATEMENT", "");
      temp->block.push_back($1);
      $$ = temp;
  }
  | statements statement {
      // $$ = new std::string(*$1 + *$2); delete $1; delete $2;
      Tree * temp = new Tree("STATEMENT", "");
      temp->block.push_back($1);
      temp->block.push_back($2);
      $$ = temp;
    }
  ;

/*
 * This is a high-level symbol used to represent an individual statement.
 */
statement
  : assign_statement { $$ = $1; }
  | if_statement { $$ = $1; }
  | while_statement { $$ = $1; }
  | break_statement { $$ = $1; }
  ;

/*
 * A primary expression is a "building block" of an expression.
 */
primary_expression
  : IDENTIFIER {
        Tree * temp =new Tree("IDENTIFIER", *$1);
        $$ = temp;
      }
  | FLOAT {
        Tree * temp =new Tree("FLOAT", *$1);
        $$ = temp;
      }
  | INTEGER {
        Tree * temp =new Tree("INTEGER", *$1);
        $$ = temp;
      }
  | BOOLEAN {
        Tree * temp =new Tree("BOOLEAN", *translate_boolean_str($1));
        $$ = temp;
      }
  | LPAREN expression RPAREN {
        Tree * temp =new Tree("PARENTHESES", "");
        $$ = temp;
      }
  ;

/*
 * Symbol representing a boolean "not" operation.
 */
negated_expression
  : NOT primary_expression {
        // Tree * temp =new Tree("NOT", NULL, $2, NULL);
        Tree * temp =new Tree("NOT", NULL);
        temp->child.push_back($2);
        $$ = temp;
      }
  ;

/*
 * Symbol representing algebraic expressions.  For most forms of algebraic
 * expression, we generate a translated string that simply concatenates the
 * C++ translations of the operands with the C++ translation of the operator.
 */
expression
  : primary_expression { $$ = $1; }
  | negated_expression { $$ = $1; }
  | expression PLUS expression {
      //$$ = new std::string(*$1 + " + " + *$3); delete $1; delete $3;
      Tree * temp =new Tree("PLUS","");
      temp->child.push_back($1);
      temp->child.push_back($3);
      $$ = temp;
     }
  | expression MINUS expression {
      //$$ = new std::string(*$1 + " - " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("MINUS", "", $1, $3);
      Tree * temp =new Tree("MINUS", "");
      temp->child.push_back($1);
      temp->child.push_back($3);
      $$ = temp;
     }
  | expression TIMES expression {
      //$$ = new std::string(*$1 + " * " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("TIMES", "", $1, $3);
      Tree * temp =new Tree("TIMES", "");
      temp->child.push_back($1);
      temp->child.push_back($3);
      $$ = temp;
     }
  | expression DIVIDEDBY expression {
      //$$ = new std::string(*$1 + " / " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("DIVIDEDBY", "", $1, $3);;
      Tree * temp =new Tree("DIVIDEDBY", "");
      temp->child.push_back($1);
      temp->child.push_back($3);
      $$ = temp;
     }
  | expression EQ expression {
      //$$ = new std::string(*$1 + " == " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("EQ", "", $1, $3);;
      Tree * temp =new Tree("EQ", "");
      temp->child.push_back($1);
      temp->child.push_back($3);      
      $$ = temp;
     }
  | expression NEQ expression {
      //$$ = new std::string(*$1 + " != " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("NEQ", "", $1, $3);;
      Tree * temp =new Tree("NEQ", "");
      temp->child.push_back($1);
      temp->child.push_back($3);      
      $$ = temp;
     }
  | expression GT expression {
      //$$ = new std::string(*$1 + " > " + *$3); delete $1; delete $3;
      Tree * temp =new Tree("GT", "");
      temp->child.push_back($1);
      temp->child.push_back($3);
      $$ = temp;
     }
  | expression GTE expression {
      //$$ = new std::string(*$1 + " >= " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("GTE", "", $1, $3);;
      Tree * temp =new Tree("GTE", "");
      temp->child.push_back($1);
      temp->child.push_back($3);      
      $$ = temp;
     }
  | expression LT expression {
      //$$ = new std::string(*$1 + " < " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("LT", "", $1, $3);;
      Tree * temp =new Tree("LT", "");
      temp->child.push_back($1);
      temp->child.push_back($3);      
      $$ = temp;
     }
  | expression LTE expression {
      //$$ = new std::string(*$1 + " <= " + *$3); delete $1; delete $3;
      // Tree * temp =new Tree("LTE", "", $1, $3);;
      Tree * temp =new Tree("LTE", "");
      temp->child.push_back($1);
      temp->child.push_back($3);      
      $$ = temp;
     }
  ;

/*
 * This symbol represents an assignment statement.  For each assignment
 * statement, we first make sure to insert the LHS identifier into the symbol
 * table, since it is potentially a new symbol.  Then, we generate a C++
 * translation for the whole assignment by combining the C++ translations of
 * the LHS and the RHS along with an equals sign and a semi-colon, to make sure
 * we have proper C++ punctuation.
 */
assign_statement
  : IDENTIFIER ASSIGN expression NEWLINE {
      //symbols.insert(*$1); $$ = new std::string(*$1 + " = " + *$3 + ";\n");
      //delete $1; delete $3;
      Tree * id =new Tree("IDENTIFIER", *$1);
      // Tree * temp =new Tree("AssignmentStatement", "", id, $3);
      Tree * temp =new Tree("AssignmentStatement", "");
      temp->child.push_back(id);
      temp->child.push_back($3);
      // Tree * temp =new Tree("AssignmentStatement", *$1, $3, NULL);
      $$ = temp;
    }
  ;

/*
 * A `block` represents the collection of statements associated with an
 * if, elif, else, or while statement.  The C++ translation for a block of
 * statements is wrapped in curly braces ({}) instead of INDENT and DEDENT.
 */
block
  : INDENT statements DEDENT {
      //$$ = new std::string("{\n" + *$2 + "}"); delete $2;
      Tree * temp =new Tree("block", "");
      temp->child.push_back($2);
      $$ = temp;
     }
  ;

/*
 * This symbol represents a boolean condition, used with an if, elif, or while.
 * The C++ translation of a condition concatenates the C++ translations of its
 * operators with one of the C++ boolean operators && or ||.
 */
condition
  : expression { $$ = $1; }
  | condition AND condition {
      //$$ = new std::string(*$1 + " && " + *$3); delete $1; delete $3;
      Tree * temp =new Tree("AND", "AND");
      temp->child.push_back($1);
      temp->child.push_back($3);
      $$ = temp;
    }
  | condition OR condition {
      //$$ = new std::string(*$1 + " || " + *$3); delete $1; delete $3;
      Tree * temp =new Tree("OR", "OR");
      temp->child.push_back($1);
      temp->child.push_back($3);
      $$ = temp;
    }
  ;

/*
 * This symbol represents an entire if statement, including optional elif
 * blocks and an optional else block.  The C++ translations for the blocks
 * are simply combined here into one larger translation, and the if condition
 * is wrapped in parentheses, as is required in C++.
 */
if_statement
  : IF condition COLON NEWLINE block elif_blocks else_block {
      //$$ = new std::string("if (" + *$2 + ") " + *$5 + *$6 + *$7 + "\n"); delete $2; delete $5; delete $6; delete $7;
      // Tree * temp =new Tree("IF_STATEMENT", "", $2, NULL);
      Tree * temp =new Tree("IF_STATEMENT", "");
      temp->child.push_back($2);
      temp->child.push_back($5);
      temp->child.push_back($6);
      temp->child.push_back($7);
      $$ = temp;
    }
  ;

/*
 * This symbol represents zero or more elif blocks to be attached to an if
 * statement.  When a new elif block is recognized, the Pythonic "elif" is
 * translated to the C++ "else if", and the condition is wrapped in parens.
 */
elif_blocks
  : %empty {
      //$$ = new std::string("");
      $$ = NULL;
    }
  | elif_blocks ELIF condition COLON NEWLINE block {
      //$$ = new std::string(*$1 + " else if (" + *$3 + ") " + *$6); delete $1; delete $3; delete $6;
      Tree * temp =new Tree("ELIF_BLOCKS", "");
      temp->block.push_back($1);
      temp->child.push_back($6);
      temp->child.push_back($3);
      $$ = temp;
    }
  ;

/*
 * This symbol represents an if statement's optional else block.
 */
else_block
  : %empty {
      //$$ = new std::string("");
      $$ = NULL;
    }
  | ELSE COLON NEWLINE block {
      //$$ = new std::string(" else " + *$4); delete $4;
      Tree * temp =new Tree("ELSE", "");
      temp->child.push_back($4);
      $$ = temp;
    }


/*
 * This symbol represents a while statement.  The C++ translation wraps the
 * while condition in parentheses.
 */
while_statement
  : WHILE condition COLON NEWLINE block {
      //$$ = new std::string("while (" + *$2 + ") " + *$5 + "\n"); delete $2; delete $5;
      Tree * temp =new Tree("ELSE", "");
      temp->child.push_back($5);
      temp->child.push_back($2);
      $$ = temp;
    }
  ;

/*
 * This symbol represents a break statement.  The C++ translation simply adds
 * a semicolon.
 */
break_statement
  : BREAK NEWLINE {
      //$$ = new std::string("break;\n");
      Tree * temp =new Tree("BREAK", "");
      $$ = temp;
      }
  ;

%%

/*
 * This is our simple error reporting function.  It prints the line number
 * and text of each error.
 */
void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

/*
 * This function translates a Python boolean value into the corresponding
 * C++ boolean value.
 */
std::string* translate_boolean_str(std::string* boolean_str) {
  if (*boolean_str == "True") {
    return new std::string("true");
  } else {
    return new std::string("false");
  }
}
