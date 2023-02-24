#pragma once
#include<bits/stdc++.h>
using namespace std;
typedef long long int ll;
typedef double db;


class SymbolInfo{
public:
    SymbolInfo* next;
    string name;
    string type;
    string typeSpecifier;
    bool isToken;
    bool isArray;
    bool isFunction;
    bool isDeclared;
    bool isCond;
    vector<SymbolInfo*> son; 
    vector<SymbolInfo*> declarationlist; 
    vector<SymbolInfo*> parameterlist;
    int stackOffset;
    int arraySize;
    bool isGlobal;
    string lTrue;
    string lFalse;
    string lEnd;


    SymbolInfo(){
        isToken = false;
        this->isArray = false;
        this->isDeclared = false;
        this->isFunction = false;
    }

    SymbolInfo(string name, string type, string typeSpecifier, vector<SymbolInfo*> SI){
        this->name = name;
        this->type = type;
        this->typeSpecifier = typeSpecifier;
        this->next = nullptr;
        this->isArray = false;
        this->isDeclared = false;
        this->isFunction = false;
        isToken = false;
        isCond = false;
        lEnd = "";
        lTrue = "";
        lFalse = "";

        for(auto si: SI){
            son.push_back(si);
        }
    }

    SymbolInfo(string name, string type){
        this->name = name;
        this->type = type;
        this->next = nullptr;
        isToken = false;
        this->isArray = false;
        this->isDeclared = false;
        this->isFunction = false;
    }

    SymbolInfo(SymbolInfo* symbol){
        this->name = symbol->name;
        this->type = symbol->type;
        this->next = symbol->next;
    }

    string getName(){
        return name;
    }
    string getType(){
        return type;
    }
    SymbolInfo* getNext(){
        return this->next;
    }
    vector<SymbolInfo*> getExpansion(){
        return son;
    }
    bool getIsToken(){
        return isToken;
    }
    bool getIsArray(){
        return isArray;
    }
    bool getIsFunction(){
        return isFunction;
    }
    bool getIsDeclared(){
        return isDeclared;
    }
    string getTypeSpecifier(){
        return typeSpecifier;
    }
    vector<SymbolInfo*> getDeclarationList(){
        return declarationlist;
    }
    vector<SymbolInfo*> getParameterList(){
        return parameterlist;
    }

    void setName(string s){
        name = s;
        return;
    }
    void setType(string s){
        type = s;
        return;
    }
    void setNext(SymbolInfo* next){
        this->next = next;
    }
    void addExpansion(vector<SymbolInfo*> SI){
        for(auto si: SI){
            son.push_back(si);
        }
    }
    void setIsToken(bool b){
        isToken = b;
    }
    void setIsArray(bool b){
        isArray = b;
    }
    void setIsFunction(bool b){
        isDeclared = b;
        isFunction = b;
    }
    void setIsDeclared(bool b){
        isDeclared = b;
    }
    void setTypeSpecifier(string typeSpecifier){
        this->typeSpecifier = typeSpecifier;
    }
    void setDeclarationList(vector<SymbolInfo*> SI){
        declarationlist = SI;
    }
    void addDeclaration(SymbolInfo* si){
        declarationlist.push_back(si);
    }
    void setParameterList(vector<SymbolInfo*> SI){
        parameterlist = SI;
    }
    void addParameter(SymbolInfo* si){
        parameterlist.push_back(si);
    }

    void printParseTree(int t, ostream& os){
        for(int i=0; i<t; i++) {
            os<< " ";
        }
        os<< type<< " : ";

        for(SymbolInfo* si : son){
            os<< si->type<< " ";
        }
        if(son.size()==0) os<< name<< " ";
        os<< "\n";
        for(SymbolInfo* si : son){
            si->printParseTree(t+1,os);
        }
    }

    string getStatement(){
        if(isToken) return name;
        string a = "";
        for(auto b : son){
            a+=b->getStatement();
        }
        return a;
    }


    friend ostream& operator<<(ostream& os, const SymbolInfo& dt);
    ~SymbolInfo(){
        delete next;
    }

