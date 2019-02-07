





CREATE     proc sp__UpdateProductGridModule
	@ProductGridModuleID int = null,
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
	@UserID int = null

as
begin
	declare @errorcode int
	
/*
created by: Kelly Roe
created on: 12/12/2006
purpose:
	Updates a product grid module for a page (along with page module reln info)
	
history:
	Brian Gaines (12/12/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblProductGridModule') > 0)
	begin
	
		if (@ProductGridModuleID is null or @ProductGridModuleID = 0)
		begin
			print 'A product grid module id is required'
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
					
				update 	tblProductGridModule
				set 	ProductGridTitle = @ProductGridTitle,
					ProductGridBlurb = @ProductGridBlurb,
					ProductGridID = @ProductGridID,
					ModuleOrder = @ModuleOrder,
					PublishDate = @PublishDate,
					ExpirationDate = @ExpireDate,
					WorkflowStatus = @WorkflowStatus,
					MarkedForDeletion = 0, 
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID,
					DeploymentJobId = @JobID
				where	ProductGridModuleID = @ProductGridModuleID

				select @errorcode = @@error

				-- update the product grid info (name)
				if (@errorcode = 0)
				begin
					update	tblProductGrid
					set	ProductGridName = @ProductGridName,
						PublishDate = @PublishDate,
						ExpirationDate = @ExpireDate,
						WorkflowStatus = @WorkflowStatus,
						MarkedForDeletion = 0, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						DeploymentJobId = @JobID
					where	ProductGridID = @ProductGridID	
				end
				

				-- mark cols (attribs) and rows (products) for deletion
				-- and then re-add them
				-- check to see if this grid was live, if so, then marked the 
				-- cols/rows for deletions, otherwise just delete them 2/28/07 KR
				if exists(select 1 from tblProductGrid_LIVE where ProductGridID = @ProductGridID)
				begin
					if (@errorcode = 0)
					begin		
						update 	tblProductGridColDef
						set	MarkedForDeletion = 1,
							LastModifiedDate = getdate(),
							LastModifiedBy = @UserID,
							WorkflowStatus = @WorkflowStatus,
							DeploymentJobId = @JobID
						where	ProductGridID = @ProductGridID
						
						select @errorcode = @@error
					end
	
					if (@errorcode = 0)
					begin
						update 	tblProductGridRowDef
						set	MarkedForDeletion = 1,
							LastModifiedDate = getdate(),
							LastModifiedBy = @UserID,
							WorkflowStatus = @WorkflowStatus,
							DeploymentJobId = @JobID
						where	ProductGridID = @ProductGridID					
	
						select @errorcode = @@error
					end
				end
				else -- just delete the cols and rows
				begin

					if (@errorcode = 0)
					begin
						delete from tblProductGridColDef 
						where	ProductGridID = @ProductGridID
						select @errorcode = @@error
					end

					if (@errorcode = 0)
					begin
						delete from tblProductGridRowDef 
						where	ProductGridID = @ProductGridID
						select @errorcode = @@error
					end


				end


				-- now re-add the columns (attributes) and rows (products)
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





				if (@errorcode = 0)
				begin
					
					-- now update page module reln
					update 	tblPageModuleReln
					set	ModuleOrder = @ModuleOrder,
						ShowTitle = @ShowTitle,
						PublishDate = @PublishDate,
						ExpirationDate = @ExpireDate,
						WorkflowStatus = @WorkflowStatus,
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						DeploymentJobId = @JobID
			
					where	SourceID = @ProductGridModuleID
					and	SourceName = 'PRODUCT GRID'

					-- now update the job to working
					if (@errorcode = 0)
					begin
						exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
						select @errorcode = @@error
					end					

				end

				if (@errorcode = 0)
				begin
			
					commit tran
					print 'The  module was updated'
					return 1
				end
				else
				begin
					rollback tran
					print 'An error occurred while attempting to update the module'
					return 0
				end
		end
	
	end
	else
	begin
		print 'Table is missing'
		return 0
	end

end