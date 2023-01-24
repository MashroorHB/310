#pragma once
#include<bits/stdc++.h>
using namespace std;
typedef long long int ll;
typedef double db;


class SymbolInfo{
private:
    SymbolInfo* next;
    string name;
    string type;
    string typeSpecifier;
    bool isToken;
    bool isArray;
    bool isFunction;
    bool isDeclared;
    int lineStart;
    int lineEnd;
    vector<SymbolInfo*> expansion; 
    vector<SymbolInfo*> declarationlist; 
    vector<SymbolInfo*> parameterlist; 
public:
    SymbolInfo(){
        isToken = false;
        this->isArray = false;
        this->isDeclared = false;
        this->isFunction = false;
    }

    SymbolInfo(string name, string type, string typeSpecifier, int lineStart, int lineEnd, bool isToken, ostream& os, vector<SymbolInfo*> SI){
        this->name = name;
        this->type = type;
        this->typeSpecifier = typeSpecifier;
        this->next = nullptr;
        this->lineStart = lineStart;
        this->lineEnd = lineEnd;
        this->isToken = isToken;
        this->isArray = false;
        this->isDeclared = false;
        this->isFunction = false;
        if(isToken){
            os<< "Line# "<< lineStart<< ": Token <"<< type<< "> Lexeme "<< name<<" found\n";
        }
        else{
            os<< type<< " :"<< name<< " \n";
        }
        isToken = false;

        for(auto si: SI){
            expansion.push_back(si);
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
    int getStart(){
        return lineStart;
    }
    int getEnd(){
        return lineEnd;
    }
    SymbolInfo* getNext(){
        return this->next;
    }
    vector<SymbolInfo*> getExpansion(){
        return expansion;
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
    void setStart(int n){
        lineStart = n;
    }
    void setEnd(int n){
        lineEnd = n;
    }
    void setNext(SymbolInfo* next){
        this->next = next;
    }
    void addExpansion(vector<SymbolInfo*> SI){
        for(auto si: SI){
            expansion.push_back(si);
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
        if(isToken) os<< type<< " : "<< name<< "\t<Line: "<< lineStart<< ">\n";
        else os<< type<< " :"<< name<< "\t<Line: "<< lineStart<< "-"<< lineEnd<< ">\n";
        if(name=="error") return;
        for(SymbolInfo* si : expansion){
            si->printParseTree(t+1,os);
        }
    }

    string getStatement(){
        if(isToken) return name;
        string a = "";
        for(auto b : expansion){
            a+=b->getStatement();
        }
        return a;
    }


    friend ostream& operator<<(ostream& os, const SymbolInfo& dt);
    ~SymbolInfo(){
        delete next;
    }
};
