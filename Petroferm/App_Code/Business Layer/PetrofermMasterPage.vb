Imports Microsoft.VisualBasic

Public Class PetrofermMasterPage
    Inherits MasterPage

    Public Enum RegionType
        OneColumn = 0
        TwoColumn = 1
    End Enum

    Public Enum PageType
        BusinessHome
        MarketHome
        GeneralContent
        GeneralContentAbout
        GeneralContentCapabilities
        GeneralContentHistory
        GeneralContentTerms
        Passthrough
        Product
    End Enum
End Class
