/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.5.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 3 "sintatico.y"

#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
#include <stack>
#include <list>
using std::string;
using std::getline;
//colocar na tabela uma variavel pra pra verificar se a mesma foi inicializada ou nao

#define YYSTYPE atributos

using namespace std;
int var_temp_qnt;

typedef struct Variable{

	string tipo;
	string nome;
	string valor;
	string tmp;
} variable;

typedef struct Atributos
{
	string tipo;
	string label;
	string traducao_dec;
	string traducao;
	string tmp;
} atributos;

typedef struct{

	string implicita; //tradução após conversão
	string nomeVar; //nome da variável
	string varConvertida; //nome da variável que foi convertida
} structAux; //struct auxiliar utilizada para conversões

//variaveis
int valorVar = 1;
vector<variable> tabelaSimbolos; // Vetor global para armazenar as variáveis declaradas

//funções yacc
int yylex(void);
void yyerror(string);
string gentempcode();
bool verificaVariavel(string nome);
variable acharVariable(string nome);

//função geradora de label
string genLabel();

//funções de conversão
structAux implicitConversion(string tipo0, string tipo1, string nome0, string nome1);
string explicitConversion(string tipo0, string tipo1);

//funções para checar tipos específicos
string isBoolean(string tipo0, string tipo1);
int erroTipo(string tipo0, string tipo1);



#line 136 "y.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 1
#endif

/* Use api.header.include to #include this header
   instead of duplicating it here.  */
#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    DECLARACAO = 258,
    TK_MAIN = 259,
    TK_ENTRADA = 260,
    TK_SAIDA = 261,
    TK_ID = 262,
    TK_DEC_VAR = 263,
    TK_GLOBAL = 264,
    TK_TIPO_INT = 265,
    TK_TIPO_FLOAT = 266,
    TK_TIPO_BOOL = 267,
    TK_TIPO_CHAR = 268,
    TK_TIPO_STRING = 269,
    TK_CONV_FLOAT = 270,
    TK_CONV_INT = 271,
    TK_LE = 272,
    TK_HE = 273,
    TK_EQ = 274,
    TK_DIFF = 275,
    TK_UN_SUM = 276,
    TK_UN_SUB = 277,
    TK_NUN_SUM = 278,
    TK_NUN_SUB = 279,
    TK_NUN_MUL = 280,
    TK_NUN_DIV = 281,
    TK_CHAR = 282,
    TK_FLOAT = 283,
    TK_BOOL = 284,
    TK_NUM = 285,
    TK_ENTER = 286,
    TK_STRING = 287,
    TK_FIM = 288,
    TK_ERROR = 289
  };
#endif
/* Tokens.  */
#define DECLARACAO 258
#define TK_MAIN 259
#define TK_ENTRADA 260
#define TK_SAIDA 261
#define TK_ID 262
#define TK_DEC_VAR 263
#define TK_GLOBAL 264
#define TK_TIPO_INT 265
#define TK_TIPO_FLOAT 266
#define TK_TIPO_BOOL 267
#define TK_TIPO_CHAR 268
#define TK_TIPO_STRING 269
#define TK_CONV_FLOAT 270
#define TK_CONV_INT 271
#define TK_LE 272
#define TK_HE 273
#define TK_EQ 274
#define TK_DIFF 275
#define TK_UN_SUM 276
#define TK_UN_SUB 277
#define TK_NUN_SUM 278
#define TK_NUN_SUB 279
#define TK_NUN_MUL 280
#define TK_NUN_DIV 281
#define TK_CHAR 282
#define TK_FLOAT 283
#define TK_BOOL 284
#define TK_NUM 285
#define TK_ENTER 286
#define TK_STRING 287
#define TK_FIM 288
#define TK_ERROR 289

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */



#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))

/* Stored state numbers (used for stacks). */
typedef yytype_int8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && ! defined __ICC && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                            \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  4
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   51

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  50
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  8
/* YYNRULES -- Number of rules.  */
#define YYNRULES  23
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  42

