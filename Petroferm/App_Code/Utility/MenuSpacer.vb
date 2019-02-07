Imports Microsoft.VisualBasic

Public Class MenuSpacer
    Inherits HtmlImage

    Sub New()
        With Me
            .Src = SiteProfile.GetNavImagePath("nav_spacer.gif")
            .Width = 1
            .Height = 44
            .Border = 0
        End With
    End Sub

End Class
