'Imports Microsoft.VisualBasic

'Public Class PetrofermMaster
'    Inherits System.Web.UI.MasterPage
'    Implements IPetrofermMasterPage

'    Private m_MasterTitle As String
'    Private m_MasterMetaKeywords As String
'    Private m_MasterMetaDescription As String
'    Private m_MasterWelcomeJavaScript As String
'    Private m_MasterLogo As HtmlImage
'    Private m_MasterAdvanceSearchLink As HtmlAnchor
'    Private m_MasterSimpleSearchButton As HtmlInputButton
'    Private m_MasterTopMenuRegion As HtmlTableCell
'    Private m_MasterBodyRegion As HtmlTableCell
'    Private m_MasterSideNavigationRegion As PlaceHolder
'    Private m_MasterBodyTag As HtmlGenericControl
'    Private m_MasterBodyTitle As HtmlGenericControl
'    Private m_MasterShowBodyTitle As Boolean
'    Private m_MasterCopyrightLabel As HtmlGenericControl
'    Private m_MasterTermsLink As HtmlAnchor
'    Private m_MasterRegionFormat As PetrofermMasterPage.RegionType
'    Private m_MasterPageType As PetrofermMasterPage.PageType

'    Public Property MasterAdvanceSearchLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IPetrofermMasterPage.MasterAdvanceSearchLink
'        Get
'            Return m_MasterAdvanceSearchLink
'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlAnchor)
'            m_MasterAdvanceSearchLink = value
'        End Set
'    End Property

'    Public Property MasterBodyRegion() As System.Web.UI.HtmlControls.HtmlTableCell Implements IPetrofermMasterPage.MasterBodyRegion
'        Get
'            Return m_MasterBodyRegion
'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlTableCell)
'            m_MasterBodyRegion = value
'        End Set
'    End Property

'    Public Property MasterBodyTag() As System.Web.UI.HtmlControls.HtmlGenericControl Implements IPetrofermMasterPage.MasterBodyTag
'        Get
'            Return m_MasterBodyTag
'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlGenericControl)
'            m_MasterBodyTag = value
'        End Set
'    End Property

'    Public Property MasterBodyTitle() As System.Web.UI.HtmlControls.HtmlGenericControl Implements IPetrofermMasterPage.MasterBodyTitle
'        Get
'            Return m_MasterBodyTitle
'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlGenericControl)
'            m_MasterBodyTitle = value
'        End Set
'    End Property

'    Public Property MasterCopyrightLabel() As System.Web.UI.HtmlControls.HtmlGenericControl Implements IPetrofermMasterPage.MasterCopyrightLabel
'        Get
'            Return m_MasterCopyrightLabel
'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlGenericControl)
'            m_MasterCopyrightLabel = value
'        End Set
'    End Property

'    Public Property MasterLogo() As System.Web.UI.HtmlControls.HtmlImage Implements IPetrofermMasterPage.MasterLogo
'        Get
'            Return m_MasterLogo
'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlImage)
'            m_MasterLogo = value
'        End Set
'    End Property

'    Public Property MasterMetaDescription() As String Implements IPetrofermMasterPage.MasterMetaDescription
'        Get
'            Return m_MasterMetaDescription
'        End Get
'        Set(ByVal value As String)
'            m_MasterMetaDescription = value
'        End Set
'    End Property

'    Public Property MasterMetaKeywords() As String Implements IPetrofermMasterPage.MasterMetaKeywords
'        Get

'        End Get
'        Set(ByVal value As String)

'        End Set
'    End Property

'    Public Property MasterPageType() As PetrofermMasterPage.PageType Implements IPetrofermMasterPage.MasterPageType
'        Get

'        End Get
'        Set(ByVal value As PetrofermMasterPage.PageType)

'        End Set
'    End Property

'    Public Property MasterRegionFormat() As PetrofermMasterPage.RegionType Implements IPetrofermMasterPage.MasterRegionFormat
'        Get

'        End Get
'        Set(ByVal value As PetrofermMasterPage.RegionType)

'        End Set
'    End Property

'    Public Property MasterShowBodyTitle() As Boolean Implements IPetrofermMasterPage.MasterShowBodyTitle
'        Get

'        End Get
'        Set(ByVal value As Boolean)

'        End Set
'    End Property

'    Public Property MasterSideNavigationRegion() As System.Web.UI.WebControls.PlaceHolder Implements IPetrofermMasterPage.MasterSideNavigationRegion
'        Get

'        End Get
'        Set(ByVal value As System.Web.UI.WebControls.PlaceHolder)

'        End Set
'    End Property

'    Public Property MasterSimpleSearchButton() As System.Web.UI.HtmlControls.HtmlInputButton Implements IPetrofermMasterPage.MasterSimpleSearchButton
'        Get

'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlInputButton)

'        End Set
'    End Property

'    Public Property MasterTermsLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IPetrofermMasterPage.MasterTermsLink
'        Get

'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlAnchor)

'        End Set
'    End Property

'    Public Property MasterTitle() As String Implements IPetrofermMasterPage.MasterTitle
'        Get

'        End Get
'        Set(ByVal value As String)

'        End Set
'    End Property

'    Public Property MasterTopMenuRegion() As System.Web.UI.HtmlControls.HtmlTableCell Implements IPetrofermMasterPage.MasterTopMenuRegion
'        Get

'        End Get
'        Set(ByVal value As System.Web.UI.HtmlControls.HtmlTableCell)

'        End Set
'    End Property

'    Public Property MasterWelcomeJavaScript() As String Implements IPetrofermMasterPage.MasterWelcomeJavaScript
'        Get

'        End Get
'        Set(ByVal value As String)

'        End Set
'    End Property
'End Class