%{
#include "parser.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

%}

%%

"난대학시절"             { return START; }

"묵찌빠를"       { yylval.sval = _strdup("CBNU SOFTWARE"); return PSTRING; }

"전공했단사실" { yylval.sval = _strdup("2019038025"); return PSTRING; }

"네놈을이겨" { yylval.sval = _strdup("KANG HEE SOO"); return PSTRING; }

"눈물콧물" { yylval.sval = _strdup("COMPILER"); return PSTRING; }

"쏙다빼주마" { yylval.sval = _strdup("LECTURE"); return PSTRING; }

"난묵찌빠로" { return IF; } 

"유학까지" {yylval.ival = 0; return NUMBER;}

"다녀왔단" { return QUESTION; }

"사실" { yylval.sval = _strdup("I LOVE"); return PSTRING; }

"니놈을" { return ELS; }

"이겨" { yylval.sval = _strdup("I LOVE LEE JAE SUNG PROFESSOR"); return PSTRING; }

"(" 	{return LBRACKET;}
")" 	{return RBRACKET;}

"가문의이름"	{ yylval.sval = _strdup("THANK YOU SO MUCH!"); return PSTRING; }
"제로"		{return ASSIGN;}
"높이리"     { return END; }
"가위"                    { return INT; }
"바위"                    { return FLOAT; }
"보"                      { return CHAR; }
"묵묵"                      { return PLUS1; }
"찌"                      { return MULT; }
"빠"                      { return DIV; }
"정정"						{ return FUNC; }
"당당"						{ return CALL; }
"한"							{ return FEND; }
"게임"						{ return DEF; }
"묵"                       { return ADD; }
"찌빠"                       { return SUB; }
"남자는역시"              { return PRINT; }
"주먹"                    { return PRINT_END; }
"쏙다"                    { yylval.ival = 3; return NUMBER; }
"눈물"					{ return IVALUE; }
"콧물"					{ return FVALUE; }
"빼주마"					{ return SVALUE; }
"인정"					{ return BSN; }
">"						{ return BIG; }
">="					{ return BIGGER; }
"<"						{ return SMALL; }
"<="					{ return SMALLER; }
"다시해"					{return WHILE;}


\"[^\"]*\"              { yylval.sval = _strdup(yytext+1); yylval.sval[strlen(yylval.sval)-1] = 0; return RSTRING; }
[0-9]+                    { yylval.ival = atoi(yytext); return NUMBER; }
[a-zA-Z][a-zA-Z0-9]*      { yylval.sval = _strdup(yytext); return IDENTIFIER; }
;                    { return EOL; }
[ \t]                     { /* 공백무시 */ }
.                         { /* 감지안되는 문자는 무시한다. */ }

%%

int yywrap(void) {
    return 1;
}
