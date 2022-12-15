#pragma once
#include<bits/stdc++.h>
#include "1905069_symbol_info.h"
using namespace std;
typedef unsigned int ll;
typedef double db;



class ScopeTable{
private:
    ll bucketSize;
    ll symbolCount;
    ScopeTable* parentScope;
    SymbolInfo** bucket;
    ll id;
public:
    ScopeTable(ll bucketSize, ScopeTable* parent){
        this->bucketSize = bucketSize;
        symbolCount = 0;
        parentScope = parent;
        bucket = new SymbolInfo*[bucketSize];
        for(ll i=0; i<bucketSize; i++) bucket[i]=nullptr;
        id = cnt+1;
        cnt++;
        cout<< "\tScopeTable# "<< id<< " created\n";
    }
    ll sdbm_hash(string s) {
        ll h = 0, len = s.size();
        for (ll i=0; i<len; i++){
            h =((s[i])+(h<<6)+(h<<16)-h)%bucketSize;
        }
        return h;
    }
    bool insert(string name, string type){

        SymbolInfo* newSymbol = this->lookUp(name,false);
        if(newSymbol) return false;

        newSymbol = new SymbolInfo(name,type);
        ll h = sdbm_hash(name);
        ll pos=1;
        if(!bucket[h]) bucket[h] = newSymbol;
        else{
            SymbolInfo* curr = bucket[h];
            pos++;
            while(curr->getNext()){
                curr=curr->getNext();
                pos++;
            }
            curr->setNext(newSymbol);
        }
        symbolCount++;
        cout<< "\tInserted in ScopeTable# "<< this->id<< " at position "<< h+1<< ", "<< pos<< "\n";
        return true;
    }

    SymbolInfo* lookUp(string name, bool show = true){
        ll h = sdbm_hash(name);
        ll pos=1;
        SymbolInfo* curr = bucket[h];


        if(!curr){
            if(show) cout<< "\t'"<< name<< "' not found in any of the ScopeTables\n";
            return nullptr;
        }

        while(curr && curr->getName()!=name){
            pos++;
            curr = curr->getNext();
        }
        if(!curr){
            if(show) cout<< "\t'"<< name<< "' not found in any of the ScopeTables\n";
            return nullptr;
        }
        if(show) cout<< "\t'"<< name<< "' found in ScopeTable# "<< this->id<< " at position "<< h+1<< ", "<< pos<< "\n";
        return curr;
    }

    bool remove(string name){
        ll h = sdbm_hash(name);
        ll pos = 1;
        SymbolInfo* curr = bucket[h];

        if(!curr) {
            cout<< "\tNot found in the current ScopeTable\n";
            return false;
        }

        if(bucket[h]->getName()==name){
            (bucket[h]->getNext())? bucket[h]=bucket[h]->getNext() : bucket[h]=nullptr;
            //delete curr;
            cout<< "\tDeleted '"<< name<< "' from ScopeTable# "<< this->id<< " at position "<< h+1<< ", "<< pos<< "\n";
            return true;
        }
        pos++;
        while(curr->getNext() && curr->getNext()->getName()!=name){
            curr = curr->getNext();
            pos++;
        }
        if(!curr->getNext()){
            cout<< "\tNot found in the current ScopeTable\n";
            return false;
        }
        SymbolInfo* dlt = curr->getNext();
        curr->setNext(curr->getNext()->getNext());
        //delete dlt;
        cout<< "\tDeleted at scope "<< this->id<< " bucket "<< h<< " position "<< pos<< "\n";
        return true;
    }

    void print(){
        cout<< "\tScopeTable# "<< id<< "\n";
        for(ll i=0; i<bucketSize; i++){
            cout<< "\t"<< i+1<< "--> ";
            SymbolInfo* curr = bucket[i];
            while(curr){
                cout<< *curr;
                curr = curr->getNext();
            }
            cout<< endl;
        }
    }

    friend ostream& operator<<(ostream& os, const ScopeTable dt){
        cout<< "\tScope Table# "<< dt.id<< "\n";
        for(ll i=0; i<dt.bucketSize; i++){
            cout<< "\t"<< i+1<< "-->";
            SymbolInfo* curr = dt.bucket[i];
            while(curr){
                cout<< " "<< *curr;
                curr = curr->getNext();
            }
            cout<< endl;
        }
        return os;
    }
    ScopeTable* getParent(){
        return parentScope;
    }
    ll getID(){
        return id;
    }

    ~ScopeTable(){
        cout<< "\tScopeTable# "<< id<< " removed"<< endl;
        delete [] bucket;
    }
    static ll cnt;
};

ll ScopeTable::cnt = 0;
