#pragma once
#include<bits/stdc++.h>
#include "1905069_symbol_table.h"
using namespace std;
typedef unsigned int ll;
typedef double db;

void initiateSymbolTable(){

    ifstream in("in18.txt");
    streambuf *cinbuf = std::cin.rdbuf();
    cin.rdbuf(in.rdbuf());

    ofstream out("out.txt");
    streambuf *coutbuf = std::cout.rdbuf();
    cout.rdbuf(out.rdbuf());

    ll n; cin>> n;
    SymbolTable G(n);
    G.run();
}

int main(){
    initiateSymbolTable();
}
