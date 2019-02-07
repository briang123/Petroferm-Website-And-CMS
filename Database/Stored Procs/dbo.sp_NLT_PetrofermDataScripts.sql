



--select * from tblbusinessappuser
--dbo.sp__UpdateJobStatus 2, 1, 'LIVE'
--sp_NLT_PetrofermDataScripts 1
CREATE           proc sp_NLT_PetrofermDataScripts
	@deploy_this_content_to_live_site bit = 0,
	@userName varchar(100) = 'Administrator'
as
begin

/*
created by: Brian Gaines
created on: 11/2006
purpose:
The following scripts are update SQL statements with data directly retrieved from the petroferm 
website for the particular divisions. These scripts were created in efforts to simplify our 
testing and deployment process during development efforts. The data contained in these scripts 
which were fetched from the Petroferm website are only as recent as 11/2006, therefore, they may 
need to be updated as a result.


NOTE: 
- We create the application name
- All the data scripts below will be associated with DeploymentJobId = 1.
- We are updating the Title and Body Content fields in the tblContentModule table, 
the images associated with the navigation and header images, and the url rewrite table
- We are updating the Petroferm home page
- We are updating regional information

History:
Kelly Roe    (12/24/2006) - fixed expire date on region image inserts
Brian Gaines (12/31/2006) - updated the regions
Brian Gaines (1/1/2007) - added asp.net membership information (application name, roles, admin user)
			- added user id as a variable to all data scripts
			- update approvals product attribute type to not allow multiple
*/

/******************************************************************
MEMBERSHIP SETUP
*******************************************************************/
declare @appId uniqueidentifier
declare @userId int
--deletes all cms users
--exec sp_UTIL_DeleteAllMembershipInfo 1
--create application, roles, and user if they don't exist
--TODO: does not work properly if we don't have the user currently in the system 
--      (need to look at the sp_UTIL_CreateBasicMembership script)
exec sp_UTIL_CreateBasicMembership @userName, @applicationid = @appId, @uid = @userId output

declare @retval int,
	@busId int,
	@logoId int,
	@mktId int,
	@attribId int,
	@pcid int 

