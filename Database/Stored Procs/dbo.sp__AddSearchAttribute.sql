




CREATE       proc sp__AddSearchAttribute
	@BusUnitID int = null,
	@MarketID int = null,
	@SearchAttribName varchar(100) = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null,
	@SearchAttribTypeID int OUTPUT
as
begin

/*
created by: Kelly Roe
created on: 12/04/2006
purpose:
	Adds a new search attribute for a particular business unit/market; however, we check if the record 
	exists first and if it does, we don't insert a duplicate attribute name.
	
syntax usage:
	declare @attribId int
	exec sp__AddSearchAttribute
		@MarketID = 1,
		@BusUnitId = 1,
		@SearchAttribName = 'Attribute Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1
		@UserID = 1,
		@SearchAttribTypeID = @attribId OUTPUT

	select @attribId

history:
	Brian Gaines (11/30/2006) - created initial procedure
	Kelly Roe    (12/05/2006) - added update to job to working status
*/

declare @errorcode int

	if (dbo.fn__TableExists('tblSearchAttribType') > 0)
	begin
	
		if (@BusUnitID is null or @BusUnitID = 0)
		begin
			print 'A business unit id is required'
			return 0
		end
		else if (@SearchAttribName is null or len(ltrim(rtrim(@SearchAttribName))) = 0)
		begin
			print 'An attribute name is required'
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

			if not exists(select 1 from tblSearchAttribType 
					where BusinessUnitID = @BusUnitID
					and MarketID = @MarketID 
					and UPPER(SearchAttributeName) = UPPER(@SearchAttribName))
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
				
				insert into tblSearchAttribType (BusinessUnitID, MarketID, SearchAttributeName, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@BusUnitID, @MarketID, @SearchAttribName, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
		
	
				select @errorcode = @@error
			
				if (@errorcode = 0)
				begin
					select @SearchAttribTypeID = @@identity
					
			
					update 	tblDeploymentJobs
					set 	WorkflowStatus = 'WORKING',
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where 	DeploymentJobID = @JobID
			
					select @errorcode = @@error
				end
				else
				begin
					select @SearchAttribTypeID = 0

				end
			
				if (@errorcode <> 0)
				begin
					print 'An error occurred'
					rollback tran
					return 0
				end
				else
				begin
					print 'Success'
					commit tran
					return 1
				end
			end
			else
			begin
				print 'An attribute with the the name [' + @SearchAttribName + '] already exists in the system'
				return 0
			end
		end
	
	end
	else
	begin
		print 'The tblSearchAttribType table is missing'
		return 0
	end

end