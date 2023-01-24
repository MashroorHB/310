%option noyywrap

%{
#include<bits/stdc++.h>
#include "1905069_symbol_table.h"

using namespace std;

int line_count=1;
int scope_line=0;
int error_count = 0;
int strtype;
string str;
string token;

ofstream logout;
ofstream tokenout;

SymbolTable *st;


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

%}

WhiteSpace [ \t\f\r\v]+ 
NewLine [\n]
Keyword if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue
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
	tokenout<< "<CONST_INT, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <CONST_INT> Lexeme "<< yytext<< " found\n";
}

<INITIAL>{FloatWE}	{
	tokenout<< "<CONST_FLOAT, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <CONST_FLOAT> Lexeme "<< yytext<< " found\n";
}

<INITIAL>{FloatWE}(\.{Digits}?)(\.{Digits}?)	{
	//tokenout<< "<CONST_FLOAT, "<< yytext<< ">\n";
	logout<< "Error at line# "<< line_count<< ": TOO_MANY_DECIMAL_POINTS "<< yytext<< "\n";
	error_count++;
}

<INITIAL>{FloatWE}([eE][-+]?{Digits})(\.{Digits}?)+	{
	//tokenout<< "<CONST_FLOAT, "<< yytext<< ">\n";
	logout<< "Error at line# "<< line_count<< ": ILLFORMED_NUMBER "<< yytext<< "\n";
	error_count++;
}

