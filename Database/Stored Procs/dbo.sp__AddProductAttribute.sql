



CREATE  proc sp__AddProductAttribute
	@BusUnitID int = null,
	@AttribName varchar(100) = null,
	@AllowMultiple bit = 0,
	@IsReadOnly bit = 0,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null,
	@AttribTypeID int OUTPUT
as
begin

/*
created by: Brian Gaines
created on: 11/30/2006
purpose:
	Adds a new attribute for a particular business unit; however, we check if the record 
	exists first and if it does, we don't insert a duplicate attribute name.
	
syntax usage:
	declare @attribId int
	exec sp__AddProductAttribute
		@BusUnitId = 1,
		@AttribName = 'Attribute Name',
		@AllowMultiple = 0,
		@IsReadOnly = 0,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus = 'WORKING',
		@JobID = 1
		@UserID = 1,
		@AttribTypeID = @attribId OUTPUT

	select @attribId

history:
	Brian Gaines (11/30/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblProductAttributeType') > 0)
	begin
	
		if (@BusUnitID is null or @BusUnitID = 0)
		begin
			print 'A business unit id is required'
			return 0
		end
		else if (@AttribName is null or len(ltrim(rtrim(@AttribName))) = 0)
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

			if not exists(select 1 from tblProductAttributeType 
					where BusinessUnitID = @BusUnitID 
					and UPPER(AttribName) = UPPER(@AttribName))
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
				
				insert into tblProductAttributeType (BusinessUnitID, AttribName, AllowMultiple, IsReadOnly, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@BusUnitID, @AttribName, @AllowMultiple, @IsReadOnly, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
		
				if (@@error = 0)
				begin
					select @AttribTypeId = @@identity
					return 1
				end
				begin
					select @AttribTypeId = 0
					return 0
				end


				-- now update the job to working
				if (@@error = 0)
				begin
	
					exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
				end	

			end
			else
			begin
				print 'An attribute with the the name [' + @AttribName + '] already exists in the system'
				return 0
			end
		end
	
	end
	else
	begin
		print 'The tblProductAttributeType table is missing'
		return 0
	end

end