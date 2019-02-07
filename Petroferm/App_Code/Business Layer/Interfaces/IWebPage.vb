Public Interface IWebPage
    Property PageId() As Integer
    Property PageTitle() As String
    Property UrlRewritePath() As String
    Property MetaKeywords() As String
    Property MetaDescription() As String
    Property PassthroughUrl() As String
    Property IsRequired() As Boolean
    Property IsReadOnly() As Boolean
    Property CachePageContent() As Boolean
    Property BusUnit() As BusinessUnit
    Property PageType() As String
    Property CurrentMarket() As Market
    Property Markets() As SortedList

    Property TopMenuNavigationRegion() As ArrayList
    Property HeaderImageRegion() As ArrayList
    Property HeaderSideContentRegion() As ArrayList
    Property HeaderSideImageRegion() As ArrayList
    Property SideBodyContentRegion() As ArrayList
    Property SideNavigationRegion() As String
    Property BodyContentRegion() As ArrayList

    Function GetPageDefinition() As DataTable
    Function GetList() As DataTable
    Sub FillLiveContent()
    Sub FillCmsContent()
    Function Delete() As Boolean
    Function Save() As Boolean
End Interface
