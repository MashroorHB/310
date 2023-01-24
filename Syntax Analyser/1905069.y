%{
#include<bits/stdc++.h>
#include "1905069_symbol_info.h"
#include "1905069_symbol_table.h"
using namespace std;
//#define YYSTYPE SymbolInfo*      /* yyparse() stack type */

ofstream parseout;
ofstream logout;
ofstream errorout;


SymbolTable* st;
SymbolInfo* funcparams = new SymbolInfo();

extern int line_count;
extern int error_count;
extern FILE *yyin;

//small functions

string ruleOf(vector<SymbolInfo*> SI){
	string name = "";
	for(auto si: SI){
		name += " ";
		name += si->getType();
	}
	return name;
}

void printError(string s){
	errorout<< "Line# "<< line_count<< ": "<< s<< endl;
	error_count++;
}

string typeCast(SymbolInfo* a,SymbolInfo* b){
	if(a->getTypeSpecifier() == "error" or b->getTypeSpecifier() == "error" or a->getTypeSpecifier() == "VOID"  or b->getTypeSpecifier() == "VOID"  ) return "error"; 
	if(a->getTypeSpecifier() == "FLOAT" or b->getTypeSpecifier() == "FLOAT" ) return "FLOAT";
	return "INT";
}

void voidError1(SymbolInfo* a){
	if(a->getTypeSpecifier()=="VOID") printError("Variable or field '"+ a->getName()+"' declared void");
}
void voidError2(SymbolInfo* a){
	printError("Void cannot be used in expression "); 
	a->setTypeSpecifier("error");
	return;
}

void checkFuncDeclared(SymbolInfo* funcName, SymbolInfo* funcType){
	funcName->setTypeSpecifier(funcType->getTypeSpecifier());
	funcName->setParameterList(funcparams->getParameterList());
	funcName->setIsFunction(true);

	if( st->insert(funcName)) return;
	
	SymbolInfo* oldFunc = st->lookUp(funcName->getName());
	if( !oldFunc->getIsDeclared() ){
		printError("\'"+funcName->getName()+"\' redeclared as different kind of symbol");
	}else{
		if( oldFunc->getTypeSpecifier() != funcName->getTypeSpecifier() ){
			printError("Conflicting types for \'"+funcName->getName()+"\'");
		}
		if( oldFunc->getParameterList().size() != funcName->getParameterList().size() ){
			printError("Conflicting types for \'"+funcName->getName()+"\'");
		}else{
			vector<SymbolInfo*> declaredArgs = oldFunc->getParameterList();
			vector<SymbolInfo*> definedArgs = funcName->getParameterList();
			for(int i=0;i<declaredArgs.size();i++){
				if( declaredArgs[i]->getTypeSpecifier() != definedArgs[i]->getTypeSpecifier()){
					printError("Type mismatch for argument "+to_string(i+1)+" of '"+funcName->getName()+"'");
				}
			}
		}
	}
	
}


void yyerror(char *s){
	printf("%s\n",s);
}

int yylex(void);


%}


%union{
    SymbolInfo* si; 
}

%token<si> NEWLINE CONST_FLOAT CONST_INT CONST_CHAR IF FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTLN ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL COMMA SEMICOLON ID
%type<si> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments lcurl error

%%
start				: program							{ $$ = new SymbolInfo(ruleOf({$1}),"start","",$1->getStart(),$1->getEnd(),false,logout, {$1});
														$$->printParseTree(0,parseout); 
														logout<< "Total Lines: "<< line_count<< endl<< "Total Errors: "<< error_count<< endl; }
					;
