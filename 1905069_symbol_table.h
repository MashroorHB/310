#pragma once
#include<bits/stdc++.h>
#include "1905069_scope_table.h"
using namespace std;
typedef unsigned int ll;
typedef double db;


class SymbolTable{
private:
    ll tableSize;
    ScopeTable* top;

    string* strin(char d, ll cmd){
        char s[1000];
        cin.getline(s,1000);
        cout<< "Cmd "<< cmd<< ": "<< d<< "";
        for(ll i=0; i<strlen(s); i++) cout<< s[i];
        cout<< endl;
        string h;
        string* f = new string[3];
        ll cnt = 0;
        char *ptr=strtok(s," ");
            while(ptr!=NULL){
                h=ptr;
                if(cnt==2){
                    cnt=3;
                    break;
                }
                else{
                    f[cnt]=ptr;
                    cnt++;
                }
                ptr = strtok (NULL, " ");
            }
            char c = '0';
            c+=cnt;
            f[2]="";
            f[2]=f[2]+c;
        return f;
    }

    void showv(string* v){
        ll k=(v[2][0]-'0');
        for(ll i=0; i<k; i++){
            cout<< v[i]<< " ";
        }
        cout<< endl;
        return;
    }

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
    void insert(string name, string type){
        if(!top->lookUp(name, false)){
            top->insert(name,type);
        }
        else{
            cout<< "\t'"<< name<< "' already exists in the current ScopeTable\n";
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

    void print(bool all){
        ScopeTable* curr = top;
        curr->print();
        while(curr->getParent() && all){
            curr = curr->getParent();
            curr->print();
        }
        return;
    }

    friend ostream& operator<<(ostream& os, const SymbolTable dt){
        ScopeTable* curr = dt.top;
        while(curr){
            curr->print();
            cout<< endl;
            curr = curr->getParent();
        }
        return os;
    }

    void errorCntMsg(char cmd){
        cout<< "\tNumber of parameters mismatch for the command "<< cmd<< "\n";
        return;
    }

    void run(){
        char c;
        int p = 1;
        while(cin>> c){
            string* inp = strin(c,p);
            p++;
            ll k = (inp[2][0]-'0');
            //cout<< "Cmd "<< p++<< ": ";
            //cout<< c<< " "; showv(inp);
            if(c=='I'){
                if(k==2){
                    this->insert(inp[0],inp[1]);
                }
                else errorCntMsg(c);
            }
            else if(c=='D'){
                if(k==1){
                    bool f=this->remove(inp[0]);
                }
                else errorCntMsg(c);
            }
            else if(c=='L'){
                if(k==1){
                    SymbolInfo* f=this->lookUp(inp[0]);
                }
                else errorCntMsg(c);
            }
            else if(c=='P'){
                if(k==1){
                    if(inp[0]=="A") print(true);
                    else if(inp[0]=="C") print(false);
                    else{
                        cout<< "invalid print parameter\n";
                    }
                }
                else errorCntMsg(c);
            }
            else if(c=='S'){
                this->enterScope();
            }
            else if(c=='E'){
                this->exitScope();
            }
            else if(c=='Q'){
                break;
            }
            else{
                cout<< "\tWrong command symbol!!!\n\tOnly use I, D, L, P, S, E, Q to control!!!\n";
            }
        }
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

