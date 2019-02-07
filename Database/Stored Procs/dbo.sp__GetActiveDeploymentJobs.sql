

CREATE PROC sp__GetActiveDeploymentJobs
as
begin

/*
created by: Kelly Roe
created on: 12/05/2006
purpose:
	Returns a list of active (any status that is not LIVE) deployment jobs

usage syntax:
	exec sp__GetActiveDeploymentJobs

history:
	Kelly Roe    (12/05/2006) - created initial stored procedure
*/

	select 	d.DeploymentJobID, 
		d.JobName, 
		d.JobDescription, 
		d.ReviewBy, 
		case when d.ReviewBy = 0 then null else a1.FirstName + ' ' + a1.LastName end as 'ReviewByName',
		d.ApprovedBy, 
		case when d.ApprovedBy = 0 then null else a2.FirstName + ' ' + a2.LastName end as 'ApproveByName',
		d.DeploymentDate,
		dbo.fn__GetDateOnly(d.DeploymentDate) as 'FmtDeploymentDate', 
		d.DeployedBy, 
		case when d.DeployedBy = 0 then null else a4.FirstName + ' ' + a4.LastName end as 'DeployByName',
		d.WorkflowStatus, 
		d.LastModifiedDate, 
		dbo.fn__FormatDate(d.LastModifiedDate,'mm/dd/yyyy h:nn') as 'FmtLastModDate',
		d.LastModifiedBy, 
		a3.FirstName + ' ' + a3.LastName as 'LastModByName',
		d.ActiveFlag
	from	tblDeploymentJobs d 
	left outer join tblAppUser a1 on d.ReviewBy = a1.AppUserId
	left outer join tblAppUser a2 on d.ApprovedBy = a2.AppUserId 
	left outer join tblAppUser a3 on d.LastModifiedBy = a3.AppUserId 
	left outer join tblAppUser a4 on d.DeployedBy = a4.AppUserId 
	where d.WorkflowStatus <> 'LIVE'
	order by d.DeploymentDate desc


end