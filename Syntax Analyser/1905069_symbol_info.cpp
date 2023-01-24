#include "1905069_symbol_info.h"

ostream& operator<<(ostream& os, const SymbolInfo& dt){
    if(dt.isDeclared) os<< "<"<< dt.name<<", FUNCTION, "<< dt.typeSpecifier<< "> ";
    else if(dt.isArray) os<< "<"<< dt.name<<", ARRAY, "<< dt.typeSpecifier<< "> ";
    else os<< "<"<< dt.name<<", "<< dt.typeSpecifier<< "> "; 
    return os;
}