<INITIAL>{Keyword}	{
	tokenout<< "<"<< toUpper(yytext)<< ", "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <"<< toUpper(yytext)<< "> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"+" 	| 
<INITIAL>"-"	{
	tokenout<< "<ADDOP, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <ADDOP> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"*" 	| 
<INITIAL>"/" 	| 
<INITIAL>"%"	{
	tokenout<< "<MULOP, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <MULOP> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"++" 	| 
<INITIAL>"--"	{
	tokenout<< "<INCOP, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <INCOP> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"<" 	| 
<INITIAL>"<=" 	| 
<INITIAL>">" 	| 
<INITIAL>">=" 	| 
<INITIAL>"==" 	| 
<INITIAL>"!="	{
	tokenout<< "<RELOP, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <RELOP> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"="	{
	tokenout<< "<ASSIGNOP, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <ASSIGNOP> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"&&" 	| 
<INITIAL>"||"	{
	tokenout<< "<LOGICOP, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <LOGICOP> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"&" 	| 
<INITIAL>"|" 	| 
<INITIAL>"^" 	| 
<INITIAL>"<<" 	| 
<INITIAL>">>"	{
	tokenout<< "<BITOP, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <BITOP> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"!"	{
	tokenout<< "<NOT, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <NOT> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"("	{
	tokenout<< "<LPAREN, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <LPAREN> Lexeme "<< yytext<< " found\n";
}

<INITIAL>")"	{
	tokenout<< "<RPAREN, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <RPAREN> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"{"	{
	tokenout<< "<LCURL, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <LCURL> Lexeme "<< yytext<< " found\n";
	st->enterScope();
}

<INITIAL>"}"	{
	tokenout<< "<RCURL, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <RCURL> Lexeme "<< yytext<< " found\n";
	st->exitScope();
}

<INITIAL>"["	{
	tokenout<< "<LSQUARE, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <LSQUARE> Lexeme "<< yytext<< " found\n";
}

<INITIAL>"]"	{
	tokenout<< "<RSQUARE, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <RSQUARE> Lexeme "<< yytext<< " found\n";
}

<INITIAL>","	{
	tokenout<< "<COMMA, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <COMMA> Lexeme "<< yytext<< " found\n";
}

<INITIAL>";"	{
	tokenout<< "<SEMICOLON, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <SEMICOLON> Lexeme "<< yytext<< " found\n";
}

<INITIAL>{VarType}	{
	tokenout<< "<ID, "<< yytext<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <ID> Lexeme "<< yytext<< " found\n";
	if(st->insert(yytext,"ID",logout)) st->print(logout,true);
}

<INITIAL>{ConstInt}{VarType}	{
	logout<< "Error at line# "<< line_count<< ": INVALID_ID_SUFFIX_NUM_PREFIX "<< yytext<< "\n";
	error_count++;
}

<INITIAL>{FloatWE}{VarType}	{
	//tokenout<< "<CONST_FLOAT, "<< yytext<< ">\n";
	logout<< "Error at line# "<< line_count<< ": ILLFORMED_NUMBER "<< yytext<< "\n";
	error_count++;
}

<INITIAL>"\'"{Character}*"\r\n"	{
	str = "";
	str = str + yytext;
	str = str.substr(0,str.size()-1);
	logout<< "Error at line# "<< line_count<< ": UNFINISHED_CONST_CHAR "<< str<< "\n";
	error_count++;
	line_count++;
}

<INITIAL>"\'\\t\'"	{
	str = "\'\t\'";
	str = str.substr(1,str.size()-2);
	tokenout<< "<CONST_CHAR, "<< str<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <CONST_CHAR> Lexeme "<< str<< " found\n";
}

<INITIAL>"\'"{Character}"\'"	{
	str = "";
	str = str + yytext;
	str = str.substr(1,str.size()-2);
	tokenout<< "<CONST_CHAR, "<< markerReturn(str)<< ">\n";
	logout<< "Line# "<< line_count<< ": Token <CONST_CHAR> Lexeme "<< markerReturn(str)<< " found\n";
}

<INITIAL>"\'\'"	{
	logout<< "Error at line# "<< line_count<< ": EMPTY_CONST_CHAR "<< yytext<< "\n";
	error_count++;
}

<INITIAL>"\'"{Character}{Character}+"\'"	{
	logout<< "Error at line# "<< line_count<< ": MULTICHAR_CONST_CHAR "<< yytext<< "\n";
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
		tokenout<< "<SINGLE LINE STRING, "<< token<< ">\n";
		logout<< "Line# "<< line_count<< ": Token <SINGLE LINE STRING> Lexeme "<< str<< " found\n";
	}
	else{
		tokenout<< "<MULTI LINE STRING, "<< token<< ">\n";
		logout<< "Line# "<< line_count<< ": Token <MULTI LINE STRING> Lexeme "<< str<< " found\n";
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
	logout<< "Error at line# "<< line_count<< ": UNFINISHED_STRING "<< str<< "\n";
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
	logout<< "Error at line# "<< line_count<< ": UNFINISHED_STRING "<< str<< "\n";
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
	logout<< "Line# "<< line_count<< ": Token <SINGLE LINE COMMENT> Lexeme "<< str<< " found\n";
	line_count+=scope_line;
	BEGIN 0;
}

<CMNT1><<EOF>>	{
	logout<< "Line# "<< line_count<< ": Token <SINGLE LINE COMMENT> Lexeme "<< str<< " found\n";
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
	logout<< "Line# "<< line_count<< ": Token <MULTI LINE COMMENT> Lexeme "<< str<< " found\n";
	line_count+=scope_line;
	BEGIN 0;
}

<CMNT2><<EOF>>	{

	line_count+=scope_line;
	logout<< "Error at line# "<< line_count<< ": UNFINISHED_COMMENT "<< str<< "\n";
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
	logout<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<"\n";
	error_count++;
}

%%

int main(int argc, char** argv) {

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout.open("1905069_log.txt");
	tokenout.open("1905069_token.txt");

	st = new SymbolTable(10);


	yyin= fin;
	yylex();
	st->print(logout,true);
	logout<<"Total lines: "<< line_count<<"\n";
	logout<<"Total errors: "<< error_count<<"\n";


	delete st;
	fclose(yyin);
	tokenout.close();
	logout.close();
	return 0;
}
