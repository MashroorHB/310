%{
#include<bits/stdc++.h>
#include "1905069_symbol_info.cpp"
#include "1905069_symbol_table.h"
using namespace std;



SymbolTable* st;
SymbolInfo* funcparams = new SymbolInfo();
vector<SymbolInfo*> globalVariables;
string newLineProc = "NEWLINE proc\n\tpush ax\n\tpush dx\n\tmov ah,2\n\tmov dl,cr\n\tint 21h\n\tmov ah,2\n\tmov dl,lf\n\tint 21h\n\tpop dx\n\tpop ax\n\tret\nNEWLINE endp\n";
string printOutputProc = "PRINTNUMBER proc  ;print what is in ax\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush si\n\tlea si,number\n\tmov bx,10\n\tadd si,4\n\tcmp ax,0\n\tjnge negate\n\tprint:\n\txor dx,dx\n\tdiv bx\n\tmov [si],dl\n\tadd [si],'0'\n\tdec si\n\tcmp ax,0\n\tjne print\n\tinc si\n\tlea dx,si\n\tmov ah,9\n\tint 21h\n\tpop si\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\tnegate:\n\tpush ax\n\tmov ah,2\n\tmov dl,'-'\n\tint 21h\n\tpop ax\n\tneg ax\n\tjmp print\nPRINTNUMBER endp\n";
string header = ";-------\n;\n;-------\n.MODEL SMALL\n.STACK 1000H\n.DATA\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tnumber DB \"00000$\"\n";


extern int line_count;
extern int error_count;
extern FILE *yyin;

//small functions

string ruleOf(vector<SymbolInfo*> SI){
	string name = "";
	for(auto si: SI){
		name += " ";
		name += si->type;
	}
	return name;
}

string typeCast(SymbolInfo* a,SymbolInfo* b){
	if(a->typeSpecifier == "FLOAT" or b->typeSpecifier == "FLOAT" ) return "FLOAT";
	return "INT";
}

int labelCount=0;
int tempCount=0;



string newTemp()
{
	string h = to_string(tempCount++);
	h = "t"+h;
	return h;
}

string getOpcode(string op){
	string opcode = "";
	if(op == "<") opcode ="\tJL";
	else if(op == ">") opcode ="\tJG";
	else if(op == ">=") opcode ="\tJGE";
	else if(op == "<=") opcode ="\tJLE";
	else if(op == "==") opcode ="\tJE";
	else if(op == "!=") opcode ="\tJNE";
	return opcode;
}

string currFunc;

void checkFuncDeclared(SymbolInfo* funcName, SymbolInfo* funcType){
	funcName->setTypeSpecifier(funcType->typeSpecifier);
	funcName->setParameterList(funcparams->parameterlist);
	funcName->setIsFunction(true);
	currFunc = funcName->name;
	if( st->insert(funcName)) return;
	
	SymbolInfo* oldFunc = st->lookUp(funcName->name);
		
	vector<SymbolInfo*> declaredArgs = oldFunc->parameterlist;
	vector<SymbolInfo*> definedArgs = funcName->parameterlist;
}

void optimizeCode(){
    vector< vector<string> > mycode;
    string line;
    ifstream cs1("1905069_code.asm");
    if(cs1.is_open()){
        while( getline(cs1,line) ){
            string w = "";
            vector<string > words;
            for(int i=0; i<line.size(); i++){
                if(line[i]==' ' || line[i]=='\n' || line[i]=='\t' || line[i]==',' || line[i]==':' || line[i]==';'){
                    if(w.size()>0) words.push_back(w);
                    w = "";
                }
                else{
                    w += line[i];
                }
            }
            if(w.size()>0) words.push_back(w);
            words.push_back(line+'\n');
            mycode.push_back(words);
            for(int i=0; i<words.size(); i++){
                //cout<< words[i]<< " __ " ;
            }
            //cout<< "."<< endl;
        }
    }
    cs1.close();

    int g = INT_MAX;

    while(g>mycode.size()){
        g = mycode.size();
        vector< vector<string> > passone;
        for(int i=0; i<mycode.size(); i++){
            if((mycode[i][0]=="ADD" || mycode[i][0]=="SUB") && mycode[i][2]=="0") continue;
            if(i<mycode.size()-1 &&  mycode[i][0]=="PUSH" && mycode[i+1][0]=="POP"){
                if(mycode[i][1]!=mycode[i+1][1]){
                    passone.push_back({"MOV",mycode[i+1][1],mycode[i][1],"\tMOV "+mycode[i+1][1]+", "+mycode[i][1]+"\n"});
                }
                i++;
                continue;
            }
            passone.push_back(mycode[i]);
        }

        vector< vector<string> > passtwo;

        for(int i=0; i<passone.size(); i++){
            if(i<passone.size()-1 &&  passone[i][0]=="MOV" && passone[i+1][0]=="MOV" && passone[i][1]==passone[i+1][2] && passone[i][2]==passone[i+1][1]){
                i++;
                continue;
            }
            passtwo.push_back(passone[i]);
        }

        vector< vector<string> > passthree;

        for(int i=0; i<passtwo.size(); i++){
            if(i<passtwo.size()-1 && passtwo[i][0]=="MOV" && passtwo[i+1][0]=="POP" && passtwo[i][1]==passtwo[i+1][1]){
                continue;
            }
            passthree.push_back(passtwo[i]);
        }

        vector< vector<string> > passfour;

        for(int i=0; i<passthree.size(); i++){
            if(i<passthree.size()-1 && passthree[i][0][0]=='J' && passthree[i][1]==passthree[i+1][0]){
                continue;
            }
            passfour.push_back(passthree[i]);
        }

        mycode = passfour;

    }
    ofstream optcode("1905069_optcode.asm");
    for(int i=0; i<mycode.size(); i++){
        optcode<< mycode[i][mycode[i].size()-1];
    }
	optcode.close();


}


void yyerror(char *s){
	printf("%s\n",s);
}

int yylex(void);


%}


