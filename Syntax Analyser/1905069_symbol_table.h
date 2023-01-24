#pragma once
#include<bits/stdc++.h>
#include "1905069_scope_table.h"
using namespace std;
typedef long long int ll;
typedef double db;


class SymbolTable{
private:
    ll tableSize;
    ScopeTable* top;

public:
    SymbolTable(ll n){
        this->tableSize = n;
        top = new ScopeTable(tableSize,nullptr);
        ScopeTable::cnt = 1;
    }
    void enterScope(){
        ScopeTable* curr = new ScopeTable(tableSize, top);
        top = curr;
    }
    void exitScope(){
        if(top->getParent()){
            ScopeTable* curr = top->getParent();
            delete top;
            top = curr;
        }
        else{
            cout<< "\tScopeTable# "<< top->getID()<< " cannot be removed\n";
        }
    }
    bool insert(string name, string type, ostream& os = cout){
        if(!top->lookUp(name, false)){
            return top->insert(name,type);
        }
        else{
            os<< "\t"<< name<< " already exisits in the current ScopeTable\n";
            //cout<< "\t'"<< name<< "' already exists in the current ScopeTable\n";
            return false;
        }
    }

    bool insert(SymbolInfo* si){
        if(!top->lookUp(si)){
            return top->insert(si);
        }
        else{
            return false;
        }
    }

    bool remove(string name){
        return top->remove(name);
    }

    SymbolInfo* lookUp(string name){
        ScopeTable* curr = top;
        while(curr && !curr->lookUp(name,false)){
            curr = curr->getParent();
            if(!curr) break;
        }
        return (curr)? curr->lookUp(name) : top->lookUp(name);
    }

    void print(ostream& os, bool all=true){
        ScopeTable* curr = top;
        curr->print(os);
        while(curr->getParent() && all){
            curr = curr->getParent();
            curr->print(os);
        }
        return;
    }

    ll getID(){
        return top->getID();
    }

    friend ostream& operator<<(ostream& os, const SymbolTable dt){
        ScopeTable* curr = dt.top;
        while(curr){
            curr->print(os);
            cout<< endl;
            curr = curr->getParent();
        }
        return os;
    }

    void errorCntMsg(char cmd){
        cout<< "\tNumber of parameters mismatch for the command "<< cmd<< "\n";
        return;
    }

    ~SymbolTable(){
        ScopeTable* curr = top;
        while(curr){
            top = curr->getParent();
            delete curr;
            curr = top;
        }
    }
};