program				: program unit						{ $$ = new SymbolInfo(ruleOf({$1,$2}),"program","",$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); }
    				| unit								{ $$ = new SymbolInfo(ruleOf({$1}),"program","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
    				;
unit				: var_declaration					{ $$ = new SymbolInfo(ruleOf({$1}),"unit","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| func_declaration					{ $$ = new SymbolInfo(ruleOf({$1}),"unit","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| func_definition					{ $$ = new SymbolInfo(ruleOf({$1}),"unit","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| error								{ yyclearin; yyerrok; printError("Syntax error at unit"); 
														$$ = new SymbolInfo("error","unit","",line_count,line_count,true,logout, {$1}); }
					;
func_declaration	: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON			{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5,$6}),"func_declaration","",$1->getStart(),$6->getEnd(),false,logout, {$1,$2,$3,$4,$5,$6}); 
																						$2->setTypeSpecifier($1->getTypeSpecifier()); 
																						$2->setIsDeclared(true); 
																						$2->setParameterList($4->getParameterList()); 
																						funcparams->setParameterList({}); 
																						st->insert($2); }
					| type_specifier ID LPAREN error RPAREN SEMICOLON					{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5,$6}),"func_declaration","",$1->getStart(),$6->getEnd(),false,logout, {$1,$2,$3,$4,$5,$6}); 
																						$2->setTypeSpecifier($1->getTypeSpecifier()); 
																						$2->setIsDeclared(true); 
																						funcparams->setParameterList({}); 
																						st->insert($2); }
					| type_specifier ID LPAREN RPAREN SEMICOLON							{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5}),"func_declaration","",$1->getStart(),$5->getEnd(),false,logout, {$1,$2,$3,$4,$5}); 
																						$2->setTypeSpecifier($1->getTypeSpecifier()); 
																						$2->setIsDeclared(true); 
																						st->insert($2); }
					;
func_definition		: type_specifier ID LPAREN parameter_list RPAREN { checkFuncDeclared($2,$1); } compound_statement	{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5,$7}),"func_definition","",$1->getStart(),$7->getEnd(),false,logout, {$1,$2,$3,$4,$5,$7}); }
					| type_specifier ID LPAREN error RPAREN { checkFuncDeclared($2,$1); } compound_statement			{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5,$7}),"func_definition","",$1->getStart(),$7->getEnd(),false,logout, {$1,$2,$3,$4,$5,$7}); printError("Syntax error at func_definition"); }
					| type_specifier ID LPAREN RPAREN { checkFuncDeclared($2,$1); } compound_statement					{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$6}),"func_definition","",$1->getStart(),$6->getEnd(),false,logout, {$1,$2,$3,$4,$6}); }
					;
parameter_list		: parameter_list COMMA type_specifier ID							{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4}),"parameter_list","",$1->getStart(),$4->getEnd(),false,logout, {$1,$2,$3,$4}); 
																						$$->setParameterList($1->getParameterList()); 
																						$$->addParameter($4); 
																						$4->setTypeSpecifier($3->getTypeSpecifier()); 
																						funcparams->setParameterList($$->getParameterList()); 
																						voidError1($3); }
					| parameter_list COMMA type_specifier								{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"parameter_list","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); 
																						SymbolInfo* body = new SymbolInfo("","ID"); 
																						$$->setParameterList($1->getParameterList()); 
																						$$->addParameter(body);  
																						body->setTypeSpecifier($3->getTypeSpecifier()); 
																						funcparams->setParameterList($$->getParameterList()); 
																						voidError1($3); }
					| type_specifier ID					{ $$ = new SymbolInfo(ruleOf({$1,$2}),"parameter_list","",$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); 
														$2->setTypeSpecifier($1->getTypeSpecifier()); 
														$$->addParameter($2); 
														funcparams->setParameterList($$->getParameterList()); 
														voidError1($1); }
					| type_specifier					{ $$ = new SymbolInfo(ruleOf({$1}),"parameter_list","",$1->getStart(),$1->getEnd(),false,logout, {$1}); 
														SymbolInfo* body = new SymbolInfo("","ID"); 
														body->setTypeSpecifier($1->getTypeSpecifier()); 
														$$->addParameter(body); 
														funcparams->setParameterList($$->getParameterList()); 
														voidError1($1); }
					| error								{ yyclearin; yyerrok; printError("Syntax error at parameter list of function definition"); 
														$$ = new SymbolInfo("error","parameter_list","",line_count,line_count,true,logout, {$1}); }
					;
