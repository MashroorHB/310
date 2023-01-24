%option noyywrap

%{
#include<bits/stdc++.h>
#include "1905069_symbol_info.h"
#include "1905069_symbol_table.h"
#include "y.tab.h"


using namespace std;

int line_count=1;
int scope_line=0;
int error_count = 0;
int strtype;
string str;
string token;

extern ofstream parseout;
extern ofstream logout;
extern ofstream errorout;

extern SymbolTable *st;


string toUpper(string s){
    for(auto &c:s) c = toupper(c);
    return s;
}

string markerReturn(string s){
		if(s=="\\n")
			return "\n";
		else if(s=="\\t")
			return "\t";
		else if(s=="\\\"")
			return "\"";
		else if(s=="\\\'")
			return "\'";
		else if(s=="\\\\")
			return "\\";
		else if(s=="\\a")
			return "\a";
		else if(s=="\\f")
			return "\f";
		else if(s=="\\r")
			return "\r";
		else if(s=="\\b")
			return "\b";
		else if(s=="\\v")
			return "\v";
		else if(s=="\\0")
			return "\0";
		else
			return ""+s[0];
}

//extern double yylval;
%}


WhiteSpace [ \t\f\r\v]+ 
NewLine [\n]
Keyword if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue|println
Digit [0-9]
Digits {Digit}+
ConstInt {Digit}+
FloatWoE {ConstInt}(\.{Digits})?
DecimalFWE (\.{Digits})
IntWE {ConstInt}([eE][-+]?{Digits})?
Float1WE {FloatWoE}([eE][-+]?{Digits})?
Float2WE {DecimalFWE}([eE][-+]?{Digits})?
Float3WE {ConstInt}\.[eE]{ConstInt}
FloatWE {Float1WE}|{Float2WE}|{Float3WE}
Letter [A-Za-z_]
VarType {Letter}({Letter}|{Digit})*
Character ([^\\\'\"\n\r]|\\n|\\t|\\\"|\\\'|\\\\|\\a|\\f|\\r|\\b|\\v|\\0)
Markers (\\n|\\t|\\\"|\\\'|\\\\|\\a|\\f|\\r|\\b|\\v|\\0)
%s STRING
%s CMNT1
%s CMNT2

%%
<INITIAL>{WhiteSpace}+	{
	;
}

<INITIAL>{NewLine}	{
	line_count++;
}

<INITIAL>{ConstInt}[\.]?	{
	yylval.si = new SymbolInfo(yytext,"CONST_INT","INT",line_count,line_count,true,logout,{});
	return CONST_INT;
}

<INITIAL>{FloatWE}	{
	yylval.si = new SymbolInfo(yytext,"CONST_FLOAT","FLOAT",line_count,line_count,true,logout,{});
	return CONST_FLOAT;
}

<INITIAL>{FloatWE}(\.{Digits}?)(\.{Digits}?)	{
	logout<< "Error at line# "<< line_count<< ": TOO_MANY_DECIMAL_POINTS "<< yytext<< "\n";
	error_count++;
}

<INITIAL>{FloatWE}([eE][-+]?{Digits})(\.{Digits}?)+	{
	logout<< "Error at line# "<< line_count<< ": ILLFORMED_NUMBER "<< yytext<< "\n";
	error_count++;
}

<INITIAL>"if"	{
	yylval.si = new SymbolInfo(yytext,"IF","okay",line_count,line_count,true,logout,{});
	return IF;
}

<INITIAL>"for"	{
	yylval.si = new SymbolInfo(yytext,"FOR","okay",line_count,line_count,true,logout,{});
	return FOR;
}

<INITIAL>"do"	{
	yylval.si = new SymbolInfo(yytext,"DO","okay",line_count,line_count,true,logout,{});
	return DO;
}

<INITIAL>"int"	{
	yylval.si = new SymbolInfo(yytext,"INT","INT",line_count,line_count,true,logout,{});
	return INT;
}

<INITIAL>"float"	{
	yylval.si = new SymbolInfo(yytext,"FLOAT","FLOAT",line_count,line_count,true,logout,{});
	return FLOAT;
}

<INITIAL>"void"	{
	yylval.si = new SymbolInfo(yytext,"VOID","VOID",line_count,line_count,true,logout,{});
	return VOID;
}

<INITIAL>"switch"	{
	yylval.si = new SymbolInfo(yytext,"SWITCH","okay",line_count,line_count,true,logout,{});
	return SWITCH;
}

<INITIAL>"default"	{
	yylval.si = new SymbolInfo(yytext,"DEFAULT","okay",line_count,line_count,true,logout,{});
	return DEFAULT;
}

<INITIAL>"else"	{
	yylval.si = new SymbolInfo(yytext,"ELSE","okay",line_count,line_count,true,logout,{});
	return ELSE;
}

<INITIAL>"while"	{
	yylval.si = new SymbolInfo(yytext,"WHILE","okay",line_count,line_count,true,logout,{});
	return WHILE;
}

<INITIAL>"break"	{
	yylval.si = new SymbolInfo(yytext,"BREAK","okay",line_count,line_count,true,logout,{});
	return BREAK;
}

<INITIAL>"char"	{
	yylval.si = new SymbolInfo(yytext,"CHAR","okay",line_count,line_count,true,logout,{});
	return CHAR;
}

<INITIAL>"double"	{
	yylval.si = new SymbolInfo(yytext,"DOUBLE","okay",line_count,line_count,true,logout,{});
	return DOUBLE;
}

<INITIAL>"return"	{
	yylval.si = new SymbolInfo(yytext,"RETURN","okay",line_count,line_count,true,logout,{});
	return RETURN;
}

<INITIAL>"case"	{
	yylval.si = new SymbolInfo(yytext,"CASE","okay",line_count,line_count,true,logout,{});
	return CASE;
}

<INITIAL>"continue"	{
	yylval.si = new SymbolInfo(yytext,"CONTINUE","okay",line_count,line_count,true,logout,{});
	return CONTINUE;
}

<INITIAL>"println"	{
	yylval.si = new SymbolInfo(yytext,"PRINTLN","okay",line_count,line_count,true,logout,{});
	return PRINTLN;
}

<INITIAL>"+" 	| 
<INITIAL>"-"	{
	yylval.si = new SymbolInfo(yytext,"ADDOP","okay",line_count,line_count,true,logout,{});
	return ADDOP;
}

<INITIAL>"*" 	| 
<INITIAL>"/" 	| 
<INITIAL>"%"	{
	yylval.si = new SymbolInfo(yytext,"MULOP","okay",line_count,line_count,true,logout,{});
	return MULOP;
}


<INITIAL>"++" 	| 
<INITIAL>"--"	{
	yylval.si = new SymbolInfo(yytext,"INCOP","okay",line_count,line_count,true,logout,{});
	return INCOP;
}

<INITIAL>"<" 	| 
<INITIAL>"<=" 	| 
<INITIAL>">" 	| 
<INITIAL>">=" 	| 
<INITIAL>"==" 	| 
<INITIAL>"!="	{
	yylval.si = new SymbolInfo(yytext,"RELOP","okay",line_count,line_count,true,logout,{});
	return RELOP;
}

<INITIAL>"="	{
	yylval.si = new SymbolInfo(yytext,"ASSIGNOP","okay",line_count,line_count,true,logout,{});
	return ASSIGNOP;
}

<INITIAL>"&&" 	| 
<INITIAL>"||"	{
	yylval.si = new SymbolInfo(yytext,"LOGICOP","okay",line_count,line_count,true,logout,{});
	return LOGICOP;
}

<INITIAL>"&" 	| 
<INITIAL>"|" 	| 
<INITIAL>"^" 	| 
<INITIAL>"<<" 	| 
<INITIAL>">>"	{
	yylval.si = new SymbolInfo(yytext,"BITOP","okay",line_count,line_count,true,logout,{});
	return BITOP;
}

<INITIAL>"!"	{
	yylval.si = new SymbolInfo(yytext,"NOT","okay",line_count,line_count,true,logout,{});
	return NOT;
}

<INITIAL>"("	{
	yylval.si = new SymbolInfo(yytext,"LPAREN","okay",line_count,line_count,true,logout,{});
	return LPAREN;
}

<INITIAL>")"	{
	yylval.si = new SymbolInfo(yytext,"RPAREN","okay",line_count,line_count,true,logout,{});
	return RPAREN;
}

<INITIAL>"{"	{
	yylval.si = new SymbolInfo(yytext,"LCURL","okay",line_count,line_count,true,logout,{});
	return LCURL;
}

<INITIAL>"}"	{
	yylval.si = new SymbolInfo(yytext,"RCURL","okay",line_count,line_count,true,logout,{});
	return RCURL;
}

<INITIAL>"["	{
	yylval.si = new SymbolInfo(yytext,"LSQUARE","okay",line_count,line_count,true,logout,{});
	return LTHIRD;
}

<INITIAL>"]"	{
	yylval.si = new SymbolInfo(yytext,"RSQUARE","okay",line_count,line_count,true,logout,{});
	return RTHIRD;
}

<INITIAL>","	{
	yylval.si = new SymbolInfo(yytext,"COMMA","okay",line_count,line_count,true,logout,{});
	return COMMA;
}

<INITIAL>";"	{
	yylval.si = new SymbolInfo(yytext,"SEMICOLON","okay",line_count,line_count,true,logout,{});
	return SEMICOLON;
}

<INITIAL>{VarType}	{
	yylval.si = new SymbolInfo(yytext,"ID","okay",line_count,line_count,true,logout,{});
	return ID;
}

<INITIAL>{ConstInt}{VarType}	{
	errorout<< "Error at line# "<< line_count<< ": INVALID_ID_SUFFIX_NUM_PREFIX "<< yytext<< "\n";
	error_count++;
}

<INITIAL>{FloatWE}{VarType}	{
	errorout<< "Error at line# "<< line_count<< ": ILLFORMED_NUMBER "<< yytext<< "\n";
	error_count++;
}

<INITIAL>"\'"{Character}*"\r\n"	{
	str = "";
	str = str + yytext;
	str = str.substr(0,str.size()-1);
	errorout<< "Error at line# "<< line_count<< ": UNFINISHED_CONST_CHAR "<< str<< "\n";
	error_count++;
	line_count++;
}

<INITIAL>"\'\\t\'"	{
	str = "\'\t\'";
	str = str.substr(1,str.size()-2);
	yylval.si = new SymbolInfo(str,"CONST_CHAR","okay",line_count,line_count,true,logout,{});
	return CONST_CHAR;
}

<INITIAL>"\'"{Character}"\'"	{
	str = "";
	str = str + yytext;
	str = str.substr(1,str.size()-2);
	yylval.si = new SymbolInfo(markerReturn(str),"CONST_CHAR","okay",line_count,line_count,true,logout,{});
	return CONST_CHAR;
}

<INITIAL>"\'\'"	{
	errorout<< "Error at line# "<< line_count<< ": EMPTY_CONST_CHAR "<< yytext<< "\n";
	error_count++;
}

<INITIAL>"\'"{Character}{Character}+"\'"	{
	errorout<< "Error at line# "<< line_count<< ": MULTICHAR_CONST_CHAR "<< yytext<< "\n";
	error_count++;
}

<INITIAL>"\""	{
	token = "";
	str = "\"";
	strtype = 1;
	scope_line = 0;
	BEGIN STRING;
}

<STRING>"\""	{
	str = str + "\"";
	if(strtype==1){
		//tokenout<< "<SINGLE LINE STRING, "<< token<< ">\n";
		//logout<< "Line# "<< line_count<< ": Token <SINGLE LINE STRING> Lexeme "<< str<< " found\n";
	}
	else{
		//tokenout<< "<MULTI LINE STRING, "<< token<< ">\n";
		//logout<< "Line# "<< line_count<< ": Token <MULTI LINE STRING> Lexeme "<< str<< " found\n";
	}
	line_count+=scope_line;
	BEGIN 0;
}

<STRING>\\[\r]?\n	{
	token = token + "";
	str = str + "\\\n";
	strtype = 2;
	scope_line++;
}

<STRING>[\r]?\n	{
	line_count+=scope_line;
	errorout<< "Error at line# "<< line_count<< ": UNFINISHED_STRING "<< str<< "\n";
	error_count++;
	line_count++;
	BEGIN 0;
}

<STRING>{Markers}	{
	token = token + markerReturn(yytext);
	str = str + yytext;
}

<STRING>.	{
	token = token + yytext;
	str = str + yytext;
}

<STRING><<EOF>>	{
	line_count+=scope_line;
	errorout<< "Error at line# "<< line_count<< ": UNFINISHED_STRING "<< str<< "\n";
	error_count++;
	BEGIN 0;
}

<INITIAL>"//"	{
	str = "//";
	scope_line=0;
	BEGIN CMNT1;
}

<CMNT1>\\[\r]?\n	{
	//logout<< "03\n";
	str = str + "\\\n";
	scope_line++;
}

<CMNT1>[\r]?\n	{
	scope_line++;
	line_count+=scope_line;
	BEGIN 0;
}

<CMNT1><<EOF>>	{
	line_count+=scope_line;
	BEGIN 0;
}

<CMNT1>\\	{
	//logout<< "03\n";
	str = str + "\\";
	//scope_line++;
}

<CMNT1>.	{
	str = str + yytext;
}

<INITIAL>"/*"	{
	str = "/*";
	scope_line = 0;
	BEGIN CMNT2;
}

<CMNT2>"*/"	{
	str = str + "*/";
	line_count+=scope_line;
	BEGIN 0;
}

<CMNT2><<EOF>>	{

	line_count+=scope_line;
	errorout<< "Error at line# "<< line_count<< ": UNFINISHED_COMMENT "<< str<< "\n";
	error_count++;
	BEGIN 0;
}

<CMNT2>"\n"	{
	str = str + "\n";
	scope_line++;
}

<CMNT2>"\r"	{
	str = str + "\r";
}

<CMNT2>.	{
	str = str + yytext;
}

<INITIAL>.	{
	//errorout<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<"\n";
	error_count++;
}