%union{
    SymbolInfo* si; 
}

%token<si> NEWLINE CONST_FLOAT CONST_INT CONST_CHAR IF LOWER_THAN_ELSE FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTLN ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL COMMA SEMICOLON ID
%type<si> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments lcurl error

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start			: program		{
									$$ = new SymbolInfo("","start","",{$1});
									ofstream parseout("parseTree.txt");
									$$->printParseTree(0,parseout);
									parseout.close();
									ofstream codeout("1905069_code.asm");
									$$->globalVars = globalVariables;
									$$->codeGeneration(0,codeout);
									codeout.close();
									optimizeCode();
								}
				;
program 		: program unit	{$$ = new SymbolInfo("","program","",{$1,$2});} 
				| unit			{$$ = new SymbolInfo("","program","",{$1});} 
				;
unit 			: var_declaration	{$$ = new SymbolInfo($1->name,"unit","",{$1});}
				| func_declaration	{$$ = new SymbolInfo($1->name,"unit","",{$1});}
				| func_definition	{$$ = new SymbolInfo($1->name,"unit","",{$1});}
				;	
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON	{ 
									$$ = new SymbolInfo($2->name,"func_declaration","",{$1,$2,$3,$4,$5,$6}); 
									$2->setTypeSpecifier($1->typeSpecifier); 
									$2->setIsDeclared(true); 
									$2->setParameterList($4->parameterlist); 
									funcparams->setParameterList({}); 
									st->insert($2); 
								}
				| type_specifier ID LPAREN RPAREN SEMICOLON	{ 
									$$ = new SymbolInfo($2->name,"func_declaration","",{$1,$2,$3,$4,$5}); 
									$2->setTypeSpecifier($1->typeSpecifier); 
									$2->setIsDeclared(true); 
									st->insert($2); 
								}
				;
func_definition	: type_specifier ID LPAREN parameter_list RPAREN { checkFuncDeclared($2,$1); } compound_statement	{ $$ = new SymbolInfo($2->name,"func_definition","",{$1,$2,$3,$4,$5,$7});}
				| type_specifier ID LPAREN RPAREN { checkFuncDeclared($2,$1); } compound_statement	{ $$ = new SymbolInfo($2->name,"func_definition","",{$1,$2,$3,$4,$6});}
				;
parameter_list	: parameter_list COMMA type_specifier ID	{
									$$ = new SymbolInfo("","parameter_list","",{$1,$2,$3,$4});
									$$->setParameterList($1->parameterlist); 
									$$->addParameter($4); 
									$4->setTypeSpecifier($3->typeSpecifier); 
									funcparams->setParameterList($$->parameterlist); 
								}
				| parameter_list COMMA type_specifier	{ 
									$$ = new SymbolInfo("","parameter_list","",{$1,$2,$3}); 
									SymbolInfo* body = new SymbolInfo("","ID"); 
									$$->setParameterList($1->parameterlist); 
									$$->addParameter(body);  
									body->setTypeSpecifier($3->typeSpecifier); 
									funcparams->setParameterList($$->parameterlist); 
								}
				| type_specifier ID	{ 
									$$ = new SymbolInfo("","parameter_list","",{$1,$2}); 
									$2->setTypeSpecifier($1->typeSpecifier); 
									$$->addParameter($2); 
									funcparams->setParameterList($$->parameterlist); 
								}
				| type_specifier{ 
									$$ = new SymbolInfo("","parameter_list","",{$1}); 
									SymbolInfo* body = new SymbolInfo("","ID"); 
									body->setTypeSpecifier($1->typeSpecifier); 
									$$->addParameter(body); 
									funcparams->setParameterList($$->parameterlist); 
								}
				;