#define YYUNDEFTOK  2
#define YYMAXUTOK   289


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    35,     2,     2,     2,     2,    38,     2,
      45,    46,    43,    41,     2,    42,     2,    44,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    49,
      39,    36,    40,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    47,    37,    48,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,    95,    95,   102,   109,   115,   121,   125,   129,   133,
     140,   154,   184,   186,   255,   322,   389,   459,   503,   572,
     579,   586,   593,   600
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 1
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "DECLARACAO", "TK_MAIN", "TK_ENTRADA",
  "TK_SAIDA", "TK_ID", "TK_DEC_VAR", "TK_GLOBAL", "TK_TIPO_INT",
  "TK_TIPO_FLOAT", "TK_TIPO_BOOL", "TK_TIPO_CHAR", "TK_TIPO_STRING",
  "TK_CONV_FLOAT", "TK_CONV_INT", "TK_LE", "TK_HE", "TK_EQ", "TK_DIFF",
  "TK_UN_SUM", "TK_UN_SUB", "TK_NUN_SUM", "TK_NUN_SUB", "TK_NUN_MUL",
  "TK_NUN_DIV", "TK_CHAR", "TK_FLOAT", "TK_BOOL", "TK_NUM", "TK_ENTER",
  "TK_STRING", "TK_FIM", "TK_ERROR", "'!'", "'='", "'|'", "'&'", "'<'",
  "'>'", "'+'", "'-'", "'*'", "'/'", "'('", "')'", "'{'", "'}'", "';'",
  "$accept", "S", "BLOCO", "COMANDOS", "COMANDO", "ATRIBUICAO", "LOGICOS",
  "E", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_int16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,    33,    61,   124,    38,    60,
      62,    43,    45,    42,    47,    40,    41,   123,   125,    59
};
# endif

#define YYPACT_NINF (-43)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-13)

#define yytable_value_is_error(Yyn) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int8 yypact[] =
{
      -4,     3,    15,   -23,   -43,   -25,   -14,    -3,   -43,   -26,
       8,    27,   -43,   -43,   -43,   -43,    -1,    -3,     0,     2,
      -6,   -43,     1,     9,   -43,   -43,   -43,   -43,     1,     1,
       1,     1,     1,   -43,   -24,     1,    -2,   -42,   -42,   -43,
     -43,   -24
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       0,     0,     0,     0,     1,     0,     0,     5,     2,     0,
      23,     0,    21,    20,    22,    19,     0,     5,     0,     0,
       0,     8,     0,    10,     3,     4,     7,     9,     0,     0,
       0,     0,     0,     6,    18,     0,    17,    13,    14,    15,
      16,    11
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -43,   -43,   -43,    31,   -43,   -43,   -43,   -19
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     2,     8,    16,    17,    18,    19,    20
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
       9,    31,    32,    34,    10,    11,     1,     3,    10,    36,
      37,    38,    39,    40,    28,     4,    41,    29,    30,    31,
      32,     6,     5,    21,    12,    13,    14,    15,    12,    13,
      14,    15,    28,     7,    23,    29,    30,    31,    32,    29,
      30,    31,    32,    33,    22,    35,   -12,    24,    25,    26,
       0,    27
};

