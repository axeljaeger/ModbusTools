#ifndef SERVER_SCRIPTEDITOR_H
#define SERVER_SCRIPTEDITOR_H

#include <QPlainTextEdit>

#include "server_scripthighlighter.h"

class mbServerScriptHighlighter;

class mbServerScriptEditor : public QPlainTextEdit
{
    Q_OBJECT

public:
    struct Settings
    {
        Settings() {}
        Settings(bool vwordWrap      ,
                 bool vuseLineNumbers,
                 int  vtabSpaces     ,
                 const QString &vfont,
                 const mbServerScriptHighlighter::ColorFormats &vcolorFormats) :
            wordWrap      (vwordWrap      ),
            useLineNumbers(vuseLineNumbers),
            tabSpaces     (vtabSpaces     ),
            font          (vfont          ),
            colorFormats  (vcolorFormats  )
        {
        }
        bool    wordWrap      ;
        bool    useLineNumbers;
        int     tabSpaces     ;
        QString font          ;
        mbServerScriptHighlighter::ColorFormats colorFormats;
    };

public:
    struct Defaults
    {
        const Settings settings;

        Defaults();
        static const Defaults &instance();
    };


public:
    mbServerScriptEditor(const mbServerScriptEditor::Settings settings, QWidget *parent = nullptr);

public:
    bool wordWrap() const;
    void setWordWrap(bool wrap);
    bool useLineNumbers() const;
    void setUseLineNumbers(bool use);
    int tabSpaces() const;
    void setTabSpaces(int spaces);
    QString fontString() const;
    void setFontString(const QString &font);

    mbServerScriptEditor::Settings settings() const;
    void setSettings(const mbServerScriptEditor::Settings &s);

public:
    void lineNumberAreaPaintEvent(QPaintEvent *event);
    int lineNumberAreaWidth();

protected:
    void resizeEvent(QResizeEvent *event) override;
    void keyPressEvent(QKeyEvent *event) override;

protected Q_SLOTS:
    void updateLineNumberAreaWidth(int newBlockCount);
    void highlightCurrentLine();
    void updateLineNumberArea(const QRect &rect, int dy);

protected:
    void insertFromMimeData(const QMimeData *source) override;

private:
    struct
    {
        int tabSpaces;
    } m_settings;
    QWidget *lineNumberArea;
    mbServerScriptHighlighter *m_highlighter;

    class LineNumberArea : public QWidget
    {
    public:
        LineNumberArea(mbServerScriptEditor *editor);
        QSize sizeHint() const;

    protected:
        void paintEvent(QPaintEvent *event);

    private:
        mbServerScriptEditor *codeEditor;
    };

};

#endif // SERVER_SCRIPTEDITOR_H