compound_statement	: lcurl statements RCURL			{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"compound_statement","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); st->print(logout); st->exitScope(); }
					| lcurl error RCURL					{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"compound_statement","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); st->print(logout); st->exitScope(); }
					| lcurl RCURL						{ $$ = new SymbolInfo(ruleOf({$1,$2}),"compound_statement","",$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); st->print(logout); st->exitScope(); }
					;
var_declaration		: type_specifier declaration_list SEMICOLON							{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"var_declaration","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3});
																						for(auto a : $2->getDeclarationList()){ 
																							a->setTypeSpecifier($1->getTypeSpecifier()); 
																							if(a->getTypeSpecifier()=="VOID") printError("Variable or field '"+ a->getName()+"' declared void");
																							else if(!st->insert(a)) printError("Conflicting types for \'"+a->getName()+"\'");	
																						}  }
					| type_specifier error SEMICOLON 	{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"var_declaration","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3});
														printError("Syntax error at var_declaration"); }
					;
type_specifier		: INT								{ $$ = new SymbolInfo(ruleOf({$1}),"type_specifier",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| FLOAT								{ $$ = new SymbolInfo(ruleOf({$1}),"type_specifier",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| VOID								{ $$ = new SymbolInfo(ruleOf({$1}),"type_specifier",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					;
declaration_list	: declaration_list COMMA ID			{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"declaration_list","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); 
														$$->setDeclarationList($1->getDeclarationList()); 
														$$->addDeclaration($3);  
														$3->setIsArray(false); 
														SymbolInfo* a = st->lookUp($3->getName());
														if(a && a->getIsDeclared())	printError("Function exists"); }
					| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD					{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5,$6}),"declaration_list","",$1->getStart(),$6->getEnd(),false,logout, {$1,$2,$3,$4,$5,$6}); 
																						$$->setDeclarationList($1->getDeclarationList()); 
																						$$->addDeclaration($3); 
																						$3->setIsArray(true);  
																						SymbolInfo* a = st->lookUp($3->getName());
																						if(a && a->getIsDeclared()) printError("Function exists"); }
					| ID								{ $$ = new SymbolInfo(ruleOf({$1}),"declaration_list","",$1->getStart(),$1->getEnd(),false,logout, {$1});
														$$->addDeclaration($1);  
														$1->setIsArray(false); 
														SymbolInfo* a = st->lookUp($1->getName());
														if(a && a->getIsDeclared()) printError("Function exists"); }
					| ID LTHIRD CONST_INT RTHIRD		{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4}),"declaration_list","",$1->getStart(),$4->getEnd(),false,logout, {$1,$2,$3,$4}); 
														$$->addDeclaration($1);  
														$1->setIsArray(true);  
														SymbolInfo* a = st->lookUp($1->getName());
														if(a && a->getIsDeclared()) printError("Function exists"); }
					| error								{ yyclearin; yyerrok; printError("Syntax error at declaration list of variable declaration"); 
														$$ = new SymbolInfo("error","declaration_list","",line_count,line_count,true,logout, {$1}); }
					;
statements			: statement							{ $$ = new SymbolInfo(ruleOf({$1}),"statements","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| statements statement				{ $$ = new SymbolInfo(ruleOf({$1,$2}),"statements","",$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); }
					;
statement			: var_declaration					{ $$ = new SymbolInfo(ruleOf({$1}),"statement","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| expression_statement				{ $$ = new SymbolInfo(ruleOf({$1}),"statement","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| compound_statement				{ $$ = new SymbolInfo(ruleOf({$1}),"statement","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| FOR LPAREN expression_statement expression_statement expression RPAREN statement						{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5,$6,$7}),"statement","",$1->getStart(),$7->getEnd(),false,logout, {$1,$2,$3,$4,$5,$6,$7}); }
					| IF LPAREN expression RPAREN statement								{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5}),"statement","",$1->getStart(),$5->getEnd(),false,logout, {$1,$2,$3,$4,$5}); }
					| IF LPAREN expression RPAREN statement ELSE statement				{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5,$6,$7}),"statement","",$1->getStart(),$7->getEnd(),false,logout, {$1,$2,$3,$4,$5,$6,$7}); }
					| WHILE LPAREN expression RPAREN statement							{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5}),"statement","",$1->getStart(),$5->getEnd(),false,logout, {$1,$2,$3,$4,$5}); }
					| PRINTLN LPAREN ID RPAREN SEMICOLON								{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4,$5}),"statement","",$1->getStart(),$5->getEnd(),false,logout, {$1,$2,$3,$4,$5});
																						if( !st->lookUp($3->getName()) ) printError("Undeclared variable '"+$3->getName()+"'"); }
					| RETURN expression SEMICOLON		{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"statement","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); }
					;
expression_statement: SEMICOLON							{ $$ = new SymbolInfo(ruleOf({$1}),"expression_statement","",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| expression SEMICOLON				{ $$ = new SymbolInfo(ruleOf({$1,$2}),"expression_statement",$1->getTypeSpecifier(),$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); }
					| error SEMICOLON 					{ yyclearin; yyerrok; printError("Syntax error at expression of expression statement"); 
														$$ = new SymbolInfo("error","expression_statement","",line_count,line_count,true,logout, {}); }
					;
variable			: ID								{ $$ = new SymbolInfo(ruleOf({$1}),"variable","",$1->getStart(),$1->getEnd(),false,logout, {$1}); 
														SymbolInfo* a = st->lookUp($1->getName());
														if( !a  || (a && a->getIsDeclared())){ printError("Undeclared variable '"+$1->getName()+"'"); $$->setTypeSpecifier("error"); }
														else { $$->setTypeSpecifier(a->getTypeSpecifier()); $$->setIsArray(a->getIsArray()); }  }
					| ID LTHIRD expression RTHIRD		{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4}),"variable","",$1->getStart(),$4->getEnd(),false,logout, {$1,$2,$3,$4});
														SymbolInfo* a = st->lookUp($1->getName());
														if( !a  || (a && a->getIsDeclared())){ printError("Undeclared variable '"+$1->getName()+"'"); $$->setTypeSpecifier("error"); }
														else if(!a->getIsArray()){ printError("'"+$1->getName()+"' is not an array"); $$->setTypeSpecifier("error"); }
														else if($3->getStatement()==""){ printError("No index in array"); }
														else if($3->getTypeSpecifier()!="INT"){ printError("Array subscript is not an integer"); $$->setTypeSpecifier("error"); }
														else { $$->setTypeSpecifier(a->getTypeSpecifier()); $$->setIsArray(false); } }
					| ID LTHIRD error RTHIRD 	{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4}),"variable","",$1->getStart(),$4->getEnd(),false,logout, {$1,$2,$3,$4});
														printError("No index in array."); }
					;
