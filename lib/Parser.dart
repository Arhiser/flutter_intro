
enum LexemeType {
    LEFT_BRACKET, RIGHT_BRACKET,
    OP_PLUS, OP_MINUS, OP_MUL, OP_DIV,
    NUMBER,
    EOF
}

class Lexeme {
    LexemeType type;
    String value;

    Lexeme(LexemeType type, String value) {
        this.type = type;
        this.value = value;
    }
}

class ParseException implements Exception {
    String couse;
    ParseException(this.couse);
}

class LexemeBuffer {
    int _pos = 0;

    List<Lexeme> _lexemes;

    LexemeBuffer(List<Lexeme> lexemes) {
        this._lexemes = lexemes;
    }

    Lexeme next() {
        return _lexemes[_pos++];
    }

    void back() {
        _pos--;
    }

    int getPos() {
        return _pos;
    }
}

class Parser {

    List<Lexeme> lexAnalyze(String expText) {
        List<Lexeme> lexemes = new List();
        int pos = 0;
        while (pos< expText.length) {
            String c = expText[pos];
            switch (c) {
                case '(':
                    lexemes.add(Lexeme(LexemeType.LEFT_BRACKET, c));
                    pos++;
                    continue;
                case ')':
                    lexemes.add(Lexeme(LexemeType.RIGHT_BRACKET, c));
                    pos++;
                    continue;
                case '+':
                    lexemes.add(Lexeme(LexemeType.OP_PLUS, c));
                    pos++;
                    continue;
                case '-':
                    lexemes.add(Lexeme(LexemeType.OP_MINUS, c));
                    pos++;
                    continue;
                case '*':
                    lexemes.add(Lexeme(LexemeType.OP_MUL, c));
                    pos++;
                    continue;
                case '/':
                    lexemes.add(Lexeme(LexemeType.OP_DIV, c));
                    pos++;
                    continue;
                default:
                    if (c.codeUnitAt(0) <= '9'.codeUnitAt(0) && c.codeUnitAt(0) >= '0'.codeUnitAt(0)) {
                        StringBuffer sb = StringBuffer();
                        do {
                            sb.write(c);
                            pos++;
                            if (pos >= expText.length) {
                                break;
                            }
                            c = expText[pos];
                        } while (c.codeUnitAt(0) <= '9'.codeUnitAt(0) && c.codeUnitAt(0) >= '0'.codeUnitAt(0));
                        lexemes.add(new Lexeme(LexemeType.NUMBER, sb.toString()));
                    } else {
                        if (c != ' ') {
                            throw new ParseException("Unexpected character: " + c);
                        }
                        pos++;
                    }
            }
        }
        lexemes.add(Lexeme(LexemeType.EOF, ""));
        return lexemes;
    }

    int expr(LexemeBuffer lexemes) {
        Lexeme lexeme = lexemes.next();
        if (lexeme.type == LexemeType.EOF) {
            return 0;
        } else {
            lexemes.back();
            return plusminus(lexemes);
        }
    }

    int plusminus(LexemeBuffer lexemes) {
        int value = multdiv(lexemes);
        while (true) {
            Lexeme lexeme = lexemes.next();
            switch (lexeme.type) {
                case LexemeType.OP_PLUS:
                    value += multdiv(lexemes);
                    break;
                case LexemeType.OP_MINUS:
                    value -= multdiv(lexemes);
                    break;
                case LexemeType.EOF:
                case LexemeType.RIGHT_BRACKET:
                    lexemes.back();
                    return value;
                default:
                    throw new ParseException("Unexpected token: " + lexeme.value
                            + " at position: " + lexemes.getPos().toString());
            }
        }
    }

    int multdiv(LexemeBuffer lexemes) {
        int value = factor(lexemes);
        while (true) {
            Lexeme lexeme = lexemes.next();
            switch (lexeme.type) {
                case LexemeType.OP_MUL:
                    value *= factor(lexemes);
                    break;
                case LexemeType.OP_DIV:
                    value = (value / factor(lexemes)).round();
                    break;
                case LexemeType.EOF:
                case LexemeType.RIGHT_BRACKET:
                case LexemeType.OP_PLUS:
                case LexemeType.OP_MINUS:
                    lexemes.back();
                    return value;
                default:
                    throw new ParseException("Unexpected token: " + lexeme.value
                            + " at position: " + lexemes.getPos().toString());
            }
        }
    }

    int factor(LexemeBuffer lexemes) {
        Lexeme lexeme = lexemes.next();
        switch (lexeme.type) {
            case LexemeType.NUMBER:
                return int.parse(lexeme.value);
            case LexemeType.LEFT_BRACKET:
                int value = plusminus(lexemes);
                lexeme = lexemes.next();
                if (lexeme.type != LexemeType.RIGHT_BRACKET) {
                    throw new ParseException("Unexpected token: " + lexeme.value
                            + " at position: " + lexemes.getPos().toString());
                }
                return value;
            default:
                throw new ParseException("Unexpected token: " + lexeme.value
                        + " at position: " + lexemes.getPos().toString());
        }
    }
}
