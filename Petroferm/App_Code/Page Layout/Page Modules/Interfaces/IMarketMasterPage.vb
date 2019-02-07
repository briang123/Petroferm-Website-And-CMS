Public Interface IMarketMasterPage
    Property MasterTopMenuRegion() As HtmlTableCell
    Property MasterLogoAndLink() As HtmlAnchor
    'Property MasterSimpleSearchButton() As HtmlInputButton
    Property MasterSideNavigationRegion() As PlaceHolder
    Property MasterHeaderImage() As HtmlImage
    Property MasterBodyContentRegion() As ContentPlaceHolder
    Property MasterAdvanceSearchLink() As HtmlAnchor
    Property MasterHeaderSideContent() As PlaceHolder
    Property MasterWelcomeJavaScript() As String
End Interface
