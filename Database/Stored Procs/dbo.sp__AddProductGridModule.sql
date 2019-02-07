


/*
declare @ModID int
declare @PageRelnID int
exec sp__AddProductGridModule 58, 'PRODUCT GRID', 'TITLE','BLURB',
	1,0,0,'GRIDNAME',4,'1,2,3','1,2,3',null,null,0,'WORKING',2,1,@ModID,@PageRelnID
*/
create   proc sp__AddProductGridModule
		@PageID int = null,
		@ModuleType varchar(50) = 'PRODUCT GRID',
		@ProductGridTitle varchar(50) = null,
		@ProductGridBlurb text = null,
		@ModuleOrder int = null,
		@ShowTitle bit = 0,
		@ProductGridID int = 0,
		@ProductGridName varchar(100) = null,
		@BusUnitID int = 0,
		@ProductIDList varchar(200) = '',
		@AttributeIDList varchar(200) = '',
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = null,
		@UserID int = null,
		@ProductGridModuleID int OUTPUT,
		@PageModuleRelnID int OUTPUT
as
begin
	declare @errorcode int
	
/*
created by: Kelly Roe
created on: 12/12/2006
purpose:
	Adds a new product grid module for a page
	
history:
	Kelly Roe    (12/12/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblProductGridModule') > 0)
	begin
	
		if (@PageID is null or @PageID = 0)
		begin
			print 'A page id is required'
			return 0
		end
		else if (@ModuleType is null or len(ltrim(rtrim(@ModuleType))) = 0)
		begin
			print 'An module type is required'
			return 0
		end
		else if (@UserID is null or @UserID = 0)
		begin
			print 'A user id is required'
			return 0
		end
		else if (@JobID is null or @JobId = 0)
		begin
			print 'a job id is required'
			return 0
		end
		else if (@ProductGridTitle is null or len(ltrim(rtrim(@ProductGridTitle))) = 0)
		begin
			print 'a grid title is required'
			return 0
		end
		else
		begin 

			if (@PublishDate is null)
			begin
				select @PublishDate = dbo.fn__GetDateOnly(getdate())
			end
			else
			begin
				select @Publishdate = dbo.fn__GetDateOnly(@PublishDate)
			end
			
			if (@ExpireDate is null)
			begin
				select @ExpireDate = dbo.fn__GetDateOnly(dateadd(year,30,@PublishDate))
			end
			else
			begin
				select @ExpireDate = dbo.fn__GetDateOnly(@ExpireDate)
			end
			
			begin tran
			

			-- first add the product grid data (if it doesn't exist already) --
			if (@ProductGridID = 0)
			begin
				insert into tblProductGrid (ProductGridName, BusinessUnitID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@ProductGridName, @BusUnitID, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID)

				select @ProductGridID = @@identity
				select @errorcode = @@error

				-- now add the columns (attributes) and rows (products)
				if (@errorcode = 0)
				begin
					insert into tblProductGridColDef (ProductGridID, ColumnNumber, AttribTypeID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
					select @ProductGridID, listpos, str, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID
					from dbo.fn__CharListToTable(@AttributeIDList,',')
					select @errorcode = @@error
				end
				-- add rows (products)
				if (@errorcode = 0)
				begin
					insert into tblProductGridRowDef (ProductGridID, RowNumber, ProductID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
					select @ProductGridID, listpos, str, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID
					from dbo.fn__CharListToTable(@ProductIDList,',')
					select @errorcode = @@error
				end				

			end

			-- insert the product grid module record now that the grid is created (or grid id was provided for shared grid)
			insert into tblProductGridModule (ProductGridTitle, ProductGridBlurb, ProductGridID, ModuleOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
			values (@ProductGridTitle, @ProductGridBlurb, @ProductGridID, @ModuleOrder, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID )
			select @ProductGridModuleID = @@identity
			select @errorcode = @@error

			if (@errorcode = 0)
			begin
				-- now add page module reln
				insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
				values (@PageID, @ProductGridModuleID, @ModuleType, @ModuleOrder, @ShowTitle, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID)

				select @errorcode = @@error
				select @PageModuleRelnId = @@identity
												
			end

			-- now update the job to working
			if (@errorcode = 0)
			begin

				select @PageModuleRelnID = @@identity
	
				exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
				select @errorcode = @@error
			end					


			if (@errorcode = 0)
			begin
		
				commit tran
				print 'The module was added'
				return 1
			end
			else
			begin
				select @PageModuleRelnID = 0
				rollback tran
				print 'An error occurred while attempting to add the module'
				return 0
			end
		end

	end
	else
	begin
		print 'A table is missing'
		return 0
	end

end