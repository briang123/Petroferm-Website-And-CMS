Public Interface IGeneralContentMasterPage
    Property MasterLogoAndLink() As HtmlAnchor
    Property MasterTopMenuRegion() As HtmlTableCell
    Property MasterSearchRegion() As HtmlTableCell
    Property MasterAdvanceSearchLink() As HtmlAnchor
    Property MasterBodyContentRegion() As ContentPlaceHolder
    Property MasterSideNavigationRegion() As PlaceHolder
    Property MasterTermsLink() As HtmlAnchor
    Property MasterCopyrightText() As HtmlGenericControl
    'Property RegionFlags() As PlaceHolder
End Interface