compound_statement: lcurl statements RCURL	{
									$$ = new SymbolInfo($2->name,"compound_statement","",{$1,$2,$3});
									$$->stackOffset = st->getStackOffset();
									st->exitScope();
								}
 		    	| lcurl RCURL	{
									$$ = new SymbolInfo("","compound_statement","",{$1,$2});
									$$->stackOffset = st->getStackOffset();
									st->exitScope();
								}
 		    	;	
var_declaration	: type_specifier declaration_list SEMICOLON		{
									$$ = new SymbolInfo("","var_declaration","",{$1,$2,$3});
									if(st->getID()==1) $$->isGlobal = true;
									else $$->isGlobal = false;
									for(int i=0; i<$2->declarationlist.size(); i++){
										auto a = $2->declarationlist[i];
										a->setTypeSpecifier($1->typeSpecifier);
										st->insert(a);
										if(st->getID()==1){
											a->stackOffset = 0;
											globalVariables.push_back(a);
											a->isGlobal = true;
											if(a->isArray) cout<< "libtard\n";
											else cout<< a->name << " nooo\n";
										}
										else{
											a->isGlobal = false;
											if(a->isArray) st->setStackOffset(st->getStackOffset()-2*a->arraySize);
											else st->setStackOffset(st->getStackOffset()-2);
											a->stackOffset = st->getStackOffset();
										}
									}
								}
 		 		;
type_specifier	: INT			{$$ = new SymbolInfo($1->name,"type_specifier",$1->typeSpecifier,{$1});}
				| FLOAT			{$$ = new SymbolInfo($1->name,"type_specifier",$1->typeSpecifier,{$1});}
				| VOID			{$$ = new SymbolInfo($1->name,"type_specifier",$1->typeSpecifier,{$1});}
				;
declaration_list	: declaration_list COMMA ID	{
									$$ = new SymbolInfo("","declaration_list","",{$1,$2,$3});
									$$->setDeclarationList($1->declarationlist);
									$$->addDeclaration($3);
								}
				| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD	{
									$$ = new SymbolInfo("","declaration_list","",{$1,$2,$3,$4,$5,$6});
									$$->setDeclarationList($1->declarationlist);
									$3->setIsArray(true);
									string s = $5->name;
									istringstream is(s);
									int i;
									is >> i;
									$3->arraySize = i;
									cout<< "yay\n";
									$$->addDeclaration($3);
								}
				| ID			{
									$$ = new SymbolInfo("","declaration_list","",{$1});
									$$->addDeclaration($1);
								}
				| ID LTHIRD CONST_INT RTHIRD	{
									$$ = new SymbolInfo("","declaration_list","",{$1,$2,$3,$4});
									$1->setIsArray(true);
									string s = $3->name;
									istringstream is(s);
									int i;
									is >> i;
									$1->arraySize = i;	
									cout<< $1->name<< " yay\n";				
									$$->addDeclaration($1);
								}
				;
statements		: statement		{$$ = new SymbolInfo($1->name,"statements","",{$1});}
				| statements statement	{$$ = new SymbolInfo($1->name,"statements","",{$1,$2});}
				;
statement		: var_declaration	{$$ = new SymbolInfo($1->name,"statement","",{$1});}
				| expression_statement	{$$ = new SymbolInfo($1->name,"statement","",{$1});}
				| compound_statement	{$$ = new SymbolInfo($1->name,"statement","",{$1});}
				|  FOR LPAREN expression_statement expression_statement expression RPAREN statement	{
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5,$6,$7});
								}
				|  IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5});
								}
				|  IF LPAREN expression RPAREN statement ELSE statement {
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5,$6,$7});
								}
				| WHILE LPAREN expression RPAREN statement	{
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5});
								}
				| PRINTLN LPAREN ID RPAREN SEMICOLON	{
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3,$4,$5});
									auto a = st->lookUp($3->name);
									$$->stackOffset = a->stackOffset;
									if(a->isGlobal) $$->isGlobal = true;
									else $$->isGlobal = false;
								}
				| RETURN expression SEMICOLON	{
									$$ = new SymbolInfo($1->name,"statement","",{$1,$2,$3});
									$1->name = currFunc;
								}
				;
expression_statement: SEMICOLON	{$$ = new SymbolInfo("","expression_statement","",{$1});}
				| expression SEMICOLON		{$$ = new SymbolInfo($1->name,"expression_statement",$1->typeSpecifier,{$1,$2});}
				;		
