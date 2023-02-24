#include "1905069_symbol_info.h"

int SymbolInfo::labelCnt = 0;
int SymbolInfo::tempCnt = 0;
vector<SymbolInfo*> SymbolInfo::globalVars;

   


ostream& operator<<(ostream& os, const SymbolInfo& dt){
    if(dt.isDeclared) os<< "<"<< dt.name<<", FUNCTION, "<< dt.typeSpecifier<< "> ";
    else if(dt.isArray) os<< "<"<< dt.name<<", ARRAY, "<< dt.typeSpecifier<< "> ";
    else os<< "<"<< dt.name<<", "<< dt.typeSpecifier<< "> "; 
    return os;
}