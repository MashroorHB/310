#pragma once
#include<bits/stdc++.h>
using namespace std;
typedef unsigned int ll;
typedef double db;


class SymbolInfo{
private:
    SymbolInfo* next;
    string name;
    string type;
public:
    SymbolInfo(){
        ;
    }

    SymbolInfo(string name, string type){
        this->name = name;
        this->type = type;
        this->next = nullptr;
    }
    string getName(){
        return name;
    }
    string getType(){
        return type;
    }
    void setNext(SymbolInfo* next){
        this->next = next;
    }
    SymbolInfo* getNext(){
        return this->next;
    }
    friend ostream& operator<<(ostream& os, const SymbolInfo& dt);
    ~SymbolInfo(){
        delete next;
    }
};

ostream& operator<<(ostream& os, const SymbolInfo& dt){
    cout<< "<"<< dt.name<< ","<< dt.type<< "> ";
    return os;
}