expression			: logic_expression					{ $$ = new SymbolInfo(ruleOf({$1}),"expression",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1}); $$->setIsArray($1->getIsArray()); }
					| variable ASSIGNOP logic_expression								{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"expression","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3});
																						$$->setIsArray($1->getIsArray());
																						if(($3->getIsArray() && !$1->getIsArray()) || ($1->getIsArray() && !$3->getIsArray())){
																							printError("Array type mismatch."); $$->setIsArray(false); }
																						else if($3->getTypeSpecifier()=="VOID"){
																								voidError2($$);
																						}
																						else if($1->getTypeSpecifier() == "INT" && $3->getTypeSpecifier()=="FLOAT"){
																							printError("Warning: possible loss of data in assignment of FLOAT to INT");
																						}
																						}
					| error								{ yyclearin; yyerrok;
														$$ = new SymbolInfo("error","expression","",line_count,line_count,true,logout, {$1}); }
					;
logic_expression	: rel_expression					{ $$ = new SymbolInfo(ruleOf({$1}),"logic_expression",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1});  
														$$->setIsArray($1->getIsArray()); }
					| rel_expression LOGICOP rel_expression								{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"logic_expression","INT",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); 
																						if( $1->getIsArray() || $3->getIsArray() ){
																							printError("Can't be array. ");
																						}else if( $3->getTypeSpecifier() == "VOID" || $1->getTypeSpecifier() == "VOID"){
																							voidError2($$);
																						}else if( !($1->getTypeSpecifier()== "INT" and $3->getTypeSpecifier() == "INT") ){
																							printError("Type mismatch");
																						}
																						}
					;
