Public Class HtmlEditor
    Inherits InnovaStudio.WYSIWYGEditor

    Sub New()
        ' set default features of the editor for CCM
        ' set which buttons to display by default
        'Me.ButtonFeatures = New String() { _
        '    "CssText", _
        '    "Copy", "Paste", "PasteWord", "Undo", "Redo", "|", _
        '    "Bookmark", "Hyperlink", "Numbering", "Bullets", _
        '    "|", "Indent", "Outdent", _
        '    "|", "Image", "Table", _
        '    "Characters", "Styles", "Bold", "Italic", "Underline"}
        ' Me.InternalLink = "True"
        Me.EditMode = "HTMLBody"

        'Me.ButtonFeatures = New String() { _
        '    "FullScreen", "Preview", "Print", "SpellCheck", "|", "Cut", "Copy", "Paste", "PasteWord", "|", "Undo", "Redo", "|", "Bookmark", "Hyperlink", "Image", _
        '    "Characters", "|", "RemoveFormat", "XHTMLSource", "ClearAll", "BRK", "StyleAndFormatting", "TextFormatting", "ListFormatting", "BoxFormatting", "ParagraphFormatting", "CssText", "FontName", "FontSize", _
        '    "Styles", "Bold", "Italic", "|", "JustifyLeft", "JustifyCenter", "JustifyRight", "JustifyFull", "|", "Numbering", "Bullets", "|", _
        '    "Indent", "Outdent", "|", "Table", "Guidelines"}

        'Me.Css = "/FWPortal/EditorStyles.css"
        'Me.btnFont = True
        'Me.btnSize = True
        'Me.btnTextFormatting = True
        'Me.btnForeColor = True

        ' WITH SPELL CHECK
        'Me.ButtonFeatures = New String() { _
        '    "Print", "SpellCheck", "|", "Cut", "Copy", "Paste", "PasteWord", "|", "Undo", "Redo", "|", _
        '    "Bookmark", "Hyperlink", "Image", "Characters", "|", "Table", "Guidelines", "|", _
        '    "Numbering", "Bullets", "|", "Indent", "Outdent", "|", "RemoveFormat", "XHTMLSource", "ClearAll", "BRK", _
        '    "StyleAndFormatting", "TextFormatting", "ListFormatting", "BoxFormatting", "ParagraphFormatting", _
        '    "CssText", "FontName", "FontSize", "|", "Bold", "Italic", "|", "JustifyLeft", "JustifyCenter", _
        '    "JustifyRight", "JustifyFull"}

        Me.ButtonFeatures = New String() { _
            "FullScreen", "Preview", "Print", "|", "Cut", "Copy", "Paste", "PasteWord", "|", "Undo", "Redo", "|", _
            "Bookmark", "Hyperlink", "InternalLink", "Image", "Characters", "Form", "|", "Table", "Guidelines", "|", _
           "RemoveFormat", "XHTMLSource", "ClearAll", "BRK", _
            "StyleAndFormatting", "TextFormatting", "ListFormatting", "BoxFormatting", "ParagraphFormatting", _
            "Styles", "FontName", "FontSize", "|", "Bold", "Italic", "|", "JustifyLeft", "JustifyCenter", _
            "JustifyRight", "JustifyFull", "|", "Numbering", "Bullets", "|", "Indent", "Outdent", "|"}
        'Me.StyleList = New String(,) { _
        '{".heading", "True", "", "color: #4d4d4d; font-size: 12pt; font-family: helvetica, arial; font-weight: bold; line-height: 20pt;"}, _
        '{".small", "True", "", "font-size: 8pt; font-family: helvetica, arial;"}, _
        '{"body", "True", "", "color: #4d4d4d; font-size: 10pt; font-family: helvetica, arial; background-color: white;"}, _
        '{"a:link", "True", "", "color: #4d4d4d ; text-decoration: underline;"}, _
        '{"a:visited", "True", "", "color: #4d4d4d ; text-decoration: underline;"}, _
        '{"a:hover", "True", "", "color: #ADBECA; text-decoration: none;"}, _
        '{"a:active", "True", "", "color: #ADBECA ; font-weight: bold; text-decoration: underline;"}, _
        '{"p", "True", "", NORMAL_STYLE}, _
        '{"li", "True", "", NORMAL_STYLE}, _
        '{"div", "True", "", NORMAL_STYLE}, _
        '{"span", "True", "", NORMAL_STYLE}, _
        '{"ul", "True", "", NORMAL_STYLE}, _
        '{"ol", "True", "", NORMAL_STYLE}, _
        '{"td", "True", "", NORMAL_STYLE}}


        '.Content = BuildBodyBeginning() & BuildSignature()
        Me.scriptPath = "scripts/"
        Me.spellCheckMode = "NetSpell"
        Me.UseTagSelector = False
        'Me.scriptPath = "scripts/"
        Me.EditorWidth = "750"
        'Me.AssetManager = "/Petroferm/cms/assetmanager/assetmanager.asp"
        ' fully qualified path for asset manager:
        Dim path As String = ""
        With My.Request.Url
            path = .Scheme & "://" & (.Authority & My.Request.ApplicationPath & _
                "/cms/assetmanager/assetmanager.asp").Replace("//", "/") ' take out double slash for remote servers
        End With
        'Me.AssetManager = My.Request.ApplicationPath & "/cms/assetmanager/assetmanager.asp"
        Me.AssetManager = path
        Me.AssetManagerHeight = "500"
        Me.AssetManagerWidth = "650"
        Me.InitialRefresh = True
        Me.UseCSSBuilder = False
        Me.Css = "scripts/PetrofermLive.css"
        Me.btnSpellCheck = False ' this may be turned on later
         ' TODO: Edit the line below (also check editor.js)
        ' Me.InternalLink = "modalDialogShow('links.htm',365,270);"
        'modelessDialogShow('"+this.scriptPath+"media.htm',340,272)"
        'IDoEdit1.cmdInternalLink = "modalDialogShow('links.htm',365,270)"

    End Sub

    Sub New(ByVal buttonsToDisplay As String())
        Me.ButtonFeatures = buttonsToDisplay
    End Sub

    ' added property to trim fields that just have <p>&nbsp</p> in it
    Public ReadOnly Property ContentTrimmed() As String
        Get
            Dim strText As String = Me.Content.ToLower
            strText = strText.Replace("<p>&nbsp;</p>", String.Empty)
            If strText = String.Empty Then ' set content to empty string
                Me.Content = String.Empty
            End If
            Return Me.Content
        End Get
    End Property


End Class
