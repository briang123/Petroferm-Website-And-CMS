Imports Microsoft.VisualBasic
Imports System.Configuration.ConfigurationManager

Public Class SiteProfile

    Public Shared Function GetConnectionString() As String
        Return System.Configuration.ConfigurationManager.ConnectionStrings("PetrofermConnectionString").ConnectionString
    End Function

    Public Shared Function GetFeedbacRequestFromEmail() As String
        Return System.Configuration.ConfigurationManager.AppSettings("FEEDBACK_REQUEST_FROM_EMAIL")
    End Function
    Public Shared Function GetSmtpServer() As String
        Return System.Configuration.ConfigurationManager.AppSettings("SMTP_SERVER")
    End Function

    Public Shared Function GetRequestInfoMessage() As String
        Return System.Configuration.ConfigurationManager.AppSettings("REQUEST_INFO_MESSAGE")
    End Function

    Public Shared Function GetProvideFeedbackMessage() As String
        Return System.Configuration.ConfigurationManager.AppSettings("FEEDBACK_MESSAGE")
    End Function

    Public Shared Function GetUserTemporaryPassword() As String
        Return System.Configuration.ConfigurationManager.AppSettings("TEMP_USER_PASSWORD").Replace("[CURRENT_YEAR]", Today.Year.ToString)
    End Function

#Region " PATH INFO "

    Public Shared Function GetNavImagePath(ByVal imageName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("NAV_IMAGE_DIRECTORY") & ImageName
    End Function

    Public Shared Function GetLogoImagePath(ByVal imageName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("LOGO_IMAGE_DIRECTORY") & ImageName
    End Function

    Public Shared Function GetContentImagePath(ByVal imageName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("CONTENT_IMAGE_DIRECTORY") & ImageName
    End Function

    Public Shared Function GetMiscImagePath(ByVal imageName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("MISC_IMAGE_DIRECTORY") & ImageName
    End Function

    Public Shared Function GetHeaderImagePath(ByVal imageName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("HEADER_IMAGE_DIRECTORY") & ImageName
    End Function

    Public Shared Function GetScriptPath(ByVal scriptName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("SCRIPTS_DIRECTORY") & scriptName
    End Function

    Public Shared Function GetDocPath(ByVal docName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("DOCS_DIRECTORY") & docName
    End Function

    Public Shared Function GetSecureDocPath(ByVal docName As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings("SECURE_DOCS_DIRECTORY") & docName
    End Function
#End Region

#Region " SEARCH CONFIGURATIONS "

    Public Shared Function GetDefaultSearchView() As String
        Return System.Configuration.ConfigurationManager.AppSettings("SEARCH_PAGE_DEFAULT_VIEW").ToString.ToUpper
    End Function

    Public Shared Function GetInstructions(ByVal key As String) As String
        Return System.Configuration.ConfigurationManager.AppSettings(key.ToUpper & "_INSTRUCTIONS").Replace("[BREAK]", "<BR/>")
    End Function

    Public Shared Function GetSearchResultsBgColor() As String
        Return System.Configuration.ConfigurationManager.AppSettings("SEARCH_RESULTS_BGCOLOR")
    End Function

    Public Shared Function GetSearchResultsSelectedForeColor() As String
        Return System.Configuration.ConfigurationManager.AppSettings("SEARCH_RESULTS_SELECTED_FORECOLOR")
    End Function

    Public Shared Function GetSearchResultsSelectedFontWeight() As String
        Return System.Configuration.ConfigurationManager.AppSettings("SEARCH_RESULTS_SELECTED_FONTWEIGHT")
    End Function

    Public Shared Function GetSearchResultsDescriptionOffset() As Integer
        Return CType(System.Configuration.ConfigurationManager.AppSettings("SEARCH_RESULTS_DESCRIPTION_OFFSET"), Integer)
    End Function

#End Region

    Public Enum UserRole
        Reader
        Author
        Reviewer
        Approver
        Deployer
        Administrator
        WebsiteUser
    End Enum


End Class