rel_expression		: simple_expression					{ $$ = new SymbolInfo(ruleOf({$1}),"rel_expression",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1});   $$->setIsArray($1->getIsArray()); }
					| simple_expression RELOP simple_expression							{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"rel_expression","INT",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); 
																						if( $1->getIsArray() || $3->getIsArray() ){
																							printError("Can't be array. ");
																						}else if( $3->getTypeSpecifier() == "VOID" || $1->getTypeSpecifier() == "VOID"){
																							voidError2($$);
																						}
																						}
					;
simple_expression	: term 								{ $$ = new SymbolInfo(ruleOf({$1}),"simple_expression",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1});    $$->setIsArray($1->getIsArray()); }
					| simple_expression ADDOP term		{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"simple_expression",typeCast($1,$3),$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3});
														if( $3->getIsArray() ){
															printError("Can't be array. ");
														}else if( $3->getTypeSpecifier() == "VOID"){
															voidError2($$);
														}
														}
					;
term				: unary_expression					{ $$ = new SymbolInfo(ruleOf({$1}),"term",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1});
														$$->setIsArray($1->getIsArray()); }
					| term MULOP unary_expression		{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"term",typeCast($1,$3),$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3});
														if( $3->getIsArray() ) printError("Can't be array. ");
														else if( $3->getTypeSpecifier() == "VOID") voidError2($$);
														else if( $2->getName() == "%" && $3->getStatement() == "0" ){ printError("Warning: division by zero i=0f=1Const=0"); $$->setTypeSpecifier("error"); }
														else if($2->getName() == "%" && ( $1->getTypeSpecifier() != "INT" || $3->getTypeSpecifier() != "INT") ){ printError("Operands of modulus must be integers "); $$->setTypeSpecifier("error"); } 
														else if( $2->getName() == "/" and $3->getStatement() == "0" ){ printError("Warning: division by zero i=0f=1Const=0"); $$->setTypeSpecifier("error"); } }
					;
unary_expression	: ADDOP unary_expression			{ $$ = new SymbolInfo(ruleOf({$1,$2}),"unary_expression",$2->getTypeSpecifier(),$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); 
														if( $2->getIsArray() ){ printError("Can't be array. "); }
														if( $1->getTypeSpecifier() == "VOID" ){ voidError2($$); }  }
					| NOT unary_expression				{ $$ = new SymbolInfo(ruleOf({$1,$2}),"unary_expression","INT",$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); 
														if( $2->getIsArray() ) printError("Can't be array. ");
														if( $1->getTypeSpecifier() != "INT" ){ printError("Must be of integer type");  $$->setTypeSpecifier("error"); }  }
					| factor							{ $$ = new SymbolInfo(ruleOf({$1}),"unary_expression",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1}); $$->setIsArray($1->getIsArray()); }
					;
