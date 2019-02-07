


CREATE   proc sp__GetContentModule
	@PageId int = 0,
	@LiveMode bit = 1
as
begin

/*
created by: Brian Gaines
created on: 11/29/2006
purpose:
	Returns the list of documents that get linked to from the product grid
	
history:
	Brian Gaines (11/29/2006) - created initial procedure
*/
	
if (@PageId = 0)
begin
	print 'A page id is required'
	return 0
end
else
begin
	if (@LiveMode = 1)
	begin
		if (dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0 and 
			dbo.fn__TableExists('tblContentModule_LIVE') > 0)
		begin
			select c.ContentId, c.Title, c.Content
			from tblContentModule c, tblPageModuleReln pm
			where pm.PageId = @PageID
			and c.ActiveFlag = 1
			and dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(c.PublishDate) and dbo.fn__GetDateOnly(c.ExpirationDate)
			and UPPER(c.WorkflowStatus) = 'LIVE'
			and pm.SourceId = c.ContentId
			and UPPER(pm.SourceName) = 'CONTENT'
			order by pm.ModuleOrder asc
		end
	end
	else
	begin
		if (dbo.fn__TableExists('tblPageModuleReln') > 0 and 
			dbo.fn__TableExists('tblContentModule') > 0)
		begin

			select	c.ContentID, 
				c.Title, 
				c.Content, 
				c.PublishDate, 
				c.ExpirationDate, 
				c.WorkflowStatus,
				c.LastModifiedDate, 
				c.LastModifiedBy, 
				u.FirstName + ' ' + u.LastName as 'LastModifiedByName', 
				case when c.MarkedForDeletion = 1 then 'Yes' else 'No' end as 'FmtMarkedForDeletion', 
				pm.PageModuleRelnID, 
				pm.ModuleOrder, 
				pm.ShowTitle, 
				j.DeploymentJobID,
				j.JobName,
				j.JobDescription
			from 	tblContentModule c, 
				tblPageModuleReln pm,
				tblAppUser u,
				tblDeploymentJobs j
			where 	pm.PageId = @PageID
			and 	c.ActiveFlag = 1
			and 	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(c.PublishDate) and dbo.fn__GetDateOnly(c.ExpirationDate)
			and 	UPPER(pm.SourceName) = 'CONTENT'
			and 	pm.SourceId = c.ContentId
			and	c.LastModifiedBy = u.AppUserId
			and	c.DeploymentJobID = j.DeploymentJobId
			order by pm.ModuleOrder asc
			
			return 1
		end
		else
		begin
			print 'You are missing CMS tables'
			return 0
		end
	end
end

end