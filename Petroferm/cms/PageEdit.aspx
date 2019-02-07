<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="PageEdit.aspx.vb" Inherits="CmsPageEdit" title="Untitled Page" StylesheetTheme="CMS_Theme"  validateRequest="false" %>
<%@ Register Src="controls/ProductGridEdit.ascx" TagName="ProductGridEdit" TagPrefix="uc6" %>
<%@ Register Src="controls/DocumentEdit.ascx" TagName="DocumentEdit" TagPrefix="uc4" %>
<%@ Register Src="controls/ImageEdit.ascx" TagName="ImageEdit" TagPrefix="uc5" %>
<%@ Register Src="controls/ProductBlurbEdit.ascx" TagName="ProductBlurbEdit" TagPrefix="uc3" %>
<%@ Register Src="controls/HeaderSideContentEdit.ascx" TagName="HeaderSideContentEdit" TagPrefix="uc2" %>
<%@ Register Src="controls/ContentEdit.ascx" TagName="ContentEdit" TagPrefix="ModuleControl" %>
<%@ Register Src="controls/WorkflowInfo.ascx" TagName="WorkflowInfo" TagPrefix="uc1" %>
<%@ MasterType TypeName="MasterCMS" %> 
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
<asp:Label ID="lblMessage" runat="server"></asp:Label>
   <asp:Wizard ID="wzForm" runat="server" DisplayCancelButton="True" Width="950px" ActiveStepIndex="1" >
        <WizardSteps>
            <asp:WizardStep ID="stepGenInfo" runat="server" Title="1 - General Info">
    <table id="Table2" style="width: 659px">
        <tr>
            <td class="formFieldLabel" style="width: 129px; height: 16px">
                Market</td>
            <td style="width: 352px; height: 16px">
                <asp:DropDownList ID="ddlMarket" runat="server" DataSourceID="MarketDS"
                    DataTextField="MarketName" DataValueField="MarketID">
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td style="width: 129px;" class="formFieldLabel">
                Page Title</td>
            <td>
                <asp:TextBox ID="txtPageTitle" runat="server" Width="269px" MaxLength="100"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldNameRequired" runat="server" ControlToValidate="txtPageTitle"
                    Display="Dynamic" ErrorMessage="Page Title is required." SetFocusOnError="True"></asp:RequiredFieldValidator></td>
        </tr>
        <tr runat="server" id="trFriendlyURL" visible="false">
            <td class="formFieldLabel" style="width: 129px" runat="server">
                Friendly URL</td>
            <td runat="server">
                <asp:TextBox ID="txtFriendlyURL" runat="server" MaxLength="100" Width="444px"></asp:TextBox>
                <br />
                <asp:RequiredFieldValidator ID="vldFriendlyURL" runat="server" ControlToValidate="txtFriendlyURL"
                    Display="Dynamic" ErrorMessage="Friendly URL is required." SetFocusOnError="True"></asp:RequiredFieldValidator>
                <asp:CustomValidator ID="vldDuplicateFriendlyURL" runat="server" ControlToValidate="txtFriendlyURL"
                    Display="Dynamic" ErrorMessage="The Friendly URL you entered cannot be used because it is already in use by another page."></asp:CustomValidator>
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px; height: 125px;" valign="top">
                Meta Keywords</td>
            <td style="width: 352px; height: 125px;">
                <asp:TextBox ID="txtMetaKeywords" runat="server" Height="150px" MaxLength="1500"
                    Width="447px" TextMode="MultiLine"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px; height: 96px" valign="top">
                Meta Description</td>
            <td style="width: 352px; height: 96px">
                <asp:TextBox ID="txtMetaDescription" runat="server" Height="100px" MaxLength="500" Width="447px" TextMode="MultiLine"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px;">
                Publish Date</td>
            <td style="width: 352px;">
                <ew:CalendarPopup ID="dtePublishDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                    ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" JavascriptOnChangeFunction=""
                    LowerBoundDate="" Nullable="True" PadSingleDigits="True" SelectedDate="" ShowClearDate="True"
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px" EnableHideDropDown="True">
                    <TodayDayStyle BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <WeekendStyle BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <OffMonthStyle BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Gray" />
                    <WeekdayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <SelectedDateStyle BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <MonthHeaderStyle CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <GoToTodayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <DayHeaderStyle CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <ClearDateStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                </ew:CalendarPopup>
                <asp:CompareValidator ID="vldNavPublishDateValid" runat="server" ControlToValidate="dtePublishDate"
                    Display="Dynamic" ErrorMessage="Valid publish date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px; height: 37px">
                Expiration Date</td>
            <td style="width: 352px; height: 37px;">
                <ew:CalendarPopup ID="dteExpireDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                    ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" JavascriptOnChangeFunction=""
                    LowerBoundDate="" Nullable="True" PadSingleDigits="True" SelectedDate="" ShowClearDate="True"
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px" EnableHideDropDown="True">
                    <TodayDayStyle BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <WeekendStyle BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <OffMonthStyle BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Gray" />
                    <WeekdayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <SelectedDateStyle BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <MonthHeaderStyle CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <GoToTodayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <DayHeaderStyle CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <ClearDateStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                </ew:CalendarPopup>
                <asp:CompareValidator ID="vldNavExpireDateValid" runat="server" ControlToValidate="dteExpireDate"
                    Display="Dynamic" ErrorMessage="Valid expiration date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator></td>
        </tr>
    </table>
                <asp:TextBox ID="hidFormMode" runat="server" Visible="False" Width="19px"></asp:TextBox>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
            </asp:WizardStep>
            <asp:WizardStep ID="stepPageModules" runat="server" Title="2 - Page Modules">
            
            
                <asp:Label ID="lblInstructions" runat="server"></asp:Label>
                <table id="Table4" style="width: 100%; vertical-align: top;" height="100%">
                    <tr valign="top">
                        <td colspan="2" style="width: 837px; height: 15px">
                            <asp:Label ID="lblTitleStep2" runat="server" CssClass="formFieldLabel">Page Title</asp:Label>
                            &nbsp;
                            <asp:Label ID="lblPageTitleStep2" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td colspan="2" style="width: 837px;">
                        
                            <asp:Panel ID="pnlAddPageModuleDropdown" runat="server" Width="100%">
                                <table>
                                    <tr>
                                        <td style="width: 150px; height: 25px">
                            <asp:Label ID="lblSelectModuleType" runat="server" CssClass="formFieldLabel">Select Module Type</asp:Label>
                                        </td>
                                        <td style="width: 591px; height: 25px">
                            <asp:DropDownList ID="ddlModuleAdd" runat="server" DataSourceID="ModuleTypesDS">
                            </asp:DropDownList>
                            <asp:LinkButton ID="lbtnAddModule" runat="server"><img alt="Add" src= "../App_Themes/CMS_Theme/images/newitem.gif" style="padding-right:5px;padding-bottom:5px;border:none;vertical-align:middle;"  />Add</asp:LinkButton>
                                        </td>
                                    </tr>
                                    <tr runat="server" ID="trCopyExistingModule">
                                        <td style="width: 150px" class="formFieldLabel" >OR
                                <asp:Label ID="lblClone" runat="server" CssClass="formFieldLabel">Copy Existing Module</asp:Label>
                                        </td>
                                        <td style="width: 591px">
                                <asp:DropDownList ID="ddlModuleCopy" runat="server" DataSourceID="GetPageModulesToCopyDS" DataTextField="DropdownText" DataValueField="DropdownValue">
                                </asp:DropDownList>
                                            &nbsp;<asp:LinkButton ID="lbtnCopyModule" runat="server"><img alt="Copy" src= "../App_Themes/CMS_Theme/images/copy.gif" style="padding-right:5px;padding-bottom:5px;border:none;vertical-align:middle;"  />Copy</asp:LinkButton>
                                        </td>
                                    </tr>
                                </table>
                            <asp:ObjectDataSource ID="ModuleTypesDS" runat="server" SelectMethod="GetModuleTypes"
                                TypeName="PageModule"></asp:ObjectDataSource>
                                <asp:ObjectDataSource ID="GetPageModulesToCopyDS" runat="server" SelectMethod="GetCopyListByBu"
                                    TypeName="PageModule">
                                    <SelectParameters>
                                        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                                    </SelectParameters>
                                </asp:ObjectDataSource>
                            </asp:Panel>
                            
                        </td>
                    </tr>
                    <tr style="color: #000000" valign="top">
                        <td colspan="2" style="width: 837px; text-align: left" align="center">
                        <asp:Panel runat="server" ID="pnlPageModule" Width="100%">
                            <ModuleControl:ContentEdit ID="ucContentModule" runat="server" Visible="False" />
                            <uc2:HeaderSideContentEdit ID="ucHeaderSideContentModule" runat="server" Visible="False" />
                            <uc3:ProductBlurbEdit ID="ucProductBlurbModule" runat="server" Visible="False" />
                            <uc4:DocumentEdit ID="ucDocumentModule" runat="server" Visible="False" />
                            <uc5:ImageEdit ID="ucImageModule" runat="server" Visible="False" />
                            <uc6:ProductGridEdit ID="ucProductGridModule" runat="server" Visible="False" />
                         </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td align="center">
                        <asp:Panel runat="server" ID="pnlSaveCancelModuleButtons" Width="100%" Visible="False">
                            <asp:Button ID="btnSaveModule" runat="server" SkinID="WizardButton" Text="Save Module" />
                                                       &nbsp; &nbsp;&nbsp;
                            <asp:Button ID="btnCancelModule" runat="server" SkinID="WizardButton" Text="Cancel" CausesValidation="False"/><br /><br />
                        </asp:Panel>
                        </td>
                    </tr>
                    <tr style="color: #000000" valign="top">
                        <td colspan="2" rowspan="1" style="width: 837px">
                            <asp:GridView ID="gvPageModules" runat="server" AllowPaging="True" AllowSorting="True"
                                AutoGenerateColumns="False" DataKeyNames="PageModuleRelnID" EnableTheming="True"
                                DataSourceID="PageModulesDS" EnableViewState="False">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("PageModuleRelnID") %>'
                                                CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("PageModuleRelnID") %>'
                                                CommandName="EditItem" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnView" AlternateText="View" CommandArgument='<%# Eval("PageModuleRelnID") %>'
                                                CommandName="ReadItem" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>                                    
                                    <asp:BoundField DataField="ModuleTitle" HeaderText="Module Title" SortExpression="ModuleTitle" />
                                    <asp:BoundField DataField="SourceName" HeaderText="Module Type" SortExpression="SourceName" />
                                    <asp:BoundField DataField="ModuleOrder" HeaderText="Order" SortExpression="ModuleOrder" >
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                                        HtmlEncode="False" SortExpression="PublishDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                                        HtmlEncode="False" SortExpression="ExpirationDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
                                    <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                                        HtmlEncode="False" SortExpression="LastModifiedDate">
                                        <ItemStyle HorizontalAlign="Center" Width="60px" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                                        SortExpression="FmtMarkedForDeletion">
                                        <ItemStyle HorizontalAlign="Center" Width="65px" />
                                    </asp:BoundField>
                                </Columns>
                            </asp:GridView>
                            <asp:ObjectDataSource ID="PageModulesDS" runat="server" SelectMethod="GetList" TypeName="PageModule">
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="hidPageID" DefaultValue="0" Name="pageId" PropertyName="Text"
                                        Type="Int32" />
                                    <asp:Parameter DefaultValue="False" Name="liveMode" Type="Boolean" />
                                </SelectParameters>
                            </asp:ObjectDataSource>
                            &nbsp; &nbsp;
                        </td>
                    </tr>
                </table>            
            
            
            </asp:WizardStep>
            <asp:WizardStep ID="stepNavigation" runat="server" Title="3 - Navigation">
                <asp:Label ID="lblNavigationInstructions" runat="server"></asp:Label>
                <table id="tblSideNavigation" width="100%">
                    <tr>
                        <td class="formFieldLabel" colspan="2">
                            Display link to page in Side Navigation?&nbsp;
                            <asp:RadioButtonList ID="rdoSideNavYesNo" runat="server" RepeatDirection="Horizontal" AutoPostBack="True" RepeatLayout="Flow">
                                <asp:ListItem>Yes</asp:ListItem>
                                <asp:ListItem>No</asp:ListItem>
                            </asp:RadioButtonList>
                            &nbsp;</td>
                    </tr>
                    <tr>
                        <td class="formFieldLabel" style="width: 25px; height: 24px;">
                            </td>
                        <td style="width: 697px">
                         <table runat="server" id="tblSideNavInfo" width="100%">
                                <tr runat="server">
                                    <td class="formFieldLabel" style="width: 68px" runat="server">
                            Section</td>
                                    <td style="width: 119px" runat="server">
                            <asp:DropDownList ID="ddlSideNavSection" runat="server" AutoPostBack="True" DataSourceID="SideNavSectionsDS" DataTextField="SectionName" DataValueField="SectionID">
                            </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr runat="server" id="trProductCategory" visible="false">
                                    <td class="formFieldLabel" style="width: 68px; height: 16px" runat="server">
                            Product Category</td>
                                    <td style="width: 119px; height: 16px" runat="server">
                            <asp:DropDownList ID="ddlProductCategory" runat="server" DataSourceID="ProductCategoriesDS" DataTextField="CategoryName" DataValueField="ProdCatID">
                            </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr runat="server">
                                    <td class="formFieldLabel" style="width: 68px" runat="server">
                            Link Text</td>
                                    <td style="width: 119px" runat="server">
                            <asp:TextBox ID="txtLinkText" runat="server" MaxLength="100" Width="314px"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                            <asp:ObjectDataSource ID="SideNavSectionsDS" runat="server" SelectMethod="GetSectionList"
                                TypeName="SideNavigation"></asp:ObjectDataSource>
                <asp:ObjectDataSource ID="ProductCategoriesDS" runat="server" SelectMethod="GetList"
                    TypeName="ProductCategory">
                    <SelectParameters>
                        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </asp:WizardStep>
        </WizardSteps>
        
        <FinishNavigationTemplate>
            <table cellspacing="5" cellpadding="5" border="0">
                <tr>
                    <td align="right">
                        <asp:Button ID="FinishPreviousButton" runat="server" CausesValidation="False" CommandName="MovePrevious"
                            Text="Previous" SkinID="WizardButton" />
                        <asp:Button ID="FinishButton" runat="server" CommandName="MoveComplete" Text="Finish"
                          SkinID="WizardButton" />
                        <asp:Button ID="CancelButton" runat="server" CausesValidation="False" CommandName="Cancel"
                            Text="Cancel" SkinID="WizardButton" />
                    </td>
                </tr>
            </table>
        </FinishNavigationTemplate>        
       <StepStyle Width="800px" />
       <SideBarStyle Width="120px" />
    </asp:Wizard>
    <uc1:WorkflowInfo ID="ucWorkflowInfo" runat="server" />
                <asp:TextBox ID="hidPageID" runat="server" Visible="False" Width="19px"></asp:TextBox>
    
    <asp:ObjectDataSource ID="MarketDS" runat="server" SelectMethod="GetListByBu" TypeName="Market">
        <SelectParameters>
            <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
            <asp:Parameter DefaultValue="0" Name="mode" Type="Object" />
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>

