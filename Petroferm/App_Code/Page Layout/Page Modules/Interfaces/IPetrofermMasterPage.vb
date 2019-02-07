Public Interface IPetrofermMasterPage
    Property MasterWelcomeJavaScript() As String                            'JavaScriptWelcomeArrayList
    Property MasterLogoAndLink() As HtmlAnchor                              'MasterLogoHref <a>
    Property MasterAdvanceSearchLink() As HtmlAnchor                        'MasterAdvancedSearch
    Property MasterTopMenuRegion() As HtmlTableCell                         'MasterTopMenu <td>
    Property MasterHeaderImageRegion() As ContentPlaceHolder                'MasterHeaderImage <cph> ==> call BuildMenuAction() to generate look/feel/action for a menu mouseover/out
    Property MasterBodyRegion() As HtmlTableCell                            'MasterBodyContent <cph> ==> can consume the MasterBodyTitle (can loop through mult. content mods) - (can get rid of PageModulePlaceHolder cph below)
    Property MasterSideNavigationRegion() As PlaceHolder                    'SideNavigationPlaceHolder <cph> (made SideNavigation as a <ph>)
    Property MasterBodyTag() As HtmlGenericControl                          'MasterBody <body>
End Interface