static const yytype_int8 yycheck[] =
{
       3,    43,    44,    22,     7,     8,    10,     4,     7,    28,
      29,    30,    31,    32,    38,     0,    35,    41,    42,    43,
      44,    46,    45,    49,    27,    28,    29,    30,    27,    28,
      29,    30,    38,    47,     7,    41,    42,    43,    44,    41,
      42,    43,    44,    49,    36,    36,    49,    48,    17,    49,
      -1,    49
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    10,    51,     4,     0,    45,    46,    47,    52,     3,
       7,     8,    27,    28,    29,    30,    53,    54,    55,    56,
      57,    49,    36,     7,    48,    53,    49,    49,    38,    41,
      42,    43,    44,    49,    57,    36,    57,    57,    57,    57,
      57,    57
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_int8 yyr1[] =
{
       0,    50,    51,    52,    53,    53,    54,    54,    54,    54,
      55,    55,    56,    57,    57,    57,    57,    57,    57,    57,
      57,    57,    57,    57
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     5,     3,     2,     0,     2,     2,     2,     2,
       2,     4,     0,     3,     3,     3,     3,     3,     3,     1,
       1,     1,     1,     1
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YYUSE (yyoutput);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyo, yytoknum[yytype], *yyvaluep);
# endif
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyo, yytype, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[+yyssp[yyi + 1 - yynrhs]],
                       &yyvsp[(yyi + 1) - (yynrhs)]
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen(S) (YY_CAST (YYPTRDIFF_T, strlen (S)))
#  else
/* Return the length of YYSTR.  */
static YYPTRDIFF_T
yystrlen (const char *yystr)
{
  YYPTRDIFF_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYPTRDIFF_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYPTRDIFF_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            else
              goto append;

          append:
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (yyres)
    return yystpcpy (yyres, yystr) - yyres;
  else
    return yystrlen (yystr);
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYPTRDIFF_T *yymsg_alloc, char **yymsg,
                yy_state_t *yyssp, int yytoken)
{
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat: reported tokens (one for the "unexpected",
     one per "expected"). */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Actual size of YYARG. */
  int yycount = 0;
  /* Cumulated lengths of YYARG.  */
  YYPTRDIFF_T yysize = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[+*yyssp];
      YYPTRDIFF_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
      yysize = yysize0;
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYPTRDIFF_T yysize1
                    = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM)
                    yysize = yysize1;
                  else
                    return 2;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
    default: /* Avoid compiler warnings. */
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    /* Don't count the "%s"s in the final size, but reserve room for
       the terminator.  */
    YYPTRDIFF_T yysize1 = yysize + (yystrlen (yyformat) - 2 * yycount) + 1;
    if (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM)
      yysize = yysize1;
    else
      return 2;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          ++yyp;
          ++yyformat;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss;
    yy_state_t *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYPTRDIFF_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYPTRDIFF_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    goto yyexhaustedlab;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
# undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2:
#line 96 "sintatico.y"
                                {
					cout << "/*Salve Kappa!*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << 
					"//------------------ Escopo Variáveis ------------------\\\\ \n" << yyvsp[0].traducao_dec << "//------------------ Escopo Atribuições ------------------\\\\ \n" << yyvsp[0].traducao << "\treturn 0;\n}" << endl;
				}
#line 1459 "y.tab.c"
    break;

  case 3:
#line 103 "sintatico.y"
                                {
					yyval.traducao = yyvsp[-1].traducao;
					yyval.traducao_dec = yyvsp[-1].traducao_dec;
				}
#line 1468 "y.tab.c"
    break;

  case 4:
#line 110 "sintatico.y"
                                {
					yyval.traducao = yyvsp[-1].traducao + yyvsp[0].traducao;
					yyval.traducao_dec = yyvsp[-1].traducao_dec + yyvsp[0].traducao_dec;
				}
#line 1477 "y.tab.c"
    break;

  case 5:
#line 115 "sintatico.y"
                                {
					yyval.traducao = "";
					yyval.traducao_dec = "";
				}
#line 1486 "y.tab.c"
    break;

  case 6:
#line 122 "sintatico.y"
                                {
					yyval = yyvsp[-1];
				}
#line 1494 "y.tab.c"
    break;

  case 7:
#line 126 "sintatico.y"
                                {
					yyval = yyvsp[-1];
				}
#line 1502 "y.tab.c"
    break;

  case 8:
#line 130 "sintatico.y"
                                {
					yyval = yyvsp[-1];
				}
#line 1510 "y.tab.c"
    break;

  case 9:
#line 134 "sintatico.y"
                                {
					yyval = yyvsp[-1];
				}
#line 1518 "y.tab.c"
    break;

  case 10:
#line 141 "sintatico.y"
                                {
					if(verificaVariavel(yyvsp[0].label) != true){
						variable ref;
						ref.tipo = "";
						ref.nome = yyvsp[0].label;
						ref.valor = ""; //Forço a variável a receber uma string vazia pois irei fazer comparações utilizando a string "vazia"
						ref.tmp = genLabel();
						tabelaSimbolos.push_back(ref);//Salva na tabela de simbolos o tipo e o nome da variável
						//$$.traducao = $1.traducao;
					}else{
						yyerror("Você já declarou essa variável animal.\n");
					}			
				}
#line 1536 "y.tab.c"
    break;

  case 11:
#line 155 "sintatico.y"
                                {
					if(verificaVariavel(yyvsp[0].label) && yyvsp[0].tmp == ""){//Se eu não colocar $4.tmp == "" ele não irá interpretar quando alguma operação vier, pois quando tem alguma operação
						variable var1 = acharVariable(yyvsp[0].label);//o $4.tmp não fica = ""
						variable ref;
						if(var1.valor != ""){
							ref.tipo = var1.tipo;
							ref.nome = yyvsp[-2].label;
							ref.valor = var1.valor;
							ref.tmp = genLabel();
							tabelaSimbolos.push_back(ref);
							yyval.traducao_dec = yyvsp[0].traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
							yyval.traducao = yyvsp[0].traducao + "\t" + ref.tmp + " = " + var1.tmp + ";\n";

						}else{
							yyerror("Voce ainda não inicialiou a variavel que está sendo atribuida.\n");
						}
					}
					else{
						variable ref;
						ref.tipo = yyvsp[0].tipo;
						ref.nome = yyvsp[-2].label;
						ref.valor = yyvsp[0].label;
						ref.tmp = genLabel();
						tabelaSimbolos.push_back(ref);
					    yyval.traducao_dec = yyvsp[0].traducao_dec + "\t" + ref.tipo + " " + ref.tmp + ";\n";
						yyval.traducao = yyvsp[0].traducao + "\t" + ref.tmp + " = " + yyvsp[0].tmp + ";\n";
					}
				}
#line 1569 "y.tab.c"
    break;

  case 13:
#line 187 "sintatico.y"
                                {
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if(yyvsp[-2].label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if(yyvsp[0].label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Soma de inteiro --------------------------------------------------------//
					if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int + var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " + " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && yyvsp[0].tipo == "int"){//var int + num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " + " + yyvsp[0].tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && yyvsp[-2].tipo == "int"){//num + var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " + " + var2.tmp;
					}
					else if(yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "int"){//num + num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " + " + yyvsp[0].tmp;
					}
					//--------------------------------------------------------- Soma de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) + var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " + " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && yyvsp[0].tipo == "float" ) || (var1.tipo == "float" && yyvsp[0].tipo == "int" ) || (var1.tipo == "float" && yyvsp[0].tipo == "float" ))){//var a(int||float) + num(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " + " + yyvsp[0].tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && yyvsp[-2].tipo == "float" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "int" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "float" ))){//num(int||float) + var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = yyvsp[-2].tmp + " + " + var2.tmp;
					}
					else if((yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "float" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "int" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "float" )){//num(int||float) + num(int||float)
						string aux = genLabel();
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec + "\tfloat " + aux + ";\n";
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao + "\t" +  aux + " = (float)" + yyvsp[-2].tmp + ";\n";
						yyval.tipo = "float";
						yyval.tmp = aux + " + " + yyvsp[0].tmp;
					}
					else{
						yyerror("Soma não permitida\n");
					}
					
				}
#line 1642 "y.tab.c"
    break;

  case 14:
#line 256 "sintatico.y"
                                {
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if(yyvsp[-2].label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if(yyvsp[0].label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Subtração de inteiro --------------------------------------------------------//
					if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int - var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " - " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && yyvsp[0].tipo == "int"){//var int - num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " - " + yyvsp[0].tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && yyvsp[-2].tipo == "int"){//num - var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " - " + var2.tmp;
					}
					else if(yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "int"){//num - num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " - " + yyvsp[0].tmp;
					}
					//--------------------------------------------------------- Subtração de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) - var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " - " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && yyvsp[0].tipo == "float" ) || (var1.tipo == "float" && yyvsp[0].tipo == "int" ) || (var1.tipo == "float" && yyvsp[0].tipo == "float" ))){//var a(int||float) - num(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " - " + yyvsp[0].tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && yyvsp[-2].tipo == "float" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "int" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "float" ))){//num(int||float) - var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = yyvsp[-2].tmp + " - " + var2.tmp;
					}
					else if((yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "float" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "int" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "float" )){//num(int||float) + num(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = yyvsp[-2].tmp + " - " + yyvsp[0].tmp;
					}
					else{
						yyerror("Subtração não permitida\n");
					}
				}
#line 1713 "y.tab.c"
    break;

  case 15:
#line 323 "sintatico.y"
                                {
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if(yyvsp[-2].label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if(yyvsp[0].label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Multiplicação de inteiro --------------------------------------------------------//
					if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int * var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " * " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && yyvsp[0].tipo == "int"){//var int * num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " * " + yyvsp[0].tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && yyvsp[-2].tipo == "int"){//num * var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " * " + var2.tmp;
					}
					else if(yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "int"){//num * num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " * " + yyvsp[0].tmp;
					}
					//--------------------------------------------------------- Multiplicação de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) * var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " * " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && yyvsp[0].tipo == "float" ) || (var1.tipo == "float" && yyvsp[0].tipo == "int" ) || (var1.tipo == "float" && yyvsp[0].tipo == "float" ))){//var a(int||float) * num(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " * " + yyvsp[0].tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && yyvsp[-2].tipo == "float" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "int" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "float" ))){//num(int||float) * var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = yyvsp[-2].tmp + " * " + var2.tmp;
					}
					else if((yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "float" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "int" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "float" )){//num(int||float) * num(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = yyvsp[-2].tmp + " * " + yyvsp[0].tmp;
					}
					else{
						yyerror("Multiplicação não permitida\n");
					}
				}
#line 1784 "y.tab.c"
    break;

  case 16:
#line 390 "sintatico.y"
                                {
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if(yyvsp[-2].label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if(yyvsp[0].label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Divisão de inteiro --------------------------------------------------------//
					if(yyvsp[0].label == "0" || var2.valor == "0"){
						yyerror("Impossível dividir por zero\n");
					}
					else if(var1.valor != "" && var2.valor != "" && var1.tipo == "int" && var2.tipo == "int"){//var int / var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " / " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "int" && yyvsp[0].tipo == "int"){//var int / num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = var1.tmp + " / " + yyvsp[0].tmp;
					}
					else if(var2.valor != "" && var2.tipo == "int" && yyvsp[-2].tipo == "int"){//num / var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " / " + var2.tmp;
					}
					else if(yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "int"){//num / num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "int";
						yyval.tmp = yyvsp[-2].tmp + " / " + yyvsp[0].tmp;
					}
					//--------------------------------------------------------- Divisão de float ---------------------------------------------------------//
					else if(var1.valor != "" && var2.valor != "" && ((var1.tipo == "int" && var2.tipo == "float") || (var1.tipo == "float" && var2.tipo == "int") || (var1.tipo == "float" && var2.tipo == "float"))){//var a(int||float) / var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " / " + var2.tmp;
					}
					else if(var1.valor != "" && ((var1.tipo == "int" && yyvsp[0].tipo == "float" ) || (var1.tipo == "float" && yyvsp[0].tipo == "int" ) || (var1.tipo == "float" && yyvsp[0].tipo == "float" ))){//var a(int||float) / num(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = var1.tmp + " / " + yyvsp[0].tmp;
					}	
					else if(var2.valor != "" && ((var2.tipo == "int" && yyvsp[-2].tipo == "float" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "int" ) || (var2.tipo == "float" && yyvsp[-2].tipo == "float" ))){//num(int||float) / var a(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = yyvsp[-2].tmp + " / " + var2.tmp;
					}
					else if((yyvsp[-2].tipo == "int" && yyvsp[0].tipo == "float" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "int" ) || (yyvsp[-2].tipo == "float" && yyvsp[0].tipo == "float" )){//num(int||float) / num(int||float)
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "float";
						yyval.tmp = yyvsp[-2].tmp + " / " + yyvsp[0].tmp;
					}
					else{
						yyerror("Divisão não permitida\n");
					}
				}
#line 1858 "y.tab.c"
    break;

  case 17:
#line 460 "sintatico.y"
                                {	
					variable var1;
					variable var2;
					//Não preciso verificar se a variável já foi declarada, pois já foi feita essa verificação.
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o primeiro termo é alguma variável já declarada
						if(yyvsp[-2].label == tabelaSimbolos[i].nome){
							var1 = tabelaSimbolos[i];		
						}
						if(yyvsp[0].label == tabelaSimbolos[i].nome){//For que verifica se o segundo termo é alguma variável já declarada
							var2 = tabelaSimbolos[i];		
						}
					}
					//-------------------------------------------------------- Comparação de Boolean --------------------------------------------------------//
					if(var1.valor != "" && var2.valor != "" && var1.tipo == "bool" && var2.tipo == "bool"){//var int + var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "bool";
						yyval.tmp = var1.tmp + " && " + var2.tmp;
					}
					else if(var1.valor != "" && var1.tipo == "bool" && yyvsp[0].tipo == "bool"){//var int + num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "bool";
						yyval.tmp = var1.tmp + " && " + yyvsp[0].tmp;
					}
					else if(var2.valor != "" && var2.tipo == "bool" && yyvsp[-2].tipo == "bool"){//num + var int
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "bool";
						yyval.tmp = yyvsp[-2].tmp + " && " + var2.tmp;
					}
					else if(yyvsp[-2].tipo == "bool" && yyvsp[0].tipo == "bool"){//num + num
						yyval.traducao_dec = yyvsp[-2].traducao_dec + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[-2].traducao + yyvsp[0].traducao;
						yyval.tipo = "bool";
						yyval.tmp = yyvsp[-2].tmp + " && " + yyvsp[0].tmp;
					}
					else
					{
						yyerror("Algo deu errado.");
					}
										
				}
#line 1906 "y.tab.c"
    break;

  case 18:
#line 504 "sintatico.y"
                                {
					bool encontrei = false;
					bool found = false;
					variable var1;
					variable var2;
					int i;
					for(i = 0; i < tabelaSimbolos.size();i++){//For que localiza a variavel na tabela de simbolos
						if(tabelaSimbolos[i].nome == yyvsp[-2].label){
							var1 = tabelaSimbolos[i];
							encontrei = true;
							break;
						}					
					}
					for(int y = 0; y < tabelaSimbolos.size();y++){//For que irá servir para verificar se o termo a ser atribuido é uma variável já declarada
						if(tabelaSimbolos[y].nome == yyvsp[0].label){
							var2 = tabelaSimbolos[y];
							found = true;
							break;
						}					
					}
					//------------------------------------------------ Atribuições sem valores iniciais ------------------------------------------------//
					if(encontrei == true && found == true && var1.tipo == "" && var2.tipo != "" && yyvsp[0].tmp == ""){//Se o $3.tmp for igual a vazio a atribuição é somente de variável
						tabelaSimbolos[i].valor = var2.valor;													//e não da soma de duas coisas, pois se fosse da soma de duas coisas
						tabelaSimbolos[i].tipo = var2.tipo;														//o $3.tmp iria ter valor			
						yyval.traducao_dec ="\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n";
						yyval.traducao =  yyvsp[0].traducao + "\t" + tabelaSimbolos[i].tmp + " = " + var2.tmp + ";\n";
						//cout<<"Tst1"<<endl;
					}
					else if(encontrei == true && var1.tipo == ""){
						tabelaSimbolos[i].valor = yyvsp[0].label;
						tabelaSimbolos[i].tipo = yyvsp[0].tipo;
						yyval.traducao_dec = "\t" + tabelaSimbolos[i].tipo + " " + tabelaSimbolos[i].tmp + ";\n" + yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[0].traducao + "\t" + tabelaSimbolos[i].tmp + " = " + yyvsp[0].tmp +  ";\n";
						//cout<<"Tst2"<<endl;
					}
					//------------------------------------------------ Atribuições com valores iniciais ------------------------------------------------//
					else if(encontrei == true && found == true && var1.tipo == "float" && (var2.tipo == "int" || var2.tipo == "float") ){//If que verifica se a variavel que está recebendo
						tabelaSimbolos[i].valor = var2.valor;//a atribuição é do tipo float, permitindo ser adicionado uma variável do tipo int ou float
						//Não preciso do traducao_dec pois a variavel que está recebendo a atribuição e a variável que está sendo atribuida, já foram inicializadas
						yyval.traducao_dec = yyvsp[0].traducao_dec;
						yyval.traducao = "\t" + tabelaSimbolos[i].tmp + " = " + var2.tmp + ";\n";//Não preciso propagar o $3.traducao pois eles ja foram feitos antes
						cout<<"Tst3"<<endl;
					}
					else if(encontrei == true && var1.tipo == "float" && (yyvsp[0].tipo == "int" || yyvsp[0].tipo == "float")){//Verifica se a variável que está recebendo a atribuição é do tipo
						tabelaSimbolos[i].valor = yyvsp[0].label;//float e se o valor qualquer adicionado é do tipo int ou float para fazer a atribuição
					 	yyval.traducao_dec = yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[0].traducao + "\t" + tabelaSimbolos[i].tmp + " = " + yyvsp[0].tmp + ";\n" ;
						//cout<<"Tst4"<<endl;
					}
					else if(encontrei == true && found == true && var1.tipo != "" && var1.tipo == var2.tipo){//Verifica se o termo a ser atribuido é do mesmo tipo da variável a recebe-lo
						tabelaSimbolos[i].valor = var2.valor;
						yyval.traducao_dec = yyvsp[0].traducao_dec;
						yyval.traducao ="\t" + tabelaSimbolos[i].tmp + " = " + var2.tmp + ";\n";//Salva o novo valor na variavel e na tabela de simbolos
						//cout<<"Tst5"<<endl;
					}
					else if(encontrei == true && found == false && var1.tipo == yyvsp[0].tipo){//Verifica se o termo a ser atribuido é um valor qualquer
						tabelaSimbolos[i].valor = yyvsp[0].label;
						yyval.traducao_dec = yyvsp[0].traducao_dec;
						yyval.traducao = yyvsp[0].traducao + "\t" + tabelaSimbolos[i].tmp + " = " + yyvsp[0].tmp + ";\n";
						//cout<<"Tst6"<<endl;
					}
					else if(found == true && var2.valor == ""){
						yyerror("Você não inicializou a variável " + yyvsp[0].label + ".\n");
					}
					else{
						yyerror("Atribuição não permitida, tipo da variável a ser atribuida é diferente do tipo de atribuição.\n");
					}
				}
#line 1979 "y.tab.c"
    break;

  case 19:
#line 573 "sintatico.y"
                                {
					yyval.tipo = "int";
					yyval.tmp = genLabel();
					yyval.traducao_dec = "\t" + yyval.tipo + " " + yyval.tmp + ";\n";
					yyval.traducao = "\t" + yyval.tmp + " = " + yyval.label + ";\n";
				}
#line 1990 "y.tab.c"
    break;

  case 20:
#line 580 "sintatico.y"
                                {
					yyval.tipo = "float";
					yyval.tmp = genLabel();
					yyval.traducao_dec = "\t" + yyval.tipo + " " + yyval.tmp + ";\n";
					yyval.traducao = "\t" + yyval.tmp + " = " + yyval.label + ";\n";
				}
#line 2001 "y.tab.c"
    break;

  case 21:
#line 587 "sintatico.y"
                                {
					yyval.tipo = "char";
					yyval.tmp = genLabel();
					yyval.traducao_dec = "\t" + yyval.tipo + " " + yyval.tmp + ";\n";
					yyval.traducao = "\t" + yyval.tmp + " = " + yyval.label + ";\n";
				}
#line 2012 "y.tab.c"
    break;

  case 22:
#line 594 "sintatico.y"
                                {
					yyval.tipo = "bool";
					yyval.tmp = genLabel();
					yyval.traducao_dec = "\t" + yyval.tipo + " " + yyval.tmp + ";\n";
					yyval.traducao = "\t" + yyval.tmp + " = " + yyval.label + ";\n";
				}
#line 2023 "y.tab.c"
    break;

  case 23:
#line 601 "sintatico.y"
                                {	
					bool encontrei = false;
					variable variavel;
					for(int i = 0; i < tabelaSimbolos.size();i++){//For que verifica se o nome de uma variável já foi declarado antes
						if(tabelaSimbolos[i].nome == yyvsp[0].label){
							variavel = tabelaSimbolos[i];
							encontrei = true;
							yyval.tipo = variavel.tipo;//Salva o tipo da variavel
						}					
					}

					if(!encontrei){
						yyerror("Você não declarou a variável " + yyvsp[0].label + "\n");	
					}
				}
#line 2043 "y.tab.c"
    break;


#line 2047 "y.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = YY_CAST (char *, YYSTACK_ALLOC (YY_CAST (YYSIZE_T, yymsg_alloc)));
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;


#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif


/*-----------------------------------------------------.
| yyreturn -- parsing is finished, return the result.  |
`-----------------------------------------------------*/
yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[+*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 618 "sintatico.y"


#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + std::to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	yyparse();

	return 0;
}

void yyerror(string MSG)
{
	cout << MSG << endl;
	exit (0);
}	

string genLabel(){

	return "temp" + to_string(valorVar++);
}

int erroTipo(string tipo0, string tipo1)
{
	if (tipo1 != tipo0)
	{
		yyerror("Tipo de variaveis incompativeis.\n");

	}
	
	return 0;
}

bool verificaVariavel(string nome){
	for(int i = 0; i < tabelaSimbolos.size(); i++){
		if(tabelaSimbolos[i].nome == nome){
			return true;
		}
	}
	return false;
}

variable acharVariable(string nome){

	variable var1;
	var1.nome = "";
	var1.tipo = "";
	var1.valor = "";
	var1.tmp = "";

	for(int i = 0; i < tabelaSimbolos.size(); i++){
		if(tabelaSimbolos[i].nome == nome){
			return tabelaSimbolos[i];
		}
	}
	return var1;
}
