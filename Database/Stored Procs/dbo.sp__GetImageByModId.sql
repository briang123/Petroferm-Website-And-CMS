


create proc sp__GetImageByModId
	@ImageModId int = 0,
	@LiveMode bit = 0,
	@ImageId int output,
	@ImagePath varchar(500) output, 
	@Alt varchar(200) output, 
	@Width int OUTPUT, 
	@Height int OUTPUT, 
	@PublishDate datetime output, 
	@ExpireDate datetime output, 
	@WorkflowStatus varchar(50) output, 
	@LastModifiedDate datetime output, 
	@LastModifiedBy int output, 
	@ActiveFlag bit output, 
	@MarkedForDeletion bit output, 
	@JobID int output
as
begin

	if (@LiveMode = 1)
	begin
		select 
			i.ImageID, 
			i.ImagePath, 
			i.Alt, 
			i.Width, 
			i.Height, 
			i.PublishDate, 
			i.ExpirationDate, 
			i.WorkflowStatus, 
			i.LastModifiedDate, 
			i.LastModifiedBy, 
			i.ActiveFlag, 
			i.MarkedForDeletion, 
			i.DeploymentJobID
		from	tblImage i, tblImageModule im
		where	i.ImageId = im.ImageId
		and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(i.PublishDate) and dbo.fn__GetDateOnly(i.ExpirationDate)
		and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(im.PublishDate) and dbo.fn__GetDateOnly(im.ExpirationDate)
		and	i.ActiveFlag = 1 and im.ActiveFlag = 1
		and	upper(i.WorkflowStatus) = 'LIVE' and upper(im.WorkflowStatus) = 'LIVE'
	end

end