exec sp_NLT_TruncateDataFromNonLiveTables 1
truncate table tblimage
truncate table tbldocument
truncate table tbldocumentstats
truncate table tblurlrewrite
truncate table tblregion
-- make a backup of the original domain mapping table to get data 
-- from (don't necessarily need to start from scratch) if want to load 
-- existing data into truncated table
if (dbo.fn__TableExists('tblDomainMapping_U_Backup') > 0)
begin
	drop table tblDomainMapping_U_Backup
end
select * into tblDomainMapping_U_Backup from tblDomainMapping_U
truncate table tblDomainMapping_U
exec sp_NLT_BuildPetrofermFromScratchOnlyPetroData 1, @userId

/***************************************************************
CREATE PETROFERM CLEANING DIVISION WITH MARKETS
****************************************************************/
	
exec @retval = sp__AddBusinessUnit 
		@BusName = 'Petroferm Cleaning Division', 
		@DocAuth = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@userId = @userId, 
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@JobID = 1, 
		@IsPetro = 0, 
		@LogoImagePath = 'web/files/images/logos/PetrofermCleaningLogo.gif',
		@ExistingLogoID = 0,
		@LogoAltText = 'Petroferm Cleaning Division',
		@LogoHeight = 0,
		@LogoWidth = 0,
		@LogoID = @logoId OUTPUT,
		@BusUnitID = @busId OUTPUT

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Electronics Market',
		@MktOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Precision Cleaning Market',
		@MktOrder = 2,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Asphalt Products Market',
		@MktOrder = 3,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Aerospace/Airline Market',
		@MktOrder = 4,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

--- ADD DEFAULT SET OF SIDE NAVIGATION PRODUCT CATEGORIES
exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Application',
		@CategoryOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output

exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Chemistry',
		@CategoryOrder = 2,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output

exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Process',
		@CategoryOrder = 3,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output


--- ADD DEFAULT PRODUCT ATTRIBUTES THAT ARE AT BUSINESS UNIT LEVEL
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Product',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Description',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Datasheets',
		@AllowMultiple = 1,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

-- added 12/28/2006 - kr
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Approvals',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemical Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'CFR Clearance',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'HLB',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'INCI Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Melting Point(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Designation',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Type',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Types & Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemistry Type & Use Concentration',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point,°F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Solvent Base',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'pH',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Corrosion Inhibitor',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Process',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Vapor Pressure, mm HG',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Boiling Point, °F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Exposure Limits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Benefits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT


/***************************************************************
CREATE PETROFERM FUEL AND OILFIELD DIVISION WITH MARKETS
****************************************************************/

exec @retval = sp__AddBusinessUnit 
		@BusName = 'Petroferm Fuel and Oil Division', 
		@DocAuth = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@userId = @userId, 
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@JobID = 1,
		@IsPetro = 0, 
		@LogoImagePath = 'web/files/images/logos/FuelOilfieldLogo.gif',
		@ExistingLogoID = 0,
		@LogoAltText = 'Petroferm Fuel and Oilfield Division',
		@LogoHeight = 0,
		@LogoWidth = 0,
		@LogoID = @logoId OUTPUT,
		@BusUnitID = @busId OUTPUT

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = 3,
		@MktName = 'Fuel Market',
		@MktOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = 3,
		@MktName = 'Oilfield Market',
		@MktOrder = 2,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

--- ADD DEFAULT SET OF SIDE NAVIGATION PRODUCT CATEGORIES (AT BUSINESS UNIT LEVEL ONLY)
exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Application',
		@CategoryOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output

--- ADD DEFAULT PRODUCT ATTRIBUTES THAT ARE AT BUSINESS UNIT LEVEL
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Product',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Description',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Datasheets',
		@AllowMultiple = 1,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

-- added 12/28/2006 - kr
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Approvals',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemical Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'CFR Clearance',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'HLB',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'INCI Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Melting Point(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Designation',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Type',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Types & Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemistry Type & Use Concentration',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point,°F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Solvent Base',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'pH',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Corrosion Inhibitor',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Process',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Vapor Pressure, mm HG',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Boiling Point, °F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Exposure Limits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Benefits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Particulate Emissions (mg/m3)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Excess O2',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Residual Carbon in Ash(%)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'NOx Emissions (ppm)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Fuel Oil Viscosity (SSF)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Technical Information',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

/***************************************************************
CREATE PETROFERM LAMBENT TECHONOLOGIES DIVISION WITH MARKETS
****************************************************************/

exec @retval = sp__AddBusinessUnit 
		@BusName = 'Lambent Technologies Corp.', 
		@DocAuth = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@userId = @userId, 
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@JobID = 1, 
		@IsPetro = 0, 
		@LogoImagePath = 'web/files/images/logos/LambentLogo.gif',
		@ExistingLogoID = 0,
		@LogoAltText = 'Lambent Technologies Corp',
		@LogoHeight = 0,
		@LogoWidth = 0,
		@LogoID = @logoId OUTPUT,
		@BusUnitID = @busId OUTPUT

--- ADD DEFAULT SET OF SIDE NAVIGATION PRODUCT CATEGORIES (AT BUSINESS UNIT LEVEL)
exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Function',
		@CategoryOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output

exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Application',
		@CategoryOrder = 2,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output

exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Chemistry',
		@CategoryOrder = 3,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output

--- ADD MARKETS
exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Food Market',
		@MktOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT


--- ADD DEFAULT PRODUCT ATTRIBUTES THAT ARE AT BUSINESS UNIT LEVEL
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Product',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Description',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Datasheets',
		@AllowMultiple = 1,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

-- added 12/28/2006 - kr
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Approvals',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemical Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'CFR Clearance',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'HLB',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'INCI Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Melting Point(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Designation',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Type',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Types & Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemistry Type & Use Concentration',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point,°F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Solvent Base',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'pH',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Corrosion Inhibitor',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Process',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Vapor Pressure, mm HG',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Boiling Point, °F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Exposure Limits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Benefits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

declare @searchAttribList varchar(1000)
select @searchAttribList = '''Unique Lambent Product'',''High HLB'',''Medium HLB'',''Low HLB'',''Low trans fat (< 1%)'',''Kosher Products'',''Halal Products'',''GRAS products'',''CFR Approved - Direct Food Contact'',''CFR Approved - Indirect Food Contact'',''Liquid Products'',Solid Products - melting point < 40 degrees Celsius'',''Solid Products - melting point > 40 degrees Celsius'''
insert into tblSearchAttribType (BusinessUnitID, MarketID, SearchAttributeName, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
select @busId, @mktId, replace(str,'''',''), dbo.fn__GetDateOnly(getdate()), dbo.fn__GetDateOnly(dateadd(year,30,getdate())),'WORKING', @userId, 1, 0, 1 
from dbo.fn__CharListToTable(@searchAttribList,',')

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Coatings and Colorants Market',
		@MktOrder = 2,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

select @searchAttribList = '''Unique Lambent products'',''High HLB'',''Medium HLB'',''Low HLB'',''Low IV'', ''High IV'',''Solid (or High melting point)'',''Anionic'',''Low pH'',''Oil Soluble'',''Water soluble'''
insert into tblSearchAttribType (BusinessUnitID, MarketID, SearchAttributeName, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
select @busId, @mktId, replace(str,'''',''), dbo.fn__GetDateOnly(getdate()), dbo.fn__GetDateOnly(dateadd(year,30,getdate())),'WORKING', @userId, 1, 0, 1 
from dbo.fn__CharListToTable(@searchAttribList,',')

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Lubricants and Metalworking Market',
		@MktOrder = 3,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

select @searchAttribList = '''Unique Lambent products'',''Veggie derived'',''High HLB'',''Medium HLB'',''Low HLB'',''Kosher'',''Oxidatively stable'',''Low pour point'',''High flash point'',''High smoke point'',''High viscosity index'',''High molecular weight'',''HEAR oil derivatives'''
insert into tblSearchAttribType (BusinessUnitID, MarketID, SearchAttributeName, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
select @busId, @mktId, replace(str,'''',''), dbo.fn__GetDateOnly(getdate()), dbo.fn__GetDateOnly(dateadd(year,30,getdate())),'WORKING', @userId, 1, 0, 1 
from dbo.fn__CharListToTable(@searchAttribList,',')

exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Personal Care and Pharmaceutical Market',
		@MktOrder = 4,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

select @searchAttribList = '''Unique Lambent products'',''High HLB'',''Medium HLB'',''Low HLB'',''NF Products'',''O/W Emulsifiers'',''W/O Emulsifiers'',''Non-Animal Derived'',''Liquid products'',''Solid products (melting point < 40C)'',''Solid products (melting point > 40C)'''
insert into tblSearchAttribType (BusinessUnitID, MarketID, SearchAttributeName, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
select @busId, @mktId, replace(str,'''',''), dbo.fn__GetDateOnly(getdate()), dbo.fn__GetDateOnly(dateadd(year,30,getdate())),'WORKING', @userId, 1, 0, 1 
from dbo.fn__CharListToTable(@searchAttribList,',')

/***************************************************************
CREATE PETROFERM JOSEPH STOREY DIVISION WITH MARKETS
****************************************************************/

exec @retval = sp__AddBusinessUnit 
		@BusName = 'Joseph Storey and Co, LTD', 
		@DocAuth = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@userId = @userId, 
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@JobID = 1, 
		@IsPetro = 0, 
		@LogoImagePath = 'web/files/images/logos/JosephStoreyLogo.gif',
		@ExistingLogoID = 0,
		@LogoAltText = 'Joseph Storey & Co LTD',
		@LogoHeight = 0,
		@LogoWidth = 0,
		@LogoID = @logoId OUTPUT,
		@BusUnitID = @busId OUTPUT

--- ADD DEFAULT SET OF SIDE NAVIGATION PRODUCT CATEGORIES (AT BUSINESS UNIT LEVEL)
exec @retval = sp__AddSideNavProdCategory
		@BusUnitID = @busId,
		@MarketID = 0,
		@CategoryName = 'by Application',
		@CategoryOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@ProdCatID = @pcid output

--- ADD MARKETS
exec @retval = sp__AddMarket
		@userId = @userId, 
		@JobID = 1, 
		@BusID = @busId,
		@MktName = 'Flame Retardants Market',
		@MktOrder = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@WorkflowStatus = 'WORKING',
		@ActiveFlag = 1,
		@MarkedForDeletion = 0,
		@MktId = @mktId OUTPUT

--- ADD DEFAULT PRODUCT ATTRIBUTES THAT ARE AT BUSINESS UNIT LEVEL
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Product',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Description',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Datasheets',
		@AllowMultiple = 1,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

-- added 12/28/2006 - kr
-- updated 1/1/2007 - bg (allowmultiple value)
exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Approvals',
		@AllowMultiple = 0,
		@IsReadOnly = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemical Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'CFR Clearance',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'HLB',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'INCI Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Melting Point(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Designation',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Type',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Equipment Types & Applications',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Chemistry Type & Use Concentration',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Flash Point,°F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Solvent Base',
		@AllowMultiple = 1,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'pH',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Corrosion Inhibitor',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Process',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Vapor Pressure, mm HG',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Boiling Point, °F(°C)',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Exposure Limits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

exec @retval = sp__AddProductAttribute
		@BusUnitId = @busId,
		@AttribName = 'Benefits',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1,
		@userId = @userId,
		@AttribTypeID = @attribId OUTPUT

/***************************************************************
CREATE ADDITIONAL WEB PAGES 
****************************************************************/

-- Lambent page
declare @PageID int
exec sp__AddWebPage
	@BusUnitID = 4, 
	@MarketID = 0, 
	@PageType = 'GENERAL CONTENT', 
	@PageTitle = 'Worldwide Organizations', 
	@MetaKeywords = null, 
	@MetaDescription = null, 
	@PassthroughURL = null, 
	@IsRequired = 0, 
	@IsReadOnly = 0, 
	@PublishDate = null, 
	@ExpireDate = null, 
	@WorkflowStatus = 'WORKING', 
	@userId = @userId, 
	@ActiveFlag = 1, 
	@MarkedForDeletion = 0, 
	@JobID = 1,
	@PageID = @PageId

declare @cid int, @pmrid int
exec sp__AddContentModule
	@PageID = @PageId,
	@ModuleType = 'GENERAL CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'Worldwide Organizations',
	@Content = '<p><b>Petroferm</b></p>
				<p>Petroferm is the parent company to Lambent Technologies and the other subsidiaries listed below.  Petroferm is a specialty chemical company that has achieved rapid growth through both internal development and acquisitions. Our expertise in controlling the behavior of materials at surfaces and interfaces provides our customers with effective solutions to complex problems. Customers use Petroferm products to clean high reliability circuit boards used in applications from heart pacemakers to aircraft instrumentation; to improve the flow of heavy crude from oil wells; and to increase fuel combustion efficiency in oil-fired industrial boilers.
				<br><br><a href="~/?bus=3" title="Petroferm website">View</a> the website</p>
				<p><strong>Joseph Storey and Co Ltd</strong>
				<p>Joseph Storey is a Chemical Manufacturer, established in 1860, producing the STORFLAM range of Fire Retardants based on Inorganic Borate and Stannate chemistry. The STORFLAM Fire Retardant range is sold world-wide to many polymer industries.
				<br><br><a href="/?bus=5" title="Joseph Storey and Co Ltd website">View</a> the website</p>
				<p>
				<b>Petroferm Contract Services Inc. (PCSI)</b>
				<p>Petroferm Contract Services Inc. is a service-oriented organization dedicated to meeting customers'' OUTSOURCE PARTS CLEANING needs. PCSI offers solvent vapor degreasing, aqueous and semi-aqueous cleaning processes. Currently cleaning an average of 4.5 million pieces per month PCSI is geared to meet high volume cleaning demands while maintaining strict quality adherence.<br><br>
				<a href="http://www.partscleaned.com" title="Petroferm Contract Services Inc. website">View</a> the website</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid,
	@PageModuleRelnID = @pmrid


-- Joseph Storey page
exec sp__AddWebPage
	@BusUnitID = 5, 
	@MarketID = 0, 
	@PageType = 'GENERAL CONTENT', 
	@PageTitle = 'Worldwide Organizations', 
	@MetaKeywords = null, 
	@MetaDescription = null, 
	@PassthroughURL = null, 
	@IsRequired = 0, 
	@IsReadOnly = 0, 
	@PublishDate = null, 
	@ExpireDate = null, 
	@WorkflowStatus = 'WORKING', 
	@userId = @userId, 
	@ActiveFlag = 1, 
	@MarkedForDeletion = 0, 
	@JobID = 1,
	@PageID = @PageId

exec sp__AddContentModule
	@PageID = @PageId,
	@ModuleType = 'GENERAL CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'Worldwide Organizations',
	@Content = '				  <table width="100%" border="0" cellspacing="0" cellpadding="3">
					<tr valign="top" bgcolor="#CC9900"> 
					  <td width="65" class="tblHdr"><b>Country</b></td>
					  <td width="95" class="tblHdr"><b>Organisation 
						name </b></td>
					  <td width="95" class="tblHdr"><b>Address</b></td>
					  <td width="95" class="tblHdr">&nbsp;</td>
					  <td width="95" class="tblHdr">&nbsp;</td>
					  <td width="95" class="tblHdr"><b>Phone 
						Number</b></td>
					  <td width="95" class="tblHdr"><b>Fax 
						Number</b></td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Austria</td>
					  <td width="95" class="tblRow1">Klockner 
						Austria </td>
					  <td width="95" class="tblRow1">Seilergasse 
						14/PO Box 78</td>
					  <td width="95" class="tblRow1">A-1015 
						Wien</td>
					  <td width="95" class="tblRow1">Wien 
						</td>
					  <td width="95" class="tblRow1">43 
						015131231</td>
					  <td width="95" class="tblRow1">43 
						1513123123</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Belgium</td>
					  <td width="95" class="tblRow1">Keyser 
						&amp; Mackay</td>
					  <td width="95" class="tblRow1">144/7 
						av. Plasky Iaan</td>
					  <td width="95" class="tblRow1">1030 
						Brussels</td>
					  <td width="95" class="tblRow1">&nbsp;</td>
					  <td width="95" class="tblRow1">32 
						27354072</td>
					  <td width="95" class="tblRow1">32 
						27347600</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">France</td>
					  <td width="95" class="tblRow1">SPCI</td>
					  <td width="95" class="tblRow1">58 
						Rue du Landy</td>
					  <td width="95" class="tblRow1">Boite 
						Postale 43 93212</td>
					  <td width="95" class="tblRow1">St-Denis 
						La Plaine Cedex</td>
					  <td width="95" class="tblRow1">33 
						478726665</td>
					  <td width="95" class="tblRow1">33 
						478724790</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Germany</td>
					  <td width="95" class="tblRow1">Goldmann</td>
					  <td width="95" class="tblRow1">Schillerstrasse 
						79</td>
					  <td width="95" class="tblRow1">D-33609</td>
					  <td width="95" class="tblRow1">Bielefeld</td>
					  <td width="95" class="tblRow1">49 
						521932780</td>
					  <td width="95" class="tblRow1">49 
						5219327825</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Holland</td>
					  <td width="95" class="tblRow1">Lithos 
						Benelux</td>
					  <td width="95" class="tblRow1">Kon. 
						Wilhelminahaven NZ21-26</td>
					  <td width="95" class="tblRow1">PO 
						Box 234</td>
					  <td width="95" class="tblRow1">3130 
						AE Vlaardingen</td>
					  <td width="95" class="tblRow1">31 
						104456129</td>
					  <td width="95" class="tblRow1">31 
						104603238</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Indonesia</td>
					  <td width="95" class="tblRow1">Behn Meyer & Co Limited</td>
					  <td width="95" class="tblRow1">Plaza Ciputat Mas Blok E Kav. H, Jl. Ir.H. Juanda No. A</td>
					  <td width="95" class="tblRow1">Ciputat</td>
					  <td width="95" class="tblRow1">Tangerang 515412</td>
					  <td width="95" class="tblRow1">62 21 7428921</td>
					  <td width="95" class="tblRow1">&nbsp;</td>
					</tr>					
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>										
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Israel</td>
					  <td width="95" class="tblRow1">Orian 
						International Marketing</td>
					  <td width="95" class="tblRow1">PO 
						Box 741</td>
					  <td width="95" class="tblRow1">Raanana 
						43100</td>
					  <td width="95" class="tblRow1">&nbsp;</td>
					  <td width="95" class="tblRow1">972 
						9408666</td>
					  <td width="95" class="tblRow1">972 
						97416444</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Italy</td>
					  <td width="95" class="tblRow1">Hulss 
						and Capelli</td>
					  <td width="95" class="tblRow1">Via 
						Cechov, 48</td>
					  <td width="95" class="tblRow1">20151 
						Milano</td>
					  <td width="95" class="tblRow1">&nbsp;</td>
					  <td width="95" class="tblRow1">39 
						0233400770</td>
					  <td width="95" class="tblRow1">39 
						0233400774</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td class="tblRow1">Korea</td>
					  <td width="95" class="tblRow1">Chem 
						Tech Trading</td>
					  <td width="95" class="tblRow1">Rm 
						1103, Life Officetel, 61-3</td>
					  <td width="95" class="tblRow1">Yoido-dong, 
						Young deungpo Gu</td>
					  <td width="95" class="tblRow1">Seoul</td>
					  <td width="95" class="tblRow1">82 
						2 780 1091</td>
					  <td width="95" class="tblRow1">82 
						27837704</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td class="tblRow1">&nbsp;</td>					
					  <td width="95" class="tblRow1">Cho 
						Yang Chemicals Co., Ltd</td>
					  <td width="95" class="tblRow1">24, 
						2 ka</td>
					  <td width="95" class="tblRow1">Munrae 
						dong, Young deungpo Gu</td>
					  <td width="95" class="tblRow1">Seoul</td>
					  <td width="95" class="tblRow1">82 
						226761005</td>
					  <td width="95" class="tblRow1">82 
						226750846</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Malaysia</td>
					  <td width="95" class="tblRow1">Behn Meyer & Co Limited</td>
					  <td width="95" class="tblRow1">Plastics Dept No 5, Jalan TP2, Taman Perind, </td>
					  <td width="95" class="tblRow1">Subang Jaya</td>
					  <td width="95" class="tblRow1">Selangor 47600</td>
					  <td width="95" class="tblRow1">603 8026 3333</td>
					  <td width="95" class="tblRow1">603 8026 3366</td>
					</tr>					
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">New 
						Zealand</td>
					  <td width="95" class="tblRow1">Union 
						Chemicals</td>
					  <td width="95" class="tblRow1">Private 
						Bag</td>
					  <td width="95" class="tblRow1">102-960 
						North Shore Mail Centre</td>
					  <td width="95" class="tblRow1">Auckland 
						10</td>
					  <td width="95" class="tblRow1">64 
						94156663</td>
					  <td width="95" class="tblRow1">64 
						94156767</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Poland</td>
					  <td width="95" class="tblRow1">Chem-Link</td>
					  <td width="95" class="tblRow1">ul. Jana Olbrachta 94</td>
					  <td width="95" class="tblRow1">01-102 
						Warszawa</td>
					  <td width="95" class="tblRow1">&nbsp;</td>
					  <td width="95" class="tblRow1">48 
						225331770</td>
					  <td width="95" class="tblRow1">48 
						225331771</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Portugal</td>
					  <td width="95" class="tblRow1">Mapril SA</td>
					  <td width="95" class="tblRow1">Rua Jose Falcao, 52-1</td>
					  <td width="95" class="tblRow1">Lisbon</td>
					  <td width="95" class="tblRow1">1000-185</td>
					  <td width="95" class="tblRow1">218460903</td>
					  <td width="95" class="tblRow1">218462179</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">South 
						Africa</td>
					  <td width="95" class="tblRow1">Carst 
						and Walker</td>
					  <td width="95" class="tblRow1">Private 
						Bag X01</td>
					  <td width="95" class="tblRow1">Isipingo 
						Beach</td>
					  <td width="95" class="tblRow1">Durban 
						4115</td>
					  <td width="95" class="tblRow1">27 
						31 9122022</td>
					  <td width="95" class="tblRow1">27 
						31 9122024</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Spain</td>
					  <td width="95" class="tblRow1">Warwick-Benbassat</td>
					  <td width="95" class="tblRow1">Comte 
						d''Urgell 240</td>
					  <td width="95" class="tblRow1">08036 
						Barcelona</td>
					  <td width="95" class="tblRow1">&nbsp;</td>
					  <td width="95" class="tblRow1">34 
						934949200</td>
					  <td width="95" class="tblRow1">34 
						933220993</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Sweden</td>
					  <td width="95" class="tblRow1">Univar AB</td>
					  <td width="95" class="tblRow1">Ekonomivagen 5</td>
					  <td width="95" class="tblRow1">Askim</td>
					  <td width="95" class="tblRow1">SE 436 33</td>
					  <td width="95" class="tblRow1">4631838183</td>
					  <td width="95" class="tblRow1">4631838182</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">Thailand</td>
					  <td width="95" class="tblRow1">Behn 
						Meyer &amp; Co Limited</td>
					  <td width="95" class="tblRow1">189 
						Moo 6</td>
					  <td width="95" class="tblRow1">Bangkok- 
						Chomburi Rd, Tubyao, Ladkrabang</td>
					  <td width="95" class="tblRow1">Bangkok 
						10520</td>
					  <td width="95" class="tblRow1">882 
						326 9456</td>
					  <td width="95" class="tblRow1">882 
						326 6954</td>
					</tr>
					<TR>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>
						<TD class=tblRow2></TD>						
					</TR>					
					<tr valign="top"> 
					  <td width="65" class="tblRow1">USA</td>
					  <td width="95" class="tblRow1">Petroferm 
						Inc</td>
					  <td width="95" class="tblRow1">2416 
						Lynndale Road</td>
					  <td width="95" class="tblRow1">Femandina 
						Beach</td>
					  <td width="95" class="tblRow1">Florida</td>
					  <td width="95" class="tblRow1">904 
						2618286</td>
					  <td width="95" class="tblRow1">904 
						2616994</td>
					</tr>
				  </table><br/><br/>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid,
	@PageModuleRelnID = @pmrid

-- lambent SSD page
exec sp__AddWebPage
	@BusUnitID = 4, 
	@MarketID = 0, 
	@PageType = 'GENERAL CONTENT', 
	@PageTitle = 'Lambent Technologies Synthetic Specialties Division - Functional Silicones', 
	@MetaKeywords = null, 
	@MetaDescription = null, 
	@PassthroughURL = null, 
	@IsRequired = 0, 
	@IsReadOnly = 0, 
	@PublishDate = null, 
	@ExpireDate = null, 
	@WorkflowStatus = 'WORKING', 
	@userId = @userId, 
	@ActiveFlag = 1, 
	@MarkedForDeletion = 0, 
	@JobID = 1,
	@PageID = @PageId

exec sp__AddContentModule
	@PageID = @PageId,
	@ModuleType = 'GENERAL CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'Lambent Technologies Synthetic Specialties Division - Functional Silicones',
	@Content = '<p>We appreciate your patience while we update our website to better serve you.</p><p>Please feel free to contact us at <a href="mailto:lambent@lambentcorp.com">lambent@lambentcorp.com</a> or at 1-800-432-7187, extension 6740. You can also request more information by completing our online <a href="Contact.aspx?type=request" title="Request more information">request form</a>.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid,
	@PageModuleRelnID = @pmrid

-- lambent hansotech page
exec sp__AddWebPage
	@BusUnitID = 4, 
	@MarketID = 0, 
	@PageType = 'GENERAL CONTENT', 
	@PageTitle = 'Welcome to Lambent Technologies!', 
	@MetaKeywords = null, 
	@MetaDescription = null, 
	@PassthroughURL = null, 
	@IsRequired = 0, 
	@IsReadOnly = 0, 
	@PublishDate = null, 
	@ExpireDate = null, 
	@WorkflowStatus = 'WORKING', 
	@userId = @userId, 
	@ActiveFlag = 1, 
	@MarkedForDeletion = 0, 
	@JobID = 1,
	@PageID = @PageId

exec sp__AddContentModule
	@PageID = @PageId,
	@ModuleType = 'GENERAL CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'Welcome to Lambent Technologies!',
	@Content = '<a href="http://www.kahlwax.de" target="_blank"><img src="web/files/images/content/kahl-logo.jpg" border="0" width="80" height="45" align="right" hspace="10" vspace="10" alt="Kahl"></a>
		<p>Don''t worry - The Company has changed, but the products haven''t.</p>
		<p>All the waxes, oils and butters previously available from Hansotech are now available from Lambent Technologies and Lambent is now the agent for Kahl waxes in the U.S.</p>
		<p>Lambent Technologies has been a manufacturer of oleochemical derivatives for the food, personal care, and industrial industries since 1952.  Since 1999, Hansotech and Lambent Technologies have worked together closely as subsidiaries of Petroferm Inc.  Now, we are merging these two product lines under the Lambent Technologies umbrella, to provide you with a complete range of products for the personal care, food, and industrial markets.</p>
		<p>We invite you to explore the Lambent <a href="http://www.petroferm.com/lambent" title="Visit our Website">website</a> to learn more about our background and the products that we manufacture.  If you would like technical assistance or to request samples, please <a href="http://www.petroferm.com/Contact.aspx?bus=2&type=request" title="Contact us">click here</a>.  You may also call (800) 432-7187.</p>
		<p>Following is an overview of the waxes that we offer.  In addition to these, there are numerous specialty waxes for the food, personal care, automotive care, and industrial markets.  Please click on the following links to learn more about waxes for the <a href="http://www.petroferm.com/markets.asp?bus=2&mkt=FOOD" title="Browse our Food Market">Food</a> and <a href="http://www.petroferm.com/markets.asp?bus=2&mkt=PERSONAL" title="Browse our Personal Care Market">Personal Care Industries</a>.</p>
		<p><div class="blueTitle">Natural Waxes</div></p>
		<p>Derived from natural sources all over the world, these waxes are used in a variety of formulations.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid,
	@PageModuleRelnID = @pmrid

/*********************************************************************************
PETROFERM BUSINESS UNIT DATA SCRIPTS
**********************************************************************************/

-- petroferm home page
update tblpage set pagetitle = 'Welcome to Petroferm Inc.' where pageid = 1
update tblimage set imagepath = 'web/files/images/logos/petrofermlogo.png', alt='Petroferm Inc.' where imageid=1
update tblimage set imagepath = 'web/files/images/header/petroferm_home_menu2.jpg', width=443, height=110, Alt='Petroferm Inc.' where imageid=2

update tblurlrewrite set urlfriendlyname = 'petroferm.welcome-to-petroferm-inc.aspx' where pageid = 1

-- START TASK #28 --
-- petroferm top navigation records -- (added 12/27/2006 - kr - task #28)
declare @imageId int,
	@imageModId int

-- === Cleaning Navigation Off Image ===
-- add image
insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/nav/nav_petroferm_cleaning_off.gif','Cleaning Division',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imageId = @@identity
-- add image module
insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (@imageId,'NAVIGATION OFF',2,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select 	@imageModId = @@identity
-- add page module reln between new image module and pageid=1
insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (1,@imageModId,'NAV OFF IMAGE',2,1,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)



-- === Cleaning Navigation On Image ===
-- add image
insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/nav/nav_petroferm_cleaning_on.gif','Cleaning Division',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imageId = @@identity
-- add image module
insert into tblImageModule (ImageID, ImageType, ImageOrder, RelatedImageModuleID, WelcomeImageID, WelcomeTitle, WelcomeLinkPageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (@imageId,'NAVIGATION ON',1,@imageModId,4,'Petroferm Cleaning Products',10,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select 	@imageModId = @@identity
-- add page module reln between new image module and pageid=1
insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (1,@imageModId,'NAV ON IMAGE',1,1,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)


-- === Fuel Navigation Off Image ===
-- add image
insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/nav/nav_petroferm_fuel_off.gif','Petroferm Fuel Products',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imageId = @@identity
-- add image module
insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (@imageId,'NAVIGATION OFF',2,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select 	@imageModId = @@identity
-- add page module reln between new image module and pageid=1
insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (1,@imageModId,'NAV OFF IMAGE',4,1,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)


-- === Fuel Navigation On Image ===
-- add image
insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/nav/nav_petroferm_fuel_on.gif','Petroferm Fuel Products',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imageId = @@identity
-- add image module
insert into tblImageModule (ImageID, ImageType, ImageOrder, RelatedImageModuleID, WelcomeImageID, WelcomeTitle, WelcomeLinkPageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (@imageId,'NAVIGATION ON',1,@imageModId,18,'Petroferm Fuel Products',22,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select 	@imageModId = @@identity
-- add page module reln between new image module and pageid=1
insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (1,@imageModId,'NAV ON IMAGE',3,1,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)



-- === Industrial Navigation Off Image ===
-- add image
insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/nav/nav_petroferm_industrial_off.gif','Industrial Products Division',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imageId = @@identity
-- add image module
insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (@imageId,'NAVIGATION OFF',2,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
--insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
--values (@imageId,'NAVIGATION OFF',2,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)

select 	@imageModId = @@identity
-- add page module reln between new image module and pageid=1
insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (1,@imageModId,'NAV OFF IMAGE',6,1,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)


-- === Industrial Navigation On Image ===
-- add welcome image 
declare @welcomeImageId int
insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/header/industrial_home_menu1.jpg','Industrial Products Divisions',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @welcomeImageId = @@identity

-- add image
insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/nav/nav_petroferm_industrial_on.gif','Industrial Products Division',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imageId = @@identity
-- add image module
insert into tblImageModule (ImageID, ImageType, ImageOrder, RelatedImageModuleID, WelcomeImageID, WelcomeTitle, WelcomeLinkPageIDList, WelcomeLinkTextList, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (@imageId,'NAVIGATION ON',1,@imageModId, @welcomeImageId,'Industrial Products Division','32|55|56|44','Lambent Technologies|Lambent Technologies SSD|Hansotech Inc.|Joseph Storey',getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
--insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
--values (@imageId,'NAVIGATION ON',1,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)

select 	@imageModId = @@identity
-- add page module reln between new image module and pageid=1
insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values (1,@imageModId,'NAV ON IMAGE',5,1,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)


-- END TASK #28 --

update tblcontentmodule set Title = 'Welcome to Petroferm Inc.', Content = '			<br>
			<div style="color:#393934;font-size:15px;font-weight:bold;text-align:center;padding-top:10px;padding-bottom:10px;">Our Divisions</div>
			<!-- Begin Our Three Divisions table -->
			<table cellpadding="0" cellspacing="0" border="0" width="450" align="center">
				<tr>
					<td width="5" rowspan="2"><img src="images/spacer.gif" width="5" height="1" border="0"></td>
					<td class="divisionTitleBold" align="center">Petroferm&nbsp;Products</td>
					<td width="5" rowspan="2"><img src="images/spacer.gif" width="5" height="1" border="0"></td>
					<td class="divisionTitleBold" align="center">Industrial&nbsp;Products</td>
					<td width="5" rowspan="2"><img src="images/spacer.gif" width="5" height="1" border="0"></td>
				</tr>
				<!-- links row -->
				<tr> 
					<td valign="top" width="50%" align="center">
						<div style="padding-top:5px;"><a href="default.aspx?bu=2">Petroferm Cleaning Agents</a></div>
						<div style="padding-top:5px;"><a href="default.aspx?bu=3">Petroferm Fuels </a></div>
					</td>
					<td valign="top" width="50%" align="center"> 
						<div style="padding-top:5px;"><a href="default.aspx?bu=4">Lambent Technologies</a></div>
						<div style="padding-top:5px;"><a href="ssd.asp">Lambent Technologies, SSD</a></div>
						<div style="padding-top:5px;"><a href="wax.asp">Hansotech Inc.</a></div>
						<div style="padding-top:5px;"><a href="default.aspx?bu=5">Joseph Storey</a></div>
					</td>
				</tr>
			</table>
			<!-- End Our Three Divisions table -->
			<br>
			<table cellpadding="0" cellspacing="0" border="0" width="572">
				<tr>
					<td style="line-height:20px;padding-left:5px;" colspan="2"> 
						<b>Petroferm</b> is a specialty chemical manufacturer with a diverse product offering. 
						Our <b>Petroferm Products Division</b> provides finished products used in the manufacturing
						 industry to clean high-reliability electronics and precision parts, and in the fuels and 
						 oil field industry to increase fuel combustion in oil-fired industrial boilers.  Our 
						 <b>Industrial Products Division</b> provides ingredients used in products including plastics 
						 and polymers, lubricants, personal care products, food, and household and institutional cleaners.  
						
					</td>
				</tr>
			</table>' 
where contentid = 1


-- petroferm contact us
update tblcontentmodule set content = '			<p>
				<strong>Petroferm Administrative Offices</strong><br>
				2416 Lynndale Road<br>
				Fernandina Beach, FL 32034<br>
				Phone: 904-261-8286<br>
				Fax: 904-261-6994
			<p>
				<strong>Lambent Technologies</strong><br>
				3938 Porett Drive<br>
				Gurnee, IL 60031<br>
				Phone: 800-432-7187<br>
				Fax: 847-249-6792
			<p>
				<strong>Joseph Storey and Company, Ltd</strong><br>
				Heron Chemical Works<br>
				Lancaster, England, LA1 1QQ<br>
				Phone: +44 (0)1524 63252<br>
				Fax: +44 (0)1524 381805
			<p>' 
where contentid = 5

-- petroferm terms & conditions
update tblcontentmodule set content = '<p>Petroferm Inc., a specialty chemical company, makes this Web Site ("Site") 
                                        available to the public as a service to longstanding customers, new and potential customers, 
                                        and those who merely are interested in our company and/or subsidiaries. We expect the Site to 
                                        expand and change significantly to mirror our rapidly growing company and to promote new business 
                                        opportunities. We encourage your feedback in order to improve the Site and enhance customer 
                                        relationships. We promise to protect customer relationships with honesty, privacy and trust.</p>
                                        
                                        <p>In order to avoid misunderstandings and to promote sound business practices, we set forth 
                                        below terms and conditions for the use of this Site. By accessing, viewing, or using the material 
                                        in the Site, you indicate that you understand the Terms and Conditions and agree to be legally 
                                        bound by them. You should not use this Site if you do not wish to engage in the agreement about 
                                        the Terms and Conditions (this "Agreement").</p>
                                        
                                        <b>1. Use and Accuracy</b>
                                        <p>This Site is designed to provide general information about the business and services of Petroferm Inc.. 
                                        While Petroferm Inc. endeavors to keep these materials accurate and up-to-date, Petroferm Inc. does not warrant 
                                        or represent, either expressly or by implication, that the information contained or referenced 
                                        herein is accurate or complete and Petroferm Inc. shall not be liable in any way for possible errors or 
                                        omissions in the contents hereof. In addition, Petroferm Inc. reserves the right to alter the content of 
                                        this Site at any time, for any reason, without prior notification, and will not be liable in any 
                                        way for possible consequences of such changes. Petroferm Inc. reserves the right to terminate your access 
                                        to the Site or any portion of this Site without notice in the event that you violate this Agreement 
                                        or for any reason whatsoever.</p>
                                        
                                        <b>2. Intellectual Property</b>
                                        <p>All material contained in this Site is protected by law, including but not limited to, United States copyright and trademark laws, as well as other state, national and international laws and regulations. Except as indicated, the entire content of www.petroferm.com is ©2003 Petroferm Inc., and any commercial use requires written permission of Petroferm Inc.. Petroferm Inc. also owns a copyright in this Site as a collective work and/or compilation, and in the selection, coordination, arrangement, organization and enhancement of such content. You may use, reproduce, distribute or reprint materials available from this Site for your personal and non-commercial use, provided (i) proper copyright notices appear in all reproductions, (ii) no documents or related images are modified in any way; and (iii) no graphic images available from this Site are used, copied or distributed separate from accompanying text. Any text materials in the Web Site may not be modified in any way. All marks designating Petroferm Inc.''s products and services are proprietary trademarks of Petroferm Inc.. Use or misuse of these trademarks is expressly prohibited and may violate federal and state trademark laws. Please be apprised that Petroferm Inc. enforces its intellectual property rights to the fullest extent of the law.</p>

                                        <b>3. Disclaimers and Limitation of Liability</b>
                                        <p>USE OF THIS SITE IS ENTIRELY AT YOUR OWN RISK. NEITHER Petroferm Inc. NOR ANY OF ITS AFFILIATES IS RESPONSIBLE FOR THE CONSEQUENCES OF RELIANCE ON ANY INFORMATION CONTAINED OR SUBMITTED TO THE SITE, AND THE RISK OF INJURY RESTS ENTIRELY WITH YOU. THESE MATERIALS ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. </p>
                                        <p>Petroferm Inc. AND ITS AFFILIATES SHALL NOT BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL, PUNITIVE OR CONSEQUENTIAL DAMAGES, INCLUDING WITHOUT LIMITATION, LOST REVENUES OR LOST PROFITS, WHICH MAY RESULT FROM THE USE OF, ACCESS TO, OR INABILITY TO USE THESE MATERIALS. BECAUSE SOME STATES DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, THE ABOVE LIMITATION OR EXCLUSION MAY NOT APPLY TO YOU. IF YOU ARE DISSATISFIED WITH ANY PORTION OF THIS SITE, OR WITH ANY OF THESE TERMS OF USE, YOUR SOLE AND EXCLUSIVE REMEDY IS TO DISCONTINUE USING THIS SITE. </p>
                                        <p>Petroferm Inc. and its affiliates will not be liable for any loss resulting from a cause over which they do not have complete control, including but not limited to failure of electronic or mechanical equipment or communication lines, telephone or other interconnect problems, computer viruses, unauthorized access, theft, operator errors, severe weather, earthquakes or natural disasters, strikes or other labor problems, wars, or governmental restrictions. </p>
                                        <p>This Site may contain links to other Internet web sites for the convenience of users in locating information that may be of interest. These sites are maintained by third parties over which Petroferm Inc. exercises no control and, accordingly, Petroferm Inc. expressly disclaims any responsibility for the content, the accuracy of the information and/or quality of products or services provided by or advertised on these third-party sites. Petroferm Inc.''s inclusion of links to any web sites does not imply any endorsement of the material on such web sites or any association with their operators. </p>
                                        
                                        <b>4. Applicable Laws and Jurisdictional Issues</b>
                                        <p>In connection with use of this Site, you shall abide by all applicable federal, state and local laws, including those pertaining to such areas as libel, slander, defamation, trade libel, product disparagement, harassment, invasion of privacy, and copyright or trademark infringement. </p>
                                        <p>These Terms and Conditions will be governed by and construed in accordance with the laws of the State of Florida, United States of America, without reference to its conflicts or choice of law rules. All activity occurring in connection with the site (including, but not limited to, accessing pages, downloading materials or other activities initiated by you) is presumed to occur in the State of Florida. Furthermore, if you accept these Terms and Conditions, you consent to the jurisdiction of the federal and state courts presiding in Florida, and agree to accept service of process by mail and hereby waive any and all jurisdictional and venue defenses otherwise available. </p>
                                        <p>If any part of this Agreement is declared invalid or unenforceable under applicable law, then such provision will be automatically adjusted to the minimum extent necessary to conform to the requirements for validity as declared at such time and, as so adjusted, will be incorporated as a part of this Agreement as though originally included and the remaining parts will continue to remain in effect. A printed version of this Agreement and of any notice given in electronic form will be admissible in any proceeding relating to this Agreement to the same extent as if in writing and signed by each party. </p>

                                        <b>5. Indemnification</b>
                                        <p>You agree to indemnify and hold harmless Petroferm Inc., its affiliates, and all of their respective directors, officers, employees, representatives, proprietors, partners, shareholders, servants, agents, predecessors, successors, assigns, and attorneys from and against any and all claims, proceedings, damages, injuries, liabilities, losses, costs, and expenses (including attorney''s fees and litigation expenses) relating to or arising from your use of the Site and any breach by you of this Agreement. </p>
                                        
                                        <b>6. Privacy</b>
                                        <p>"Petroferm Inc.''s policy is to respect and protect the privacy of our users. Petroferm Inc. agrees to exercise reasonable precautions to maintain the confidentiality of all information provided by users in connection with accessing this site. Petroferm Inc. does not collect personal identifying information about individuals except when specifically and knowingly provided by such individuals. </p>
                                        <p>Petroferm Inc. will never willfully sell, rent or trade personal information about our users to any third party. (Except in the case where Petroferm Inc. is acquired by a third party.) Petroferm Inc. may disclose personal information in special cases when we have reason to believe that disclosing this information is necessary to identify, contact, or bring legal action against someone who may be causing injury to or interference with (either intentionally or unintentionally) Petroferm Inc.''s rights or property or anyone that could be harmed by such activities. Petroferm Inc. may disclose personal information when we believe in good faith that the law requires it. </p>
                                        <p>Petroferm Inc. does routinely disclose personal information to its sales, marketing and service personnel and may disclose personal information to one of its suppliers, business partners or distributors. In this case, we will make every effort to receive your permission before disclosing personal information. </p>
                                        <p>Petroferm Inc. also collects aggregate information about our Web site users. Aggregate information includes, for example, unique URLs; top referring sites and URLs; keyword referrals; top search engines; and most used browsers and platforms. We may share this information with suppliers, business partners, distributors and other third parties. Aggregate data is used to make our site a better experience for you." </p>
                                        
                                        <b>7. Correspondence</b>
                                        <p>Petroferm Inc. is pleased to hear from users of our Web Site and welcomes your feedback and suggestions about how to improve this Site. Petroferm Inc. must, however, regretfully ask that you do not send it any copyrighted or proprietary information. If you send such information, the information shall be deemed, and shall remain, the property of Petroferm Inc.. Any ideas, suggestions, or any other material received through this Site will be deemed to include permission for Petroferm Inc. to adopt, publish, reproduce, disseminate, transmit, distribute, copy, use or act on such communications without additional approval or consideration, and you hereby waive any claim to the contrary. </p>
                                        
                                        <b>8. Export Controls</b>
                                        <p>This Site is controlled and operated by Petroferm Inc. from its offices within the United States. Petroferm Inc. makes no representation that materials in the Site are appropriate or available for use in other locations, and access to them from territories where their contents are illegal is prohibited. Those who choose to access this Site from other locations do so on their own volition and are responsible for compliance with all applicable local laws. </p>
                                        
                                        <b>9. Modifications to Agreement</b>
                                        <p>Petroferm Inc. reserves the right to update this Agreement from time to time and without notice. Updates will, in no way, relieve you of your obligations under earlier versions of this Agreement. Use of this Site constitutes acceptance of the terms of the Agreement in place at the moment of use. </p>
                                        
                                        <b>10. Termination</b>
                                        <p>This Agreement is effective until terminated by either party. However, this Agreement''s jurisdictional provisions shall remain in full force and effect for any dispute that arises over prior activities on this Site, regardless of whether or not either party has terminated the Agreement. By destroying all materials obtained from any and all the Petroferm Inc. Site(s) and all related documentation and all copies and installations thereof, whether made under the terms of this Agreement or otherwise, this Agreement may be terminated at any time. This Agreement will terminate immediately without notice if in our sole discretion you fail to comply with any term or condition. Upon termination, you must destroy all materials obtained from this Site and all copies thereof. </p>
                                        
                                        <b>11. Entire Agreement</b>
                                        <p>These Terms and Conditions and the other terms and conditions as may be found throughout the Site constitute the entire agreement between you and Petroferm Inc. with respect to your use of the Site. You acknowledge that, in providing you access to and use of the Site, Petroferm Inc. has relied on your agreement to be legally bound by these Terms and Conditions. </p>' 
where contentid = 6


/*********************************************************************************
PETROFERM BUSINESS UNIT/CLEANING DIVISION/FUEL&OILFIELD DIVISION SHARED DATA SCRIPTS
**********************************************************************************/

-- petroferm general information (same for cleanng division and fuel/oil)
update tblcontentmodule set content = '<p>Petroferm Inc. is a privately held specialty chemical manufacturer with facilities in the U.S. and Europe.  We have achieved success by combining a relentless focus on our core markets with continued technological innovation.  In Gurnee, IL, we manufacture specialty ingredients for the food, personal care, lubricant, and polymer industries, as well as proprietary products that are used to create water-in-oil emulsions with heavy fuel oil that is burned in large industrial boilers.  In Fernandina Beach, FL we manufacture products that are used to clean high reliability electronics, airplane, and aerospace components.  In Lancaster, UK, we manufacture non-halogenated flame retardants and smoke suppressants based on borates and stannates that are used in the plastics, rubber, and paint industries.</p>
				<p>At Petroferm, our mission is to drive our customers'' growth by constantly supplying innovative solutions through superior customer service, a diverse product offering and applications support. </p>' 
where contentid in (2,8,17)

-- petroferm company history (same for cleaning division and fuel/oil)
update tblcontentmodule set Title = 'Company History', Content = '<p>Founded in 1981, Petroferm is a privately held manufacturer of specialty chemicals. In its early days, Petroferm was a biotechnology company focused on recovery, transportation and combustion of heavy hydrocarbons (crude oil).  The "Fuel Services" business unit, Petroferm''s oldest division, emerged from this initial work.  The "Cleaning Products" business unit was also founded in the mid-1980''s, with early work to replace hazardous cleaning solvents commonly used in manufacturing processes.  Then the signing of the Montreal Protocol in the late 1980''s presented a global opportunity for Petroferm scientists to use their expertise to formulate CFC-free cleaning products, leading to Petroferm''s worldwide success in Electronics and Precision Cleaning industries.<p>In the mid-1990''s, Petroferm began a series of acquisitions that began with Siltech, manufacturer of specialty silicones, followed by Oleochemical derivatives manufacturer Calgene Chemical, and Hansotech, which sold natural waxes primarily to the Personal Care industry.  These three companies today are the subsidiary Lambent Technologies, now based in Gurnee, IL, in a large surfactant manufacturing plant acquired from BASF Corp in 2003.  In 1999, Petroferm acquired Banner Chemicals in the UK, and in 2004 divested Banner Chemicals, retaining ownership of Banner subsidiary Joseph Storey and Co., Ltd, a manufacturer of flame retardants and smoke suppressants. <p>Today, the Company is organized into two divisions to best serve our customers and focus on target markets.  The Industrial Products Division (Lambent Technologies and Joseph Storey) manufactures specialty ingredients for personal care, food, polymers, and lubricants.  The Petroferm Products Division manufactures a wide variety of industrial cleaning agents (Cleaning Products) and solutions to aid in the combustion of heavy crude (Fuels Services).' 
where contentid in (4,10,19)

-- petroferm capabilities (same for cleaning division and fuel/oil)
update tblcontentmodule set Title = 'Manufacturing Capabilities', content = '<p>Petroferm''s manufacturing capabilities range from simple blends to complex reactions.  Our facility in Florida manufactures all of Petroferm''s Cleaning Agents to the strictest quality standards.
				<P>Our Gurnee production facility is ideal for making esters and alkoxylates. In addition to 19 reactors, the facility boasts 7 rail spots, 9 loading docks and over 760,000 gallons of storage capacity for increased materials handling. We fully expect these new capabilities to strengthen our product line offering.
				<p>	
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="tblHdr">Esterfication</td>
					<td class="tblHdr">Alkoxylation</td>
					<td class="tblHdrctr">Silicones/Silanes</td>
					<td class="tblHdr">Antifoams</td>
					<td class="tblHdr">Vegetable Oils</td>
				</tr>
				<tr valign="top">
					<td class="tblRow2">
						Amides<br>
						Fatty Esters<br>
						Glycerol Esters<br>
						Methyl Esters<br>
						PEG Esters<br>
						Phosphate Esters<br>
						Polyglycerol Esters<br>
						Propoxylated Esters<br>
						Sorbitan Esters
					</td>
					<td class="tblRow2">
						Ethoxylated Alcohols<br>
						Ethoxylated Amines<br>
						Ethoxylated Esters<br>
						Ethoxylated Glycerine<br>
						Ethoxylated Sorbitol<br>
						EO/PO Copolymers<br>
						PEGs<br>
						Polysorbates<br>
						Surfactants, Anionic<br>and Cationic
					</td>
					<td class="tblRow2">
						Silicone Emulsions<br>
						Silicone Fluids<br>
						Functionalized Silicones
					</td>
					<td class="tblRow2">
						Silicone<br>
						Non-silicone
					</td>
					<td class="tblRow2">
						Canola Oil<br>
						High Oleic Canola Oil<br>
						HEAR Oil<br>
						Medium Blown HEAR Oil
					</td>
				</tr>
				</table>

				<p>The Inorganic Borate and Stannate product range manufactured at Lancaster UK includes the following listed below.

				<p>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="tblHdr">Inorganic Borates</td>
					<td class="tblHdr">Inorganic Stannates</td>
					<td class="tblHdrctr">Epoxy Floor Screeds</td>
				</tr>
				<tr valign="top">
					<td class="tblRow2">
						Zinc Borate<br>
						Barium Metaborate<br>
						Calcium Borate<br>
						Magnesium Borate<br>
						Aluminium Borate<br>
						Potassium Borate<br>
						Melamine Borate<br>
						Zinc Borophosphate<br>
						Zinc Borate Anhydrous<br>
						Calcium Borate Anhydrous<br>
						Magnesium Borate Anhydrous<br>
					</td>
					<td class="tblRow2">
						Zinc Hydroxy Stannate<br>
						Zinc Stannate<br>
						ZHS Coated Alumina Trihydrate<br>
						ZHS Coated Magnesium Hydroxide <br>
					</td>
					<td class="tblRow2">
						Trawlerdeck 
					</td>
				</tr>
				</table>'
where contentid in (3,9,18)


/*********************************************************************************
CLEANING DIVISION DATA SCRIPTS
**********************************************************************************/

update tblurlrewrite set urlfriendlyname = 'petroferm-cleaning-division.advanced-products-for-advanced-cleaning.aspx' where pageid= 10
update tblpage set pagetitle = 'Advanced Products for Advanced Cleaning' where pageid=10

exec sp__AddContentModule
	@PageID = 10,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<div id="content" style="overflow:hidden;height:;width:169;padding-right:3px;">	
	<p>Most of our Cleaning Products Division is relocating from Fernandina Beach, FL to our Gurnee, IL facility.  
	<a href="static/files/cleaning/2006CustomerNotificationLetter.pdf" target="_blank">Click here</a> for more details.
	</p><p></p></div>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

exec sp__AddContentModule
	@PageID = 10,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 2,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = '<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr valign="top"><td>PETROFERM CLEANING PRODUCTS DIVISION<br>
		ISO9001:2000 approved<br>At the Gurnee, IL facility.<br><a href="static/files/ISO Certificate UL.pdf" target="_blank">Click here</a> for details.							
		</td><td>&nbsp;</td></tr><tr><td height="5"></td></tr></table>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


-- update cleaning division home page
update tblcontentmodule set title = 'Advanced Products for Advanced Cleaning', content = 'Petroferm''s proprietary cleaning agents are synergistic blends formulated to 					
					meet the increasing  demands of today''s manufacturing operations.  Offering the 					
					most diverse chemical technologies in the cleaning industry, our high 					
					performance cleaning agents are capable of removing both organic and inorganic 
					soils from a wide range of surfaces and substrates.  These products are 
					specifically designed to effectively replace toxic, hazardous, 
					flammable or environmentally undesirable chemicals.  Petroferm products are 
					formulated to perform in a wide range of equipment and processes such as;  
					immersion, ultrasonic, turbulation, spray-in-air,  vapor degreasing and hand wipe. 
					<br><br>
					Our products are used in a broad variety of critical cleaning processes and 					
					complex applications including  electronics, aerospace, defense, medical and 					
					automotive applications. Petroferm provides solutions designed to meet and 					
					exceed many stringent industrial environmental and manufacturing 
					specifications.  The Petroferm products are sold under the AXAREL, BIOACT, 			
					CleanSafe, HYDREX, LENIUM, MEGASOLV, Re-Entry, and RustSafe 
					registered tradenames.' 
where contentid = 7


-- cleaning division contact us
update tblcontentmodule set title = 'Contact Us', content = '<strong>Petroferm Administrative Offices</strong><br>
				2416 Lynndale Road<br>
				Fernandina Beach, FL 32034<br>
				Phone: 904-261-8286<br>
				Fax: 904-261-6994
			<p>
			
				<table width="50%" border="0" cellspacing="0" cellpadding="3">
				<tr>
					<td width="100%" class="tblHdr">Regional Managers/USA</td>
				</tr>
				<tr><td class="tblRow2" colspan="2"></td></tr>			
				<tr valign="top">
					<td class="tblRow1">
						Sandra Gates<br>
						RM Southeast Region<br>
						<a href="mailto:sgates@petroferm.com">sgates@petroferm.com</a><br>
					</td>			
				</tr>			
				<tr><td class="tblRow2" colspan="2"></td></tr>
				<tr valign="top">
					<td class="tblRow1">
						Bill Johnson<br>
						RM Western Region<br>
						<a href="mailto:bjohnson@petroferm.com">bjohnson@petroferm.com</a><br>
					</td>
				</tr>
				<tr><td class="tblRow2" colspan="1"></td></tr>
				<tr valign="top">
					<td class="tblRow1">
						Jose Zapata<br>
						RM Latin America<br>
						<a href="mailto:jzapata@petroferm.com">jzapata@petroferm.com</a>
					</td>
				</tr>				
				<tr><td class="tblRow2" colspan="1"></td></tr>
				<tr valign="top">
					<td class="tblRow1">
						Mike Winters<br>
						RM Midwest Region<br>
						<a href="mailto:mwinters@petroferm.com">mwinters@petroferm.com</a>
					</td>
				</tr>
				<tr><td class="tblRow2" colspan="1"></td></tr>
				<tr valign="top">
					<td class="tblRow1">
						Mike Savidakis<br>
						RM Northeast Region<br>
						<a href="mailto:msavidakis@petroferm.com">msavidakis@petroferm.com</a>
					</td>
				</tr>
				<tr><td class="tblRow2" colspan="2"></td></tr>
				<tr>
					<td width="100%" class="tblHdr">International Regional Managers</td>
				</tr>				
				<tr><td class="tblRow2" colspan="1"></td></tr>			
				<tr valign="top">
					<td class="tblRow1">
						Jonathan Tomassetti<br>
						RM Asia Pacific<br>
						<a href="mailto:jtomassetti@petroferm.com">jtomassetti@petroferm.com</a>
					</td>
				</tr>			
				<tr><td class="tblRow2" colspan="1"></td></tr>
				<tr valign="top">
					<td class="tblRow1">
						Kul Sappal <br>
						RM Europe/Africa/Middle East<br>
						<a href="mailto:ksappal@petroferm.com">ksappal@petroferm.com</a>
					</td>			
				</tr>				
												
			</table>' 
where contentid = 11

-- cleaning (electronics home page)
update tblpage set pagetitle = 'Electronics Cleaning' where pageid=18
update tblcontentmodule set title = 'Electronics Cleaning',  content = '<div style="padding-left: 40px;width:100%;" class="bodyBig"> 
						<br/>
						<p>For over 15 years Petroferm has been providing environmentally responsible chemistries formulated for outstanding performance and competitive use-costs.  Petroferm''s electronics cleaning agents have been developed specifically for electronic assembly manufacturing and semiconductor packaging applications. Our products offer chemistries designed to serve all major types of cleaning processes: semi-aqueous, aqueous, vapor degreasing, and manual/non-aqueous cleaning. Petroferm, along with its worldwide marketing partners, is committed to helping you with your selection to ensure your total satisfaction. </p>
						<p>Petroferm products are sold under the AXAREL, BIOACT, HYDREX, LENIUM, and MEGASOLV registered tradenames.</p>
						</div>' 
where contentid = 12

exec sp__AddContentModule
	@PageID = 18,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = '<p>Most of our Cleaning Products Division is relocating from Fernandina Beach, FL to our Gurnee, IL facility.  
			<a href="static/files/cleaning/2006CustomerNotificationLetter.pdf" target="_blank">Click here</a> for more details.</p>
		<p><a href="static/files/cleaning/Introducing HYDREX LF.pdf" target="_blank">HYDREX LF</a> - NEW Aqueous Cleaner for LEAD FREE Manufacturing</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


-- cleaning (precision cleaning home page)
update tblpage set pagetitle = 'Precision and Industrial Cleaning' where pageid=19
update tblcontentmodule set title = 'Precision and Industrial Cleaning',  content = '<div style="padding-left: 40px;width:100%;" class="bodyBig"> 
						<br/>
						<p>Petroferm offers a comprehensive range of cleaning agents specifically engineered for use in all major types of cleaning processes: aqueous, semi-aqueous, non-aqueous immersion, vapor degreasing, and manual/handwipe cleaning.  Petroferm''s precision cleaning products have been developed specifically for the removal of a broad range of soils including oils, greases, coolants, lubricants, adhesives, fluxes, or waxes in precision applications. </p>
						<p>Petroferm products are sold under the AXAREL, BIOACT, CleanSafe, LENIUM, and RE-ENTRY registered tradenames.</p></div>' 
where contentid = 13

exec sp__AddContentModule
	@PageID = 19,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>Most of our Cleaning Products Division is relocating from Fernandina Beach, FL to our Gurnee, IL facility.  
		<a href="static/files/cleaning/2006CustomerNotificationLetter.pdf" target="_blank">Click here</a> for more details.</p>
		<p>Product bulletin available discussing the challenges of cleaning bellows or expansion joints.  Includes recommendations for operating conditions and a method for determining cleanliness.  
		<a href="static/files/cleaning/Bellows - Product Bulletin.pdf" target="_blank">Click here</a> for more details.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

-- cleaning (asphalt products home page)
update tblpage set pagetitle = 'Asphalt Products' where pageid=20
update tblcontentmodule set title = 'Asphalt Products',  content = '<div style="padding-left: 40px;width:100%;" class="bodyBig"> 
						<br/>
						<p>Petroferm Asphalt Extractants and Cleaners are an ideal biodegradable alternative to replace chlorinated solvents such as Trichloroethylene and 1,1,1 Trichloroethane traditionally used to perform quality control tests with bituminous hot-mix asphalt to determine asphalt content values. The asphalt extractants have been designed to be used with vacuum and centrifuge equipment for test procedures approved by State DOT agencies.  These products can also be used to dissolve and remove asphalt from lab equipment, tools, and heavy equipment.</p>
						<p>Petroferm products are sold under the BIOACT, and LENIUM registered tradenames.</p>
						</div>' 
where contentid = 14

exec sp__AddContentModule
	@PageID = 20,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>Most of our Cleaning Products Division is relocating from Fernandina Beach, FL to our Gurnee, IL facility.  
			<a href="static/files/cleaning/2006CustomerNotificationLetter.pdf" target="_blank">Click here</a> for more details.
			</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

-- cleaning (aerospace/airline home page)
update tblpage set pagetitle = 'Aerospace/Airline' where pageid=21
update tblcontentmodule set title = 'Aerospace/Airline',  content = '<div style="padding-left: 40px;width:100%;" class="bodyBig"> 
						<br/>
						<p>Petroferm has been providing cutting-edge cleaning agents to many industries for over 15 years. Our products are environmentally responsible and have been formulated for outstanding performance and competitive in-use costs. We offer several brands of hand-wipe, vapor degreasing, aqueous, non-aqueous and semi-aqueous products. Our Cleaning Agents are approved and used by manufacturers of aerospace and commercial airline equipment as well as their suppliers, customers and maintenance companies.  Petroferm products are used to clean a broad range of soils for all types of cleaning processes used in the manufacture and maintenance of aerospace and aviation equipment. </p>
						<p>Petroferm products are sold under the AXAREL, BIOACT, LENIUM, and RE-ENTRY registered tradenames.</p>
						</div>' 
where contentid = 15


exec sp__AddContentModule
	@PageID = 21,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>Most of our Cleaning Products Division is relocating from Fernandina Beach, FL to our Gurnee, IL facility.  
			<a href="static/files/cleaning/2006CustomerNotificationLetter.pdf" target="_blank">Click here</a> for more details.
			</p>
			<p>
			Boeing PSD-652 released March 30, 2006 included CleanSafe™ 787 approved and qualified to 
			BAC 5763 (emulsion cleaning and aqueous degreasing) guidelines.  
			<a href="static/files/cleaning/tds/cleansafe787.pdf" target="_blank">Click here</a> for further product information.		
			</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

update tblurlrewrite set urlfriendlyname = 'petroferm-cleaning-division.electronics-market.electronics-cleaning.aspx' where pageid = 18
update tblurlrewrite set urlfriendlyname = 'petroferm-cleaning-division.precision-cleaning-market.precision-and-industrial-cleaning.aspx' where pageid = 19
update tblurlrewrite set urlfriendlyname = 'petroferm-cleaning-division.asphalt-products-market.asphalt-products.aspx' where pageid = 20
update tblurlrewrite set urlfriendlyname = 'petroferm-cleaning-division.aerospace-airline-market.aerospace-airline.aspx' where pageid = 21


update tblimage set imagepath = 'web/files/images/header/cleaning_home_menu1.jpg', width=443, height=110 where imageid=4

update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_electronics_on.gif' where imageid=5
update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_electronics_off.gif' where imageid=6
update tblimage set imagepath = 'web/files/images/header/cleaning_electronics_menu1.jpg', width=443, height=110 where imageid=7

update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_precision_on.gif' where imageid=8
update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_precision_off.gif' where imageid=9
update tblimage set imagepath = 'web/files/images/header/cleaning_precision_menu1.jpg', width=443, height=110 where imageid=10

update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_asphalt_on.gif' where imageid=11
update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_asphalt_off.gif' where imageid=12
update tblimage set imagepath = 'web/files/images/header/cleaning_asphalt_menu1.jpg', width=443, height=110 where imageid=13

update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_aerospace_on.gif' where imageid=14
update tblimage set imagepath = 'web/files/images/nav/nav_cleaning_aerospace_off.gif' where imageid=15
update tblimage set imagepath = 'web/files/images/header/cleaning_aerospace_menu1.jpg', width=443, height=110 where imageid=16


/*********************************************************************************
FUEL AND OILFIELD DIVISION DATA SCRIPTS
**********************************************************************************/

-- update fuel & oilfield division home page
update tblurlrewrite set urlfriendlyname = 'petroferm-fuel-and-oil-division.fuels-division.aspx' where pageid= 22

update tblcontentmodule set title = 'Fuels Division', content = '<br><table cellpadding="0" cellspacing="0" border="0" width="375"><tr><td style="line-height:20px;padding-left:5px;">
The Fuels division provides chemicals and field expertise to improve combustion of heavy fuel oils and production of oil and gas.  The PEP-99® and PAF® products create stable emulsions of heavy fuel oils with 10-30% water.  These products allow the combustion of low-grade heavy fuel oil.  The results are increased combustion efficiency, lower stack emissions and reduction in the use of costly diluents.
<p></p>Petroferm has leveraged this technology to create the HO-FLOW® family of products for the oilfield.  The HO-FLOW products form water external emulsions with heavy crude oils with only 30% water in the mixture.  These emulsions have reduced apparent viscosities that lower pressure losses in tubing and pipelines.  The technology has increased production and lowered pipeline transportation costs in Canada and Mexico.
<p></p>The surfactant chemistry at Petroferm has been expanded to develop products for oil and gas production.  Products for Paraffin, Asphaltenes, Dehydration and Gas Well Foam treatments are available.  Petroferm continues to search for cost-effective solutions in the petroleum industry by combining their expertise in surface chemistry and integrated manufacturing capabilities.
<p></p><em>*PEP-99, PAF and HO-FLOW are registered trademarks of Petroferm Inc.</em></td></tr></table>' 
where contentid = 16


exec sp__AddContentModule
	@PageID = 22,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>Petroferm is adding 3 new fuel emulsion products to compliment our successful and widely used PEP-99 
						product.  Please <a href="Contact.aspx?ref=3,0,22">contact us</a> for more information.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


exec sp__AddContentModule
	@PageID = 22,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 2,
	@ShowTitle = 1,
	@Title = 'Distributors Wanted',
	@Content = '<p>Petroferm is seeking qualified distributors and representatives. <a href="fueloil_distributorswanted.asp">Click here</a> for more information.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


exec sp__AddContentModule
	@PageID = 22,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 3,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = 'PETROFERM FUELS DIVISION<br>ISO 9001:2000 approved at the Gurnee, IL facility.<br>
		<a href="static/files/ISO Certificate UL.pdf" target="_blank">Click here</a> for details.',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


-- Fuel division > fuel home page
update tblcontentmodule set title = 'Combustion Enhancement Technologies', content = 'PEP®-99 technology creates and stabilizes water-in-oil emulsions with heavy fuel oil typically burned in large industrial boilers and process heaters. PEP-99 technology is particularly advantageous when used in the older or lower-technology boilers.  Patented PAF technology converts low-value refinery bottoms into more valuable fuels. These emulsified fuels provide significant improvements in the handling and combustion characteristics of the hydrocarbon feedstock.  
						<p><img src="web/files/images/content/fuel_combustion_diagram.jpg" width="545" hspace="5"></p>
						<p>A typical burner atomizer produces a spray of fuel oil with an average droplet size greater than 100 microns in diameter. Fuel droplets of this size tend to burn incompletely, and unburned carbon is deposited as soot or escapes up the stack as particulate. 
						</p>
						<p><img src="web/files/images/content/fuel_combustion_diagram_PEP99.jpg" width="545" hspace="5"></p><p>
						Fuels which are atomized to smaller droplet sizes are able to improve combustion in a number of ways such as: 
						</p>
						<ul>
						<li>Better carbon burnout</li>
						<li>Lower excess oxygen</li>
						<li>Greater boiler efficiency </li>
						<li>Lower particulate emissions</li>
						<li>Less NO<sub>x</sub>  and SO<sub>3</sub> production </li>
						<li>Cleaner, lower maintenance boilers </li>
						</ul>
						<p>
						These benefits arise from a more compact flame which has a lower peak flame temperature and requires less excess oxygen.  The boiler efficiency increases due to the lower excess oxygen and better fuel combustion.  The improved combustion produces less soot, reducing particulate emissions and slag deposition in the boiler.  Less soot also maintains heat transfer surfaces cleaner, providing longer boiler run times between scheduled cleaning.   NO<sub>x</sub> and SO<sub>3</sub> emissions are reduced with a cooler flame.						
						</p>
						
						<p><img src="web/files/images/content/fuel_smokestacks.jpg" align="right">
						Smaller droplet sizes can be achieved using both water-in-oil and oil-in-water emulsion technology from Petroferm. Petroferm has the capability to design, install and operate an on-site fuel emulsion facility.  Fireside corrosion inhibitors are also provided to complement our combustion improvers and provide a complete fuel treatment package.  The corrosion inhibitors convert combustion products formed from vanadium and sulfur in heavy fuel oils into harmless by-products.
						</p>					
					</td>
					<td width="30"><img src="images/spacer.gif" height="1" border="0"></td>
				</tr>
			</table>' 
where contentid = 21


-- Fuel Division > Oilfield home page
update tblcontentmodule set title = 'Oilfield Products', content = '<p>Petroferm was founded in 1981 specifically to develop chemistry related to emulsified crude and fuel oil.  Petroferm has continued to maintain a presence in the upstream petroleum industry.  Today the Petroferm staff has over 40 years of experience in production chemistry.  As our distribution grows, our product line expands to meet the demands of our clients.  Petroferm offers products and technical service for many oilfield applications.  Several projects have led to technology development not commonly found at competing companies:</p>
						<!-- Begin Content Info Table -->
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="tblHdr">Technology</td>
								<td class="tblHdr">Application</td>
							</tr>
							<tr>
								<td class="tblRow2"></td>
								<td class="tblRow2"></td>		
							</tr>
							<tr>
								<td class="tblRow1">HO-FLOW</td>
								<td class="tblRow1">Heavy crude oil dispersions in water for pipeline transportation</td>
							</tr>
							<tr>
								<td class="tblRow2"></td>
								<td class="tblRow2"></td>		
							</tr>
							<tr>
								<td class="tblRow1">HO-FLOW</td>
								<td class="tblRow1">Dispersion of high pour-point crude oils in water</td>
							</tr>
							<tr>
								<td class="tblRow2"></td>
								<td class="tblRow2"></td>		
							</tr>
							<tr>
								<td class="tblRow1">HO-FLOW</td>
								<td class="tblRow1">Wellbore stimulation and increased flow of heavy crude oils</td>
							</tr>
							<tr>
								<td class="tblRow2"></td>
								<td class="tblRow2"></td>		
							</tr>
							<tr>
								<td class="tblRow1">BIOACT</td>
								<td class="tblRow1">Dispersion of high-molecular weight paraffins in crude oil or hot water</td>
							</tr>
							<tr>
								<td class="tblRow2"></td>
								<td class="tblRow2"></td>		
							</tr>
							<tr>
								<td class="tblRow1">BIOACT</td>
								<td class="tblRow1">Dewatering waxy emulsions below the wax appearance temperature</td>
							</tr>
						</table><br><br> ' 
where contentid = 22


exec sp__AddContentModule
	@PageID = 31,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>Petroferm is adding 3 new fuel emulsion products to compliment our successful and widely used PEP-99 
			product.  Please <a href="Contact.aspx?ref=3,0,22">contact us</a> for more information.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


exec sp__AddContentModule
	@PageID = 31,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 2,
	@ShowTitle = 1,
	@Title = 'Distributors Wanted',
	@Content = '<p>Petroferm is seeking qualified distributors and representatives. <a href="fueloil_distributorswanted.asp">Click here</a> for more information.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


-- fuel/oil contact us
update tblcontentmodule set title = 'Contact Us', content = '<p><strong>Petroferm Inc.</strong><br>
			2416 Lynndale Road<br>
			Fernandina Beach, FL 32034<br>
			Phone: 904-277-5237<br>
			Fax: 904-261-6994<br>
			E-mail: <a href="mailto:awood@petroferm.com" title="Contact Petroferm Inc.">awood@petroferm.com</a><br><br>' 
where contentid = 20

-- fuel/oil page titles
update tblpage set pagetitle = 'Fuels Division' where pageid = 22
update tblpage set pagetitle = 'Combustion Enhancement Technologies' where pageid = 30
update tblpage set pagetitle = 'Oilfield Products' where pageid = 31

update tblurlrewrite set urlfriendlyname = 'petroferm-fuel-and-oil-division.fuel-market.combustion-enhancement-technologies.aspx' where pageid = 30
update tblurlrewrite set urlfriendlyname = 'petroferm-fuel-and-oil-division.oilfield-market.oilfild-products.aspx' where pageid = 31

update tblimage set imagepath = 'web/files/images/header/fueloil_home_menu1.jpg', width=443, height=110, Alt='Petroferm Fuel and Oil Division' where imageid=18
update tblimage set imagepath = 'web/files/images/nav/nav_fueloil_fuel_on.gif', width=145, height=44 where imageid=19
update tblimage set imagepath = 'web/files/images/nav/nav_fueloil_fuel_off.gif', width=145, height=44 where imageid=20
update tblimage set imagepath = 'web/files/images/header/fueloil_fuel_menu1.jpg', width=443, height=110 where imageid=21

update tblimage set imagepath = 'web/files/images/nav/nav_fueloil_oilfield_on.gif', width=145, height=44 where imageid=22
update tblimage set imagepath = 'web/files/images/nav/nav_fueloil_oilfield_off.gif', width=145, height=44 where imageid=23
update tblimage set imagepath = 'web/files/images/header/fueloil_oilfield_menu1.jpg', width=443, height=110 where imageid=24

/*********************************************************************************
LAMBENT DATA SCRIPTS
**********************************************************************************/

update tblurlrewrite set urlfriendlyname = 'lambent-technologies-corp.our-customers-first-choice.aspx' where pageid = 32

update tblcontentmodule set title = 'Our Customers'' First Choice', content = '<br>
			<table cellpadding="0" cellspacing="0" border="0" width="375">
				<tr>
					<td valign="top" style="padding:0;" width="188" height="64"><img src="web/files/images/content/home1L.jpg" width="188px" height="64px" alt="Lambent Technologies - Our Customers'' First Choice" border="0"></td>
					<td valign="top" style="padding:0;" width="187" height="64"><img src="web/files/images/content/home1R.jpg" width="187px" height="64px" alt="Lambent Technologies - Our Customers'' First Choice" border="0"></td>
				</tr>
				<tr>
					<td valign="top" style="padding:0;" width="188" height="63"><img src="web/files/images/content/home2L.jpg" width="188px" height="63px" alt="Lambent Technologies - Our Customers'' First Choice" border="0"></td>
					<td valign="top" style="padding:0;" width="187" height="63"><img src="web/files/images/content/home2R.jpg" width="187px" height="63px" alt="Lambent Technologies - Our Customers'' First Choice" border="0"></td>
				</tr>
				<tr>
					<td valign="top" style="padding:0;" width="188" height="64"><img src="web/files/images/content/home3L.jpg" width="188px" height="64px" alt="Lambent Technologies - Our Customers'' First Choice" border="0"></td>
					<td valign="top" style="padding:0;" width="187" height="64"><img src="web/files/images/content/home3R.jpg" width="187px" height="64px" alt="Lambent Technologies - Our Customers'' First Choice" border="0"></td>
				</tr>
				<tr>
					<td style="line-height:20px;padding-left:5px;" colspan="2">
						<b>Lambent Technologies</b> manufactures and supplies select raw materials for use in 
						value added formulations.  Using our esterification, alkoxylation and blending capabilities, 
						Lambent manufactures about 100 oleochemical derivatives for customers seeking high performance, 
						naturally derived ingredients.  We also supply select vegetable oils to industrial markets 
						and have a custom manufacturing segment providing solutions for your specific requirements.
					</td>
				</tr>
			</table>'
where contentid = 23


exec sp__AddContentModule
	@PageID = 32,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>For a list of specialty silicones and waxes for automotive care and household, industrial, and institutional cleaning, <a href="static/files/lambent/HIIMarketProducts.pdf" title="HI&I Bulletin">click here</a>.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


exec sp__AddContentModule
	@PageID = 32,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 2,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = '<table border="0" cellspacing="0" cellpadding="0" width="100%">					
			<tr valign="top">
				<td>
				LAMBENT TECHNOLOGIES, A DIVISION OF PETROFERM, INC.<br>
				ISO 9001:2000 approved at the Gurnee, IL facility.<br>
				<a href="static/files/ISO Certificate UL.pdf" target="_blank">Click here</a> for details.							
				</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td height="5"></td>
			</tr>
			<tr valign="top">
				<td colspan="2" align="left"><a href="http://www.cicil.net" target="_blank"><img src="web/files/images/content/CICI150x50.gif" border="0" width="150" height="50" align="middle"></a></td>
			</tr>
			<tr>
				<td height="5"></td>
			</tr>
		</table>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

-- lambent about us page
update tblcontentmodule set title = 'About Lambent Technologies', content = '<img src="web/files/images/content/floor.jpg" align="right" hspace="10px" vspace="5px" alt="" border="0">
				
				<p>Lambent Technologies manufactures and supplies select raw materials for use in value added formulations. Lambent, a division of Petroferm Inc., manufactures  Oleochemical Derivatives and silicone specialties at its Gurnee, IL headquarters.
				<p><strong>Oleochemical Derivatives:</strong> 
				<p>Using our esterification, alkoxylation and blending capabilities, Lambent manufactures about 100 oleochemical derivatives for customers seeking high performance, naturally derived ingredients. We also supply select vegetable oils to industrial markets and have a custom manufacturing segment providing solutions for your specific requirements. 
				<p><strong>Production Facility</strong>
				<ul> 
					<li>Purchased from BASF in 1993, Lambent''s Gurnee facility represents a multi-million dollar investment that increased our capacity and broadened our versatility, complete with state-of-the-art process and lab equipment. 
					<li>Capacity at Gurnee tops 100 million pounds. 
					<li>Highly modern facility has an outstanding safety record along with several widely recognized quality certifications including: 
						<ul type="square">
							<li>Current Good Manufacturing Practices (cGMP) 
							<li>ISO 9001-2000 
							<li>Kosher and Kosher for Passover (OU) certified production 
							<li>Halaal certified production
							<li>Food grade certified production 
							<li>American Institute of Bakers (AIB) "Superior" production rating 
							<li>USP/NF grade certified production 
						</ul>
				</ul>
				<strong>Silicone Specialties:</strong>
				<p>Lambent''s product offering includes several custom synthesized silicone and Guerbet alcohol derivatives. These products mirror conventional surfactants in variety and type, while also providing characteristics not found in traditional hydrocarbons.  These products provide unique properties to formulations including household and automotive cleaners, air fresheneners and odor neutralizers, and Personal Care products.' 
where contentid = 24

-- lambent capabilities
update tblcontentmodule set title = 'Manufacturing Capabilities', content = '<p>
				The Gurnee production facility is ideal for making esters and alkoxylates, currently Lambent''s two largest volume processes. 
				In addition to 19 reactors, the facility boasts 7 rail spots, 9 loading docks and over 760,000 gallons of storage capacity for 
				increased materials handling. We fully expect these new capabilities to strengthen our product line offering.</p>
				<!-- Begin Content Info Table -->
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="tblHdr">Esterfication</td>
					<td class="tblHdr">Alkoxylation</td>
					<td class="tblHdrctr">Silicones/Silanes</td>
					<td class="tblHdr">Antifoams</td>
					<td class="tblHdr">Vegetable Oils</td>
				</tr>
				<tr valign="top">
					<td class="tblRow2">
						Amides<br>
						Fatty Esters<br>
						Glycerol Esters<br>
						Methyl Esters<br>
						PEG Esters<br>
						Phosphate Esters<br>
						Polyglycerol Esters<br>
						Propoxylated Esters<br>
						Sorbitan Esters
					</td>
					<td class="tblRow2">
						Ethoxylated Alcohols<br>
						Ethoxylated Amines<br>
						Ethoxylated Esters<br>
						Ethoxylated Glycerine<br>
						Ethoxylated Sorbitol<br>
						EO/PO Copolymers<br>
						PEGs<br>
						Polysorbates<br>
						Surfactants, Anionic<br>and Cationic
					</td>
					<td class="tblRow2">
						Silicone Emulsions<br>
						Silicone Fluids<br>
						Functionalized Silicones
					</td>
					<td class="tblRow2">
						Silicone<br>
						Non-silicone
					</td>
					<td class="tblRow2">
						Canola Oil<br>
						High Oleic Canola Oil<br>
						HEAR Oil<br>
						Medium Blown HEAR Oil
					</td>
				</tr>
				</table>' 
where contentid = 25

-- lambent company history
update tblcontentmodule set title = 'Company history', content = '<p>Lambent Technologies was incorporated in 1952 as Hodag Chemical, with a manufacturing facility in Skokie, IL.  Calgene Inc. purchased Hodag Chemical in 1992 and renamed it Calgene Chemical.  In 1997, Calgene Inc. was purchased by Monsanto.  Petroferm Inc. purchased Calgene Chemical from Monsanto in 1998 and renamed Lambent Technologies.</p>
				<p>Throughout its history (and name changes), Lambent Technologies has been a reputable manufacturer of oleochemical derivatives, such as esters, alkoxylates, antifoams and specialty blends.  Over the last few years, demand for Lambent products outpaced the Skokie plant’s manufacturing capacity.  In response to this increased demand, Lambent purchased a manufacturing facility in Gurnee, IL from BASF in July 2003.</p>
				<p>The Gurnee facility was strategically selected based on its close proximity to the Skokie facility and its nearly identical manufacturing capabilities.  The Gurnee site was constructed in 1970 and operated until 1986 by Mazer Chemical.  The facility was sold in 1986 to PPG who proceeded to upgrade many aspects of the operations until selling the plant in 1996 to BASF.  BASF continued making significant capital improvements to the facility until selling the Gurnee plant to Petroferm in 2003.  This state-of-the-art facility is now the headquarters and primary manufacturing site of Lambent Technologies.  Lambent continues to invest capital in the facility to maintain and improve safety, quality, efficiencies and capacity.  The Skokie manufacturing site is still in operation today and producing Lambent products.</p>
				<p>With the acquisition of the Gurnee site from BASF, most of the site operations and laboratory staff were hired into Lambent.  This dedicated and highly motivated team of employees has been extensively trained in all facets of manufacturing, quality and safety.  The Gurnee site is ISO 9001-2000 certified and efforts are currently being made to register the Skokie manufacturing site as well.</p>' 
where contentid = 26

-- lambent contact us
update tblcontentmodule set title = 'Contact Us', content = '			<p align="center">
				<img src="web/files/images/content/lam-gurn-aerial.jpg" width="160" height="140" alt="Lambent Technologies, Corp. Headquarters Aerial Photo" border="0">
				&nbsp;&nbsp;
				<img src="web/files/images/content/lam-map.gif" width="160" height="140" alt="Lambent Technologies, Corp. Gurnee, Illinois" border="0"
				</p>
			<p align="center">
				Lambent Technologies<br>
				3938 Porett Drive<br>
				Gurnee, Illinois 60031<br><br>
			</p>
			<p align="center">
				More information?<br>
				Phone: (800) 432-7187<br>
				Fax: (847) 249-6792<br>
				Email: <a href="mailto:lambent@lambentcorp.com">lambent@lambentcorp.com</a>
			</p>' 
where contentid = 27

-- lambent food market
update tblcontentmodule set title = 'Food & Food Processing', content = '<p>Lambent Technologies manufactures and supplies functional ingredients for various food formulations and processing applications. Using premium food grade raw materials, and with a strong position in vegetable oil-based chemistries, Lambent currently serves its customers with select ingredients for: </p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>
									<td width="40%">
										- Processed and Prepared Foods<br/>
										- Baked Goods and Confectioneries<br/>
										- Flavors and Spices <br/>
										- Lecithin Replacement <br/>
										- Sprays, Coatings and Packaging
									</td>
								</tr>
							</table>
						<p>Our facility in Gurnee, IL has many quality certifications.  Those that are important for food manufacturers include:</p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>
									<td width="40%">
										- ISO 9001-2000<br/>
										- Food cGMP<br/>
										- American Institute of Bakers "Superior" Rating<br/>
										- Kosher and Kosher for Passover (OU) certified production<br/>
										- Halaal certified production
									</td>
								</tr>
							</table>' 
where contentid = 28

exec sp__AddContentModule
	@PageID = 40,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = '<table border="0" cellspacing="0" cellpadding="0" width="100%">		
			
			<tr valign="top">
				<td colspan="2" align="center"><a href="http://www.ift.org" target="_blank"><img src="web/files/images/content/IFT124x50.gif" border="0" width="124" height="50" align="middle"></a></td>
			</tr>
			<tr>
				<td height="5"></td>
			</tr>
			<tr valign="top">
				<td colspan="2" align="center"><a href="http://www.ou.org" target="_blank"><img src="web/files/images/content/OUKOSHER92x50.gif" border="0" width="92" height="50" align="middle"></a></td>
			</tr>
			<tr>
				<td height="5"></td>
			</tr>
			<tr valign="top">
				<td colspan="2" align="center"><a href="http://www.ifanca.org" target="_blank"><img src="web/files/images/content/HALAL114x50.gif" border="0" width="114" height="50" align="middle"></a></td>
			</tr>
			<tr>
				<td height="5"></td>
			</tr>				
			<tr valign="top">
				<td align="center" valign="middle"><a href="http://www.aibonline.org" target="_blank"><img src="web/files/images/content/AIB60x64.gif" border="0" width="60" height="64" align="middle"></a></td>
				<td align="center" valign="middle">&nbsp;</td>
			</tr>	
			<tr>
				<td height="5"></td>
			</tr>
			<tr valign="top">
				<td colspan="2" align="center"><a href="http://www.kahlwax.de" target="_blank"><img src="web/files/images/content/kahl-logo.jpg" border="0" width="80" height="45" align="middle"></a></td>
			</tr>
			
		</table>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

-- lambent coatings market
update tblcontentmodule set title = 'Coatings & Colorants', content = '<p>Lambent Technologies manufactures and supplies select raw materials and additives for coatings, colorants, paints, inks and adhesives.  We also manufacture process aids for polymer, printing, coating and adhesive systems.  We currently provide products for the following applications:</p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr valign="top">
									<td width="50%">
										- Clear Coatings<br/>
										- Protective and Decorative Coatings<br/>
										- Lacquers and Varnishes<br/>
										- Liquid Colorants<br/>
										- Paints
									</td>
									<td width="40%">
										- Inks<br/>
										- Resins<br/>
										- Adhesives<br/>
										- Packaging
									</td>

								</tr>
							</table>
							<p>Lambent’s specialty products add value and consistency to formulations, processes and coatings systems.  Lambent’s product line includes:</p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr valign="top">
									<td width="50%">
										- Pigment Dispersants and Emulsifiers<br/>
										- Process Aids and Leveling Agents<br/>
										- Solvents and Carriers
									</td>
									<td width="40%">
										- Release Agents<br/>
										- Catalysts and Curing Aids<br/>
										- Antifoams
									</td>

								</tr>
							</table>' 
where contentid = 29

exec sp__AddContentModule
	@PageID = 41,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = '<table border="0" cellspacing="0" cellpadding="0" width="100%">		
			<tr valign="top">
				<td align="center" valign="middle"><a href="http://www.coatingstech.org/Programs/ICE.html" target="_blank"><img src="web/files/images/content/ICE115x40.gif" border="0" width="115" height="40" align="middle"></a></td>
				<td align="center" valign="middle">&nbsp;</td>
			</tr>			
		</table>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


-- lambent lubricants market
update tblcontentmodule set title = 'Lubricants & Metalworking', content = '<p>Lambent Technologies manufactures and supplies select oleochemical 
							derivatives for lubricant formulations - and has done so for more than 30 years.  
							With a strong position in vegetable oil-based chemistries, we currently serve 
							customers by providing ingredients used in:</p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>
									<td width="40%">
										- Automotive Specialty Fluids<br/>
										- Fiber Lubricants<br/>
										- Gear Oils<br/>
										- Hydraulic Fluids<br/>
										- Marine Lubricants<br/>
										- Metalworking Fluids<br/>										
									</td>
									<td width="50%">
										- Mining and Forestry Fluids<br/>
										- Mold Releases
										- Near Dry Lubricants<br/>
										- Fiber Lubricants<br/>
										- Gear Oils<br/>
										- Hydraulic Fluids
									</td>
								</tr>
							</table>
							<p>Lambent''s vegetable oil-based chemistries add value to lubricant products by allowing the formulation of finished goods to have outstanding performance with improved environmental acceptability.  Our offering includes:</p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>							
									<td width="90%">
										- Esters as Lubricity Additives<br/>
										- Food Grade Lubricant Ingredients<br/>
										- Vegetable Oils as Base Fluids<br/>
										- Antifoams<br/>
										- Multifunctional Emulsifiers
									</td>
								</tr>
							</table>
							<br/>' 
where contentid = 30

exec sp__AddContentModule
	@PageID = 42,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>Lambent exhibited at the 2004 STLE Annual Meeting in Toronto, Canada where we highlighted three products; 
							<a href="static/files/lambent/market/h-102.pdf" target="_blank">ERUCICAL H-102</a> (High Erucic Acid Rapeseed Oil), 
							<a href="static/files/lambent/market/est-300.pdf" target="_blank">LUMULSE EST-300</a> (Emulsifier and Lubricant) and 
							<a href="static/files/lambent/market/pe-130.pdf" target="_blank">LAMCHEM PE-130 K</a> (Phosphate Ester EP Additive).</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

exec sp__AddContentModule
	@PageID = 42,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 2,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = '<table border="0" cellspacing="0" cellpadding="0" width="100%">		
						
						<tr valign="top">
							<td align="center" valign="middle">
								<a href="http://www.stle.org" target="_blank"><img src="web/files/images/content/STLE52x50.gif" border="0" width="52" height="50" align="middle"></a>&nbsp;&nbsp; 
								<a href="http://www.aocs.org" target="_blank"><img src="web/files/images/content/AOCS93x26.gif" border="0" width="93" height="26" align="middle"></a>
							</td>
						</tr>	
						<tr>
							<td height="5"></td>
						</tr>														
						<tr valign="top">
							<td align="center" valign="middle">
								<a href="http://www.ou.org" target="_blank"><img src="web/files/images/content/OUKOSHER92x50.gif" border="0" width="92" height="50" align="middle"></a> &nbsp;<a href="http://www.usp.org" target="_blank"><img src="web/files/images/content/NSF64X50.gif" border="0" width="64" height="50" align="middle"></a>
							</td>
						</tr>					
						
					</table>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT


-- lambent personal care market
update tblcontentmodule set title = 'Personal Care & Pharmaceuticals', content = '<p>Lambent Technologies manufactures and supplies functional components for personal care formulations-and has done so for more than 30 years.  Lambent''s facility in Gurnee, Illinois offers state-of-the art manufacturing of alkoxylates, esters, and a variety of vegetable oil-based chemistries.  Lambent serves its customers with select ingredients for:</p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>
									<td width="50%">
										- Cosmetics<br/>
										- Bath Oils<br/>
										- Skin creams and lotions<br/>
										- Shampoo Bases<br/>
										- Oral care products
									</td>
									<td width="40%">
										- Sun Care Products<br/>
										- Topical pharmaceuticals<br/>
										- Facial Scrubs and Body Washes<br/>
										- Skin and Hair Conditioners<br/>
										- Antiperspirants
									</td>
								</tr>
							</table>
							<p>Lambent''s personal care ingredients assist formulators in producing value-added products.  Most products listed in this guide are vegetable-based and many are manufactured to meet the Kosher requirements designated by the Orthodox Union (OU).  Kosher products are designated by a "K" or "KP" at the end of the product names.  Our personal care product offering includes:</p>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>
									<td width="50%">
										- Castor Oil-Based Emulsifiers<br/>
										- Glycerol Esters<br/>
										- Sorbitan Esters and Polysorbates
									</td>
									<td width="40%">
										- PEG Esters<br/>
										- Ethoxylated Alcohols<br/>
									  	- Ethoxylated Glycerine
									</td>
								</tr>
							</table>
							<br/>' 
where contentid = 31

exec sp__AddContentModule
	@PageID = 43,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>Lambent Technologies offers two varieties of Cocoa Butter to meet your formulating needs.  
			Check out our formulations for 
			<a href="static/files/lambent/market/White Chocolate Sugar Scrub.pdf" target="_blank">White Chocolate Sugar Scrub</a> and 
			<a href="static/files/lambent/market/On-The-Go Cocoa Butter Cream.pdf" target="_blank">On-The-Go Cocoa Butter Cream</a>.			
			</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

exec sp__AddContentModule
	@PageID = 43,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 2,
	@ShowTitle = 1,
	@Title = 'Certifications & Affiliates',
	@Content = '<table border="0" cellspacing="0" cellpadding="0" width="100%">								
			<tr valign="top">
				<td align="center" colspan="2" valign="middle"><a href="http://www.ctfa.org" target="_blank"><img src="web/files/images/content/CTFA124x50.gif" border="0" width="124" height="50" align="middle"></a></td>
			</tr>	
			<tr>
				<td height="5"></td>
			</tr>														
			<tr valign="top">
				<td align="center" valign="middle">&nbsp;</td>
				<td align="center" valign="middle"><a href="http://www.ifscc-congress04.org/flash/index.htm" target="_blank"><img src="web/files/images/content/IFSCC84X47.gif" border="0" width="84" height="47" align="middle"></a></td>
			</tr>		
			<tr>
				<td height="5"></td>
			</tr>
			<tr valign="top">
				<td colspan="2" align="center"><a href="http://www.kahlwax.de" target="_blank"><img src="web/files/images/content/kahl-logo.jpg" border="0" width="80" height="45" align="middle"></a></td>
			</tr>							
		</table>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

update tblurlrewrite set urlfriendlyname = 'lambent-technologies-corp.food-market.food-and-food-processing.aspx' where pageid = 40
update tblurlrewrite set urlfriendlyname = 'lambent-technologies-corp.coatings-and-colorants-market.coatings-and-colorants.aspx' where pageid = 41
update tblurlrewrite set urlfriendlyname = 'lambent-technologies-corp.lubricants-and-metalworking-market.lubricants-and-metalworking.aspx' where pageid = 42
update tblurlrewrite set urlfriendlyname = 'lambent-technologies-corp.personal-care-and-pharmaceutical-market.personal-care-and-pharmaceuticals.aspx' where pageid = 43

-- lambent page titles
update tblpage set pagetitle = 'Our Customers'' First Choice' where pageid = 32
update tblpage set pagetitle = 'Food & Food Processing' where pageid = 40
update tblpage set pagetitle = 'Coatings & Colorants' where pageid = 41
update tblpage set pagetitle = 'Lubricants & Metalworking' where pageid = 42
update tblpage set pagetitle = 'Personal Care & Pharmaceuticals' where pageid = 43

update tblimage set imagepath = 'web/files/images/header/lambent_home_menu1.jpg', width=443, height=110 where imageid=26

update tblimage set imagepath = 'web/files/images/nav/nav_food_on.gif' where imageid=27
update tblimage set imagepath = 'web/files/images/nav/nav_food_off.gif' where imageid=28
update tblimage set imagepath = 'web/files/images/header/lambent_food_menu1.jpg', width=443, height=110 where imageid=29

update tblimage set imagepath = 'web/files/images/nav/nav_coatings_on.gif' where imageid=30
update tblimage set imagepath = 'web/files/images/nav/nav_coatings_off.gif' where imageid=31
update tblimage set imagepath = 'web/files/images/header/lambent_coatings_menu1.jpg', width=443, height=110 where imageid=32

update tblimage set imagepath = 'web/files/images/nav/nav_lubricants_on.gif' where imageid=33
update tblimage set imagepath = 'web/files/images/nav/nav_lubricants_off.gif' where imageid=34
update tblimage set imagepath = 'web/files/images/header/lambent_lubricants_menu1.jpg', width=443, height=110 where imageid=35

update tblimage set imagepath = 'web/files/images/nav/nav_personal_on.gif' where imageid=36
update tblimage set imagepath = 'web/files/images/nav/nav_personal_off.gif' where imageid=37
update tblimage set imagepath = 'web/files/images/header/lambent_personal_care_menu1.jpg', width=443, height=110 where imageid=38


/*********************************************************************************
JOSEPH STOREY DATA SCRIPTS
**********************************************************************************/

update tblurlrewrite set urlfriendlyname = 'joseph-storey-and-co-ltd.welcome-to-joseph-storey-and-co-ltd.aspx' where pageid = 44

-- joseph storey division home page
update tblcontentmodule set title = 'Welcome to Joseph Storey & Co Ltd', content = '<br>
			<table cellpadding="0" cellspacing="0" border="0" width="375">
				<tr>
					<td style="line-height:20px;padding-left:5px;">
						Welcome to Joseph Storey & Co Ltd online. We are a Chemical Manufacturer, established in 1860, producing the 
						STORFLAM range of Fire Retardants based on Inorganic Borate and Stannate chemistry. The Global business has 
						developed a strong expertise in the production of Fire Retardants and supported by a network of distributors,
						the STORFLAM Fire Retardant range is sold world-wide to many polymer industries.    
						<br><br> 
						STORFLAM products impart superior fire and smoke performance in many polymer systems with and without 
						the presence of halogens. Antimony Trioxide replacement is a key feature, invariably coupled with 
						improvement in smoke performance, a property growing in importance. Part of Petroferm Inc. and 
						supported by a well equiped technical service laboratory including a cone calorimeter, Joseph Storey are 
						at the forefront of Fire Retardant and Smoke Suppressant technology.
						<br><br>
						We also manufacture other Inorganic Borates ranging from the Ammonium, Barium, Calcium, Magnesium, Manganese, 
						Melamine through to the Potassium salt and these products find use in a variety of applications.
						<br><br>
						To complete our product range we produce the Trawlerdeck range of Heavy Duty Epoxy floor screeds 
						which have Ministry of Defence approval and have been used by the Royal Navy for many years.
					</td>
				</tr>
			</table>'
where contentid = 32

exec sp__AddContentModule
	@PageID = 44,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>We have a new website.  Please <a href="Contact.aspx?ref=5,0,44">contact us</a> with questions or feedback.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

-- joseph storey flame market
update tblcontentmodule set title = 'Flame Retardants', content = '<p>Joseph Storey manufactures a range of Fire Retardants and Smoke Suppressants under the STORFLAM trade name. The company has a particular strength and expertise in Inorganic Borate and Stannate chemistry and is a wholly owned subsidiary of Petroferm Inc. being supported by a global network of specialist distributors.<p>The STORFLAM product range is used to improve fire and smoke performance to meet increasingly stringent legislation across the full spectrum of plastic, rubber and paint industries from electrical cables, automotive, aerospace to marine and construction applications.<BR><BR>'
where contentid = 37

update tblpage set pagetitle = 'Flame Retardants' where pageid = 52

exec sp__AddContentModule
	@PageID = 52,
	@ModuleType = 'SIDE CONTENT',
	@ModuleOrder = 1,
	@ShowTitle = 1,
	@Title = 'What''s New?',
	@Content = '<p>We have a new website.  Please <a href="Contact.aspx?ref=5,0,44">contact us</a> with questions or feedback.</p>',
	@PublishDate = null,
	@ExpireDate = null,
	@MarkedForDeletion = 0,
	@WorkflowStatus = 'WORKING',
	@JobID = 1,
	@userId = @userId,
	@ContentID = @cid OUTPUT,
	@PageModuleRelnID = @pmrid OUTPUT

-- joseph storey about us page
update tblcontentmodule set title = 'About Joseph Storey & Co Ltd', content = '<p>Joseph Storey manufactures a range of Fire Retardants and Smoke Suppressants under the STORFLAM trade name. The company has a particular strength and expertise in Inorganic Borate and Stannate chemistry and is a wholly owned subsiduary of Petroferm Inc. being supported by a global network of specialist distributors.
				<p>The STORFLAM product range is used to improve fire and smoke performance to meet increasingly stringent legislation across the full spectrum of plastic, rubber and paint industries from electrical cables, automotive, aerospace to marine and construction applications.
				<p>The company are well placed with their main products, Zinc Borate and Zinc Stannates. These products have a dual fire and smoke action to enable customers to meet fire standards combined with the growing importance of smoke performance. 
				<p><strong>Production Facility</strong>
					<ul>
					<li>Dedicated facility in the North West of England, UK, producing a specialised range of Inorganic Borates and Stannates. 
					<li>Supported by state of the art Fire testing Laboratory. 
					<li>ISO 9002-2000 registered
					<li>ISO 14001 Environmentally registered
					</ul>'
where contentid = 33

-- joseph capabilities
update tblcontentmodule set title = 'Manufacturing Capabilities', content = '<p>The Inorganic Borate and Stannate product range at Lancaster, UK includes the following listed below and Joseph Storey welcome enquiries for related products.</p>
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="tblHdr">Inorganic Borates</td>
					<td class="tblHdr">Inorganic Stannates</td>
					<td class="tblHdr">Epoxy Floor Screeds</td>
				</tr>
				<tr valign="top">
					<td class="tblRow2">
						Aluminium Borate<br>
						Barium Metaborate<br>
						Calcium Borate Anhydrous<br>
						Calcium Borate<br>
						Magnesium Borate Anhydrous<br>
						Magnesium Borate<br>
						Manganese Borate<br>
						Melamine Borate<br>
						Potassium Borate<br>
						Zinc Borate Anhydrous<br>
						Zinc Borate<br>
						Zinc Borophosphate

					</td>
					<td class="tblRow2">
						ZHS Coated Alumina Trihydrate<br>
						ZHS Coated Magnesium Hydroxide<br>					
						Zinc Hydroxy Stannate<br>
						Zinc Stannate

					</td>
					<td class="tblRow2">
						Trawlerdeck
					</td>
				</tr>
				</table><!-- End Content Info Table -->'
where contentid = 34

-- joseph history
update tblcontentmodule set title = 'Company history', content = '<p>The company was formed in 1860 as a manufacturer of chemicals and pigments such as glues, sizing and Lamp Black for table covers and leather cloth. In 1875 they were the largest manufacturer of Picric Acid (for explosives) in the world. Joseph Storey have a long tradition of Borate manufacturing excellence as in 1890 they received a Silver medal for the product Manganese Borate at the Edinburgh ''International Electric'' Exhibition and the expertise has continued through the 20th and 21st centuries to today where there Inorganic Borate manufacturing expertise is second to none. Other historical facts of note were they were the first UK company to produce an Azo dye on a manufacturing scale. The business started to develop a presence in Fire Retardancy in the early 1980''s when Zinc Borate began to find significant use in Conveyor belting and in 1988 the company introduced the new Flame Retardant, Zinc Hydroxy Stannate to the market.
				<p>In 1998 Joseph Storey became part of the Banner Chemicals and in 2000 were subsequently acquired by Petroferm. 
				The company has made good progress to becoming a significant 
				player in Fire Retardant and Wood Treatment markets. Petroferm have provided the resources for 
				the company to gain ISO9002:2000 and ISO 14001 approvals.
				<p>Today, Joseph Storey are well positioned to continue their excellent growth and advancement in Fire Retardancy. They have the expertise to advise and assist customers to meet growing Fire Retardant specifications. Technical Service is an important part of this and they have recently added compounding facilities, an NBS smoke box, LFT testing and a Cone Calorimeter their laboratory.'
where contentid = 35

-- joseph contact us
update tblcontentmodule set title = 'Contact Us', content = '<p>
			<strong>Joseph Storey and Company, Ltd</strong><br>
			Heron Chemical Works<br>
			Lancaster, England, LA1 1QQ<br>
			Phone: +44 (0)1524 63252<br>
			Fax: +44 (0)1524 381805'
where contentid = 36

-- joseph page titles
update tblpage set pagetitle = 'Welcome to Joseph Storey & Co Ltd' where pageid = 44

update tblimage set imagepath = 'web/files/images/header/joseph_home_menu1.jpg', width=443, height=110 where imageid=40
update tblimage set imagepath = 'web/files/images/nav/nav_joseph_flame_on.gif' where imageid=41
update tblimage set imagepath = 'web/files/images/nav/nav_joseph_flame_off.gif' where imageid=42
update tblimage set imagepath = 'web/files/images/header/joseph_flame_menu1.jpg', width=443, height=110 where imageid=43

update tblurlrewrite set urlfriendlyname = 'joseph-storey-and-co-ltd.flame-retardants-market.welcome-to-joseph-storey-and-co-ltd.aspx' where pageid = 52


/**********************************************
update the Region information

Petroferm requirements:
The Mexican flag should be used for the “Spanish” MSDSs associated with it.
The United Kingdom flag should be used for the GB SDSs.
The German flag should be used for the EU/DE SDSs.
The French flag should be used for the EU/French SDSs.
The Italian flag should be used for the EU/Italian SDSs.
The Canadian flag should have all the CND MSDSs associated with it.
(This will need a drop down menu to select Canadian –English or Canadian French translations)
The Chinese flag should have all the Chinese MSDSs associated with it.
(This flag will need a drop down menu to select Chinese – Simplified or Traditional translations)
The Japanese flag should be used for the Japanese MSDSs.
***********************************************/
declare @imgId int

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/en-US.gif','English',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('USA - English', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/en-GB.gif','United Kingdom - English',0,0,getdate(),dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('United Kingdom - English', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/es-MX.gif','Spanish', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('Spanish', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/fr-CA.gif','Canada - English', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('Canadian - English', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/fr-CA.gif','Canada - French', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('Canadian - French', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/it-IT.gif','Italian', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING', @userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('Italian', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/de-DE.gif','German', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('German', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/zh-Hant.gif','Chinese (Traditional & Simplified)', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('Chinese - Simplified', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/zh-Hant.gif','Chinese (Traditional & Simplified)', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('Chinese - Traditional', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

insert into tblimage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('web/files/images/misc/ja-JP.gif','Japanese', 0, 0, getdate(), dateadd(year,30,getdate()),'WORKING',@userId,1,0,1)
select @imgId = @@identity
insert into tblRegion (RegionName, ImageID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
values ('Japanese', @imgId, getdate(), dateadd(year,30,getdate()), 'WORKING', @userId, 1, 0, 1)

/* Add Petroferm Domain Mapping Information */
declare @mappingId int
exec sp__AddDomainMapping
	@DomainName = 'www.petroferm.com',
	@Website = 'Petroferm Home',
	@PageID = 1,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.solventdepot.com',
	@Website = 'Petroferm Home',
	@PageID = 1,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.cheapsolvents.com',
	@Website = 'Petroferm Home',
	@PageID = 1,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.chems.biz',
	@Website = 'Petroferm Home',
	@PageID = 1,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.cleaning-agents.com',
	@Website = 'Cleaning Agents Home',
	@PageID = 10,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.e-perc.com',
	@Website = 'Cleaning Agents Home',
	@PageID = 10,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.e-tce.com',
	@Website = 'Cleaning Agents Home',
	@PageID = 10,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.e-npd.com',
	@Website = 'Cleaning Agents Home',
	@PageID = 10,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.cabanaclean.com',
	@Website = 'Change to Cabana page when created',
	@PageID = 1,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.axarel.com',
	@Website = 'Cleaning Agents Home',
	@PageID = 10,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.privatelabelcleaners.com',
	@Website = 'Cleaning Agents Home',
	@PageID = 10,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.pep99.com',
	@Website = 'Fuel & Oil Home',
	@PageID = 22,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.oilemulsions.com',
	@Website = 'Fuel & Oil Home',
	@PageID = 22,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.josephstorey.com',
	@Website = 'Joseph Storey Home',
	@PageID = 44,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.lambentcorp.com',
	@Website = 'Lambent Home',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.lambent-tech.com',
	@Website = 'Lambent Home',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.hansowax.com',
	@Website = 'Change to Lambent Wax page when created',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.lambenttechnologies.com',
	@Website = 'Lambent Home',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.lambentcorp.net',
	@Website = 'Lambent Home',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.lambentcorp.org',
	@Website = 'Lambent Home',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.lambentcorp.us',
	@Website = 'Lambent Home',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

exec sp__AddDomainMapping
	@DomainName = 'www.hansotechinc.com',
	@Website = 'Change to Wax page when created',
	@PageID = 32,
	@PublishDate = null,
	@ExpirationDate = null,
	@ActiveFlag = 1,
	@LastModifiedBy = @userID,
	@id = @mappingId output

if (@deploy_this_content_to_live_site = 1)
begin
	-- in a normal situation, we would probably want the content to be reviewed before launching
	-- however, in a testing situation or just getting data out there to be viewed, we can deploy 
	-- it from here.
	exec sp__UpdateJobStatus @userId, 1, 'PENDING DEPLOYMENT'
	exec sp_UTIL_DeployCMSContent @userId, 1
end

/*
select b.businessunitname,m.marketname,p.pagetitle,p.PageId,pmr.pagemodulerelnid,pmr.sourceid,pmr.sourcename
from tblpage p, tblpagemodulereln pmr, tblbusinessunit b, tblmarket m
where p.pageid*=pmr.pageid and p.businessunitid=b.businessunitid and p.marketid*=m.marketid

select p.PageTitle,p.pageid,pmr.sourcename,im.imagemoduleid,i.imageid,i.imagepath 
from tblpage p, tblpagemodulereln pmr, tblimage i, tblimagemodule im 
where p.pageid=pmr.pageid and pmr.sourceid=im.imagemoduleid 
and i.imageid = im.imageid

select p.pageid,im.imagemoduleid,i.imageid,pmr.sourcename
from tblpage p, tblpagemodulereln pmr, tblimage i, tblimagemodule im 
where p.pageid=pmr.pageid and pmr.sourceid=im.imagemoduleid 
and i.imageid = im.imageid and pmr.sourcename IN ('NAV ON IMAGE', 'NAV OFF IMAGE', 'HEADER IMAGE', 'HEADER SIDE CONTENT IMAGE')

select * from tblProductAttributeType

select * from tblregion
select * from tblimage 
where imageid not in (select imageid from tblimagemodule)
and imageid not in (select logoimageid from tblbusinessunit)

select * from tblWorkflowAudit_U
*/

end