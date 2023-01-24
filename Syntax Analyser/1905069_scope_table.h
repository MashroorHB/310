#pragma once
#include<bits/stdc++.h>
#include "1905069_symbol_info.h"
using namespace std;
typedef long long int ll;
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
    }
    ll sdbm_hash(string s) {
        ll h = 0, len = s.size();
        for (ll i=0; i<len; i++){
            h =((s[i])+(h<<6)+(h<<16)-h);
        }
        //cout<< s<< " "<<  h<< endl;
        return ((h%bucketSize)+bucketSize)%bucketSize;
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
        return true;
    }

    
    bool insert(SymbolInfo* si){

        ll h = sdbm_hash(si->getName());
        ll pos=1;
        if(!bucket[h]) bucket[h] = si;
        else{
            SymbolInfo* curr = bucket[h];
            pos++;
            while(curr->getNext()){
                curr=curr->getNext();
                pos++;
            }
            curr->setNext(si);
        }
        symbolCount++;
        return true;
    }


    SymbolInfo* lookUp(string name, bool show = true){
        ll h = sdbm_hash(name);
        ll pos=1;
        SymbolInfo* curr = bucket[h];


        if(!curr){
            //if(show) cout<< "\t'"<< name<< "' not found in any of the ScopeTables\n";
            return nullptr;
        }

        while(curr && curr->getName()!=name){
            pos++;
            curr = curr->getNext();
        }
        if(!curr){
            //if(show) cout<< "\t'"<< name<< "' not found in any of the ScopeTables\n";
            return nullptr;
        }
        return curr;
    }
    

    bool lookUp(SymbolInfo* si){
        ll h = sdbm_hash(si->getName());
        ll pos=1;
        SymbolInfo* curr = bucket[h];


        if(!curr){
            //if(show) cout<< "\t'"<< name<< "' not found in any of the ScopeTables\n";
            return false;
        }

        while(curr && curr->getName()!=si->getName()){
            pos++;
            curr = curr->getNext();
        }
        if(!curr){
            //if(show) cout<< "\t'"<< name<< "' not found in any of the ScopeTables\n";
            return false;
        }
        //if(show) cout<< "\t'"<< name<< "' found in ScopeTable# "<< this->id<< " at position "<< h+1<< ", "<< pos<< "\n";
        return true;
    }

    bool remove(string name){
        ll h = sdbm_hash(name);
        ll pos = 1;
        SymbolInfo* curr = bucket[h];

        if(!curr)  return false;

        if(bucket[h]->getName()==name){
            (bucket[h]->getNext())? bucket[h]=bucket[h]->getNext() : bucket[h]=nullptr;
            return true;
        }
        pos++;
        while(curr->getNext() && curr->getNext()->getName()!=name){
            curr = curr->getNext();
            pos++;
        }
        if(!curr->getNext()) return false;
        SymbolInfo* dlt = curr->getNext();
        curr->setNext(curr->getNext()->getNext());
        return true;
    }

    void print(ostream& os){
        os<< "\tScopeTable# "<< id<< "\n";
        for(ll i=0; i<bucketSize; i++){
            SymbolInfo* curr = bucket[i];
            if(!curr) continue;
            os<< "\t"<< i+1<< "--> ";
            while(curr){
                os<< *curr;
                curr = curr->getNext();
            }
            os<< "\n";
        }
    }

    friend ostream& operator<<(ostream& os, const ScopeTable dt){
        for(ll i=0; i<dt.bucketSize; i++){
            SymbolInfo* curr = dt.bucket[i];
            if(!curr) continue;
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
        delete [] bucket;
    }
    static ll cnt;
};