factor				: variable							{ $$ = new SymbolInfo(ruleOf({$1}),"factor",$1->getTypeSpecifier(),$1->getStart(),$1->getEnd(),false,logout, {$1});   $$->setIsArray($1->getIsArray()); }
					| ID LPAREN argument_list RPAREN	{ $$ = new SymbolInfo(ruleOf({$1,$2,$3,$4}),"factor","error",$1->getStart(),$4->getEnd(),false,logout, {$1,$2,$3,$4}); 
														SymbolInfo* a = st->lookUp($1->getName());
														if(!a) printError("Undeclared function '"+$1->getName()+"'");
														else if(!a->getIsDeclared()) printError($1->getName()+" is not a function");
														else{
															$$->setTypeSpecifier(a->getTypeSpecifier());
															if( $3->getParameterList().size() <  a->getParameterList().size()) printError("Too few arguments to function '"+$1->getName()+"'");
															else if($3->getParameterList().size() >  a->getParameterList().size()) printError("Too many arguments to function '"+$1->getName()+"'");
															else{
																vector<SymbolInfo*> b = $3->getParameterList();
																vector<SymbolInfo*> c = a->getParameterList();
																for(int i=0;i<b.size();i++){
																	if( b[i]->getTypeSpecifier()!= c[i]->getTypeSpecifier()) printError("Type mismatch for argument "+to_string(i+1)+" of '"+$1->getName()+"'");
																	else if( b[i]->getIsArray() and !c[i]->getIsArray() ) printError("'"+b[i]->getName()+"' is an array");
																	else if( !b[i]->getIsArray() and c[i]->getIsArray() ) printError("'"+b[i]->getName()+"' is not an array");
																}
															}
														}   }
					| LPAREN expression RPAREN			{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"factor",$1->getTypeSpecifier(),$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); }
					| CONST_INT							{ $$ = new SymbolInfo(ruleOf({$1}),"factor","INT",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| CONST_FLOAT						{ $$ = new SymbolInfo(ruleOf({$1}),"factor","FLOAT",$1->getStart(),$1->getEnd(),false,logout, {$1}); }
					| variable INCOP					{ $$ = new SymbolInfo(ruleOf({$1,$2}),"factor",$1->getTypeSpecifier(),$1->getStart(),$2->getEnd(),false,logout, {$1,$2}); 
														if( $1->getTypeSpecifier() == "VOID" ){ printError("Variable or field '"+$1->getName()+"' declared void");  $$->setTypeSpecifier("error"); /* Do I need it? */ } }
					;
argument_list		: arguments							{ $$ = new SymbolInfo(ruleOf({$1}),"argument_list","",$1->getStart(),$1->getEnd(),false,logout, {$1}); 
														$$->setParameterList($1->getParameterList()); }			
					| arguments error					{yyclearin; yyerrok; printError("Syntax error at arguments");
														$$ = new SymbolInfo(ruleOf({$1}),"argument_list","",$1->getStart(),$2->getEnd(),false,logout, {$1}); 
														$$->setParameterList($1->getParameterList()); }
				|										{ $$ = new SymbolInfo(ruleOf({}),"argument_list","",line_count,line_count,false,logout, {}); }
					;
arguments			: arguments COMMA logic_expression	{ $$ = new SymbolInfo(ruleOf({$1,$2,$3}),"arguments","",$1->getStart(),$3->getEnd(),false,logout, {$1,$2,$3}); 
														$$->setParameterList($1->getParameterList()); 
														$$->addParameter($3); }
					| logic_expression					{ $$ = new SymbolInfo(ruleOf({$1}),"arguments","",$1->getStart(),$1->getEnd(),false,logout, {$1}); 
														$$->addParameter($1); }
					;
lcurl 				: LCURL								{ $$ = $1; st->enterScope(); 
														for(auto a : funcparams->getParameterList()){
															if( a->getName() == "" ) continue;
															if( a->getTypeSpecifier() == "VOID" ) a->setTypeSpecifier("error");  // do I need it?
															if(!st->insert(a)) printError("Redefinition of parameter \'"+a->getName()+"\'"); // ulta hobe na?
														} funcparams->setParameterList({});	}	
					;
%%

int main(int argc, char** argv)
{
    st = new SymbolTable(11);
    line_count = 1;
	error_count = 0;
    if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	parseout.open("1905069_parse.txt");
	logout.open("1905069_log.txt");
	errorout.open("1905069_error.txt");

	yyin=fin;
    yyparse();

    fclose(yyin);
	errorout.close();
	logout.close();

    exit(0);
}