variable		: ID			{
									SymbolInfo* a = st->lookUp($1->name);
									$$ = new SymbolInfo($1->name,"variable",a->typeSpecifier,{$1});
									$$->setIsArray(a->isArray);
									$$->stackOffset = a->stackOffset;
									$$->isGlobal = a->isGlobal;
								}
				| ID LTHIRD expression RTHIRD	{
									SymbolInfo* a = st->lookUp($1->name);
									$$ = new SymbolInfo($1->name,"variable",a->typeSpecifier,{$1,$2,$3,$4});
									$$->setIsArray(a->isArray);
									$$->stackOffset = a->stackOffset;
									$$->isGlobal = a->isGlobal;
								}
				;
expression		: logic_expression		{$$ = new SymbolInfo($1->name,"expression","",{$1});}
				| variable ASSIGNOP logic_expression {$$ = new SymbolInfo($1->name,"expression","",{$1,$2,$3});}
				;	
logic_expression	: rel_expression		{
									$$ = new SymbolInfo($1->name,"logic_expression",$1->typeSpecifier,{$1});
									$$->setIsArray($1->isArray);
								}
				| rel_expression LOGICOP rel_expression	{$$ = new SymbolInfo($1->name,"logic_expression","INT",{$1,$2,$3});}
				;		
rel_expression	: simple_expression		{
									$$ = new SymbolInfo($1->name,"rel_expression",$1->typeSpecifier,{$1});
									$$->setIsArray($1->isArray);
								}
				| simple_expression RELOP simple_expression	{$$ = new SymbolInfo($1->name,"rel_expression","INT",{$1,$2,$3});}
				;	
simple_expression: term		{
									$$ = new SymbolInfo($1->name,"simple_expression",$1->typeSpecifier,{$1});
									$$->setIsArray($1->isArray);
								}
				| simple_expression ADDOP term {$$ = new SymbolInfo($1->name,"simple_expression",typeCast($1,$3),{$1,$2,$3});}
				;
term			: unary_expression		{
									$$ = new SymbolInfo($1->name,"term",$1->typeSpecifier,{$1});
									$$->setIsArray($1->isArray);
								}
				| term MULOP unary_expression {$$ = new SymbolInfo($1->name,"term",typeCast($1,$3),{$1,$2,$3});}
				;			
unary_expression: ADDOP unary_expression	{$$ = new SymbolInfo($2->name,"unary_expression",$2->typeSpecifier,{$1,$2});}
				| NOT unary_expression{$$ = new SymbolInfo($2->name,"unary_expression","INT",{$1,$2});}
				| factor		{
									$$ = new SymbolInfo($1->name,"unary_expression",$1->typeSpecifier,{$1});
									$$->setIsArray($1->isArray);
								}
				;		
factor			: variable		{$$ = new SymbolInfo($1->name,"factor","",{$1});}
				| ID LPAREN argument_list RPAREN	{
									auto a = st->lookUp($1->name);
									$$ = new SymbolInfo(ruleOf({$1,$2,$3,$4}),"factor",a->typeSpecifier,{$1,$2,$3,$4});
									vector<SymbolInfo*> b = $3->parameterlist;
									vector<SymbolInfo*> c = a->parameterlist;
								}
				| LPAREN expression RPAREN	{$$ = new SymbolInfo($2->name,"factor",$2->typeSpecifier,{$1,$2,$3});}
				| CONST_INT		{$$ = new SymbolInfo($1->name,"factor","INT",{$1});	}
				| CONST_FLOAT	{$$ = new SymbolInfo($1->name,"factor","FLOAT",{$1});}
				| variable INCOP	{$$ = new SymbolInfo($1->name,"factor",$1->typeSpecifier,{$1,$2});}
				;
	
argument_list	: arguments		{
									$$ = new SymbolInfo($1->name,"argument_list","",{$1});
									$$->setParameterList($1->parameterlist);
									$$->stackOffset = $1->stackOffset;
								}
				|				{$$ = new SymbolInfo("","argument_list","",{});}
				;
arguments		: arguments COMMA logic_expression	{
									$$ = new SymbolInfo($1->name,"arguments","",{$1,$2,$3});
									$$->setParameterList($1->parameterlist);
									$$->addParameter($3);
									$$->stackOffset = $1->stackOffset+2;
								}
				| logic_expression	{
									$$ = new SymbolInfo($1->name,"arguments","",{$1});
									$$->addParameter($1);
									$$->stackOffset = 2;
								}
lcurl			: LCURL			{
									$$ = $1; st->enterScope();
									int stackOffset = 2;
									for(int i = funcparams->parameterlist.size()-1; i>=0; i--){
										auto a = funcparams->parameterlist[i];
										if( a->name == "" ) continue;
										stackOffset+=2;
										a->stackOffset = stackOffset;
										st->insert(a);
									} funcparams->setParameterList({});
									st->setStackOffset(0);
								}
		
%%


void yyerror(const char *s){
	//cout << "Error at line no " << line_count << " : " << s << endl;
}

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
	yyin=fin;
    yyparse();
    exit(0);
}