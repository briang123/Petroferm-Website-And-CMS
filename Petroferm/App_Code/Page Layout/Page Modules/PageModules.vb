Imports Microsoft.VisualBasic

Public Class PageModules
    Inherits CollectionBase

    Public Enum PageSection
        TopMenuNavigationImage
        HeaderMenuImage
        HeaderSideContent
        HeaderSideImage
        BodyContent
        SideNavigation
        SideContent
        Passthrough
        Document
    End Enum

    Sub New()
        MyBase.New()
    End Sub

    Default Public Property Item(ByVal index As Integer) As Object
        Get
            Return CType(MyBase.List.Item(Index), Object)
        End Get
        Set(ByVal value As Object)
            MyBase.List.Item(Index) = Value
        End Set
    End Property

    Public Function Add(ByVal item As Object) As Integer
        Try
            Return MyBase.List.Add(Item)
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Function GetSortedModulesBySection(ByVal sectionName As PageSection) As ArrayList
        Dim list As New ArrayList
        Dim modObject As Object
        For i As Integer = 0 To MyBase.List.Count - 1

            Select Case SectionName
                Case PageSection.TopMenuNavigationImage
                    If TypeOf Me.Item(i) Is ImageModule Then
                        Dim current As ImageModule = CType(Me.Item(i), ImageModule)
                        If current.ModuleType = "NAV ON IMAGE" Or current.ModuleType = "NAV OFF IMAGE" Then
                            modObject = CType(MyBase.List.Item(i), ImageModule)
                            list.Add(modObject)
                        End If
                    End If
                Case PageSection.HeaderMenuImage
                    If TypeOf Me.Item(i) Is ImageModule Then
                        Dim current As ImageModule = CType(Me.Item(i), ImageModule)
                        If current.ModuleType = "HEADER IMAGE" Then
                            modObject = CType(MyBase.List.Item(i), ImageModule)
                            list.Add(modObject)
                        End If
                    End If
                Case PageSection.HeaderSideImage
                    If TypeOf Me.Item(i) Is ImageModule Then
                        Dim current As ImageModule = CType(Me.Item(i), ImageModule)
                        ' added the or of this if stmt - 12/23/06 kr task#2
                        If current.ModuleType = "SIDE CONTENT HEADER IMAGE" Or _
                            current.ModuleType = "HEADER SIDE CONTENT IMAGE" Then
                            modObject = CType(MyBase.List.Item(i), ImageModule)
                            list.Add(modObject)
                        End If
                    End If
                Case PageSection.HeaderSideContent
                    If TypeOf Me.Item(i) Is HeaderSideContentModule Then
                        modObject = CType(Me.List.Item(i), HeaderSideContentModule)
                        list.Add(modObject)
                    End If
                Case PageSection.SideContent
                    If TypeOf Me.Item(i) Is ContentModule Then
                        If CType(Me.Item(i), ContentModule).ModuleType = "SIDE CONTENT" Then
                            modObject = CType(Me.List.Item(i), ContentModule)
                            list.Add(modObject)
                        End If
                    End If
                Case PageSection.BodyContent
                    If TypeOf Me.Item(i) Is ProductBlurbModule Then
                        modObject = CType(Me.List.Item(i), ProductBlurbModule)
                        list.Add(modObject)
                    ElseIf TypeOf Me.Item(i) Is ProductGridModule Then
                        modObject = CType(Me.List.Item(i), ProductGridModule)
                        list.Add(modObject)
                    ElseIf TypeOf Me.Item(i) Is ContentModule Then
                        If CType(Me.Item(i), ContentModule).ModuleType = "CONTENT" Then
                            modObject = CType(Me.List.Item(i), ContentModule)
                            list.Add(modObject)
                        End If
                    ElseIf TypeOf Me.Item(i) Is QuestionnaireModule Then
                        modObject = CType(Me.List.Item(i), QuestionnaireModule)
                        list.Add(modObject)
                    End If
                Case PageSection.DOCUMENT
                    If TypeOf Me.Item(i) Is DocumentModule Then
                        modObject = CType(Me.List.Item(i), DocumentModule)
                        list.Add(modObject)
                    End If
                Case PageSection.PASSTHROUGH
                    Return Nothing
            End Select
        Next
        Return list
    End Function


End Class