    string makeRule(){
        string g = type + " :";
        for(auto s : son){
            g+=" "+s->type;
        }
        return g;
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

    string newLabel(){
        string h = to_string(labelCnt++);
        h = "L"+h;
        return h;
    }

    string newTem(){
        string h = to_string(tempCnt++);
        h = "t"+h;
        return h;
    }
    

    void codeGeneration(int t, ostream& os){
        if(makeRule()=="start : program"){
            string newLineProc = "NEWLINE PROC\n\tPUSH AX\n\tPUSH DX\n\tMOV AH,2\n\tMOV DL,CR\n\tINT 21H\n\tMOV AH,2\n\tMOV DL,LF\n\tINT 21H\n\tPOP DX\n\tPOP AX\n\tRET\nNEWLINE ENDP\n";
            string printOutputProc = "PRINTNUMBER PROC  ;PRINT WHAT IS IN AX\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tPUSH SI\n\tLEA SI,NUMBER\n\tMOV BX,10\n\tADD SI,4\n\tCMP AX,0\n\tJNGE NEGATE\n\tPRINT:\n\tXOR DX,DX\n\tDIV BX\n\tMOV [SI],DL\n\tADD [SI],'0'\n\tDEC SI\n\tCMP AX,0\n\tJNE PRINT\n\tINC SI\n\tLEA DX,SI\n\tMOV AH,9\n\tINT 21H\n\tPOP SI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\tNEGATE:\n\tPUSH AX\n\tMOV AH,2\n\tMOV DL,'-'\n\tINT 21H\n\tPOP AX\n\tNEG AX\n\tJMP PRINT\nPRINTNUMBER ENDP\n";
            string header = ";-------\n;\n;-------\n.MODEL SMALL\n.STACK 1000H\n.DATA\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tNUMBER DB \"00000$\"\n";
            os<< header;
            for(int i=0; i<globalVars.size(); i++){
                if(globalVars[i]->isArray){
                    os<< "\t"<< globalVars[i]->name<< " DW "<< globalVars[i]->arraySize<< " DUP (0000H)\n";
                }
                else{
                    os<< "\t"<< globalVars[i]->name<< " DW 1 DUP (0000H)\n";
                }
            }
            os<< ".CODE\n";
            son[0]->codeGeneration(t+1,os);
            os<< newLineProc;
            os<< printOutputProc;
            os<< "END main\n";
        }
        if(makeRule()=="program : program unit"){
            son[0]->codeGeneration(t+1,os);
            son[1]->codeGeneration(t+1,os);
        }
        if(makeRule()=="program : unit"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="unit : var_declaration"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="unit : func_declaration"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="unit : func_definition"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"){
            son[0]->codeGeneration(t+1,os);
            son[3]->codeGeneration(t+1,os);
        }
        if(makeRule()=="func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"){
            son[0]->codeGeneration(t+1,os);
            son[3]->codeGeneration(t+1,os);
            os<< name<< " PROC\n";
            if(name == "main"){
                os<< "\tMOV AX, @DATA\n";
                os<< "\tMOV DS, AX\n";
            }
            os<< "\tPUSH BP\n";
            os<< "\tMOV BP, SP\n";
            son[5]->codeGeneration(t+1,os);
            os<< name<< "_exit:\n";
            if(name == "main"){
                os<< "\tMOV AX, 4CH\n";
                os<< "\tINT 21H\n";
            }
            os<< "\tADD SP, "<< -son[5]->stackOffset<< endl;
            os<< "\tPOP BP\n";
            if(name != "main"){
                os<< "\tRET\n";
            }
            os<< name<< " ENDP\n";
        }
        if(makeRule()=="func_definition : type_specifier ID LPAREN RPAREN compound_statement"){
            son[0]->codeGeneration(t+1,os);
            os<< name<< " PROC\n";
            if(name == "main"){
                os<< "\tMOV AX, @DATA\n";
                os<< "\tMOV DS, AX\n";
            }
            os<< "\tPUSH BP\n";
            os<< "\tMOV BP, SP\n";
            son[4]->codeGeneration(t+1,os);
            os<< name<< "_exit:\n";
            if(name == "main"){
                os<< "\tMOV AX, 4CH\n";
                os<< "\tINT 21H\n";
            }
            os<< "\tADD SP, "<< -son[4]->stackOffset<< endl;
            os<< "\tPOP BP\n";
            os<< name<< " ENDP\n";
        }
        if(makeRule()=="parameter_list : parameter_list COMMA type_specifier ID"){
            son[0]->codeGeneration(t+1,os);
            son[2]->codeGeneration(t+1,os);
        }
        if(makeRule()=="parameter_list : parameter_list COMMA type_specifier"){
            son[0]->codeGeneration(t+1,os);
            son[2]->codeGeneration(t+1,os);
        }
        if(makeRule()=="parameter_list : type_specifier ID"){
            son[0]->codeGeneration(t+1,os);
            son[1]->codeGeneration(t+1,os);
        }
        if(makeRule()=="parameter_list : type_specifier"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="compound_statement : LCURL statements RCURL"){
            if(lEnd=="") lEnd = newLabel();
            son[1]->lEnd = lEnd;
            son[1]->codeGeneration(t+1,os);
        }
        if(makeRule()=="var_declaration : type_specifier declaration_list SEMICOLON"){
            son[0]->codeGeneration(t+1,os);
            son[1]->codeGeneration(t+1,os);
            for(int i= 0; i<son[1]->declarationlist.size(); i++){
                if(isGlobal);
                else{
                    if(son[1]->declarationlist[i]->isArray) os<< "\tSUB SP, "<< to_string(2*son[1]->declarationlist[i]->arraySize)<< "\n";
                    else os<< "\tSUB SP, 2\n";
                }
            }
        }
        if(makeRule()=="statements : statement"){
            son[0]->lEnd = lEnd;
            son[0]->codeGeneration(t+1,os);
            os<< lEnd<< ":\n";
        }
        if(makeRule()=="statements : statements statement"){
            son[0]->lEnd = newLabel();
            son[1]->lEnd = lEnd;
            son[0]->codeGeneration(t+1,os);
            son[1]->codeGeneration(t+1,os);
            os<< lEnd<< ":\n";
        }
        if(makeRule()=="statement : var_declaration"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="statement : expression_statement"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="statement : compound_statement"){
            son[0]->lEnd = newLabel();
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"){
            son[2]->codeGeneration(t+1,os);
            string loop = newLabel();
            os<< loop<< ":\n";
            son[3]->isCond = true;
            son[3]->lTrue = newLabel();
            son[3]->lFalse = lEnd;
            son[6]->lEnd = newLabel();
            son[3]->codeGeneration(t+1,os);
            os<< son[3]->lTrue<< ":\n";
            son[6]->codeGeneration(t+1,os);
            son[4]->codeGeneration(t+1,os);
            os<< "\tJMP "<< loop<< "\n";
        }
        if(makeRule()=="statement : IF LPAREN expression RPAREN statement"){
            son[2]->isCond = true;
            son[2]->lTrue = newLabel();
            son[2]->lFalse = lEnd;
            son[4]->lEnd = lEnd;
            son[2]->codeGeneration(t+1,os);
            os<< son[2]->lTrue<< ":\n";
            son[4]->codeGeneration(t+1,os);
        }
        if(makeRule()=="statement : IF LPAREN expression RPAREN statement ELSE statement"){
            son[2]->isCond = true;
            son[2]->lTrue = newLabel();
            son[2]->lFalse = newLabel();
            son[4]->lEnd = son[2]->lFalse;
            son[6]->lEnd = lEnd;
            son[2]->codeGeneration(t+1,os);
            os<< son[2]->lTrue<< ":\n";
            son[4]->codeGeneration(t+1,os);
            os<< "\tJMP "<< lEnd<< "\n";
            os<< son[2]->lFalse<< ":\n";
            son[6]->codeGeneration(t+1,os);
        }
        if(makeRule()=="statement : WHILE LPAREN expression RPAREN statement"){
            string loop = newLabel();
            son[2]->isCond = true;
            son[2]->lTrue = newLabel();
            son[2]->lFalse = lEnd;
            son[4]->lEnd = lEnd;
            os<< loop<< ":\n";
            son[2]->codeGeneration(t+1,os);
            os<< son[2]->lTrue<< ":\n";
            son[4]->codeGeneration(t+1,os);
            os<< "\tJMP "<< loop<< "\n";
        }
        if(makeRule()=="statement : PRINTLN LPAREN ID RPAREN SEMICOLON"){
            if(isGlobal){
                os<< "\tMOV AX, "+ son[2]->name +"\n";
                os<< "\tCALL PRINTNUMBER\n";
                os<< "\tCALL NEWLINE\n";
            }
            else{
                os<< "\tPUSH BP\n";
                os<< "\tMOV BX, "<< to_string(stackOffset)<< "\n";
                os<< "\tADD BP, BX\n";
                os<< "\tMOV AX, [BP]\n";
                os<< "\tCALL PRINTNUMBER\n";
                os<< "\tCALL NEWLINE\n";
                os<< "\tPOP BP\n";
            }
        }
        if(makeRule()=="statement : RETURN expression SEMICOLON"){
            son[1]->codeGeneration(t+1,os);
		    os<< "\tMOV DX,CX\n";
            os<< "\tJMP "<< son[0]->name<< "_exit\n";
        }
        if(makeRule()=="expression_statement : expression SEMICOLON"){
            son[0]->isCond = isCond;
            son[0]->lTrue = lTrue;
            son[0]->lFalse = lFalse;
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="variable : ID"){
            if(isGlobal);
            else{
                os<< "\tPUSH BP\n";
                os<< "\tMOV BX, "<< to_string(stackOffset)<< "\n";
                os<< "\tADD BP, BX\n";
            }
        }
        if(makeRule()=="variable : ID LTHIRD expression RTHIRD"){
            son[2]->codeGeneration(t+1,os);
            if(!isGlobal){
                os<< "\tPUSH BP\n";
                os<< "\tMOV BX, CX\n";
                os<< "\tADD BX, BX\n";
                os<< "\tADD BX, "<< to_string(stackOffset)<< "\n";
                os<< "\tADD BP, BX\n";
            }
            else{
                os<< "\tLEA SI, "<< son[0]->name<< "\n";
                os<< "\tADD SI, CX\n";
                os<< "\tADD SI, CX\n";
                os<< "\tPUSH BP\n";
                os<< "\tMOV BP, SI\n";
            }
        }
        if(makeRule()=="expression : logic_expression"){
            son[0]->isCond = isCond;
            son[0]->lTrue = lTrue;
            son[0]->lFalse = lFalse;
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="expression : variable ASSIGNOP logic_expression"){ //no more condition propagation
            son[2]->codeGeneration(t+1,os);
            son[0]->isCond = false;
            son[2]->isCond = false;
            if(son[0]->isGlobal && !son[0]->isArray){
                son[0]->codeGeneration(t+1,os);
                os<< "\tMOV "+son[0]->name<< ", CX\n";
            }
            else{
                os<< "\tPUSH CX\n";
                son[0]->codeGeneration(t+1,os);
                
                os<< "\tPOP AX\n";
                os<< "\tPOP CX\n";
                os<< "\tMOV [BP], CX\n";
                os<< "\tMOV BP, AX\n";
            }
            if(isCond) os<< "\tJMP "<< lTrue<< "\n";
        }
        if(makeRule()=="logic_expression : rel_expression"){
            son[0]->isCond = isCond;
            son[0]->lTrue = lTrue;
            son[0]->lFalse = lFalse;
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="logic_expression : rel_expression LOGICOP rel_expression"){
            son[0]->isCond = isCond;
            son[2]->isCond = isCond;
            if(son[1]->name == "||"){
                son[0]->lTrue = lTrue;
                son[0]->lFalse = newLabel()+"jmpfalse";
                son[2]->lTrue = lTrue;
                son[2]->lFalse = lFalse;
            }
            else{
                son[0]->lTrue = newLabel()+"jmptrue";
                son[0]->lFalse = lFalse;
                son[2]->lTrue = lTrue;
                son[2]->lFalse = lFalse;
            }
            son[0]->codeGeneration(t+1,os);
            if(isCond){
                if(son[1]->name == "||") os<< son[0]->lFalse<< ":\n"; 
                else  os<< son[0]->lTrue<< ":\n"; 
            }
            else os<< "\tPUSH CX\n";
            son[2]->codeGeneration(t+1,os);
            if(!isCond){
                os<< "\tPOP AX\n";
                if(son[1]->name=="||"){
                    string x = newLabel();
                    string y = newLabel();
                    string z = newLabel();
                    string a = newLabel();
                    os<< "\tCMP AX, 0\n";
                    os<< "\tJE "<< x<< "\n";
                    os<< "\tJMP "<< y<< "\n";
                    os<< x<< ":\n";
                    os<< "\tJCXZ "<< z<< " ;yay\n";
                    os<< y<< ":\n";
                    os<< "\tMOV CX, 1\n";
                    os<< "\tJMP "<< a<< ":\n";
                    os<< z<< ":\n";
                    os<< "\tMOV CX, 0\n";
                    os<< a<< ":\n";
                }
                else{
                    string x = newLabel();
                    string y = newLabel();
                    string z = newLabel();
                    os<< "\tCMP AX, 0\n";
                    os<< "\tJE "<< x<< "\n";
                    os<< "\tJCXZ "<< x<< " ;yay\n";
                    os<< "\tJMP "<< y<< "\n";
                    os<< x<< ":\n";
                    os<< "\tMOV CX, 0\n";
                    os<< "\tJMP "<< z<< ":\n";
                    os<< y<< ":\n";
                    os<< "\tMOV CX, 1\n";
                    os<< z<< ":\n";
                }
            }
        }
        if(makeRule()=="rel_expression : simple_expression"){
            son[0]->isCond = isCond;
            son[0]->lTrue = lTrue ;
            son[0]->lFalse = lFalse ;
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="rel_expression : simple_expression RELOP simple_expression"){ //cond propagation ends;
            son[0]->codeGeneration(t+1,os);
            os<< "\tPUSH CX\n";
            son[2]->codeGeneration(t+1,os);
            string opcode = getOpcode(son[1]->name);
            os<< "\tPOP AX\n";
            os<< "\tCMP AX, CX\n";
            if(lTrue == "") lTrue = newLabel();
            if(lFalse == "") lFalse = newLabel();
            os<< opcode + " " + lTrue +"\n";
            os<< "\tJMP "+lFalse+"\n";
            if(!isCond){
                os<< lTrue<< ":\n";
                os<< "\tMOV CX, 1\n";
                string leave = newLabel();
                os<< "\tJMP "<< leave<< "\n";
                os<< lFalse<< ":\n";
                os<< "\tMOV CX, 0\n";
                os<< leave<< ":\n";
            }
        }
        if(makeRule()=="simple_expression : term"){
            son[0]->isCond = isCond;
            son[0]->lTrue = lTrue ;
            son[0]->lFalse = lFalse ;
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="simple_expression : simple_expression ADDOP term"){//cond propagation ends
            son[0]->codeGeneration(t+1,os);
            os<< "\tPUSH CX\n";
            son[2]->codeGeneration(t+1,os);
            os<< "\tPOP AX\n";
            if(son[1]->name=="+") os<< "\tADD CX, AX\n";
            if(son[1]->name=="-") os<< "\tSUB AX, CX\n\tMOV CX, AX\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(makeRule()=="term : unary_expression"){
            son[0]->isCond = isCond;
            son[0]->lTrue = lTrue ;
            son[0]->lFalse = lFalse ;
            son[0]->codeGeneration(t+1,os);  
        }
        if(makeRule()=="term : term MULOP unary_expression"){//cond propagation ends
            son[0]->codeGeneration(t+1,os);
            os<< "\tPUSH CX\n";
            son[2]->codeGeneration(t+1,os);
            os<< "\tPOP AX\n";
            if(son[1]->name=="*"){
                os<< "\tIMUL CX\n";
                os<< "\tMOV CX, AX\n";
            }
            else if(son[1]->name=="/"){
                os<< "\tCWD\n";
                os<< "\tIDIV CX\n";
                os<< "\tMOV CX, AX\n";
            }
            else if(son[1]->name=="%"){
                os<< "\tCWD\n";
                os<< "\tIDIV CX\n";
                os<< "\tMOV CX, DX\n";
            }
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(makeRule()=="unary_expression : ADDOP unary_expression"){
            son[1]->isCond = isCond;
            son[1]->lTrue = lTrue ;
            son[1]->lFalse = lFalse ;
            son[1]->codeGeneration(t+1,os);
            if(son[0]->name=="-"){
                os<< "\tNEG CX\n";
            }
        }
        if(makeRule()=="unary_expression : NOT unary_expression"){
            son[1]->isCond = isCond;
            son[1]->lTrue = lFalse ;
            son[1]->lFalse = lTrue ;
            son[1]->codeGeneration(t+1,os);
            if(!isCond){
                string l0 = newLabel();
                string l1 = newLabel();
                os<< "\tJCXZ "+l1+"\n";
                os<< "\tMOV CX,0\n";
                os<< "\tJMP "<< l0<< "\n"; 
                os<< l1+":\n";
                os<< "\tMOV CX,1\n";
                os<< l0+":\n";
            }
        }
        if(makeRule()=="unary_expression : factor"){
            son[0]->isCond = isCond;
            son[0]->lTrue = lTrue ;
            son[0]->lFalse = lFalse ;
            son[0]->codeGeneration(t+1,os);
            
        }
        if(makeRule()=="factor : variable"){
            son[0]->codeGeneration(t+1,os);
            if(son[0]->isGlobal && !son[0]->isArray){
                if(!son[0]->isArray) os<< "\tMOV CX, "<< son[0]->name<< "\n";
            }
            else{
                os<< "\tMOV CX, [BP]\n";
                os<< "\tPOP BP\n";
            }
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(makeRule()=="factor : ID LPAREN argument_list RPAREN"){
            son[0]->codeGeneration(t+1,os);
            son[2]->codeGeneration(t+1,os);
            os<< "\tCALL "+son[0]->name+"\n";
            os<< "\tMOV CX, DX\n";
            os<< "\tADD SP, "<< son[2]->stackOffset<< "\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
            
        }
        if(makeRule()=="factor : LPAREN expression RPAREN"){
            son[1]->codeGeneration(t+1,os);
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(makeRule()=="factor : CONST_INT"){
            son[0]->codeGeneration(t+1,os);
            os<< "\tMOV CX, "+name+"\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(makeRule()=="factor : CONST_FLOAT"){
            son[0]->codeGeneration(t+1,os);
            os<< "\tMOV CX, "+name+"\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            } 
        }
        if(makeRule()=="factor : variable INCOP"){
            son[0]->codeGeneration(t+1,os);
            if(son[0]->isGlobal && !son[0]->isArray) os<< "\tMOV CX, "<< son[0]->name<< "\n";
            else os<< "\tMOV CX, [BP]\n";
            os<< "\tMOV AX, CX\n";
            if(son[1]->name=="++") os<< "\tINC CX\n";
            if(son[1]->name=="--") os<< "\tDEC CX\n";
            
            if(son[0]->isGlobal) os<< "\tMOV "<< son[0]->name<< ", CX\n";
            else{
                os<< "\tMOV [BP], CX\n";
                os<< "\tPOP BP\n";
            }
            os<< "\tMOV CX, AX\n";
            if(isCond){
                os<< "\tJCXZ "<< lFalse<< "\n";
                os<< "\tJMP "<< lTrue<< "\n";
            }
        }
        if(makeRule()=="argument_list : arguments"){
            son[0]->codeGeneration(t+1,os);
        }
        if(makeRule()=="arguments : arguments COMMA logic_expression"){
            son[0]->codeGeneration(t+1,os);
            son[2]->codeGeneration(t+1,os);
            os<< "\tPUSH CX ;func param\n";
        }
        if(makeRule()=="arguments : logic_expression"){
            son[0]->codeGeneration(t+1,os);
            os<< "\tPUSH CX ;func param\n";
        }
    }
    static int labelCnt;
    static int tempCnt;
    static vector<SymbolInfo*> globalVars;
};
